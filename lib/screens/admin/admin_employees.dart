import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/employee_controller.dart';
import '../../controllers/store_controller.dart';
import '../../models/employee.dart';
import '../../utils/marker_color.dart';
import '../../widgets/app_button.dart';
import '../auth/change_password_screen.dart';
import 'admin_base_page.dart';

class AdminEmployeesPage extends StatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  State<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends State<AdminEmployeesPage> {
  final _searchController = TextEditingController();
  String _filterRole = 'ALL';

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/employees',
      title: 'Сотрудники',
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 12),
          Expanded(child: _buildEmployeeList()),
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
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Поиск по ФИО или логину',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: (_) => _loadData(),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: ElevatedButton.icon(
                onPressed: () => _addEmployee(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Добавить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    final controller = context.read<EmployeeController>();
    await controller.loadEmployees();
  }

  Widget _buildEmployeeList() {
    return Consumer<EmployeeController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var employees = controller.employees;

        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          employees = employees.where((e) {
            final fullName = e.fullName.toLowerCase();
            final login = e.login.toLowerCase();
            return fullName.contains(query) || login.contains(query);
          }).toList();
        }

        if (_filterRole != 'ALL') {
          employees = employees.where((e) => e.role == _filterRole).toList();
        }

        if (employees.isEmpty) {
          return const Center(child: Text('Сотрудники не найдены'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: employees.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final employee = employees[index];
            return _EmployeeCard(
              employee: employee,
              onChangePassword: () => _changePassword(context, employee),
              onDelete: () => _deleteEmployee(context, employee),
              onEdit: () => _editEmployee(context, employee),
            );
          },
        );
      },
    );
  }

  Future<void> _changePassword(BuildContext context, Employee employee) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(employeeId: employee.id),
      ),
    );
    _loadData();
  }

  Future<void> _deleteEmployee(BuildContext context, Employee employee) async {
    // 4.1 Проверка: нельзя удалить менеджера
    if (employee.role == 'MANAGER') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Нельзя удалить менеджера. Сначала измените роль сотрудника.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить сотрудника'),
        content: Text('Вы уверены, что хотите уволить "${employee.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Уволить'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final scaffoldContext = context;
        final controller = scaffoldContext.read<EmployeeController>();
        await controller.deleteEmployee(employee.id!);
        if (mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(content: Text('${employee.fullName} уволен(а)')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при удалении: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editEmployee(BuildContext context, Employee employee) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditEmployeeScreen(employee: employee)),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _addEmployee(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }
}

class _EmployeeCard extends StatefulWidget {
  final Employee employee;
  final VoidCallback onChangePassword;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _EmployeeCard({
    required this.employee,
    required this.onChangePassword,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<_EmployeeCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(widget.employee.role);
    final roleLabel = _getRoleLabel(widget.employee.role);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Card(
          elevation: _isHovering ? 8 : 2,
          shadowColor: roleColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: roleColor.withValues(alpha: _isHovering ? 0.4 : 0.1),
              width: _isHovering ? 2 : 1,
            ),
          ),
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedScale(
                        scale: _isHovering ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: roleColor.withValues(alpha: 0.15),
                          child: Text(
                            widget.employee.lastName.isNotEmpty
                                ? widget.employee.lastName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.employee.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.employee.login,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: roleColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          roleLabel,
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.store, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Точки работы: ${widget.employee.storeIds.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.employee.storeIds.map((storeId) {
                      return _StoreDot(storeId: storeId);
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedOpacity(
                        opacity: _isHovering ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 200),
                        child: TextButton.icon(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Редактировать'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedOpacity(
                        opacity: _isHovering ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 200),
                        child: TextButton.icon(
                          onPressed: widget.onChangePassword,
                          icon: const Icon(Icons.lock, size: 18),
                          label: const Text('Сменить пароль'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedOpacity(
                        opacity: _isHovering ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 200),
                        child: TextButton.icon(
                          onPressed: widget.onDelete,
                          icon: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Уволить',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        return 'Админ';
      case 'MANAGER':
        return 'Менеджер';
      default:
        return 'Сотрудник';
    }
  }
}

class _StoreDot extends StatelessWidget {
  final int storeId;

  const _StoreDot({required this.storeId});

  @override
  Widget build(BuildContext context) {
    // 4.2 Получаем цвет из реального цвета маркера магазина
    final stores = context.watch<StoreController>().stores;
    final store = stores.where((s) => s.id == storeId).firstOrNull;
    final color = store != null
        ? getMarkerColorForDot(store.markerColor)
        : Colors.grey;

    return Tooltip(
      message: store?.name ?? 'Точка #$storeId',
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'EMPLOYEE';
  final Set<int> _selectedStoreIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _lastNameCtrl.text = widget.employee.lastName;
    _firstNameCtrl.text = widget.employee.firstName;
    _middleNameCtrl.text = widget.employee.middleName;
    _loginCtrl.text = widget.employee.login;
    _role = widget.employee.role;
    _selectedStoreIds.addAll(widget.employee.storeIds);
  }

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_lastNameCtrl.text.trim().isEmpty ||
        _firstNameCtrl.text.trim().isEmpty ||
        _loginCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните обязательные поля')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now().toIso8601String();
      final employee = Employee(
        id: widget.employee.id,
        lastName: _lastNameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        middleName: _middleNameCtrl.text.trim(),
        login: _loginCtrl.text.trim(),
        password: widget.employee.password,
        storeIds: _selectedStoreIds.toList(),
        role: _role,
        isActive: widget.employee.isActive,
        createdAt: widget.employee.createdAt,
        updatedAt: now,
      );

      final controller = context.read<EmployeeController>();
      await controller.updateEmployee(employee);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Сотрудник обновлён')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать сотрудника')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _lastNameCtrl,
              decoration: const InputDecoration(labelText: 'Фамилия *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstNameCtrl,
              decoration: const InputDecoration(labelText: 'Имя *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _middleNameCtrl,
              decoration: const InputDecoration(labelText: 'Отчество'),
            ),
            const SizedBox(height: 12),
            // 4.4 Логин только на английском
            TextField(
              controller: _loginCtrl,
              decoration: const InputDecoration(
                labelText: 'Логин * (только латиница)',
              ),
              onChanged: (value) {
                final filtered = value.replaceAll(
                  RegExp(r'[^a-zA-Z0-9_.@-]'),
                  '',
                );
                if (filtered != value) {
                  _loginCtrl.value = TextEditingValue(
                    text: filtered,
                    selection: TextSelection.collapsed(offset: filtered.length),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Новый пароль (оставьте пустым без изменений)',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Роль'),
              items: const [
                DropdownMenuItem(value: 'ADMIN', child: Text('Администратор')),
                DropdownMenuItem(value: 'MANAGER', child: Text('Менеджер')),
                DropdownMenuItem(value: 'EMPLOYEE', child: Text('Сотрудник')),
              ],
              onChanged: (value) => setState(() => _role = value!),
            ),
            const SizedBox(height: 20),
            const Text(
              'Точки работы:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildStoreCheckboxes(context),
            const SizedBox(height: 24),
            AppButton(
              text: 'Сохранить',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStoreCheckboxes(BuildContext context) {
    final stores = context.read<StoreController>().stores;

    if (stores.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Нет доступных точек. Добавьте точки в разделе "Торговые точки".',
          ),
        ),
      ];
    }

    return stores.map((store) {
      final id = store.id!;
      final selected = _selectedStoreIds.contains(id);

      return CheckboxListTile(
        value: selected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedStoreIds.add(id);
            } else {
              _selectedStoreIds.remove(id);
            }
          });
        },
        title: Text(store.name),
        subtitle: Text(store.address),
        secondary: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _getMarkerColor(store.markerColor),
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();
  }

  Color _getMarkerColor(String colorName) {
    return getMarkerColorForDot(colorName);
  }
}

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'EMPLOYEE';
  final Set<int> _selectedStoreIds = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_lastNameCtrl.text.trim().isEmpty ||
        _firstNameCtrl.text.trim().isEmpty ||
        _loginCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните обязательные поля')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now().toIso8601String();
      final employee = Employee(
        lastName: _lastNameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        middleName: _middleNameCtrl.text.trim(),
        login: _loginCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        storeIds: _selectedStoreIds.toList(),
        role: _role,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final controller = context.read<EmployeeController>();
      await controller.createEmployee(employee);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Сотрудник добавлен')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить сотрудника')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _lastNameCtrl,
              decoration: const InputDecoration(labelText: 'Фамилия *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstNameCtrl,
              decoration: const InputDecoration(labelText: 'Имя *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _middleNameCtrl,
              decoration: const InputDecoration(labelText: 'Отчество'),
            ),
            const SizedBox(height: 12),
            // 4.4 Логин и пароль только на английском
            TextField(
              controller: _loginCtrl,
              decoration: const InputDecoration(
                labelText: 'Логин * (только латиница)',
              ),
              onChanged: (value) {
                final filtered = value.replaceAll(
                  RegExp(r'[^a-zA-Z0-9_.@-]'),
                  '',
                );
                if (filtered != value) {
                  _loginCtrl.value = TextEditingValue(
                    text: filtered,
                    selection: TextSelection.collapsed(offset: filtered.length),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль * (только латиница)',
              ),
              onChanged: (value) {
                final filtered = value.replaceAll(
                  RegExp(r'[^a-zA-Z0-9!@#\$%^&*()_+=-]'),
                  '',
                );
                if (filtered != value) {
                  _passwordCtrl.value = TextEditingValue(
                    text: filtered,
                    selection: TextSelection.collapsed(offset: filtered.length),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Роль'),
              items: const [
                DropdownMenuItem(value: 'ADMIN', child: Text('Администратор')),
                DropdownMenuItem(value: 'MANAGER', child: Text('Менеджер')),
                DropdownMenuItem(value: 'EMPLOYEE', child: Text('Сотрудник')),
              ],
              onChanged: (value) => setState(() => _role = value!),
            ),
            const SizedBox(height: 20),
            const Text(
              'Точки работы:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildStoreCheckboxes(context),
            const SizedBox(height: 24),
            AppButton(
              text: 'Добавить',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStoreCheckboxes(BuildContext context) {
    final stores = context.read<StoreController>().stores;

    if (stores.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Нет доступных точек. Добавьте точки в разделе "Торговые точки".',
          ),
        ),
      ];
    }

    return stores.map((store) {
      final id = store.id!;
      final selected = _selectedStoreIds.contains(id);

      return CheckboxListTile(
        value: selected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedStoreIds.add(id);
            } else {
              _selectedStoreIds.remove(id);
            }
          });
        },
        title: Text(store.name),
        subtitle: Text(store.address),
        secondary: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _getMarkerColor(store.markerColor),
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();
  }

  Color _getMarkerColor(String colorName) {
    return getMarkerColorForDot(colorName);
  }
}
