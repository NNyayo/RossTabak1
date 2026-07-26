import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_list_items.dart';
import 'employee_base_page.dart';
import 'daily_tasks/daily_tasks_screen.dart';
import 'requests/my_requests_screen.dart';

class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({super.key});

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final employee = provider.currentEmployee;

    if (employee == null) {
      return const Scaffold(
        body: Center(child: Text('Данные сотрудника не загружены')),
      );
    }

    final taskController = context.watch<TaskController>();

    final allTasks = taskController.tasks;
    // Показываем только невыполненные задачи
    final myTasks = allTasks
        .where((t) => t.status != 'COMPLETED')
        .take(10)
        .toList();

    return EmployeeBasePage(
      title: 'Панель сотрудника',
      onLogout: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Выйти'),
            content: const Text('Вы уверены, что хотите выйти?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Выйти'),
              ),
            ],
          ),
        );
        if (confirm == true && mounted) {
          await provider.signOut();
          if (mounted) {
            context.go(AppRoutes.login);
          }
        }
      },
      child: Column(
        children: [
          // Табы для переключения между разделами
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      icon: Icons.calendar_today,
                      label: 'Ежедн.',
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      icon: Icons.task,
                      label: 'Задачи',
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      icon: Icons.description,
                      label: 'Заявки',
                      isSelected: _selectedTab == 2,
                      onTap: () => setState(() => _selectedTab = 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Контент в зависимости от выбранного таба
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                // 1. Обязательные ежедневные задачи
                _buildDailyTasksTab(),
                // 2. Обычные задачи (существующий функционал)
                _buildRegularTasksTab(context, employee, myTasks),
                // 3. Мои заявки
                const MyRequestsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTasksTab() {
    return const DailyTasksScreen();
  }

  Widget _buildRegularTasksTab(
    BuildContext context,
    dynamic employee,
    List<Task> myTasks,
  ) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(employee),
          const SizedBox(height: 16),
          _buildStatsCard(
            context.watch<TaskController>().tasks.length,
            context
                .watch<TaskController>()
                .tasks
                .where((t) => t.status == 'COMPLETED')
                .length,
            context
                .watch<TaskController>()
                .tasks
                .where((t) => t.status != 'COMPLETED')
                .length,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Дополнительные задачи',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          _buildMyTasksList(myTasks),
        ],
      ),
    );
  }

  Widget _buildMyTasksList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('Нет задач', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isPriority = task.priority != null && task.priority!.isNotEmpty;
        return AnimatedSlideItem(
          index: index,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isPriority
                  ? const BorderSide(color: Colors.amber, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.task,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  if (isPriority)
                    const Positioned(
                      top: -2,
                      right: -2,
                      child: Icon(Icons.star, color: Colors.amber, size: 14),
                    ),
                ],
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: isPriority ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(task.category ?? 'Без категории'),
                  if (isPriority) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      'Приоритет',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Открыть'),
                onPressed: () {
                  context.push('${AppRoutes.employeeTasks}/${task.id}');
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(dynamic employee) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.withValues(alpha: 0.15),
              child: Text(
                employee.firstName.isNotEmpty
                    ? employee.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    employee.login,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int total, int completed, int remaining) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: 'Всего',
              value: total.toString(),
              color: Colors.blue,
            ),
            _SummaryItem(
              label: 'Выполнено',
              value: completed.toString(),
              color: Colors.green,
            ),
            _SummaryItem(
              label: 'Осталось',
              value: remaining.toString(),
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.grey[800] : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.grey[800] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
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
