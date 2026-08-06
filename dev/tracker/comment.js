#!/usr/bin/env node
// dev/tracker/comment.js — CLI for appending a comment to a subtask.
// Usage:
//   node dev/tracker/comment.js <EOM-key> <text> [--author <name>]
//   node dev/tracker/comment.js EOM-T7 "Wired Clarify intent into AiService."
//   node dev/tracker/comment.js EOM-T7 "Fixed null guard in router." --author cursor
//
// Comments are append-only reports from agents (or humans) describing what
// was done for a subtask. They are read by the TUI and listed in the detail
// panel. Only subtask keys (EOM-T{n}) are accepted.
'use strict';

const { initDb, Epics, Stories, Subtasks, Comments } = require('./db');

function findSubtask(key) {
  for (const e of Epics.all()) {
    for (const s of Stories.forEpic(e.id)) {
      const t = Subtasks.forStory(s.id).find(x => x.key === key);
      if (t) return t;
    }
  }
  return null;
}

async function main() {
  const args = process.argv.slice(2);

  let author = 'agent';
  const authorIdx = args.indexOf('--author');
  if (authorIdx !== -1) {
    if (!args[authorIdx + 1]) {
      console.error('--author requires a value');
      process.exit(1);
    }
    author = args[authorIdx + 1];
    args.splice(authorIdx, 2);
  }

  const [keyArg, ...textParts] = args;
  const text = textParts.join(' ').trim();

  if (!keyArg || !text) {
    console.error('Usage: node comment.js <EOM-key> <text> [--author <name>]');
    console.error('  e.g. node comment.js EOM-T7 "Wired Clarify intent into AiService."');
    process.exit(1);
  }

  const key = keyArg.trim().toUpperCase();
  if (!key.startsWith('EOM-T')) {
    console.error('Comments are only supported on subtasks (EOM-T{n}).');
    process.exit(1);
  }

  await initDb();

  const subtask = findSubtask(key);
  if (!subtask) {
    console.error(`Subtask ${key} not found`);
    process.exit(1);
  }

  const comment = Comments.create({ subtaskId: subtask.id, body: text, author });
  const count = Comments.count(subtask.id);

  console.log(`✓ Comment added to ${key}  (${subtask.title.slice(0, 60)})`);
  console.log(`  #${count}  [${comment.author}]  ${comment.created_at}`);
  console.log(`  ${comment.body}`);
}

main().catch(err => { console.error(err.message); process.exit(1); });
