const List<String> secondStageMigrations = [
  '''
  CREATE TABLE IF NOT EXISTS shift_employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shift_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    role_on_shift TEXT
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER,
    employee_id INTEGER,
    text TEXT NOT NULL,
    created_at TEXT
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT UNIQUE,
    value TEXT
  )
  ''',
  '''
  CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
  ''',
  '''
  CREATE INDEX IF NOT EXISTS idx_tasks_shift ON tasks(shift_id);
  ''',
  '''
  CREATE INDEX IF NOT EXISTS idx_employee_login ON employees(login);
  ''',
  '''
  CREATE INDEX IF NOT EXISTS idx_logs_task ON task_logs(task_id);
  ''',
];
