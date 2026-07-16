import '../database/database_helper.dart';
import '../models/task_employee.dart';

class TaskEmployeeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> assignEmployees(int taskId, List<int> employeeIds) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    for (final employeeId in employeeIds) {
      await db.insert('task_employees', {
        'task_id': taskId,
        'employee_id': employeeId,
        'status': 'NEW',
        'assigned_at': now,
      });
    }
  }

  Future<void> updateStatus(
    int taskId,
    int employeeId,
    String status, {
    String? completedAt,
  }) async {
    final db = await _databaseHelper.database;
    await db.update(
      'task_employees',
      {'status': status, 'completed_at': completedAt},
      where: 'task_id = ? AND employee_id = ?',
      whereArgs: [taskId, employeeId],
    );
  }

  Future<List<TaskEmployee>> getByTask(int taskId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'task_employees',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    return maps.map((map) => TaskEmployee.fromMap(map)).toList();
  }
}
