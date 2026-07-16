import '../database/database_helper.dart';
import '../models/violation.dart';

class ViolationRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> createViolation(Violation violation) async {
    final db = await _databaseHelper.database;
    final map = violation.toMap();
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    return db.insert('violations', map);
  }

  Future<int> createViolationRaw({
    int? employeeId,
    required int taskId,
    required String type,
    String? description,
  }) async {
    final db = await _databaseHelper.database;
    final data = {
      if (employeeId != null) 'employee_id': employeeId, // ignore: use_null_aware_elements
      'task_id': taskId,
      'type': type,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    };
    return await db.insert('violations', data);
  }

  Future<List<Violation>> getByEmployee(int employeeId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'violations',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Violation.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllViolations() async {
    final db = await _databaseHelper.database;
    return await db.query('violations', orderBy: 'created_at DESC');
  }

  Future<bool> existsForTaskAndType(int taskId, String type) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'violations',
      where: 'task_id = ? AND type = ?',
      whereArgs: [taskId, type],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> deleteViolation(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('violations', where: 'id = ?', whereArgs: [id]);
  }
}
