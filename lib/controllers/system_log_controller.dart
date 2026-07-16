import 'package:flutter/foundation.dart';

import '../models/system_log.dart';
import '../repositories/system_log_repository.dart';

class SystemLogController extends ChangeNotifier {
  final SystemLogRepository _repository = SystemLogRepository();

  List<SystemLog> logs = [];
  bool isLoading = false;

  Future<void> loadLogs() async {
    isLoading = true;
    notifyListeners();
    logs = await _repository.getAllLogs();
    isLoading = false;
    notifyListeners();
  }
}
