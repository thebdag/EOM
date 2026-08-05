---
name: eom-tracker
description: Manages epics, stories, and subtasks in the EOM project's local SQLite issue tracker via a blessed TUI. Use when creating, editing, or querying tracker items (epics, stories, subtasks), cycling status, linking git branches to stories, or teaching an agent how to interact with the tracker programmatically. Don't use for Flutter app development, LLM integration, or any task unrelated to the dev/tracker tooling.
---

# EOM Tracker

The EOM tracker is a local SQLite-backed issue tracker at `dev/tracker/` inside
the EOM repository. It has three hierarchy levels: **Epic → Story → Subtask**.
The TUI is launched interactively; programmatic access goes through `db.js` directly.

Read `references/schema.md` for the full database schema.
Read `references/keybindings.md` for the complete TUI key reference.

---

## Step 1: Launch the TUI

1. Open a real interactive terminal (TTY required — does not work in non-interactive shells).
2. From the repo root run:
   ```bash
   npm run tracker
   ```
   If `node_modules` are missing, first run `cd dev/tracker && npm install`.
3. On first launch the database is auto-created at `dev/tracker/eom-tracker.db`
   and seeded with the standard EOM epics. No manual seed step is needed.

---

## Step 2: Navigate the TUI

The TUI has three panes. Use `Tab` to shift focus between them left → right.

| Pane | Contents | Focus indicator |
|---|---|---|
| Left | Epic list | Indigo border |
| Centre | Stories for selected epic | Indigo border |
| Right | Detail card + Subtask list | Indigo border |

1. Press `↑` / `↓` to move the selection within the focused pane.
2. Press `Tab` to shift focus: **Epics → Stories → Subtasks → Epics**.
3. The right pane updates automatically whenever the story selection changes.

---

## Step 3: Create items

If the agent or user needs to add a new epic, story, or subtask:

**Via TUI (interactive):**
1. Focus the target pane (`Tab` to the correct level).
2. Press `n`. A form dialog appears.
3. Fill in the fields (Title, Description, Priority for stories).
4. Press `Enter` or click Save to confirm; `Escape` to cancel.

**Via script (programmatic — preferred for bulk operations):**
1. Write a Node.js script that `require`s `./db` and calls `initDb()` first.
2. Use the CRUD helpers from `references/schema.md`.
3. If the destination story key is known, resolve its numeric `id` with:
   ```js
   const story = db.exec(`SELECT id FROM stories WHERE key = 'EOM-S1'`);
   ```
4. Call `Subtasks.create({ storyId, title })` or `Stories.create({ epicId, title, priority })`.
5. Run the script with `node <script>.js` from the `dev/tracker/` directory.

---

## Step 4: Update item status

Status cycles in one direction only: `todo → in_progress → done`.

**Via TUI:** Focus the item, press `d` to advance to the next status.

**Via script:**
```js
Stories.update(id, { status: 'in_progress' }); // or 'done'
Subtasks.update(id, { status: 'done' });
```
Valid status values: `todo`, `in_progress`, `done`. Any other value will be
rejected by the CHECK constraint.

---

## Step 5: Link a git branch to a story

Linking a branch is optional but recommended for traceability.

**Via TUI:** Focus a story in the Stories pane, press `b`. The current git
branch is pre-filled. Edit if needed, press `Enter`.

**Via script:**
```js
Stories.update(storyId, { branch: 'cursor/my-feature-b83b' });
```

---

## Step 6: Edit or delete items

**Edit:** Focus the item, press `e`. The form re-opens pre-populated. Change
any field, press `Enter`.

**Delete:** Focus the item, press `D` (capital). A confirmation prompt appears.
Deletion cascades — deleting an epic removes its stories and subtasks; deleting
a story removes its subtasks.

---

## Step 7: Programmatic bulk operations (agent use)

If the agent needs to insert many items at once (e.g., seeding subtasks for a
new story), follow this pattern:

1. Change into `dev/tracker/`:
   ```bash
   cd /path/to/EOM/dev/tracker
   ```
2. Write an inline node script or a temp file and run it with `node`:
   ```bash
   node -e "
   const { initDb, Stories, Subtasks } = require('./db');
   initDb().then(() => {
     const storyId = 1; // resolve from key first if needed
     ['Task A', 'Task B'].forEach(title =>
       Subtasks.create({ storyId, title })
     );
   });
   "
   ```
3. The DB is automatically persisted to `eom-tracker.db` after every write.
   No explicit save call is needed from caller code.

---

## Step 8: Query the tracker

To look up existing items without launching the TUI:

```bash
node -e "
const { initDb, Epics, Stories, Subtasks } = require('./db');
initDb().then(() => {
  Epics.all().forEach(e => {
    const stories = Stories.forEpic(e.id);
    const done = stories.filter(s => s.status === 'done').length;
    console.log(e.key, e.title, done + '/' + stories.length + ' done');
  });
});
"
```

Refer to `references/schema.md` for all available helper methods.

---

## Decision tree: TUI vs. script

```
Agent needs to modify tracker data
│
├── Single interactive change (one item, status flip, edit)?
│   └── Instruct user to use TUI keybinding
│
└── Bulk insert / programmatic update?
    ├── Is initDb() already called in scope? → call helpers directly
    └── New script context?
        ├── Write inline node -e script in dev/tracker/ dir
        └── await initDb() before any DB call
```
