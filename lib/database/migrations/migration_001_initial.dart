const List<String> initialMigrations = [
  '''
  CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    login TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL,
    is_active INTEGER DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
  ''',
  '''
  CREATE TABLE stores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    address TEXT,
    metro TEXT,
    marker_color TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
  ''',
  '''
  CREATE TABLE employee_stores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    FOREIGN KEY(employee_id) REFERENCES employees(id),
    FOREIGN KEY(store_id) REFERENCES stores(id)
  )
  ''',
  '''
  CREATE TABLE shifts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    store_id INTEGER NOT NULL,
    date TEXT NOT NULL,
    shift_type TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(store_id) REFERENCES stores(id)
  )
  ''',
  '''
  CREATE TABLE shift_employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shift_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    role_on_shift TEXT,
    FOREIGN KEY(shift_id) REFERENCES shifts(id),
    FOREIGN KEY(employee_id) REFERENCES employees(id)
  )
  ''',
  '''
  CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    priority TEXT DEFAULT 'NORMAL',
    created_by INTEGER,
    shift_id INTEGER,
    status TEXT DEFAULT 'NEW',
    deadline TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TEXT,
    FOREIGN KEY(created_by) REFERENCES employees(id),
    FOREIGN KEY(shift_id) REFERENCES shifts(id)
  )
  ''',
  '''
  CREATE TABLE task_employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    status TEXT DEFAULT 'NEW',
    assigned_at TEXT,
    completed_at TEXT,
    FOREIGN KEY(task_id) REFERENCES tasks(id),
    FOREIGN KEY(employee_id) REFERENCES employees(id)
  )
  ''',
  '''
  CREATE TABLE task_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER,
    employee_id INTEGER,
    action TEXT,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(task_id) REFERENCES tasks(id),
    FOREIGN KEY(employee_id) REFERENCES employees(id)
  )
  ''',
  '''
  CREATE TABLE violations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER,
    task_id INTEGER,
    type TEXT,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(employee_id) REFERENCES employees(id),
    FOREIGN KEY(task_id) REFERENCES tasks(id)
  )
  ''',
];
