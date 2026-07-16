const List<String> thirdStageMigrations = [
  '''
  CREATE TABLE IF NOT EXISTS shift_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shift_id INTEGER NOT NULL,
    report_text TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
  ''',
];
