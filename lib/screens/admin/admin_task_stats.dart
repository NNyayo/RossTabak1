import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_task_status.dart';
import '../../controllers/employee_controller.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import 'admin_base_page.dart';

class AdminTaskStatsPage extends StatefulWidget {
  const AdminTaskStatsPage({super.key});

  @override
  State<AdminTaskStatsPage> createState() => _AdminTaskStatsPageState();
}

class _AdminTaskStatsPageState extends State<AdminTaskStatsPage> {
  String _filterStore = 'ALL';
  String _filterEmployee = 'ALL';
  String _filterStatus = 'ALL';
  String _filterCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/tasks-stats',
      title: 'Статистика задач',
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 12),
          Expanded(child: _buildStats()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Фильтры',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildStoreFilter()),
                const SizedBox(width: 8),
                Expanded(child: _buildEmployeeFilter()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildStatusFilter()),
                const SizedBox(width: 8),
                Expanded(child: _buildCategoryFilter()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreFilter() {
    return Consumer<StoreController>(
      builder: (context, controller, _) {
        final stores = controller.stores;
        return DropdownButtonFormField<String>(
          initialValue: _filterStore,
          decoration: const InputDecoration(
            labelText: 'Магазин',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: 'ALL', child: Text('Все магазины')),
            ...stores.map((s) {
              return DropdownMenuItem(
                value: s.id.toString(),
                child: Text(s.name, overflow: TextOverflow.ellipsis),
              );
            }),
          ],
          onChanged: (v) => setState(() => _filterStore = v!),
        );
      },
    );
  }

  Widget _buildEmployeeFilter() {
    return Consumer<EmployeeController>(
      builder: (context, controller, _) {
        final employees = controller.employees;
        return DropdownButtonFormField<String>(
          initialValue: _filterEmployee,
          decoration: const InputDecoration(
            labelText: 'Сотрудник',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: 'ALL', child: Text('Все сотрудники')),
            ...employees.map((e) {
              return DropdownMenuItem(
                value: e.id.toString(),
                child: Text(e.fullName, overflow: TextOverflow.ellipsis),
              );
            }),
          ],
          onChanged: (v) => setState(() => _filterEmployee = v!),
        );
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _filterStatus,
      decoration: const InputDecoration(
        labelText: 'Статус',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: 'ALL', child: Text('Все статусы')),
        DropdownMenuItem(value: AppTaskStatus.newTask, child: Text('Новые')),
        DropdownMenuItem(
          value: AppTaskStatus.inProgress,
          child: Text('В процессе'),
        ),
        DropdownMenuItem(
          value: AppTaskStatus.completed,
          child: Text('Выполненные'),
        ),
        DropdownMenuItem(
          value: AppTaskStatus.failed,
          child: Text('Проваленные'),
        ),
      ],
      onChanged: (v) => setState(() => _filterStatus = v!),
    );
  }

  Widget _buildCategoryFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _filterCategory,
      decoration: const InputDecoration(
        labelText: 'Тип задачи',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(value: 'ALL', child: Text('Все типы')),
        ..._getCategories().map((c) {
          return DropdownMenuItem(value: c, child: Text(c));
        }),
      ],
      onChanged: (v) => setState(() => _filterCategory = v!),
    );
  }

  List<String> _getCategories() {
    final tasks = context.read<TaskController>().tasks;
    final categories = tasks.map((t) => t.category ?? 'Без категории').toSet();
    return categories.toList()..sort();
  }

  Widget _buildStats() {
    return Consumer<TaskController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var tasks = controller.tasks;

        // Применяем фильтры
        if (_filterStore != 'ALL') {
          final storeId = int.parse(_filterStore);
          tasks = tasks.where((t) => t.shiftId == storeId).toList();
        }

        if (_filterEmployee != 'ALL') {
          final employeeId = int.parse(_filterEmployee);
          tasks = tasks.where((t) => t.createdBy == employeeId).toList();
        }

        if (_filterStatus != 'ALL') {
          tasks = tasks.where((t) => t.status == _filterStatus).toList();
        }

        if (_filterCategory != 'ALL') {
          tasks = tasks.where((t) {
            final cat = t.category ?? 'Без категории';
            return cat == _filterCategory;
          }).toList();
        }

        final totalTasks = tasks.length;
        final completedTasks = tasks
            .where((t) => t.status == AppTaskStatus.completed)
            .length;
        final failedTasks = tasks
            .where((t) => t.status == AppTaskStatus.failed)
            .length;
        final inProgressTasks = tasks
            .where((t) => t.status == AppTaskStatus.inProgress)
            .length;
        final newTasks = tasks
            .where((t) => t.status == AppTaskStatus.newTask)
            .length;

        return Column(
          children: [
            _buildSummaryCards(
              totalTasks,
              completedTasks,
              failedTasks,
              inProgressTasks,
              newTasks,
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildTaskList(tasks)),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(
    int total,
    int completed,
    int failed,
    int inProgress,
    int newTasks,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.description,
              label: 'Всего',
              value: total.toString(),
              color: Colors.blue,
            ),
            _StatItem(
              icon: Icons.check_circle,
              label: 'Выполнено',
              value: completed.toString(),
              color: Colors.green,
            ),
            _StatItem(
              icon: Icons.error,
              label: 'Провалено',
              value: failed.toString(),
              color: Colors.red,
            ),
            _StatItem(
              icon: Icons.play_arrow,
              label: 'В процессе',
              value: inProgress.toString(),
              color: Colors.orange,
            ),
            _StatItem(
              icon: Icons.fiber_new,
              label: 'Новые',
              value: newTasks.toString(),
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('Задачи не найдены'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final statusColor = _getStatusColor(task.status);
        final statusLabel = _getStatusLabel(task.status);

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (task.category != null)
                      Chip(
                        label: Text(task.category!),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (task.priority == 'HIGH')
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.star, color: Colors.amber, size: 18),
                      ),
                    if (task.deadline != null)
                      Chip(
                        label: Text('Срок: ${task.deadline}'),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppTaskStatus.newTask:
        return Colors.blue;
      case AppTaskStatus.inProgress:
        return Colors.orange;
      case AppTaskStatus.completed:
        return Colors.green;
      case AppTaskStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case AppTaskStatus.newTask:
        return 'Новая';
      case AppTaskStatus.inProgress:
        return 'В процессе';
      case AppTaskStatus.completed:
        return 'Выполнена';
      case AppTaskStatus.failed:
        return 'Провалена';
      default:
        return status;
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
