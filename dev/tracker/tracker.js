// tracker.js — entry point for EOM Tracker TUI
'use strict';

const { execSync } = require('child_process');
const { initDb } = require('./db');
const { launchTUI } = require('./ui');

// Auto-detect current git branch
function currentBranch() {
  try {
    return execSync('git rev-parse --abbrev-ref HEAD', {
      cwd: require('path').join(__dirname, '..', '..'),
      stdio: ['pipe', 'pipe', 'pipe'],
    })
      .toString()
      .trim();
  } catch {
    return '';
  }
}

async function main() {
  // Init DB (async with sql.js)
  await initDb();

  // Auto-seed atomically on first launch. Concurrent startups serialize
  // through db.js and only one can observe an empty tracker.
  const { seed } = require('./seed');
  seed();

  launchTUI({ branch: currentBranch() });
}

main().catch(err => {
  console.error('EOM Tracker failed to start:', err.message);
  process.exit(1);
});
