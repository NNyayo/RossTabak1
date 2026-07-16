final List<String> tenthStageMigrations = [
  '''CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT,
    is_read INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
  )''',
];
