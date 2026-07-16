import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/notification_controller.dart';
import '../../models/notification.dart';
import '../../providers/auth_provider.dart';
import 'admin_base_page.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employeeId = context.read<AuthProvider>().currentEmployee?.id ?? 1;
      context.read<NotificationController>().load(employeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/notifications',
      title: 'Уведомления',
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  final employeeId =
                      context.read<AuthProvider>().currentEmployee?.id ?? 1;
                  context.read<NotificationController>().markAllAsRead(
                    employeeId,
                  );
                },
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text('Прочитать все'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<NotificationController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.notifications.isEmpty) {
                  return const Center(child: Text('Нет уведомлений'));
                }
                return ListView.separated(
                  itemCount: controller.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];
                    return _NotificationCard(
                      notification: notification,
                      onTap: () => controller.markAsRead(notification.id!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon(notification.type);
    final color = _getColor(notification.type);

    // Форматируем сообщение для отображения
    String displayMessage = notification.message ?? '';
    if (notification.type == 'TASK_COMPLETED') {
      // Сообщение уже содержит имя сотрудника (в новых версиях)
      // Для обратной совместимости заменяем "Сотрудник #N" на имя, если возможно
      // Ничего не делаем - сообщение уже корректное
    }

    return Card(
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? null : color.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: displayMessage.isNotEmpty
            ? Text(displayMessage, maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        trailing: notification.isRead
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: onTap,
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'TASK_COMPLETED':
        return Icons.check_circle;
      case 'OVERDUE_TASK':
        return Icons.warning;
      case 'NEW_TASK':
        return Icons.task_alt;
      case 'SHIFT_REMINDER':
        return Icons.access_time;
      case 'UNCLOSED_SHIFT':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'TASK_COMPLETED':
        return Colors.green;
      case 'OVERDUE_TASK':
        return Colors.red;
      case 'NEW_TASK':
        return Colors.blue;
      case 'SHIFT_REMINDER':
        return Colors.orange;
      case 'UNCLOSED_SHIFT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
