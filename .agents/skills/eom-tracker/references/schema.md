# EOM Tracker — Database Schema Reference

The tracker uses `sql.js` (pure-JS SQLite) persisted to `dev/tracker/eom-tracker.db`.
`initDb()` must be `await`ed before any helper is called.

> **Persistence model:** `sql.js` is in-memory. Every write helper calls `saveDb()`
> to flush to disk immediately. A `process.on('exit')` safety handler also flushes
> on normal exit, SIGINT, and SIGTERM. **Scripts must be run from `dev/tracker/`**
> (or any directory — `__dirname` in `db.js` anchors the path) and must `await initDb()`
> before touching any helper. If a previous script claimed to write data but the
> tracker shows it as unchanged, the script likely exited before the flush completed.
> Fix: re-apply the update manually via the pattern in Step 7 of SKILL.md.

---

## Tables

### `epics`

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | Auto-increment |
| `key` | TEXT UNIQUE | `EOM-E{n}` (e.g. `EOM-E1`) |
| `title` | TEXT | Short label |
| `description` | TEXT | Optional long description |
| `status` | TEXT | `todo` \| `in_progress` \| `done` |
| `created_at` | TEXT | ISO datetime |

### `stories`

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | Auto-increment |
| `key` | TEXT UNIQUE | `EOM-S{n}` |
| `epic_id` | INTEGER | FK → `epics.id` |
| `title` | TEXT | |
| `description` | TEXT | Optional |
| `status` | TEXT | `todo` \| `in_progress` \| `done` |
| `priority` | TEXT | `p1` \| `p2` \| `p3` |
| `branch` | TEXT | Linked git branch name |
| `created_at` | TEXT | |
| `updated_at` | TEXT | Updated on every write |

### `subtasks`

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK | Auto-increment |
| `key` | TEXT UNIQUE | `EOM-T{n}` |
| `story_id` | INTEGER | FK → `stories.id` |
| `title` | TEXT | |
| `status` | TEXT | `todo` \| `in_progress` \| `done` |
| `created_at` | TEXT | |
| `updated_at` | TEXT | |

### `meta`

Stores auto-increment counters for key generation.

| k | v |
|---|---|
| `epic_seq` | Current epic number |
| `story_seq` | Current story number |
| `subtask_seq` | Current subtask number |

---

## JS Helper API (`db.js`)

All helpers are synchronous after `await initDb()`.

### Epics

```js
Epics.all()                        // → Epic[]
Epics.get(id)                      // → Epic | null
Epics.create({ title, description? })   // → Epic
Epics.update(id, { title?, description?, status? })
Epics.delete(id)                   // cascades stories + subtasks
```

### Stories

```js
Stories.forEpic(epicId)            // → Story[]
Stories.get(id)                    // → Story | null
Stories.create({ epicId, title, description?, priority?, branch? }) // → Story
Stories.update(id, { title?, description?, status?, priority?, branch? })
Stories.delete(id)                 // cascades subtasks
```

### Subtasks

```js
Subtasks.forStory(storyId)         // → Subtask[]
Subtasks.get(id)                   // → Subtask | null
Subtasks.create({ storyId, title }) // → Subtask
Subtasks.update(id, { title?, status? })
Subtasks.delete(id)
```

---

## Key formats

| Level | Prefix | Example |
|---|---|---|
| Epic | `EOM-E` | `EOM-E1` |
| Story | `EOM-S` | `EOM-S12` |
| Subtask | `EOM-T` | `EOM-T7` |

Keys are assigned sequentially and never reused after deletion.

---

## Resolving a key to an id

```js
const { initDb } = require('./db');
const db = require('./db').getDb();

// After initDb():
const rows = db.exec(`SELECT id FROM stories WHERE key = 'EOM-S1'`);
const id = rows[0]?.values[0][0];
```

Or use `Stories.forEpic(epicId)` and filter by `key` property.
