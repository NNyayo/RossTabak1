import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          _buildAppInfoCard(),
          const SizedBox(height: 16),
          _buildProfileCard(),
          const SizedBox(height: 16),
          _buildPasswordCard(),
          const SizedBox(height: 16),
          _buildBackupCard(),
        ],
      ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'О приложении',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business_center,
                    size: 32,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RossTabak Manager',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                         'Версия 1.0.1',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Сборка 2026.07.26',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAboutDialog(context),
              icon: const Icon(Icons.info_outline),
              label: const Text('О программе'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                foregroundColor: Colors.blue,
              ),
            ),
            const Divider(height: 32),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ThemeOption(
                      icon: Icons.light_mode,
                      label: 'Светлая',
                      isSelected: !themeProvider.isDarkMode,
                      onTap: () {
                        if (themeProvider.isDarkMode) {
                          themeProvider.toggleTheme();
                        }
                      },
                    ),
                    _ThemeOption(
                      icon: Icons.dark_mode,
                      label: 'Тёмная',
                      isSelected: themeProvider.isDarkMode,
                      onTap: () {
                        if (!themeProvider.isDarkMode) {
                          themeProvider.toggleTheme();
                        }
                      },
                    ),
                    _ThemeOption(
                      icon: Icons.auto_mode,
                      label: 'Системная',
                      isSelected: false,
                      onTap: () {},
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('О приложении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.business_center,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RossTabak Manager',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                         'Версия 1.0.1',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Управление задачами и сотрудниками',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Дата сборки: 26.07.2026',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Разработчик: YAYO',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
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
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.blue : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
