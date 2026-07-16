const List<String> sixthStageMigrations = [
  '''
  CREATE TABLE IF NOT EXISTS task_templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    shift_type TEXT NOT NULL,
    time TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS task_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS system_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    action TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
  ''',
  '''
  CREATE INDEX IF NOT EXISTS idx_task_templates_shift_type ON task_templates(shift_type);
  ''',
  '''
  CREATE INDEX IF NOT EXISTS idx_system_logs_user ON system_logs(user_id);
  ''',
];
