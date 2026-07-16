import 'dart:async';

import 'package:flutter/foundation.dart';
import '../repositories/task_repository.dart';
import '../repositories/violation_repository.dart';

class TaskCheckerService {
  Timer? _timer;
  final Duration interval;

  final TaskRepository _taskRepo = TaskRepository();
  final ViolationRepository _violationRepo = ViolationRepository();

  TaskCheckerService({this.interval = const Duration(minutes: 5)});

  void start() {
    _timer ??= Timer.periodic(interval, (_) => _check());
    // run immediate first check
    _check();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _check() async {
    if (kDebugMode) {
      debugPrint('TaskCheckerService: checking tasks...');
    }

    try {
      final now = DateTime.now();
      final overdue = await _taskRepo.getOverdueTasks(now);
      for (final task in overdue) {
        final taskId = task.id;
        if (taskId == null) continue;
        final exists = await _violationRepo.existsForTaskAndType(
          taskId,
          'OVERDUE',
        );
        if (!exists) {
          await _violationRepo.createViolationRaw(
            taskId: taskId,
            type: 'OVERDUE',
            description: 'Задача просрочена',
          );
          if (kDebugMode) debugPrint('Violation created for task $taskId');
        }
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('TaskCheckerService error: $e\n$st');
    }
  }
}
