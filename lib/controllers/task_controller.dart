import 'package:flutter/foundation.dart';

import '../constants/app_task_status.dart';
import '../models/notification.dart';
import '../models/task.dart';
import '../models/task_log.dart';
import '../models/violation.dart';
import '../repositories/employee_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/store_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/task_employee_repository.dart';
import '../repositories/task_log_repository.dart';
import '../repositories/violation_repository.dart';
import '../repositories/system_log_repository.dart';

class TaskController extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final TaskEmployeeRepository _taskEmployeeRepository;
  final TaskLogRepository _taskLogRepository;
  final ViolationRepository _violationRepository;
  final SystemLogRepository _logRepository;
  final NotificationRepository _notificationRepository;

  TaskController({
    TaskRepository? taskRepository,
    TaskEmployeeRepository? taskEmployeeRepository,
    TaskLogRepository? taskLogRepository,
    ViolationRepository? violationRepository,
    SystemLogRepository? logRepository,
    NotificationRepository? notificationRepository,
  }) : _taskRepository = taskRepository ?? TaskRepository(),
       _taskEmployeeRepository =
           taskEmployeeRepository ?? TaskEmployeeRepository(),
       _taskLogRepository = taskLogRepository ?? TaskLogRepository(),
       _violationRepository = violationRepository ?? ViolationRepository(),
       _logRepository = logRepository ?? SystemLogRepository(),
       _notificationRepository =
           notificationRepository ?? NotificationRepository();

  List<Task> tasks = [];
  bool isLoading = false;

  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();
    tasks = await _taskRepository.getTasks();
    isLoading = false;
    notifyListeners();
  }

  int get overdueTasksCount {
    final now = DateTime.now();
    return tasks.where((t) {
      if (t.status == AppTaskStatus.completed) return false;
      if (t.deadline == null) return false;
      try {
        final deadline = DateTime.parse(t.deadline!);
        return deadline.isBefore(now);
      } catch (_) {
        return false;
      }
    }).length;
  }

  int get todayTasksCount {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return tasks.where((t) {
      if (t.deadline == null) return false;
      return t.deadline!.startsWith(todayStr);
    }).length;
  }

  int get activeTasksCount {
    return tasks.where((t) => t.status != AppTaskStatus.completed).length;
  }

  int get completedTasksCount {
    return tasks.where((t) => t.status == AppTaskStatus.completed).length;
  }

  int get completionRate {
    if (tasks.isEmpty) return 0;
    return ((completedTasksCount / tasks.length) * 100).round();
  }

  Future<int> createTask(
    Task task,
    List<int> assigneeIds,
    int operatorId,
  ) async {
    final taskId = await _taskRepository.addTask(task);
    await _taskEmployeeRepository.assignEmployees(taskId, assigneeIds);
    await _taskLogRepository.createLog(
      TaskLog(
        taskId: taskId,
        employeeId: operatorId,
        action: 'TASK_CREATED',
        description: 'Задача создана: ${task.title}',
      ),
    );
    await _logRepository.createLog(
      employeeId: operatorId,
      action: 'CREATE_TASK',
      description: 'Создана задача id=$taskId',
    );
    return taskId;
  }

  Future<void> startTask(int taskId, int employeeId) async {
    await _taskEmployeeRepository.updateStatus(
      taskId,
      employeeId,
      AppTaskStatus.inProgress,
    );
    await _taskLogRepository.createLog(
      TaskLog(
        taskId: taskId,
        employeeId: employeeId,
        action: 'TASK_STARTED',
        description: 'Задача начата сотрудником id=$employeeId',
      ),
    );
  }

  Future<void> completeTask(
    int taskId,
    int employeeId, {
    String? employeeFullName,
    String? storeName,
  }) async {
    final completedAt = DateTime.now().toIso8601String();
    await _taskRepository.updateTaskStatus(
      taskId,
      AppTaskStatus.completed,
      completedAt: completedAt,
    );
    await _taskEmployeeRepository.updateStatus(
      taskId,
      employeeId,
      AppTaskStatus.completed,
      completedAt: completedAt,
    );
    await _taskLogRepository.createLog(
      TaskLog(
        taskId: taskId,
        employeeId: employeeId,
        action: 'TASK_COMPLETED',
        description: 'Задача завершена сотрудником id=$employeeId',
      ),
    );

    Task task;
    try {
      task = tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      final allTasks = await _taskRepository.getTasks();
      task = allTasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => Task(
          id: taskId,
          title: 'Задача #$taskId',
          createdBy: 0,
          status: 'COMPLETED',
        ),
      );
    }

    tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();

    String resolvedEmpName = employeeFullName ?? 'Сотрудник #$employeeId';
    if (employeeFullName == null) {
      try {
        final emp = await EmployeeRepository().getEmployeeById(employeeId);
        if (emp != null) resolvedEmpName = emp.fullName;
      } catch (_) {}
    }

    String resolvedStoreName = storeName ?? '';
    if (storeName == null && task.storeId != null && task.storeId! > 0) {
      try {
        final store = await StoreRepository().getStoreById(task.storeId!);
        if (store != null) resolvedStoreName = store.name;
      } catch (_) {}
    }

    String message = '$resolvedEmpName выполнил задачу: ${task.title}';
    if (resolvedStoreName.isNotEmpty) {
      message += ' ($resolvedStoreName)';
    }

    if (task.createdBy > 0) {
      await _notificationRepository.create(
        AppNotification(
          employeeId: task.createdBy,
          type: 'TASK_COMPLETED',
          title: 'Задача выполнена',
          message: message,
          createdAt: completedAt,
        ),
      );
    }
  }

  Future<void> checkForLateTasks(int operatorId) async {
    final overdueTasks = await _taskRepository.getOverdueTasks(DateTime.now());
    for (final task in overdueTasks) {
      final taskEmployees = await _taskEmployeeRepository.getByTask(task.id!);
      for (final taskEmployee in taskEmployees) {
        await _violationRepository.createViolation(
          Violation(
            employeeId: taskEmployee.employeeId,
            taskId: task.id!,
            type: 'LATE_TASK',
            description: 'Просрочена задача ${task.title}',
          ),
        );
      }
      await _taskLogRepository.createLog(
        TaskLog(
          taskId: task.id!,
          employeeId: operatorId,
          action: 'TASK_OVERDUE_CHECK',
          description: 'Обнаружена просроченная задача id=${task.id}',
        ),
      );
    }
  }

  Future<double> calculateCompletionRate({
    String? storeDate,
    String? shiftType,
  }) async {
    final allTasks = await _taskRepository.getTasks();
    final relevantTasks = allTasks.where((task) {
      if (storeDate != null && task.deadline != null) {
        return task.deadline!.startsWith(storeDate);
      }
      return true;
    }).toList();

    if (relevantTasks.isEmpty) {
      return 0.0;
    }

    final completedCount = relevantTasks
        .where((task) => task.status == AppTaskStatus.completed)
        .length;
    return completedCount / relevantTasks.length * 100;
  }
}
