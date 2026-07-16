import '../database/database_helper.dart';
import '../models/system_log.dart';

class SystemLogRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> createLog({
    required int employeeId,
    required String action,
    String? description,
  }) async {
    final db = await _databaseHelper.database;
    return db.insert('system_logs', {
      'user_id': employeeId,
      'action': action,
      'description': description,
    });
  }

  Future<List<SystemLog>> getLogsForUser(int employeeId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'system_logs',
      where: 'user_id = ?',
      whereArgs: [employeeId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => SystemLog.fromMap(map)).toList();
  }

  Future<List<SystemLog>> getAllLogs() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'system_logs',
      orderBy: 'created_at DESC',
      limit: 500,
    );
    return maps.map((map) => SystemLog.fromMap(map)).toList();
  }
}
