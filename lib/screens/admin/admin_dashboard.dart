import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../controllers/employee_controller.dart';
import '../../controllers/shift_controller.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/task_controller.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_stat_card.dart';
import '../../widgets/animated_list_items.dart';
import '../../widgets/quick_action_chip.dart';
import 'admin_sidebar.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(selectedRoute: '/admin'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAppBar(context),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildQuickActions(context),
                        const SizedBox(height: 20),
                        _DashboardStatsGrid(),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _RecentTasksCard()),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final now = DateTime.now();
    final user = context.watch<AuthProvider>().currentEmployee;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Главная',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.withValues(alpha: 0.15),
                child: Text(
                  user?.firstName.isNotEmpty == true ? user!.firstName[0] : '?',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                user?.fullName ?? 'Пользователь',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.grey),
                tooltip: 'Выйти',
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  await authProvider.signOut();
                  if (context.mounted && authProvider.currentEmployee == null) {
                    context.go(AppRoutes.login);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        QuickActionChip(
          icon: Icons.person_add,
          label: 'Новый сотрудник',
          color: Colors.blue,
          onTap: () => context.push(AppRoutes.adminEmployees),
        ),
        QuickActionChip(
          icon: Icons.store,
          label: 'Новая точка',
          color: Colors.green,
          onTap: () => context.push(AppRoutes.adminStores),
        ),
        QuickActionChip(
          icon: Icons.add_task,
          label: 'Создать задачу',
          color: Colors.orange,
          onTap: () => context.push(AppRoutes.adminTasks),
        ),
        QuickActionChip(
          icon: Icons.access_time,
          label: 'Смены',
          color: Colors.purple,
          onTap: () => context.push(AppRoutes.adminShifts),
        ),
      ],
    );
  }
}

class _DashboardStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer4<
      StoreController,
      EmployeeController,
      TaskController,
      ShiftController
    >(
      builder: (context, stores, employees, tasks, shifts, _) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            AnimatedStatCard(
              title: 'Сотрудники',
              count: employees.employees.length,
              icon: Icons.people,
              color: Colors.blue,
              onTap: () => context.push(AppRoutes.adminEmployees),
              subtitle: 'в системе',
            ),
            AnimatedStatCard(
              title: 'Торговые точки',
              count: stores.stores.length,
              icon: Icons.store,
              color: Colors.green,
              onTap: () => context.push(AppRoutes.adminStores),
              subtitle: 'активных',
            ),
            AnimatedStatCard(
              title: 'Активные смены',
              count: shifts.activeShiftsCount,
              icon: Icons.access_time,
              color: Colors.purple,
              onTap: () => context.push(AppRoutes.adminShifts),
              subtitle: 'сейчас работают',
            ),
            AnimatedStatCard(
              title: 'Просрочено',
              count: tasks.overdueTasksCount,
              icon: Icons.warning_amber,
              color: Colors.red,
              onTap: () => context.push(AppRoutes.adminTasks),
              subtitle: 'требуют внимания',
            ),
            AnimatedStatCard(
              title: 'Сегодня',
              count: tasks.todayTasksCount,
              icon: Icons.today,
              color: Colors.amber,
              onTap: () => context.push(AppRoutes.adminTasks),
              subtitle: 'задач на сегодня',
            ),
          ],
        );
      },
    );
  }
}

class _RecentTasksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, tasks, _) {
        final recentTasks = tasks.tasks
            .where((t) => t.status != 'COMPLETED')
            .take(5)
            .toList();

        return AnimatedExpandableCard(
          title: 'Последние задачи',
          icon: Icons.task_alt,
          iconColor: Colors.blue,
          child: recentTasks.isEmpty
              ? const Center(
                  child: Text(
                    'Нет активных задач',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = recentTasks[index];
                    return AnimatedSlideItem(
                      index: index,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getTaskStatusColor(
                              task.status,
                            ).withValues(alpha: 0.15),
                            child: Icon(
                              task.status == 'COMPLETED'
                                  ? Icons.check_circle
                                  : Icons.task,
                              color: _getTaskStatusColor(task.status),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(task.category ?? 'Без категории'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getTaskStatusColor(
                                task.status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getTaskStatusLabel(task.status),
                              style: TextStyle(
                                color: _getTaskStatusColor(task.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () => context.push(AppRoutes.adminTasks),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

Color _getTaskStatusColor(String status) {
  switch (status) {
    case 'COMPLETED':
      return Colors.green;
    case 'IN_PROGRESS':
      return Colors.blue;
    default:
      return Colors.orange;
  }
}

String _getTaskStatusLabel(String status) {
  switch (status) {
    case 'COMPLETED':
      return 'Готово';
    case 'IN_PROGRESS':
      return 'В работе';
    default:
      return 'Новая';
  }
}
