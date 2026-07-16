const List<String> fifthStageMigrations = [
  '''
  PRAGMA foreign_keys = OFF;
  ''',
  '''
  CREATE TABLE IF NOT EXISTS employees_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    login TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
  ''',
  '''
  INSERT INTO employees_new (id, last_name, first_name, middle_name, login, password, role, is_active, created_at, updated_at)
  SELECT id, last_name, first_name, middle_name, login, password, role, is_active, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM employees;
  ''',
  '''
  DROP TABLE IF EXISTS employees;
  ''',
  '''
  ALTER TABLE employees_new RENAME TO employees;
  ''',
  '''
  PRAGMA foreign_keys = ON;
  ''',
];
