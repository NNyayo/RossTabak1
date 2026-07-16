import 'package:sqflite/sqflite.dart';

import '../core/password_hash.dart';
import '../database/database_helper.dart';
import '../models/employee.dart';

class EmployeeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> addEmployee(Employee employee) async {
    final db = await _databaseHelper.database;

    final map = employee.toMap();
    final now = DateTime.now().toIso8601String();
    map['created_at'] = map['created_at'] ?? now;
    map['updated_at'] = map['updated_at'] ?? now;
    if (map['password'] is String) {
      final password = map['password'] as String;
      map['password'] = PasswordHasher.isHashed(password) ? password : PasswordHasher.hash(password);
    }

    return await db.transaction<int>((txn) async {
      final id = await txn.insert('employees', map);

      for (final storeId in employee.storeIds) {
        await txn.insert('employee_stores', {
          'employee_id': id,
          'store_id': storeId,
        });
      }

      return id;
    });
  }

  Future<List<Employee>> getEmployees() async {
    final db = await _databaseHelper.database;

    final info = await db.rawQuery('PRAGMA table_info(employees)');
    final hasIsActive = info.any((row) => row['name'] == 'is_active');

    final employeesData = await db.query(
      'employees',
      where: hasIsActive ? 'is_active = ?' : 'isActive = ?',
      whereArgs: [1],
      orderBy: hasIsActive ? 'last_name ASC' : 'lastName ASC',
    );

    return _loadEmployeesWithStores(db, employeesData);
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await _databaseHelper.database;

    final employeesData = await db.query('employees', orderBy: 'last_name ASC');

    return _loadEmployeesWithStores(db, employeesData);
  }

  Future<Employee?> getEmployeeById(int id) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final employeeId = result.first['id'] as int;
    final stores = await db.query(
      'employee_stores',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
    );
    final storeIds = stores.map((s) => s['store_id'] as int).toList();

    return Employee.fromMap({...result.first, 'storeIds': storeIds});
  }

  Future<List<Employee>> _loadEmployeesWithStores(
    Database db,
    List<Map<String, dynamic>> employeesData,
  ) async {
    if (employeesData.isEmpty) return [];

    final ids = employeesData.map((e) => e['id'] as int).toList();
    final placeholders = List.filled(ids.length, '?').join(',');

    final storeRows = await db.query(
      'employee_stores',
      where: 'employee_id IN ($placeholders)',
      whereArgs: ids,
    );

    final storesByEmployee = <int, List<int>>{};
    for (final row in storeRows) {
      final empId = row['employee_id'] as int;
      storesByEmployee.putIfAbsent(empId, () => []).add(row['store_id'] as int);
    }

    return employeesData.map((data) {
      final empId = data['id'] as int;
      return Employee.fromMap({...data, 'storeIds': storesByEmployee[empId] ?? const <int>[]});
    }).toList();
  }

  Future<void> updateEmployee(Employee employee) async {
    final db = await _databaseHelper.database;

    final map = employee.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.update(
        'employees',
        map,
        where: 'id = ?',
        whereArgs: [employee.id],
      );

      await txn.delete(
        'employee_stores',
        where: 'employee_id = ?',
        whereArgs: [employee.id],
      );

      for (final storeId in employee.storeIds) {
        await txn.insert('employee_stores', {
          'employee_id': employee.id,
          'store_id': storeId,
        });
      }
    });
  }

  Future<void> changePassword(int employeeId, String newPassword) async {
    final db = await _databaseHelper.database;

    await db.update(
      'employees',
      {'password': PasswordHasher.hash(newPassword)},
      where: 'id = ?',
      whereArgs: [employeeId],
    );
  }

  Future<void> deleteEmployee(int id) async {
    final db = await _databaseHelper.database;

    await db.update(
      'employees',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreEmployee(int id) async {
    final db = await _databaseHelper.database;

    await db.update(
      'employees',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
