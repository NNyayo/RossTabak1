import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/store_controller.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task.dart';
import '../../../providers/auth_provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final task = taskController.tasks.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => Task(
        id: widget.taskId,
        title: 'Задача #${widget.taskId}',
        status: 'NEW',
        createdBy: 0,
      ),
    );

    final isPriority = task.priority != null && task.priority!.isNotEmpty;
    final isCompleted = task.status == 'COMPLETED';
    final isInProgress = task.status == 'IN_PROGRESS';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(task.title),
        actions: [
          if (isPriority)
            const Tooltip(
              message: 'Приоритетная задача',
              child: Icon(Icons.star, color: Colors.amber),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приоритетная метка
            if (isPriority)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Приоритетная задача',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Название
            _buildInfoSection(
              label: 'Название',
              value: task.title,
              isBold: true,
              fontSize: 18,
            ),
            const SizedBox(height: 16),

            // Описание
            if (task.description != null && task.description!.isNotEmpty)
              _buildInfoSection(label: 'Описание', value: task.description!),

            // Категория
            if (task.category != null && task.category!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoSection(label: 'Категория', value: task.category!),
            ],

            // Срок
            if (task.deadline != null && task.deadline!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoSection(
                label: 'Срок выполнения',
                value: task.deadline!,
                prefixIcon: Icons.schedule,
                iconColor: isInProgress ? Colors.orange : null,
                valueColor: isInProgress ? Colors.orange : null,
              ),
            ],

            // Статус
            if (task.status.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Статус',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusChip(task.status),
              const SizedBox(height: 24),
            ],

            // Кнопка выполнения
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isCompleting ? null : _completeTask,
                  icon: _isCompleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 20),
                  label: const Text(
                    'ЗАДАЧА ВЫПОЛНЕНА',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Комментарии
            const Text(
              'Комментарии',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _CommentBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String label,
    required String value,
    bool isBold = false,
    double fontSize = 15,
    IconData? prefixIcon,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        if (prefixIcon != null)
          Row(
            children: [
              Icon(prefixIcon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'COMPLETED':
        color = Colors.green;
        label = 'Выполнено';
        break;
      case 'IN_PROGRESS':
        color = Colors.blue;
        label = 'В работе';
        break;
      default:
        color = Colors.orange;
        label = 'Новая';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _completeTask() async {
    setState(() => _isCompleting = true);

    try {
      final taskController = context.read<TaskController>();
      final task = taskController.tasks.firstWhere(
        (t) => t.id == widget.taskId,
        orElse: () => Task(
          id: widget.taskId,
          title: 'Задача #${widget.taskId}',
          status: 'NEW',
          createdBy: 0,
        ),
      );

      final employee = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).currentEmployee;
      if (employee == null) return;

      String? employeeFullName;
      if (employee.firstName.isNotEmpty) {
        employeeFullName = employee.fullName.trim();
      }

      // Get store name if the task has a store
      String? storeName;
      if (task.storeId != null && task.storeId! > 0) {
        try {
          final storeController = Provider.of<StoreController>(
            context,
            listen: false,
          );
          final store = storeController.stores.firstWhere(
            (s) => s.id == task.storeId,
          );
          storeName = store.name;
        } catch (_) {}
      }

      await taskController.completeTask(
        task.id!,
        employee.id!,
        employeeFullName: employeeFullName,
        storeName: storeName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Задача выполнена!'),
            backgroundColor: Colors.green,
          ),
        );
        // Возвращаемся назад к списку задач
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }
}

class _CommentBox extends StatefulWidget {
  const _CommentBox();

  @override
  State<_CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<_CommentBox> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Комментарий',
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            final txt = _controller.text.trim();
            if (txt.isEmpty) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Комментарий отправлен')),
            );
            _controller.clear();
          },
          child: const Text('ОТПРАВИТЬ'),
        ),
      ],
    );
  }
}
