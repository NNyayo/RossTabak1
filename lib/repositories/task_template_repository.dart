import '../database/database_helper.dart';
import '../models/task_template.dart';

class TaskTemplateRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> createTemplate(TaskTemplate template) async {
    final db = await _databaseHelper.database;
    return db.insert('task_templates', template.toMap());
  }

  Future<List<TaskTemplate>> getActiveTemplates(String shiftType) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'task_templates',
      where: 'shift_type = ? AND is_active = ?',
      whereArgs: [shiftType, 1],
      orderBy: 'time ASC',
    );
    return maps.map((map) => TaskTemplate.fromMap(map)).toList();
  }
}
