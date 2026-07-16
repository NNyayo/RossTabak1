import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../controllers/task_controller.dart';
import '../../../widgets/animated_list_items.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    // Показываем только невыполненные задачи
    final tasks = taskController.tasks
        .where((t) => t.status != 'COMPLETED')
        .toList();

    return Column(
      children: [
        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Нет активных задач',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isPriority =
                    task.priority != null && task.priority!.isNotEmpty;

                return AnimatedSlideItem(
                  index: index,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isPriority
                          ? const BorderSide(color: Colors.amber, width: 2)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.orange.withValues(
                              alpha: 0.15,
                            ),
                            child: const Icon(
                              Icons.check_box_outline_blank,
                              color: Colors.orange,
                              size: 18,
                            ),
                          ),
                          if (isPriority)
                            const Positioned(
                              top: -2,
                              right: -2,
                              child: Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: isPriority
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(task.category ?? 'Без категории'),
                          if (isPriority) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Приоритет',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.amber[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Открыть'),
                        onPressed: () {
                          context.go('${AppRoutes.employeeTasks}/${task.id}');
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
