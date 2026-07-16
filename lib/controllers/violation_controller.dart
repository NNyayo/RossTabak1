import 'package:flutter/foundation.dart';
import '../repositories/violation_repository.dart';

class ViolationController extends ChangeNotifier {
  final ViolationRepository _repo = ViolationRepository();
  bool isLoading = false;
  List<Map<String, dynamic>> violations = [];

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    violations = await _repo.getAllViolations();
    isLoading = false;
    notifyListeners();
  }
}
