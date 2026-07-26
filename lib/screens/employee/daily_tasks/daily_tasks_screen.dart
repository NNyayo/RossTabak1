import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/daily_task_controller.dart';
import '../../../controllers/store_controller.dart';
import '../../../providers/auth_provider.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  int? _selectedStoreId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreController>().loadStores();
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    final employee = context.read<AuthProvider>().currentEmployee;
    if (employee == null) return;
    final storeIds = employee.storeIds;
    if (storeIds.isEmpty) return;
    if (_selectedStoreId != null) {
      await context.read<DailyTaskController>().loadTodayTasksForStore(
        _selectedStoreId!,
      );
    } else {
      await context.read<DailyTaskController>().loadTodayTasksForStores(
        storeIds,
      );
    }
  }

  void _onStoreSelected(int? storeId) {
    setState(() => _selectedStoreId = storeId);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DailyTaskController>();
    final storeController = context.watch<StoreController>();
    final employee = context.watch<AuthProvider>().currentEmployee;
    final stores = storeController.stores;

    if (employee == null) {
      return const Center(child: Text('Сотрудник не найден'));
    }

    final tasks = controller.currentAssignments;
    final completed = controller.completedCount;
    final total = controller.totalCount;
    final rate = controller.completionRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Статистика
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Всего',
                      value: total.toString(),
                      color: Colors.blue,
                    ),
                    _StatItem(
                      label: 'Выполнено',
                      value: completed.toString(),
                      color: Colors.green,
                    ),
                    _StatItem(
                      label: 'Осталось',
                      value: (total - completed).toString(),
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      rate == 100 ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rate.round()}% выполнено',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Обязательные задачи на сегодня',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        // Кнопка выбора магазина
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.store, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedStoreId,
                      isDense: true,
                      borderRadius: BorderRadius.circular(10),
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Все магазины'),
                        ),
                        ...stores
                            .where((s) => employee.storeIds.contains(s.id))
                            .map(
                              (store) => DropdownMenuItem<int>(
                                value: store.id,
                                child: Text(
                                  store.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                      ],
                      onChanged: _onStoreSelected,
                      hint: const Text('Все магазины'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (controller.isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (tasks.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'Нет обязательных задач на сегодня',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _DailyTaskCard(
                  task: task,
                  onToggle: () async {
                    if (!task.isCompleted) {
                      await controller.completeTask(task.id!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${task.taskTitle} — выполнено'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _DailyTaskCard extends StatelessWidget {
  final dynamic task;
  final VoidCallback onToggle;

  const _DailyTaskCard({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCompleted
            ? BorderSide(color: Colors.green.withValues(alpha: 0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  key: ValueKey(isCompleted),
                  color: isCompleted ? Colors.green : Colors.grey[400],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskTitle ?? 'Задача',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted
                            ? Colors.grey
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (task.storeName != null &&
                        task.storeName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.store, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            task.storeName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (task.taskDescription != null &&
                        task.taskDescription!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.taskDescription,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Готово',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}
