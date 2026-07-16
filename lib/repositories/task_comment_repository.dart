import '../database/database_helper.dart';
import '../models/task_comment.dart';

class TaskCommentRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> addComment(TaskComment comment) async {
    final db = await _db.database;
    final map = comment.toMap();
    map['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('task_comments', map);
  }

  Future<List<TaskComment>> getCommentsForTask(int taskId) async {
    final db = await _db.database;
    final maps = await db.query(
      'task_comments',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => TaskComment.fromMap(m)).toList();
  }
}
