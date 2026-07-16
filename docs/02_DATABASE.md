# Database

## Схема таблиц

### employees

- id
- lastName
- firstName
- middleName
- login
- password
- role
- isActive

### stores

- id
- name
- address
- metro
- markerColor
- isActive

### employee_stores

- id
- employeeId
- storeId

## Дополнительные будущие таблицы

- tasks
- task_categories
- reports
- shifts
- notifications
- settings
- history

## SQL-схемы

```sql
CREATE TABLE employees (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lastName TEXT NOT NULL,
  firstName TEXT NOT NULL,
  middleName TEXT,
  login TEXT NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  isActive INTEGER NOT NULL
);

CREATE TABLE stores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  metro TEXT,
  markerColor TEXT,
  isActive INTEGER NOT NULL
);

CREATE TABLE employee_stores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  employeeId INTEGER NOT NULL,
  storeId INTEGER NOT NULL
);
```