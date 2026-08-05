// db.js — SQLite layer for EOM tracker (uses sql.js — pure JS, no native compilation)
'use strict';

const path = require('path');
const fs = require('fs');

const DB_PATH = path.join(__dirname, 'eom-tracker.db');

let _db = null;

// sql.js is async-init; we expose a sync-style API by initialising eagerly.
// Call initDb() once at startup and await it before using any helpers.
let _sqlJs = null;

async function initDb() {
  if (_db) return _db;

  const initSqlJs = require('sql.js');
  _sqlJs = await initSqlJs();

  // Load existing DB file or create fresh
  if (fs.existsSync(DB_PATH)) {
    const filebuf = fs.readFileSync(DB_PATH);
    _db = new _sqlJs.Database(filebuf);
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

// Persist the in-memory db to disk
function saveDb() {
  if (!_db) return;
  const data = _db.export();
  fs.writeFileSync(DB_PATH, Buffer.from(data));
}

// Safety flush — ensures writes survive even if a script exits without
// explicitly calling saveDb() (e.g. unhandled rejection, early process.exit).
process.on('exit', () => saveDb());
process.on('SIGINT', () => { saveDb(); process.exit(0); });
process.on('SIGTERM', () => { saveDb(); process.exit(0); });

// ── Schema migration ───────────────────────────────────────────────────────────
function migrate() {
  const db = _db;
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

    CREATE TABLE IF NOT EXISTS meta (
      k TEXT PRIMARY KEY,
      v TEXT NOT NULL
    );
  `);

  // Init sequence counters
  db.run(`INSERT OR IGNORE INTO meta(k,v) VALUES ('epic_seq','0')`);
  db.run(`INSERT OR IGNORE INTO meta(k,v) VALUES ('story_seq','0')`);
  db.run(`INSERT OR IGNORE INTO meta(k,v) VALUES ('subtask_seq','0')`);

  saveDb();
}

// ── Low-level helpers ─────────────────────────────────────────────────────────

function run(sql, params = []) {
  _db.run(sql, params);
  saveDb();
}

function all(sql, params = []) {
  const stmt = _db.prepare(sql);
  stmt.bind(params);
  const rows = [];
  while (stmt.step()) {
    rows.push(stmt.getAsObject());
  }
  stmt.free();
  return rows;
}

function get(sql, params = []) {
  const rows = all(sql, params);
  return rows[0] || null;
}

function nextKey(prefix, seqName) {
  run(`UPDATE meta SET v = CAST(CAST(v AS INTEGER) + 1 AS TEXT) WHERE k = ?`, [seqName]);
  const row = get(`SELECT v FROM meta WHERE k = ?`, [seqName]);
  return `${prefix}${row.v}`;
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
    const key = nextKey('EOM-E', 'epic_seq');
    run(`INSERT INTO epics (key, title, description) VALUES (?, ?, ?)`,
        [key, title, description]);
    return get(`SELECT * FROM epics WHERE key = ?`, [key]);
  },
  update(id, fields) {
    const allowed = ['title', 'description', 'status'];
    const sets = allowed.filter(f => f in fields).map(f => `${f} = ?`).join(', ');
    const vals = allowed.filter(f => f in fields).map(f => fields[f]);
    if (!sets) return;
    run(`UPDATE epics SET ${sets} WHERE id = ?`, [...vals, id]);
  },
  delete(id) {
    // Cascade manually (sql.js doesn't enforce FK cascades by default)
    const stories = Stories.forEpic(id);
    for (const s of stories) Stories.delete(s.id);
    run(`DELETE FROM epics WHERE id = ?`, [id]);
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
    const key = nextKey('EOM-S', 'story_seq');
    run(`INSERT INTO stories (key, epic_id, title, description, priority, branch)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [key, epicId, title, description, priority, branch]);
    return get(`SELECT * FROM stories WHERE key = ?`, [key]);
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
    // Cascade subtasks
    const subtasks = Subtasks.forStory(id);
    for (const t of subtasks) Subtasks.delete(t.id);
    run(`DELETE FROM stories WHERE id = ?`, [id]);
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
    const key = nextKey('EOM-T', 'subtask_seq');
    run(`INSERT INTO subtasks (key, story_id, title) VALUES (?, ?, ?)`,
        [key, storyId, title]);
    return get(`SELECT * FROM subtasks WHERE key = ?`, [key]);
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
    run(`DELETE FROM subtasks WHERE id = ?`, [id]);
  },
};

module.exports = { initDb, getDb, saveDb, Epics, Stories, Subtasks };
