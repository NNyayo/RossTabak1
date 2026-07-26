import '../database/database_helper.dart';
import '../models/employee_request.dart';

class EmployeeRequestRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> add(EmployeeRequest request) async {
    final db = await _databaseHelper.database;
    final map = request.toMap();
    final now = DateTime.now().toIso8601String();
    map['created_at'] = map['created_at'] ?? now;
    map['updated_at'] = map['updated_at'] ?? now;
    return await db.insert('employee_requests', map);
  }

  Future<EmployeeRequest?> getById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT er.*, 
        e.last_name || ' ' || e.first_name || ' ' || COALESCE(e.middle_name, '') as employee_name,
        s.name as store_name
      FROM employee_requests er
      LEFT JOIN employees e ON er.employee_id = e.id
      LEFT JOIN stores s ON er.store_id = s.id
      WHERE er.id = ?
      LIMIT 1
    ''', [id]);
    if (maps.isEmpty) return null;
    return EmployeeRequest.fromMap(maps.first);
  }

  Future<List<EmployeeRequest>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT er.*, 
        e.last_name || ' ' || e.first_name || ' ' || COALESCE(e.middle_name, '') as employee_name,
        s.name as store_name
      FROM employee_requests er
      LEFT JOIN employees e ON er.employee_id = e.id
      LEFT JOIN stores s ON er.store_id = s.id
      ORDER BY er.created_at DESC
    ''');
    return maps.map((map) => EmployeeRequest.fromMap(map)).toList();
  }

  Future<List<EmployeeRequest>> getByEmployee(int employeeId) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT er.*, 
        e.last_name || ' ' || e.first_name || ' ' || COALESCE(e.middle_name, '') as employee_name,
        s.name as store_name
      FROM employee_requests er
      LEFT JOIN employees e ON er.employee_id = e.id
      LEFT JOIN stores s ON er.store_id = s.id
      WHERE er.employee_id = ?
      ORDER BY er.created_at DESC
    ''', [employeeId]);
    return maps.map((map) => EmployeeRequest.fromMap(map)).toList();
  }

  Future<List<EmployeeRequest>> getByStatus(String status) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT er.*, 
        e.last_name || ' ' || e.first_name || ' ' || COALESCE(e.middle_name, '') as employee_name,
        s.name as store_name
      FROM employee_requests er
      LEFT JOIN employees e ON er.employee_id = e.id
      LEFT JOIN stores s ON er.store_id = s.id
      WHERE er.status = ?
      ORDER BY er.created_at DESC
    ''', [status]);
    return maps.map((map) => EmployeeRequest.fromMap(map)).toList();
  }

  Future<void> updateStatus(int id, String status) async {
    final db = await _databaseHelper.database;
    await db.update(
      'employee_requests',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('employee_requests', where: 'id = ?', whereArgs: [id]);
  }
}