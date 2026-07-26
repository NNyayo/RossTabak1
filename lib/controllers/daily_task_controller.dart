import 'package:flutter/foundation.dart';

import '../models/daily_task_assignment.dart';
import '../models/daily_task_template.dart';
import '../repositories/daily_task_assignment_repository.dart';
import '../repositories/daily_task_template_repository.dart';

class DailyTaskController extends ChangeNotifier {
  final DailyTaskTemplateRepository _templateRepository;
  final DailyTaskAssignmentRepository _assignmentRepository;

  DailyTaskController({
    DailyTaskTemplateRepository? templateRepository,
    DailyTaskAssignmentRepository? assignmentRepository,
  }) : _templateRepository =
           templateRepository ?? DailyTaskTemplateRepository(),
       _assignmentRepository =
           assignmentRepository ?? DailyTaskAssignmentRepository();

  List<DailyTaskTemplate> templates = [];
  List<DailyTaskAssignment> currentAssignments = [];
  List<DailyTaskAssignment> historyAssignments = [];
  bool isLoading = false;

  Future<void> loadTemplates() async {
    isLoading = true;
    notifyListeners();
    templates = await _templateRepository.getAll();
    isLoading = false;
    notifyListeners();
  }

  Future<int> createTemplate(DailyTaskTemplate template) async {
    final id = await _templateRepository.add(template);
    await loadTemplates();
    return id;
  }

  Future<void> updateTemplate(DailyTaskTemplate template) async {
    await _templateRepository.update(template);
    await loadTemplates();
  }

  Future<void> deleteTemplate(int id) async {
    await _templateRepository.delete(id);
    await loadTemplates();
  }

  Future<void> restoreTemplate(int id) async {
    await _templateRepository.restore(id);
    await loadTemplates();
  }

  /// Создать задание для магазина на указанную дату
  Future<void> createAssignmentForStore({
    required int templateId,
    required int storeId,
    required String date,
  }) async {
    await _assignmentRepository.add(
      DailyTaskAssignment(
        dailyTaskTemplateId: templateId,
        storeId: storeId,
        date: date,
        status: 'NEW',
      ),
    );
  }

  /// Автоматически создаёт задания на сегодня для магазина
  /// если они ещё не были созданы
  Future<void> ensureDailyTasksForStore(int storeId) async {
    final today = _getTodayDate();
    final hasAssignments = await _assignmentRepository
        .hasAssignmentsForStoreAndDate(storeId, today);
    if (hasAssignments) return;

    final activeTemplates = await _templateRepository.getAll();
    if (activeTemplates.isEmpty) return;

    for (final template in activeTemplates) {
      await _assignmentRepository.add(
        DailyTaskAssignment(
          dailyTaskTemplateId: template.id!,
          storeId: storeId,
          date: today,
          status: 'NEW',
        ),
      );
    }
  }

  /// Загружает текущие (сегодняшние) ежедневные задачи для магазина
  Future<void> loadTodayTasksForStore(int storeId) async {
    isLoading = true;
    notifyListeners();

    final today = _getTodayDate();
    await ensureDailyTasksForStore(storeId);
    currentAssignments = await _assignmentRepository.getByStoreAndDate(
      storeId,
      today,
    );

    isLoading = false;
    notifyListeners();
  }

  /// Загружает текущие задачи для нескольких магазинов (для сотрудника)
  Future<void> loadTodayTasksForStores(List<int> storeIds) async {
    isLoading = true;
    notifyListeners();

    final today = _getTodayDate();
    for (final storeId in storeIds) {
      await ensureDailyTasksForStore(storeId);
    }
    currentAssignments = await _assignmentRepository.getByStoreIdsAndDate(
      storeIds,
      today,
    );

    isLoading = false;
    notifyListeners();
  }

  /// Загружает историю ежедневных задач для магазина
  Future<void> loadHistoryForStore(int storeId) async {
    isLoading = true;
    notifyListeners();
    historyAssignments = await _assignmentRepository.getByStore(storeId);
    isLoading = false;
    notifyListeners();
  }

  /// Отметить задачу как выполненную
  Future<void> completeTask(int assignmentId) async {
    await _assignmentRepository.complete(assignmentId);
    final index = currentAssignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      currentAssignments[index] = currentAssignments[index].copyWith(
        status: 'COMPLETED',
        completedAt: DateTime.now().toIso8601String(),
      );
      notifyListeners();
    }
  }

  /// Получить процент выполнения ежедневных задач
  double get completionRate {
    if (currentAssignments.isEmpty) return 0;
    final completed = currentAssignments.where((a) => a.isCompleted).length;
    return (completed / currentAssignments.length) * 100;
  }

  /// Количество выполненных
  int get completedCount {
    return currentAssignments.where((a) => a.isCompleted).length;
  }

  /// Общее количество
  int get totalCount {
    return currentAssignments.length;
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
