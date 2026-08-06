#!/usr/bin/env node
// dev/tracker/mark.js — CLI for immediate tracker status updates
// Usage: node dev/tracker/mark.js <key> <status>
//   key:    EOM-T7, EOM-S3, EOM-E2
//   status: done | wip | todo   (wip is an alias for in_progress)
'use strict';

const { initDb, Epics, Stories, Subtasks } = require('./db');

const STATUS_ALIASES = { done: 'done', wip: 'in_progress', todo: 'todo', in_progress: 'in_progress' };

async function main() {
  const [, , keyArg, statusArg] = process.argv;

  if (!keyArg || !statusArg) {
    console.error('Usage: node mark.js <EOM-key> <done|wip|todo>');
    console.error('  e.g. node mark.js EOM-T7 done');
    console.error('       node mark.js EOM-S3 wip');
    process.exit(1);
  }

  const key = keyArg.trim().toUpperCase();
  const status = STATUS_ALIASES[statusArg.trim().toLowerCase()];

  if (!status) {
    console.error(`Unknown status "${statusArg}". Use: done, wip, todo`);
    process.exit(1);
  }

  await initDb();

  // Determine key type and find the item
  if (key.startsWith('EOM-T')) {
    // Search all subtasks across all stories
    const epics = Epics.all();
    let found = null;
    outer: for (const e of epics) {
      for (const s of Stories.forEpic(e.id)) {
        const t = Subtasks.forStory(s.id).find(x => x.key === key);
        if (t) { found = t; break outer; }
      }
    }
    if (!found) { console.error(`Subtask ${key} not found`); process.exit(1); }
    Subtasks.update(found.id, { status });
    console.log(`✓ ${key} → ${status}  (${found.title.slice(0, 60)})`);

  } else if (key.startsWith('EOM-S')) {
    const epics = Epics.all();
    let found = null;
    for (const e of epics) {
      const s = Stories.forEpic(e.id).find(x => x.key === key);
      if (s) { found = s; break; }
    }
    if (!found) { console.error(`Story ${key} not found`); process.exit(1); }
    Stories.update(found.id, { status });
    console.log(`✓ ${key} → ${status}  (${found.title.slice(0, 60)})`);

  } else if (key.startsWith('EOM-E')) {
    const epic = Epics.all().find(e => e.key === key);
    if (!epic) { console.error(`Epic ${key} not found`); process.exit(1); }
    Epics.update(epic.id, { status });
    console.log(`✓ ${key} → ${status}  (${epic.title.slice(0, 60)})`);

  } else {
    console.error(`Unknown key format "${key}". Expected EOM-T{n}, EOM-S{n}, or EOM-E{n}`);
    process.exit(1);
  }
}

main().catch(err => { console.error(err.message); process.exit(1); });
