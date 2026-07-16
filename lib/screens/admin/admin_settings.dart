import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../controllers/employee_controller.dart';
import '../../models/employee.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/backup_service.dart';
import 'admin_base_page.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _adminNameCtrl = TextEditingController();
  final _adminLoginCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = context.read<AuthProvider>().currentEmployee;
    if (user != null) {
      setState(() {
        _adminNameCtrl.text = user.fullName;
        _adminLoginCtrl.text = user.login;
      });
    }
  }

  @override
  void dispose() {
    _adminNameCtrl.dispose();
    _adminLoginCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/settings',
      title: 'Настройки',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildPasswordCard(),
            const SizedBox(height: 16),
            _buildBackupCard(),
            const SizedBox(height: 16),
            _buildSystemCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Профиль',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('ФИО:'),
            TextField(
              controller: _adminNameCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const Text('Логин:'),
            TextField(
              controller: _adminLoginCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveProfile,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Смена пароля',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Новый пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _changePassword,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock),
              label: const Text('Изменить пароль'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final nameText = _adminNameCtrl.text.trim();
    final loginText = _adminLoginCtrl.text.trim();

    if (nameText.isEmpty || loginText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AuthProvider>();
      final employeeController = context.read<EmployeeController>();
      final currentUser = provider.currentEmployee;

      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пользователь не найден')),
          );
        }
        return;
      }

      final parts = nameText.split(' ');
      final lastName = parts.isNotEmpty ? parts[0] : currentUser.lastName;
      final firstName = parts.length > 1 ? parts[1] : currentUser.firstName;
      final middleName = parts.length > 2
          ? parts.sublist(2).join(' ')
          : currentUser.middleName;

      final updated = Employee(
        id: currentUser.id,
        lastName: lastName,
        firstName: firstName,
        middleName: middleName,
        login: loginText,
        password: currentUser.password,
        storeIds: currentUser.storeIds,
        role: currentUser.role,
        isActive: currentUser.isActive,
        createdAt: currentUser.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await employeeController.updateEmployee(updated);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    final newPassword = _newPasswordCtrl.text.trim();
    if (newPassword.isEmpty || newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль должен быть не менее 6 символов')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AuthProvider>();
      final employeeController = context.read<EmployeeController>();
      final userId = provider.currentEmployee?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пользователь не найден')),
          );
        }
        return;
      }

      await employeeController.changePassword(userId, newPassword);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Пароль изменён')));
        _newPasswordCtrl.clear();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSystemCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Системные настройки',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return SwitchListTile(
                  title: const Text('Тёмная тема'),
                  subtitle: Text(
                    themeProvider.isDarkMode ? 'Включена' : 'Выключена',
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выйти из аккаунта'),
              onTap: _logout,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('О приложении'),
              subtitle: const Text('RossTabak Manager v1.0.0'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Резервное копирование',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _createBackup,
              icon: const Icon(Icons.backup),
              label: const Text('Создать резервную копию'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _restoreBackup,
              icon: const Icon(Icons.restore),
              label: const Text('Восстановить из копии'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      final path = await BackupService.instance.createBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Резервная копия создана: $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _restoreBackup() async {
    try {
      final backups = await BackupService.instance.listBackups();
      if (backups.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Нет резервных копий')));
        }
        return;
      }

      final selected = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Восстановить из копии'),
          content: SizedBox(
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (_, i) {
                final name = backups[i].split('/').last;
                return ListTile(
                  title: Text(name),
                  onTap: () => Navigator.pop(context, backups[i]),
                );
              },
            ),
          ),
        ),
      );

      if (selected != null && mounted) {
        await BackupService.instance.restoreFromFile(selected);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('База восстановлена. Перезапустите приложение.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
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
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}
