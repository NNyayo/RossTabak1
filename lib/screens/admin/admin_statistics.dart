import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/employee_controller.dart';

import '../../controllers/shift_controller.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/employee.dart';
import '../../models/task.dart';
import '../../widgets/animated_stat_card.dart';
import '../../widgets/animated_list_items.dart';
import 'admin_base_page.dart';

class AdminStatisticsPage extends StatefulWidget {
  const AdminStatisticsPage({super.key});

  @override
  State<AdminStatisticsPage> createState() => _AdminStatisticsPageState();
}

class _AdminStatisticsPageState extends State<AdminStatisticsPage> {
  String _period = 'ALL';
  String _selectedTab = 'general';

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/tasks-stats',
      title: 'Статистика',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabs(),
          const SizedBox(height: 16),
          _buildPeriodFilter(),
          const SizedBox(height: 16),
          Expanded(
            child: IndexedStack(
              index: _selectedTab == 'general'
                  ? 0
                  : _selectedTab == 'employees'
                  ? 1
                  : _selectedTab == 'stores'
                  ? 2
                  : 3,
              children: [
                _ScrollableChild(child: _buildGeneralStats()),
                _ScrollableChild(child: _buildEmployeeStats()),
                _ScrollableChild(child: _buildStoreStats()),
                _ScrollableChild(child: _buildShiftStats()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _buildTab('Общая', 0),
            const SizedBox(width: 4),
            _buildTab('Сотрудники', 1),
            const SizedBox(width: 4),
            _buildTab('Точки', 2),
            const SizedBox(width: 4),
            _buildTab('Смены', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected =
        _selectedTab ==
        (index == 0
            ? 'general'
            : index == 1
            ? 'employees'
            : index == 2
            ? 'stores'
            : 'shifts');
    return Expanded(
      child: InkWell(
        onTap: () => setState(
          () => _selectedTab = index == 0
              ? 'general'
              : index == 1
              ? 'employees'
              : index == 2
              ? 'stores'
              : 'shifts',
        ),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text(
              'Период: ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            _periodChip('Все', 'ALL'),
            const SizedBox(width: 8),
            _periodChip('Сегодня', 'TODAY'),
            const SizedBox(width: 8),
            _periodChip('Неделя', 'WEEK'),
            const SizedBox(width: 8),
            _periodChip('Месяц', 'MONTH'),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String label, String value) {
    final isSelected = _period == value;
    return InkWell(
      onTap: () => setState(() => _period = value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralStats() {
    return Consumer4<
      StoreController,
      EmployeeController,
      TaskController,
      ShiftController
    >(
      builder: (context, stores, employees, tasks, shifts, _) {
        final totalTasks = tasks.tasks.length;
        final completed = tasks.completedTasksCount;
        final active = tasks.activeTasksCount;
        final overdue = tasks.overdueTasksCount;
        final rate = tasks.completionRate;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AnimatedStatCard(
                    title: 'Всего задач',
                    count: totalTasks,
                    icon: Icons.task_alt,
                    color: Colors.blue,
                    subtitle: 'в системе',
                  ),
                  AnimatedStatCard(
                    title: 'Выполнено',
                    count: completed,
                    icon: Icons.check_circle,
                    color: Colors.green,
                    subtitle: 'успешно',
                  ),
                  AnimatedStatCard(
                    title: 'Активные',
                    count: active,
                    icon: Icons.pending,
                    color: Colors.orange,
                    subtitle: 'в работе',
                  ),
                  AnimatedStatCard(
                    title: 'Просрочено',
                    count: overdue,
                    icon: Icons.warning_amber,
                    color: Colors.red,
                    subtitle: 'требуют внимания',
                  ),
                  AnimatedStatCard(
                    title: 'Сотрудники',
                    count: employees.employees.length,
                    icon: Icons.people,
                    color: Colors.purple,
                    subtitle: 'в системе',
                  ),
                  AnimatedStatCard(
                    title: 'Точки',
                    count: stores.stores.length,
                    icon: Icons.store,
                    color: Colors.teal,
                    subtitle: 'активных',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildCompletionBar(rate.toDouble()),
              const SizedBox(height: 20),
              _buildCategoryBreakdown(tasks.tasks),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletionBar(double rate) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Общий прогресс выполнения',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: rate / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  rate >= 80
                      ? Colors.green
                      : rate >= 50
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${rate.round()}% задач выполнено',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<Task> tasks) {
    final categories = <String, int>{};
    for (final t in tasks) {
      final cat = t.category ?? 'Без категории';
      categories[cat] = (categories[cat] ?? 0) + 1;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Задачи по категориям',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...categories.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 14)),
                    Chip(
                      label: Text('${e.value}'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeStats() {
    return Consumer<EmployeeController>(
      builder: (context, controller, _) {
        return _buildEmployeeRanking(controller.employees);
      },
    );
  }

  Widget _buildEmployeeRanking(List<Employee> employees) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Рейтинг сотрудников',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (employees.isEmpty)
              const Center(
                child: Text(
                  'Нет сотрудников',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...employees.mapIndexed(
                (index, emp) => AnimatedSlideItem(
                  index: index,
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: _getRoleColor(
                          emp.role,
                        ).withValues(alpha: 0.15),
                        child: Text(
                          emp.firstName.isNotEmpty
                              ? emp.firstName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: _getRoleColor(emp.role),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        emp.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(_getRoleLabel(emp.role)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${(index + 1) * 10}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ), // SingleChildScrollView
    );
  }

  Widget _buildStoreStats() {
    return Consumer<StoreController>(
      builder: (context, controller, _) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Статистика по торговым точкам',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (controller.stores.isEmpty)
                  const Center(
                    child: Text(
                      'Нет точек',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...controller.stores.mapIndexed(
                    (index, store) => AnimatedSlideItem(
                      index: index,
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getMarkerColor(
                              store.markerColor,
                            ).withValues(alpha: 0.15),
                            child: Icon(
                              Icons.store,
                              color: _getMarkerColor(store.markerColor),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            store.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(store.address),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: store.isActive
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  store.isActive ? 'Активна' : 'Архив',
                                  style: TextStyle(
                                    color: store.isActive
                                        ? Colors.green
                                        : Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShiftStats() {
    return Consumer<ShiftController>(
      builder: (context, controller, _) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Статистика по сменам',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ShiftSummaryCard(
                      label: 'Всего смен',
                      value: controller.allShifts.length.toString(),
                      icon: Icons.access_time,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 12),
                    _ShiftSummaryCard(
                      label: 'Активные',
                      value: controller.activeShiftsCount.toString(),
                      icon: Icons.play_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _ShiftSummaryCard(
                      label: 'Сегодня',
                      value: controller.todayShiftsCount.toString(),
                      icon: Icons.today,
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Последние смены',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (controller.allShifts.isEmpty)
                  const Center(
                    child: Text(
                      'Нет смен',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...controller.allShifts
                      .take(10)
                      .mapIndexed(
                        (index, shift) => AnimatedSlideItem(
                          index: index,
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    shift.shiftType.contains('Дневн')
                                    ? Colors.amber.withValues(alpha: 0.15)
                                    : Colors.indigo.withValues(alpha: 0.15),
                                child: Icon(
                                  shift.shiftType.contains('Дневн')
                                      ? Icons.wb_sunny
                                      : Icons.nightlight,
                                  color: shift.shiftType.contains('Дневн')
                                      ? Colors.amber
                                      : Colors.indigo,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                shift.shiftType.contains('Дневн')
                                    ? 'Дневная смена'
                                    : 'Ночная смена',
                              ),
                              subtitle: Text(
                                '${shift.date} • ${shift.startTime} - ${shift.endTime}',
                              ),
                              trailing: Text(
                                'Точка #${shift.storeId}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShiftSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ShiftSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension IndexedMapExtension<T> on Iterable<T> {
  Iterable<E> mapIndexed<E>(E Function(int index, T element) fn) {
    var i = 0;
    return map((e) => fn(i++, e));
  }
}

class _ScrollableChild extends StatelessWidget {
  final Widget child;
  const _ScrollableChild({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }
}

Color _getRoleColor(String role) {
  switch (role) {
    case 'ADMIN':
      return Colors.purple;
    case 'MANAGER':
      return Colors.blue;
    default:
      return Colors.green;
  }
}

String _getRoleLabel(String role) {
  switch (role) {
    case 'ADMIN':
      return 'Администратор';
    case 'MANAGER':
      return 'Менеджер';
    default:
      return 'Сотрудник';
  }
}

Color _getMarkerColor(String? colorName) {
  if (colorName == null) return Colors.grey;
  switch (colorName) {
    case 'Красный':
      return const Color(0xFFFF3B30);
    case 'Синий':
      return const Color(0xFF007AFF);
    case 'Зелёный':
      return const Color(0xFF34C759);
    case 'Оранжевый':
      return const Color(0xFFFF9500);
    case 'Фиолетовый':
      return const Color(0xFFAF52DE);
    case 'Коричневый':
      return const Color(0xFFA2845E);
    default:
      return Colors.grey;
  }
}
