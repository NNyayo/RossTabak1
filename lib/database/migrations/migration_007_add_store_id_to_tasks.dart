const List<String> seventhStageMigrations = [
  '''
  ALTER TABLE tasks ADD COLUMN store_id INTEGER REFERENCES stores(id)
  ''',
];
