final List<String> twelfthStageMigrations = [
  '''ALTER TABLE daily_task_assignments ADD COLUMN store_id INTEGER REFERENCES stores(id) ON DELETE CASCADE''',
  '''CREATE INDEX IF NOT EXISTS idx_daily_task_assignments_store_date ON daily_task_assignments(store_id, date)''',
];
