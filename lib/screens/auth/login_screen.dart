import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../controllers/notification_controller.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isHoveringForgot = false;
  bool _obscurePassword = true;

  // Ограничитель: только английский, цифры и спецсимволы
  final _asciiInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'''[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};'\|,.<>\/?`~ ]'''),
  );

  Future<void> _submit() async {
    final provider = context.read<AuthProvider>();
    final success = await provider.signIn(
      loginController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final role = provider.currentEmployee?.role ?? 'EMPLOYEE';
      if (role == 'ADMIN') {
        // Загружаем уведомления для админа
        final employeeId = provider.currentEmployee?.id ?? 1;
        context.read<NotificationController>().load(employeeId);
        context.go(AppRoutes.admin);
        return;
      }
      context.go(AppRoutes.employee);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // 1.4 Кнопка переключения темы в правом верхнем углу
          Positioned(
            top: 16,
            right: 16,
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: themeProvider.isDarkMode
                        ? Colors.amber
                        : Colors.grey[700],
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip: themeProvider.isDarkMode
                      ? 'Светлая тема'
                      : 'Тёмная тема',
                );
              },
            ),
          ),
          Center(
            child: SizedBox(
              width: 420,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'РОССТАБАК',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 1.2 Изменено: "Система управления" → "Авторизация"
                        Text(
                          'Авторизация',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 30),
                        AppTextField(
                          controller: loginController,
                          label: 'Логин',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9_.@-]'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: passwordController,
                          label: 'Пароль',
                          obscureText: _obscurePassword,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                r'''[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};'\|,.<>\/?`~ ]''',
                              ),
                            ),
                          ],
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (provider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        AppButton(
                          text: 'Войти',
                          isLoading: provider.isLoading,
                          onPressed: provider.isLoading ? null : _submit,
                        ),
                        const SizedBox(height: 16),
                        // 1.1 Кнопка "Забыли пароль?" с hover-эффектом
                        MouseRegion(
                          onEnter: (_) =>
                              setState(() => _isHoveringForgot = true),
                          onExit: (_) =>
                              setState(() => _isHoveringForgot = false),
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: _isHoveringForgot
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    color: _isHoveringForgot
                                        ? Colors.red
                                        : Colors.grey.withValues(alpha: 0.7),
                                    fontSize: 14,
                                    decoration: _isHoveringForgot
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                  child: const Text('Забыли пароль?'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 1.3 Надпись внизу
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'The program was created by YAYO',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 1.1 Экран "Забыли пароль?" с контактами техподдержки
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Помощь'),
        leading: Padding(
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Связаться с администратором',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(Icons.phone, color: Colors.blue),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Телефон техподдержки:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '+79095622924',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.telegram, color: Colors.blue),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Telegram:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '@o_bustylova',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.email, color: Colors.blue),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email:', style: TextStyle(color: Colors.grey)),
                          Text(
                            'rosstabakk@gmail.com',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
}
