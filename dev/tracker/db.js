// db.js — SQLite layer for EOM tracker (uses sql.js — pure JS, no native compilation)
'use strict';

const path = require('path');
const fs = require('fs');
const { Worker } = require('worker_threads');
const properLockfile = require('proper-lockfile');

const DB_PATH = path.join(__dirname, 'eom-tracker.db');
const DB_LOCK_PATH = `${DB_PATH}.lock`;
const LOCK_TIMEOUT_MS = 6000;
const LOCK_STALE_MS = 5000;
const LOCK_WAIT_MS = 10;
const LOCK_HEARTBEAT_MS = 1000;
const lockWaitArray = new Int32Array(new SharedArrayBuffer(4));

let _db = null;

// sql.js is async-init; we expose a sync-style API by initialising eagerly.
// Call initDb() once at startup and await it before using any helpers.
let _sqlJs = null;

// mtime of the DB file at last load/save — used to avoid clobbering external
// writers (mark CLI, post-commit hook) when a long-lived TUI process exits.
let _lastKnownMtimeMs = 0;

function _rememberFileMtime() {
  try {
    if (fs.existsSync(DB_PATH)) {
      _lastKnownMtimeMs = fs.statSync(DB_PATH).mtimeMs;
    }
  } catch (_) { /* ignore */ }
}

function _diskChanged() {
  try {
    return fs.existsSync(DB_PATH)
      && fs.statSync(DB_PATH).mtimeMs !== _lastKnownMtimeMs;
  } catch (_) {
    return false;
  }
}

function _startLockHeartbeat() {
  const state = new Int32Array(new SharedArrayBuffer(4));
  const worker = new Worker(
    `
      const fs = require('fs');
      const { workerData } = require('worker_threads');
      const state = new Int32Array(workerData.state);
      while (Atomics.load(state, 0) === 0) {
        const now = new Date();
        try { fs.utimesSync(workerData.lockPath, now, now); } catch (_) {}
        Atomics.wait(state, 0, 0, workerData.interval);
      }
      Atomics.store(state, 0, 2);
      Atomics.notify(state, 0);
    `,
    {
      eval: true,
      workerData: {
        state: state.buffer,
        lockPath: DB_LOCK_PATH,
        interval: LOCK_HEARTBEAT_MS,
      },
    },
  );
  return { state, worker };
}

function _stopLockHeartbeat(heartbeat) {
  Atomics.store(heartbeat.state, 0, 1);
  Atomics.notify(heartbeat.state, 0);
  while (Atomics.load(heartbeat.state, 0) !== 2) {
    Atomics.wait(heartbeat.state, 0, 1, LOCK_WAIT_MS);
  }
  heartbeat.worker.terminate();
}

function _withWriteLock(callback) {
  const deadline = Date.now() + LOCK_TIMEOUT_MS;
  let release;
  while (release === undefined) {
    try {
      release = properLockfile.lockSync(DB_PATH, {
        realpath: false,
        stale: LOCK_STALE_MS,
      });
    } catch (error) {
      if (error.code !== 'ELOCKED') throw error;
      if (Date.now() >= deadline) {
        throw new Error(
          'Timed out waiting for the tracker database write lock. '
          + `If no tracker process is running, remove ${DB_LOCK_PATH}.`,
        );
      }
      Atomics.wait(lockWaitArray, 0, 0, LOCK_WAIT_MS);
    }
  }

  let heartbeat;
  try {
    heartbeat = _startLockHeartbeat();
    return callback();
  } finally {
    if (heartbeat) _stopLockHeartbeat(heartbeat);
    release();
  }
}

async function initDb() {
  if (_db) return _db;

  const initSqlJs = require('sql.js');
  _sqlJs = await initSqlJs();

  // Load existing DB file or create fresh
  if (fs.existsSync(DB_PATH)) {
    const filebuf = fs.readFileSync(DB_PATH);
    _db = new _sqlJs.Database(filebuf);
    _rememberFileMtime();
  } else {
    _db = new _sqlJs.Database();
  }

  migrate();
  return _db;
}

function getDb() {
  if (!_db) throw new Error('DB not initialised — call initDb() first');
  return _db;
}

function _reloadDbFromDisk() {
  if (!fs.existsSync(DB_PATH)) return _db;
  const filebuf = fs.readFileSync(DB_PATH);
  if (_db) {
    try { _db.close(); } catch (_) { /* ignore */ }
  }
  _db = new _sqlJs.Database(filebuf);
  _rememberFileMtime();
  return _db;
}

// Re-read the DB file from disk into a fresh in-memory Database.
// Needed by the TUI `r` reload: sql.js keeps a snapshot, so querying alone
// cannot see writes from other processes (mark CLI, post-commit hook).
function reloadDb() {
  if (!_sqlJs) throw new Error('DB not initialised — call initDb() first');
  if (!fs.existsSync(DB_PATH)) return _db;
  return _reloadDbFromDisk();
}

function _saveDbUnlocked() {
  if (!_db) return;
  const data = _db.export();
  const tempPath = `${DB_PATH}.${process.pid}.${Date.now()}.tmp`;
  try {
    fs.writeFileSync(tempPath, Buffer.from(data));
    fs.renameSync(tempPath, DB_PATH);
  } finally {
    try { fs.unlinkSync(tempPath); } catch (_) { /* rename already removed it */ }
  }
  _rememberFileMtime();
}

// Persist a caller-mutated snapshot only when it is still current.
function saveDb() {
  if (!_db) return false;
  return _withWriteLock(() => {
    if (_diskChanged()) {
      throw new Error('Tracker database changed on disk; reload before saving.');
    }
    _saveDbUnlocked();
    return true;
  });
}

function saveDbIfNotStale() {
  if (!_db) return false;
  return _withWriteLock(() => {
    if (_diskChanged()) return false;
    _saveDbUnlocked();
    return true;
  });
}

// Every mutation reloads the latest file while holding an exclusive lock.
// This prevents a long-lived TUI snapshot from overwriting CLI/hook updates.
function write(mutator) {
  if (!_db) throw new Error('DB not initialised — call initDb() first');
  return _withWriteLock(() => {
    if (fs.existsSync(DB_PATH)) _reloadDbFromDisk();
    _db.run('BEGIN');
    try {
      const result = mutator(_db);
      _db.run('COMMIT');
      _saveDbUnlocked();
      return result;
    } catch (error) {
      try {
        _db.run('ROLLBACK');
      } catch (_) {
        if (fs.existsSync(DB_PATH)) {
          _reloadDbFromDisk();
        } else {
          try { _db.close(); } catch (_) { /* ignore */ }
          _db = new _sqlJs.Database();
        }
      }
      throw error;
    }
  });
}

// Safety flush — ensures writes survive even if a script exits without
// explicitly calling saveDb() (e.g. unhandled rejection, early process.exit).
process.on('exit', () => saveDbIfNotStale());
process.on('SIGINT', () => { saveDbIfNotStale(); process.exit(0); });
process.on('SIGTERM', () => { saveDbIfNotStale(); process.exit(0); });

// ── Schema migration ───────────────────────────────────────────────────────────
function migrate() {
  write((db) => {
    db.run(`
      CREATE TABLE IF NOT EXISTS epics (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      key         TEXT    NOT NULL UNIQUE,
      title       TEXT    NOT NULL,
      description TEXT    DEFAULT '',
      status      TEXT    NOT NULL DEFAULT 'todo',
      created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS stories (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      key         TEXT    NOT NULL UNIQUE,
      epic_id     INTEGER NOT NULL,
      title       TEXT    NOT NULL,
      description TEXT    DEFAULT '',
      status      TEXT    NOT NULL DEFAULT 'todo',
      priority    TEXT    NOT NULL DEFAULT 'p2',
      branch      TEXT    DEFAULT '',
      created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
      updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS subtasks (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      key         TEXT    NOT NULL UNIQUE,
      story_id    INTEGER NOT NULL,
      title       TEXT    NOT NULL,
      status      TEXT    NOT NULL DEFAULT 'todo',
      created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
      updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS subtask_comments (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      subtask_id  INTEGER NOT NULL,
      body        TEXT    NOT NULL,
      author      TEXT    NOT NULL DEFAULT 'agent',
      created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS meta (
      k TEXT PRIMARY KEY,
      v TEXT NOT NULL
      );
    `);

    // Init sequence counters
    db.run(`INSERT OR IGNORE INTO meta(k,v) VALUES ('epic_seq','0')`);
    db.run(`INSERT OR IGNORE INTO meta(k,v) VALUES ('story_seq','0')`);
    db.run(`INSERT OR IGNORE INTO meta(k,v) VALUES ('subtask_seq','0')`);
  });
}

// ── Low-level helpers ─────────────────────────────────────────────────────────

function run(sql, params = []) {
  return write((db) => db.run(sql, params));
}

function allFrom(db, sql, params = []) {
  const stmt = db.prepare(sql);
  stmt.bind(params);
  const rows = [];
  while (stmt.step()) {
    rows.push(stmt.getAsObject());
  }
  stmt.free();
  return rows;
}

function all(sql, params = []) {
  return allFrom(_db, sql, params);
}

function getFrom(db, sql, params = []) {
  const rows = allFrom(db, sql, params);
  return rows[0] || null;
}

function get(sql, params = []) {
  return getFrom(_db, sql, params);
}

function nextKey(db, prefix, seqName) {
  db.run(`UPDATE meta SET v = CAST(CAST(v AS INTEGER) + 1 AS TEXT) WHERE k = ?`, [seqName]);
  const row = getFrom(db, `SELECT v FROM meta WHERE k = ?`, [seqName]);
  return `${prefix}${row.v}`;
}

function lastInsertId(db) {
  const rows = db.exec(`SELECT last_insert_rowid() AS id`);
  return rows[0]?.values[0][0];
}

// ── Epics ─────────────────────────────────────────────────────────────────────

const Epics = {
  all() {
    return all(`SELECT * FROM epics ORDER BY id`);
  },
  get(id) {
    return get(`SELECT * FROM epics WHERE id = ?`, [id]);
  },
  create({ title, description = '' }) {
    return write((db) => {
      const key = nextKey(db, 'EOM-E', 'epic_seq');
      db.run(`INSERT INTO epics (key, title, description) VALUES (?, ?, ?)`,
          [key, title, description]);
      return getFrom(db, `SELECT * FROM epics WHERE key = ?`, [key]);
    });
  },
  update(id, fields) {
    const allowed = ['title', 'description', 'status'];
    const sets = allowed.filter(f => f in fields).map(f => `${f} = ?`).join(', ');
    const vals = allowed.filter(f => f in fields).map(f => fields[f]);
    if (!sets) return;
    run(`UPDATE epics SET ${sets} WHERE id = ?`, [...vals, id]);
  },
  delete(id) {
    write((db) => {
      db.run(
        `DELETE FROM subtask_comments WHERE subtask_id IN (
           SELECT t.id FROM subtasks t
           JOIN stories s ON s.id = t.story_id
           WHERE s.epic_id = ?
         )`,
        [id],
      );
      db.run(
        `DELETE FROM subtasks WHERE story_id IN (
           SELECT id FROM stories WHERE epic_id = ?
         )`,
        [id],
      );
      db.run(`DELETE FROM stories WHERE epic_id = ?`, [id]);
      db.run(`DELETE FROM epics WHERE id = ?`, [id]);
    });
  },
};

// ── Stories ───────────────────────────────────────────────────────────────────

const Stories = {
  forEpic(epicId) {
    return all(`SELECT * FROM stories WHERE epic_id = ? ORDER BY id`, [epicId]);
  },
  get(id) {
    return get(`SELECT * FROM stories WHERE id = ?`, [id]);
  },
  create({ epicId, title, description = '', priority = 'p2', branch = '' }) {
    return write((db) => {
      if (!getFrom(db, `SELECT id FROM epics WHERE id = ?`, [epicId])) {
        throw new Error(`Epic ${epicId} no longer exists.`);
      }
      const key = nextKey(db, 'EOM-S', 'story_seq');
      db.run(`INSERT INTO stories (key, epic_id, title, description, priority, branch)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [key, epicId, title, description, priority, branch]);
      return getFrom(db, `SELECT * FROM stories WHERE key = ?`, [key]);
    });
  },
  update(id, fields) {
    const allowed = ['title', 'description', 'status', 'priority', 'branch'];
    const sets = [
      ...allowed.filter(f => f in fields).map(f => `${f} = ?`),
      `updated_at = datetime('now')`,
    ].join(', ');
    const vals = allowed.filter(f => f in fields).map(f => fields[f]);
    run(`UPDATE stories SET ${sets} WHERE id = ?`, [...vals, id]);
  },
  delete(id) {
    write((db) => {
      db.run(
        `DELETE FROM subtask_comments WHERE subtask_id IN (
           SELECT id FROM subtasks WHERE story_id = ?
         )`,
        [id],
      );
      db.run(`DELETE FROM subtasks WHERE story_id = ?`, [id]);
      db.run(`DELETE FROM stories WHERE id = ?`, [id]);
    });
  },
};

// ── Subtasks ──────────────────────────────────────────────────────────────────

const Subtasks = {
  forStory(storyId) {
    return all(`SELECT * FROM subtasks WHERE story_id = ? ORDER BY id`, [storyId]);
  },
  get(id) {
    return get(`SELECT * FROM subtasks WHERE id = ?`, [id]);
  },
  create({ storyId, title }) {
    return write((db) => {
      if (!getFrom(db, `SELECT id FROM stories WHERE id = ?`, [storyId])) {
        throw new Error(`Story ${storyId} no longer exists.`);
      }
      const key = nextKey(db, 'EOM-T', 'subtask_seq');
      db.run(`INSERT INTO subtasks (key, story_id, title) VALUES (?, ?, ?)`,
          [key, storyId, title]);
      return getFrom(db, `SELECT * FROM subtasks WHERE key = ?`, [key]);
    });
  },
  update(id, fields) {
    const allowed = ['title', 'status'];
    const sets = [
      ...allowed.filter(f => f in fields).map(f => `${f} = ?`),
      `updated_at = datetime('now')`,
    ].join(', ');
    const vals = allowed.filter(f => f in fields).map(f => fields[f]);
    run(`UPDATE subtasks SET ${sets} WHERE id = ?`, [...vals, id]);
  },
  delete(id) {
    write((db) => {
      db.run(`DELETE FROM subtask_comments WHERE subtask_id = ?`, [id]);
      db.run(`DELETE FROM subtasks WHERE id = ?`, [id]);
    });
  },
};

// ── Subtask comments ──────────────────────────────────────────────────────────
//
// Agents append free-text reports to a subtask to describe what was done,
// why a decision was made, or what blocked progress. Comments are append-only
// from the CLI / post-commit hook; the TUI can also add and view them.

const Comments = {
  forSubtask(subtaskId) {
    return all(`SELECT * FROM subtask_comments WHERE subtask_id = ? ORDER BY id`, [subtaskId]);
  },
  count(subtaskId) {
    const row = get(`SELECT COUNT(*) AS n FROM subtask_comments WHERE subtask_id = ?`, [subtaskId]);
    return row ? Number(row.n) : 0;
  },
  create({ subtaskId, body, author = 'agent' }) {
    const id = write((db) => {
      if (!getFrom(db, `SELECT id FROM subtasks WHERE id = ?`, [subtaskId])) {
        throw new Error(`Subtask ${subtaskId} no longer exists.`);
      }
      db.run(`INSERT INTO subtask_comments (subtask_id, body, author) VALUES (?, ?, ?)`,
          [subtaskId, body, author]);
      return lastInsertId(db);
    });
    return get(`SELECT * FROM subtask_comments WHERE id = ?`, [id]);
  },
  delete(id) {
    run(`DELETE FROM subtask_comments WHERE id = ?`, [id]);
  },
};

function seedIfEmpty(data) {
  return write((db) => {
    const count = getFrom(db, `SELECT COUNT(*) AS n FROM epics`)?.n ?? 0;
    if (Number(count) > 0) return false;

    for (const epicData of data) {
      const epicKey = nextKey(db, 'EOM-E', 'epic_seq');
      db.run(
        `INSERT INTO epics (key, title, description) VALUES (?, ?, ?)`,
        [epicKey, epicData.title, epicData.description || ''],
      );
      const epicId = lastInsertId(db);

      for (const storyData of epicData.stories) {
        const storyKey = nextKey(db, 'EOM-S', 'story_seq');
        db.run(
          `INSERT INTO stories
             (key, epic_id, title, description, status, priority, branch)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            storyKey,
            epicId,
            storyData.title,
            storyData.description || '',
            storyData.status || 'todo',
            storyData.priority || 'p2',
            storyData.branch || '',
          ],
        );
      }
    }
    return true;
  });
}

module.exports = {
  initDb,
  getDb,
  saveDb,
  reloadDb,
  seedIfEmpty,
  Epics,
  Stories,
  Subtasks,
  Comments,
};
