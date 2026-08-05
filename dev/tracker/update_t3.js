const { initDb, getDb, Subtasks } = require('./db');
initDb().then(() => {
  const db = getDb();
  const rows = db.exec(`SELECT id FROM subtasks WHERE key = 'EOM-T3'`);
  if (rows.length > 0) {
    const id = rows[0].values[0][0];
    Subtasks.update(id, { status: 'done' });
    console.log('EOM-T3 marked as done');
  } else {
    console.log('EOM-T3 not found');
  }
});
