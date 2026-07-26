import '../database/database_helper.dart';
import '../models/daily_task_template.dart';

class DailyTaskTemplateRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> add(DailyTaskTemplate template) async {
    final db = await _databaseHelper.database;
    final map = template.toMap();
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    return await db.insert('daily_task_templates', map);
  }

  Future<DailyTaskTemplate?> getById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'daily_task_templates',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyTaskTemplate.fromMap(maps.first);
  }

  Future<List<DailyTaskTemplate>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'daily_task_templates',
      where: 'is_active = 1',
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => DailyTaskTemplate.fromMap(map)).toList();
  }

  Future<List<DailyTaskTemplate>> getAllIncludingInactive() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'daily_task_templates',
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => DailyTaskTemplate.fromMap(map)).toList();
  }

  Future<void> update(DailyTaskTemplate template) async {
    final db = await _databaseHelper.database;
    await db.update(
      'daily_task_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'daily_task_templates',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> hardDelete(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('daily_task_templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> restore(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'daily_task_templates',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}