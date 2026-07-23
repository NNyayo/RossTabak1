import '../database/database_helper.dart';
import '../models/notification.dart';

class NotificationRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> create(AppNotification notification) async {
    final db = await _db.database;
    final map = notification.toMap();
    map['created_at'] = DateTime.now().toIso8601String();
    map.remove('id');

    return await db.insert('notifications', map);
  }

  Future<List<AppNotification>> getForEmployee(int employeeId) async {
    final db = await _db.database;
    final maps = await db.query(
      'notifications',
      where: 'employee_id = ? OR employee_id IS NULL',
      whereArgs: [employeeId],
      orderBy: 'created_at DESC',
      limit: 50,
    );
    return maps.map((m) => AppNotification.fromMap(m)).toList();
  }

  Future<List<AppNotification>> getUnread(int employeeId) async {
    final db = await _db.database;
    final maps = await db.query(
      'notifications',
      where: '(employee_id = ? OR employee_id IS NULL) AND is_read = 0',
      whereArgs: [employeeId],
      orderBy: 'created_at DESC',
      limit: 100,
    );
    return maps.map((m) => AppNotification.fromMap(m)).toList();
  }

  Future<int> getUnreadCount(int employeeId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM notifications WHERE (employee_id = ? OR employee_id IS NULL) AND is_read = 0',
      [employeeId],
    );
    return (result.first['cnt'] as int?) ?? 0;
  }

  Future<void> markAsRead(int notificationId) async {
    final db = await _db.database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> markAllAsRead(int employeeId) async {
    final db = await _db.database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'employee_id = ? OR employee_id IS NULL',
      whereArgs: [employeeId],
    );
  }
}
