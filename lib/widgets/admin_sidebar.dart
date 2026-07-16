import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/notification_controller.dart';
import '../providers/theme_provider.dart';

class AdminSidebar extends StatelessWidget {
  final String selectedRoute;

  const AdminSidebar({super.key, required this.selectedRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Row(
              children: [
                const Text('Админ', style: TextStyle(fontSize: 18)),
                const Spacer(),
                Consumer<ThemeProvider>(
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
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Главная'),
            selected: selectedRoute == '/admin',
            onTap: () => context.go('/admin'),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Сотрудники'),
            selected: selectedRoute == '/admin/employees',
            onTap: () => context.go('/admin/employees'),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Магазины'),
            selected: selectedRoute == '/admin/stores',
            onTap: () => context.go('/admin/stores'),
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text('Задачи'),
            selected: selectedRoute == '/admin/tasks',
            onTap: () => context.go('/admin/tasks'),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Смены'),
            selected: selectedRoute == '/admin/shifts',
            onTap: () => context.go('/admin/shifts'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Статистика'),
            selected: selectedRoute == '/admin/statistics',
            onTap: () => context.go('/admin/statistics'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('История'),
            selected: selectedRoute == '/admin/history',
            onTap: () => context.go('/admin/history'),
          ),
          Consumer<NotificationController>(
            builder: (context, controller, _) {
              return ListTile(
                leading: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (controller.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            controller.unreadCount > 9
                                ? '9+'
                                : controller.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                title: const Text('Уведомления'),
                selected: selectedRoute == '/admin/notifications',
                onTap: () => context.go('/admin/notifications'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Поиск'),
            selected: selectedRoute == '/admin/search',
            onTap: () => context.go('/admin/search'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Настройки'),
            selected: selectedRoute == '/settings',
            onTap: () => context.go('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Выход'),
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
