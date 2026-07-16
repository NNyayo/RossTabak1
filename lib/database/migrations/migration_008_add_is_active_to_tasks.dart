const List<String> eighthStageMigrations = [
  '''
  ALTER TABLE tasks ADD COLUMN is_active INTEGER DEFAULT 1
  ''',
];
