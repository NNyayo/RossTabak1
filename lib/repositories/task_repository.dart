import '../database/database_helper.dart';
import '../models/task.dart';

class TaskRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> addTask(Task task) async {
    final db = await _databaseHelper.database;
    final map = task.toMap();
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    return await db.insert('tasks', map);
  }

  Future<Task?> getTaskById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<void> updateTask(Task task) async {
    final db = await _databaseHelper.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> updateTaskStatus(
    int taskId,
    String status, {
    String? completedAt,
  }) async {
    final db = await _databaseHelper.database;
    await db.update(
      'tasks',
      {'status': status, 'completed_at': completedAt},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'tasks',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> hardDeleteTask(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> restoreTask(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'tasks',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getArchivedTasks() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'is_active = 0',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getOverdueTasks(DateTime now) async {
    final db = await _databaseHelper.database;
    final nowString = now.toIso8601String();
    final maps = await db.query(
      'tasks',
      where:
          'deadline IS NOT NULL AND deadline < ? AND status != ? AND is_active = 1',
      whereArgs: [nowString, 'COMPLETED'],
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }
}
