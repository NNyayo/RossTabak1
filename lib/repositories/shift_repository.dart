import '../database/database_helper.dart';
import '../models/shift.dart';

class ShiftRepository {
  final DatabaseHelper databaseHelper;

  ShiftRepository({DatabaseHelper? databaseHelper})
    : databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<int> addShift(Shift shift) async {
    final db = await databaseHelper.database;
    final map = shift.toMap();
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    return await db.insert('shifts', map);
  }

  Future<List<Shift>> getShifts() async {
    final db = await databaseHelper.database;
    final maps = await db.query('shifts', orderBy: 'date ASC');
    return maps.map((map) => Shift.fromMap(map)).toList();
  }

  Future<List<Shift>> getShiftsByDateAndType(
    String date,
    String shiftType,
  ) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'shifts',
      where: 'date = ? AND shift_type = ?',
      whereArgs: [date, shiftType],
    );
    return maps.map((map) => Shift.fromMap(map)).toList();
  }

  Future<List<Shift>> getShiftsByStoreDateAndType(
    int storeId,
    String date,
    String shiftType,
  ) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'shifts',
      where: 'store_id = ? AND date = ? AND shift_type = ?',
      whereArgs: [storeId, date, shiftType],
    );
    return maps.map((map) => Shift.fromMap(map)).toList();
  }

  Future<void> deleteShift(int shiftId) async {
    final db = await databaseHelper.database;
    await db.delete('shifts', where: 'id = ?', whereArgs: [shiftId]);
  }
}
