import 'package:flutter/foundation.dart';

import '../models/employee_request.dart';
import '../repositories/employee_request_repository.dart';

class EmployeeRequestController extends ChangeNotifier {
  final EmployeeRequestRepository _repository;

  EmployeeRequestController({
    EmployeeRequestRepository? repository,
  }) : _repository = repository ?? EmployeeRequestRepository();

  List<EmployeeRequest> requests = [];
  bool isLoading = false;

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();
    requests = await _repository.getAll();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadByEmployee(int employeeId) async {
    isLoading = true;
    notifyListeners();
    requests = await _repository.getByEmployee(employeeId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> createRequest(EmployeeRequest request) async {
    await _repository.add(request);
    await loadAll();
  }

  Future<void> updateStatus(int id, String status) async {
    await _repository.updateStatus(id, status);
    final index = requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      requests[index] = requests[index].copyWith(
        status: status,
        updatedAt: DateTime.now().toIso8601String(),
      );
      notifyListeners();
    }
  }

  int get newRequestsCount {
    return requests.where((r) => r.isNew).length;
  }

  int get inProgressCount {
    return requests.where((r) => r.isInProgress).length;
  }

  int get completedCount {
    return requests.where((r) => r.isCompleted).length;
  }
}