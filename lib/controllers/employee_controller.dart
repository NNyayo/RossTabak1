import 'package:flutter/foundation.dart';

import '../models/employee.dart';
import '../repositories/employee_repository.dart';

class EmployeeController extends ChangeNotifier {
  final EmployeeRepository _repository = EmployeeRepository();

  List<Employee> employees = [];
  bool isLoading = false;

  Future<void> loadEmployees() async {
    isLoading = true;
    notifyListeners();
    employees = await _repository.getEmployees();
    isLoading = false;
    notifyListeners();
  }

  Future<List<Employee>> getAllEmployees() async {
    return _repository.getAllEmployees();
  }

  Future<Employee?> getEmployeeById(int id) async {
    return _repository.getEmployeeById(id);
  }

  Future<int> createEmployee(Employee e) async {
    final id = await _repository.addEmployee(e);
    await loadEmployees();
    return id;
  }

  Future<void> updateEmployee(Employee e) async {
    await _repository.updateEmployee(e);
    await loadEmployees();
  }

  Future<void> changePassword(int employeeId, String newPassword) async {
    await _repository.changePassword(employeeId, newPassword);
    await loadEmployees();
  }

  Future<void> deleteEmployee(int id) async {
    await _repository.deleteEmployee(id);
    await loadEmployees();
  }

  Future<void> restoreEmployee(int id) async {
    await _repository.restoreEmployee(id);
    await loadEmployees();
  }
}
