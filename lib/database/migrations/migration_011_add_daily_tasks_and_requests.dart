final List<String> eleventhStageMigrations = [
  '''CREATE TABLE IF NOT EXISTS daily_task_templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
  )''',
  '''CREATE TABLE IF NOT EXISTS daily_task_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    daily_task_template_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    shift_id INTEGER,
    date TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'NEW',
    completed_at TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (daily_task_template_id) REFERENCES daily_task_templates(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE SET NULL
  )''',
  '''CREATE TABLE IF NOT EXISTS employee_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    store_id INTEGER,
    employee_id INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'NEW',
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE SET NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
  )''',
];