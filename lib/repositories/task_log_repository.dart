import '../database/database_helper.dart';
import '../models/task_log.dart';

class TaskLogRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> createLog(TaskLog log) async {
    final db = await _databaseHelper.database;
    final map = log.toMap();
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    return db.insert('task_logs', map);
  }

  Future<List<TaskLog>> getLogsForTask(int taskId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'task_logs',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => TaskLog.fromMap(map)).toList();
  }
}
