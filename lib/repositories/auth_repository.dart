import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/password_hash.dart';
import '../database/database_helper.dart';
import '../models/employee.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Employee?> login(String login, String password) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'employees',
      where: 'login = ? AND is_active = ?',
      whereArgs: [login, 1],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    final stored = row['password'] as String;

    if (!PasswordHasher.verify(password, stored)) {
      return null;
    }

    final employeeId = row['id'] as int;

    final storeRows = await _queryEmployeeStores(db, employeeId);
    final storeIds = storeRows
        .map((r) => (r['store_id'] ?? r['storeId']) as int)
        .toList();

    return Employee.fromMap({...row, 'storeIds': storeIds});
  }

  Future<Employee?> findByLogin(String login) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'employees',
      where: 'login = ?',
      whereArgs: [login],
      limit: 1,
    );
    if (result.isEmpty) return null;
    final row = result.first;
    final id = row['id'] as int;
    final storeRows = await _queryEmployeeStores(db, id);
    final storeIds = storeRows
        .map((r) => (r['store_id'] ?? r['storeId']) as int)
        .toList();
    return Employee.fromMap({...row, 'storeIds': storeIds});
  }

  Future<List<Map<String, dynamic>>> _queryEmployeeStores(
    Database db,
    int employeeId,
  ) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info(employee_stores)');
    final hasEmployeeId = tableInfo.any((row) => row['name'] == 'employeeId');
    final hasEmployeeIdUnderscore = tableInfo.any(
      (row) => row['name'] == 'employee_id',
    );
    final columnName = hasEmployeeId
        ? 'employeeId'
        : hasEmployeeIdUnderscore
        ? 'employee_id'
        : 'employee_id';

    return await db.query(
      'employee_stores',
      where: '$columnName = ?',
      whereArgs: [employeeId],
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_id');
  }

  Future<Employee?> getCurrentUser(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final storeRows = await _queryEmployeeStores(db, id);
    final storeIds = storeRows
        .map((r) => (r['store_id'] ?? r['storeId']) as int)
        .toList();
    return Employee.fromMap({...row, 'storeIds': storeIds});
  }

  Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<int?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('user_id', userId);
  }
}
