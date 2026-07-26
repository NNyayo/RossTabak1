import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/system_log_controller.dart';
import '../../models/system_log.dart';
import 'admin_base_page.dart';

class AdminHistoryPage extends StatefulWidget {
  const AdminHistoryPage({super.key});

  @override
  State<AdminHistoryPage> createState() => _AdminHistoryPageState();
}

class _AdminHistoryPageState extends State<AdminHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemLogController>().loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/history',
      title: 'История действий',
      child: Consumer<SystemLogController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.logs.isEmpty) {
            return const Center(child: Text('История действий пуста'));
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final log = controller.logs[index];
              return _LogCard(log: log);
            },
          );
        },
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final SystemLog log;

  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon(log.action);
    final color = _getColor(log.action);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          _getActionLabel(log.action),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log.description != null && log.description!.isNotEmpty)
              Text(log.description!, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(log.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        dense: true,
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateTime;
    }
  }

  IconData _getIcon(String action) {
    switch (action) {
      case 'CREATE_TASK':
      case 'TASK_CREATED':
        return Icons.task_alt;
      case 'DELETE_TASK':
      case 'TASK_DELETED':
        return Icons.delete_outline;
      case 'COMPLETE_TASK':
      case 'TASK_COMPLETED':
        return Icons.check_circle;
      case 'CREATE_EMPLOYEE':
        return Icons.person_add;
      case 'DELETE_EMPLOYEE':
        return Icons.person_remove;
      case 'CREATE_SHIFT':
        return Icons.access_time;
      case 'DELETE_SHIFT':
        return Icons.delete_sweep;
      case 'CHANGE_PASSWORD':
        return Icons.lock;
      case 'LOGIN':
        return Icons.login;
      case 'LOGOUT':
        return Icons.logout;
      default:
        return Icons.info;
    }
  }

  Color _getColor(String action) {
    if (action.contains('CREATE') || action.contains('CREATED')) {
      return Colors.green;
    }
    if (action.contains('DELETE') || action.contains('DELETED')) {
      return Colors.red;
    }
    if (action.contains('COMPLETE') || action.contains('COMPLETED')) {
      return Colors.green;
    }
    if (action.contains('LOGIN')) {
      return Colors.blue;
    }
    if (action.contains('LOGOUT')) {
      return Colors.orange;
    }
    if (action.contains('CHANGE') || action.contains('PASSWORD')) {
      return Colors.purple;
    }
    return Colors.grey;
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'CREATE_TASK':
        return 'Создание задачи';
      case 'TASK_CREATED':
        return 'Задача создана';
      case 'DELETE_TASK':
        return 'Удаление задачи';
      case 'TASK_DELETED':
        return 'Задача удалена';
      case 'COMPLETE_TASK':
        return 'Завершение задачи';
      case 'TASK_COMPLETED':
        return 'Задача завершена';
      case 'CREATE_EMPLOYEE':
        return 'Создание сотрудника';
      case 'DELETE_EMPLOYEE':
        return 'Удаление сотрудника';
      case 'CREATE_SHIFT':
        return 'Создание смены';
      case 'DELETE_SHIFT':
        return 'Удаление смены';
      case 'CHANGE_PASSWORD':
        return 'Смена пароля';
      case 'LOGIN':
        return 'Вход в систему';
      case 'LOGOUT':
        return 'Выход из системы';
      default:
        return action;
    }
  }
}
