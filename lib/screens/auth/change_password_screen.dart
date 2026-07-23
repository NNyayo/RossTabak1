import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/password_hash.dart';
import '../../controllers/employee_controller.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int? employeeId;

  const ChangePasswordScreen({super.key, this.employeeId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _currentError;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _currentError = null;
      _newError = null;
      _confirmError = null;
    });

    bool isValid = true;

    if (currentPasswordController.text.trim().isEmpty) {
      setState(() => _currentError = 'Введите текущий пароль');
      isValid = false;
    }

    if (newPasswordController.text.isEmpty) {
      setState(() => _newError = 'Введите новый пароль');
      isValid = false;
    } else if (newPasswordController.text.length < 6) {
      setState(() => _newError = 'Пароль должен быть не менее 6 символов');
      isValid = false;
    }

    if (confirmPasswordController.text.isEmpty) {
      setState(() => _confirmError = 'Подтвердите новый пароль');
      isValid = false;
    } else if (confirmPasswordController.text != newPasswordController.text) {
      setState(() => _confirmError = 'Пароли не совпадают');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final provider = context.read<AuthProvider>();
    final employeeId = widget.employeeId ?? provider.currentEmployee?.id;

    if (employeeId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось определить пользователя')),
      );
      return;
    }

    final employeeController = context.read<EmployeeController>();

    final employee = await employeeController.getEmployeeById(employeeId);
    if (employee == null ||
        !PasswordHasher.verify(
          currentPasswordController.text.trim(),
          employee.password,
        )) {
      setState(() => _currentError = 'Неверный текущий пароль');
      return;
    }

    try {
      await employeeController.changePassword(
        employeeId,
        newPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Пароль успешно изменён')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChangingForOther = widget.employeeId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isChangingForOther ? 'Изменить пароль' : 'Изменить пароль'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isChangingForOther) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Вы меняете пароль для сотрудника',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_currentError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _currentError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            if (!isChangingForOther) ...[
              TextField(
                controller: currentPasswordController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Текущий пароль',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_newError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _newError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            TextField(
              controller: newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_confirmError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _confirmError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            TextField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 30),
            AppButton(text: 'Сохранить', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
