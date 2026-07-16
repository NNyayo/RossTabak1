import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../providers/auth_provider.dart';

class EmployeeProfileScreen extends StatelessWidget {
  const EmployeeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final employee = provider.currentEmployee;

    if (employee == null) {
      return const Center(child: Text('Не удалось загрузить данные'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.blue.withValues(alpha: 0.15),
                          child: Text(
                            employee.firstName.isNotEmpty
                                ? employee.firstName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 24,
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                employee.login,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _ProfileRow(
                      icon: Icons.badge,
                      label: 'Роль',
                      value: _getRoleLabel(employee.role),
                    ),
                    const SizedBox(height: 12),
                    _ProfileRow(
                      icon: Icons.store,
                      label: 'Точки',
                      value: employee.storeIds.isEmpty
                          ? 'Не назначены'
                          : employee.storeIds.map((id) => '#$id').join(', '),
                    ),
                    const SizedBox(height: 12),
                    _ProfileRow(
                      icon: Icons.calendar_today,
                      label: 'В системе с',
                      value: employee.createdAt != null
                          ? employee.createdAt!
                          : 'Неизвестно',
                    ),
                    const SizedBox(height: 12),
                    _ProfileRow(
                      icon: employee.isActive
                          ? Icons.check_circle
                          : Icons.cancel,
                      label: 'Статус',
                      value: employee.isActive ? 'Активен' : 'Уволен',
                      valueColor: employee.isActive ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Выйти из аккаунта',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
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
    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
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
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
