import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_shifts.dart';
import '../../controllers/employee_controller.dart';
import '../../controllers/shift_controller.dart';
import '../../controllers/store_controller.dart';
import '../../providers/auth_provider.dart';
import '../../models/employee.dart';
import '../../models/shift.dart';
import '../../models/shift_employee.dart';
import '../../models/store.dart';
import '../../repositories/shift_employee_repository.dart';
import 'admin_base_page.dart';

class AdminShiftsPage extends StatefulWidget {
  const AdminShiftsPage({super.key});

  @override
  State<AdminShiftsPage> createState() => _AdminShiftsPageState();
}

class _AdminShiftsPageState extends State<AdminShiftsPage> {
  DateTime _selectedDate = DateTime.now();
  String _filterStore = 'ALL';
  String _filterType = 'ALL';

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/shifts',
      title: 'Смены',
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Flexible(child: _buildDateSelector()),
              SizedBox(
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: _createDayShifts,
                  icon: const Icon(Icons.add),
                  label: const Text('Создать дневные'),
                ),
              ),
              SizedBox(
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: _createNightShifts,
                  icon: const Icon(Icons.add),
                  label: const Text('Создать ночные'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildShiftList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text('Магазин:'),
            const SizedBox(width: 8),
            Expanded(
              child: Consumer<StoreController>(
                builder: (context, controller, _) {
                  final stores = controller.stores;
                  return DropdownButtonFormField<String>(
                    initialValue: _filterStore,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'ALL', child: Text('Все')),
                      ...stores.map((s) {
                        return DropdownMenuItem(
                          value: s.id.toString(),
                          child: Text(s.name),
                        );
                      }),
                    ],
                    onChanged: (v) => setState(() => _filterStore = v!),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            const Text('Тип:'),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _filterType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('Все')),
                  DropdownMenuItem(
                    value: AppShifts.day,
                    child: Text('Дневная'),
                  ),
                  DropdownMenuItem(
                    value: AppShifts.night,
                    child: Text('Ночная'),
                  ),
                ],
                onChanged: (v) => setState(() => _filterType = v!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                DateFormat('dd.MM.yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.subtract(
                    const Duration(days: 1),
                  );
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftList() {
    return Consumer<StoreController>(
      builder: (context, storeController, child) {
        final shifts = context.read<ShiftController>();
        final stores = storeController.stores;

        final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

        Future<List<Shift>> loadShifts() async {
          final allShifts = await shifts.shiftRepository.getShiftsByDateAndType(
            dateString,
            AppShifts.day,
          );
          final nightShifts = await shifts.shiftRepository
              .getShiftsByDateAndType(dateString, AppShifts.night);
          return [...allShifts, ...nightShifts]
            ..sort((a, b) => a.shiftType.compareTo(b.shiftType));
        }

        return FutureBuilder<List<Shift>>(
          future: loadShifts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allShifts = snapshot.data ?? [];

            var shifts = allShifts;

            if (_filterStore != 'ALL') {
              final storeId = int.parse(_filterStore);
              shifts = shifts.where((s) => s.storeId == storeId).toList();
            }

            if (_filterType != 'ALL') {
              shifts = shifts.where((s) => s.shiftType == _filterType).toList();
            }

            if (shifts.isEmpty) {
              return const Center(child: Text('Смены не найдены на эту дату'));
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: shifts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final shift = shifts[index];
                final store = stores.firstWhere(
                  (s) => s.id == shift.storeId,
                  orElse: () => Store(
                    id: shift.storeId,
                    name: 'Unknown',
                    address: '',
                    metro: '',
                    markerColor: 'Белый',
                    isActive: true,
                  ),
                );

                return ShiftCard(
                  shift: shift,
                  storeName: store.name,
                  onAssignEmployees: () => _assignEmployees(context, shift),
                  onDelete: () => _deleteShift(context, shift),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _createDayShifts() async {
    final controller = context.read<ShiftController>();
    final stores = context.read<StoreController>().stores;
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final currentUserId = context.read<AuthProvider>().currentEmployee?.id ?? 1;

    for (final store in stores) {
      final dayShifts = await controller.shiftRepository
          .getShiftsByStoreDateAndType(store.id!, dateString, AppShifts.day);
      if (dayShifts.isEmpty) {
        await controller.createShift(
          Shift(
            storeId: store.id!,
            date: dateString,
            shiftType: AppShifts.day,
            startTime: '10:00',
            endTime: '22:00',
          ),
          currentUserId,
        );
      }
    }
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Дневные смены созданы')));
    }
  }

  Future<void> _createNightShifts() async {
    final controller = context.read<ShiftController>();
    final stores = context.read<StoreController>().stores;
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final currentUserId = context.read<AuthProvider>().currentEmployee?.id ?? 1;

    for (final store in stores) {
      final nightShifts = await controller.shiftRepository
          .getShiftsByStoreDateAndType(store.id!, dateString, AppShifts.night);
      if (nightShifts.isEmpty) {
        await controller.createShift(
          Shift(
            storeId: store.id!,
            date: dateString,
            shiftType: AppShifts.night,
            startTime: '22:00',
            endTime: '10:00',
          ),
          currentUserId,
        );
      }
    }
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ночные смены созданы')));
    }
  }

  Future<void> _assignEmployees(BuildContext context, Shift shift) async {
    final allEmployees = await context
        .read<EmployeeController>()
        .getAllEmployees();
    final assignedRepo = ShiftEmployeeRepository();
    final assigned = await assignedRepo.getByShift(shift.id!);
    final assignedIds = assigned.map((e) => e.employeeId).toSet();

    final selectedIds = <int>{};
    for (final id in assignedIds) {
      selectedIds.add(id);
    }

    final result = await showDialog<Map<int, bool>>(
      context: context,
      builder: (_) => AssignEmployeesDialog(
        employees: allEmployees,
        selectedIds: selectedIds,
      ),
    );

    if (result != null && mounted) {
      final controller = context.read<ShiftController>();
      final toAssign = result.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
      final currentUserId =
          context.read<AuthProvider>().currentEmployee?.id ?? 1;
      await controller.assignEmployees(shift.id!, toAssign, currentUserId);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Сотрудники назначены')));
      }
    }
  }

  Future<void> _deleteShift(BuildContext context, Shift shift) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить смену'),
        content: const Text('Вы уверены, что хотите удалить эту смену?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final controller = context.read<ShiftController>();
      await controller.shiftRepository.deleteShift(shift.id!);
      await controller.shiftEmployeeRepository.deleteByShift(shift.id!);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Смена удалена')));
      }
    }
  }
}

class ShiftCard extends StatelessWidget {
  final Shift shift;
  final String storeName;
  final VoidCallback onAssignEmployees;
  final VoidCallback onDelete;

  const ShiftCard({
    super.key,
    required this.shift,
    required this.storeName,
    required this.onAssignEmployees,
    required this.onDelete,
  });

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${parts[2]}.${parts[1]}.${parts[0]}';
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final isDay = shift.shiftType == AppShifts.day;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDay
                        ? const Color(0xFFFFF3CD)
                        : const Color(0xFFD1ECF1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isDay ? 'Дневная' : 'Ночная',
                    style: TextStyle(
                      color: isDay ? Colors.orange[800] : Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              storeName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_formatDate(shift.date)} ${shift.startTime}-${shift.endTime}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: PopupMenuButton(
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'assign',
                              child: Row(
                                children: [
                                  Icon(Icons.person_add, size: 18),
                                  SizedBox(width: 8),
                                  Text('Назначить сотрудников'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Удалить',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'assign') onAssignEmployees();
                            if (value == 'delete') onDelete();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<ShiftEmployee>>(
              future: ShiftEmployeeRepository().getByShift(shift.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Сотрудники не назначены');
                }
                final employees = snapshot.data!;
                if (employees.isEmpty) {
                  return const Text('Сотрудники не назначены');
                }
                return Consumer<EmployeeController>(
                  builder: (context, empController, _) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: employees.map((se) {
                        final emp = empController.employees.firstWhere(
                          (e) => e.id == se.employeeId,
                          orElse: () => Employee(
                            id: se.employeeId,
                            lastName: 'Сотр.',
                            firstName: se.employeeId.toString(),
                            middleName: '',
                            login: '',
                            password: '',
                            storeIds: [],
                            role: 'EMPLOYEE',
                            isActive: true,
                          ),
                        );
                        return Chip(
                          label: Text(emp.fullName),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AssignEmployeesDialog extends StatefulWidget {
  final List<Employee> employees;
  final Set<int> selectedIds;

  const AssignEmployeesDialog({
    super.key,
    required this.employees,
    required this.selectedIds,
  });

  @override
  State<AssignEmployeesDialog> createState() => _AssignEmployeesDialogState();
}

class _AssignEmployeesDialogState extends State<AssignEmployeesDialog> {
  late Map<int, bool> _selection;

  @override
  void initState() {
    super.initState();
    _selection = {};
    for (final emp in widget.employees) {
      _selection[emp.id!] = widget.selectedIds.contains(emp.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Назначить сотрудников'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: widget.employees.isEmpty
            ? const Text('Нет доступных сотрудников')
            : ListView(
                children: widget.employees.map((emp) {
                  return CheckboxListTile(
                    value: _selection[emp.id] ?? false,
                    onChanged: (v) => setState(() {
                      _selection[emp.id!] = v ?? false;
                    }),
                    title: Text(emp.fullName),
                    subtitle: Text(emp.login),
                  );
                }).toList(),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _selection);
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
