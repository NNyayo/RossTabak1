import '../database/database_helper.dart';
import '../models/task_category.dart';

class TaskCategoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> createCategory(TaskCategory category) async {
    final db = await _databaseHelper.database;
    return db.insert('task_categories', category.toMap());
  }

  Future<List<TaskCategory>> getCategories() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'task_categories',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => TaskCategory.fromMap(map)).toList();
  }

  Future<List<TaskCategory>> getAllCategories() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('task_categories', orderBy: 'name ASC');
    return maps.map((map) => TaskCategory.fromMap(map)).toList();
  }

  Future<void> updateCategory(TaskCategory category) async {
    final db = await _databaseHelper.database;
    await db.update(
      'task_categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'task_categories',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreCategory(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'task_categories',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
