import '../database/database_helper.dart';
import '../models/daily_task_assignment.dart';

class DailyTaskAssignmentRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> add(DailyTaskAssignment assignment) async {
    final db = await _databaseHelper.database;
    final map = assignment.toMap();
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    return await db.insert('daily_task_assignments', map);
  }

  Future<DailyTaskAssignment?> getById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'daily_task_assignments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyTaskAssignment.fromMap(maps.first);
  }

  Future<List<DailyTaskAssignment>> getByStoreAndDate(
    int storeId,
    String date,
  ) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT dta.*, dtt.title as task_title, dtt.description as task_description,
             s.name as store_name
      FROM daily_task_assignments dta
      INNER JOIN daily_task_templates dtt ON dta.daily_task_template_id = dtt.id
      LEFT JOIN stores s ON dta.store_id = s.id
      WHERE dta.store_id = ? AND dta.date = ?
      ORDER BY dta.id ASC
    ''',
      [storeId, date],
    );
    return maps.map((map) => DailyTaskAssignment.fromMap(map)).toList();
  }

  Future<List<DailyTaskAssignment>> getByStore(int storeId) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT dta.*, dtt.title as task_title, dtt.description as task_description,
             s.name as store_name
      FROM daily_task_assignments dta
      INNER JOIN daily_task_templates dtt ON dta.daily_task_template_id = dtt.id
      LEFT JOIN stores s ON dta.store_id = s.id
      WHERE dta.store_id = ?
      ORDER BY dta.date DESC, dta.id ASC
    ''',
      [storeId],
    );
    return maps.map((map) => DailyTaskAssignment.fromMap(map)).toList();
  }

  Future<List<DailyTaskAssignment>> getByDate(String date) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT dta.*, dtt.title as task_title, dtt.description as task_description,
             s.name as store_name
      FROM daily_task_assignments dta
      INNER JOIN daily_task_templates dtt ON dta.daily_task_template_id = dtt.id
      LEFT JOIN stores s ON dta.store_id = s.id
      WHERE dta.date = ?
      ORDER BY dta.id ASC
    ''',
      [date],
    );
    return maps.map((map) => DailyTaskAssignment.fromMap(map)).toList();
  }

  Future<List<DailyTaskAssignment>> getByStoreIdsAndDate(
    List<int> storeIds,
    String date,
  ) async {
    if (storeIds.isEmpty) return [];
    final db = await _databaseHelper.database;
    final placeholders = storeIds.map((_) => '?').join(',');
    final maps = await db.rawQuery(
      '''
      SELECT dta.*, dtt.title as task_title, dtt.description as task_description,
             s.name as store_name
      FROM daily_task_assignments dta
      INNER JOIN daily_task_templates dtt ON dta.daily_task_template_id = dtt.id
      LEFT JOIN stores s ON dta.store_id = s.id
      WHERE dta.store_id IN ($placeholders) AND dta.date = ?
      ORDER BY dta.store_id, dta.id ASC
    ''',
      [...storeIds, date],
    );
    return maps.map((map) => DailyTaskAssignment.fromMap(map)).toList();
  }

  Future<void> complete(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'daily_task_assignments',
      {'status': 'COMPLETED', 'completed_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateStatus(int id, String status) async {
    final db = await _databaseHelper.database;
    await db.update(
      'daily_task_assignments',
      {
        'status': status,
        if (status == 'COMPLETED')
          'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> hasAssignmentsForStoreAndDate(int storeId, String date) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'daily_task_assignments',
      where: 'store_id = ? AND date = ?',
      whereArgs: [storeId, date],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> deleteByStoreAndDate(int storeId, String date) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'daily_task_assignments',
      where: 'store_id = ? AND date = ?',
      whereArgs: [storeId, date],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('daily_task_assignments', where: 'id = ?', whereArgs: [id]);
  }
}
