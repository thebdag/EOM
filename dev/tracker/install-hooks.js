#!/usr/bin/env node
// dev/tracker/install-hooks.js — copies tracker hooks into .git/hooks/
// Run once after cloning: node dev/tracker/install-hooks.js
'use strict';

const fs = require('fs');
const path = require('path');

const repoRoot = path.join(__dirname, '..', '..');
const hooksSource = path.join(__dirname, 'hooks');
const hooksDest = path.join(repoRoot, '.git', 'hooks');

if (!fs.existsSync(hooksDest)) {
  console.error('No .git/hooks directory found. Are you in the repo root?');
  process.exit(1);
}

const hooks = fs.readdirSync(hooksSource);
let installed = 0;

for (const hook of hooks) {
  const src = path.join(hooksSource, hook);
  const dest = path.join(hooksDest, hook);

  fs.copyFileSync(src, dest);
  fs.chmodSync(dest, 0o755);
  console.log(`✓ Installed ${hook} → .git/hooks/${hook}`);
  installed++;
}

console.log(`\n${installed} hook(s) installed. Tracker will now auto-update on commit.`);
console.log(`\nCommit message syntax:`);
console.log(`  [EOM-T7 done]        mark subtask done`);
console.log(`  [EOM-T7 wip]         mark subtask in_progress`);
console.log(`  [EOM-S3 done]        mark story done`);
console.log(`  [EOM-E2 in_progress] mark epic in_progress`);
