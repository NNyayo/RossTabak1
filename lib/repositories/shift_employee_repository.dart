import '../database/database_helper.dart';
import '../models/shift_employee.dart';

class ShiftEmployeeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> assignEmployeesToShift(
    int shiftId,
    List<int> employeeIds,
  ) async {
    final db = await _databaseHelper.database;
    for (final employeeId in employeeIds) {
      await db.insert('shift_employees', {
        'shift_id': shiftId,
        'employee_id': employeeId,
      });
    }
  }

  Future<List<ShiftEmployee>> getByShift(int shiftId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'shift_employees',
      where: 'shift_id = ?',
      whereArgs: [shiftId],
    );
    return maps.map((map) => ShiftEmployee.fromMap(map)).toList();
  }

  Future<void> deleteByShift(int shiftId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'shift_employees',
      where: 'shift_id = ?',
      whereArgs: [shiftId],
    );
  }
}
