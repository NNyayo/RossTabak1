import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../constants/app_task_status.dart';
import '../../controllers/employee_controller.dart';
import '../../controllers/employee_request_controller.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/task_category_controller.dart';
import '../../controllers/task_controller.dart';
import '../../providers/auth_provider.dart';
import '../../models/task.dart';
import '../../models/task_category.dart';
import '../../repositories/task_repository.dart';
import '../../widgets/app_button.dart';
import 'admin_base_page.dart';

class AdminTasksPage extends StatefulWidget {
  const AdminTasksPage({super.key});

  @override
  State<AdminTasksPage> createState() => _AdminTasksPageState();
}

class _AdminTasksPageState extends State<AdminTasksPage> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  String _filterStatus = 'ALL';
  String? _selectedCategory;
  int? _selectedStoreId;
  List<TaskCategory> _categories = [];
  bool _isImportant = false;
  bool _showArchive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadStores();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _deadlineCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final controller = context.read<TaskCategoryController>();
    await controller.loadCategories();
    setState(() {
      _categories = controller.categories;
      _selectedCategory = _categories.isNotEmpty
          ? _categories.first.name
          : null;
    });
  }

  Future<void> _loadStores() async {
    final controller = context.read<StoreController>();
    await controller.loadStores();
    final stores = controller.stores.where((s) => s.isActive).toList();
    if (stores.isNotEmpty && _selectedStoreId == null) {
      setState(() {
        _selectedStoreId = stores.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/tasks',
      title: 'Задачи',
      child: Column(
        children: [
          _buildRequestsButton(context),
          const SizedBox(height: 12),
          _buildCreateTaskCard(),
          const SizedBox(height: 12),
          _buildFilters(),
          const SizedBox(height: 12),
          _buildTaskList(),
        ],
      ),
    );
  }

  Widget _buildRequestsButton(BuildContext context) {
    return Consumer<EmployeeRequestController>(
      builder: (context, controller, _) {
        final unread = controller.newRequestsCount;
        return InkWell(
          onTap: () => context.push(AppRoutes.adminRequests),
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 2,
            color: unread > 0 ? Colors.blue.withValues(alpha: 0.08) : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Заявки сотрудников',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Просмотр и управление заявками от сотрудников',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateTaskCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Создать задачу',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Название *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Категория',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((c) {
                      return DropdownMenuItem(
                        value: c.name,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Обязательно к выполнению',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      _StarToggle(
                        isImportant: _isImportant,
                        onChanged: (v) => setState(() => _isImportant = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _selectedStoreId,
              decoration: const InputDecoration(
                labelText: 'Торговая точка',
                border: OutlineInputBorder(),
              ),
              items: context
                  .watch<StoreController>()
                  .stores
                  .where((s) => s.isActive)
                  .map((s) {
                    return DropdownMenuItem(value: s.id, child: Text(s.name));
                  })
                  .toList(),
              onChanged: (v) => setState(() => _selectedStoreId = v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _deadlineCtrl,
              decoration: const InputDecoration(
                labelText: 'Срок (dd.mm.yyyy)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _DeadlineFormatter(),
              ],
            ),
            const SizedBox(height: 12),
            AppButton(text: 'Создать задачу', onPressed: _createTask),
          ],
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название задачи')));
      return;
    }

    final employees = context.read<EmployeeController>().employees;
    if (employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет сотрудников для назначения')),
      );
      return;
    }

    final assigneeIds = employees.map((e) => e.id!).toList();
    final currentUserId = context.read<AuthProvider>().currentEmployee?.id ?? 1;

    final task = Task(
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      category: _selectedCategory,
      priority: _isImportant ? 'HIGH' : 'NORMAL',
      createdBy: currentUserId,
      storeId: _selectedStoreId,
      status: AppTaskStatus.newTask,
      deadline: _deadlineCtrl.text.trim().isEmpty
          ? null
          : _deadlineCtrl.text.trim(),
    );

    final controller = context.read<TaskController>();
    await controller.createTask(task, assigneeIds, currentUserId);
    await controller.loadTasks();

    _titleCtrl.clear();
    _descriptionCtrl.clear();
    _deadlineCtrl.clear();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Задача создана')));
    }
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Поиск задач',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterStatus,
                    decoration: const InputDecoration(
                      labelText: 'Статус',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('Все')),
                      DropdownMenuItem(
                        value: AppTaskStatus.newTask,
                        child: Text('Новые'),
                      ),
                      DropdownMenuItem(
                        value: AppTaskStatus.inProgress,
                        child: Text('В процессе'),
                      ),
                      DropdownMenuItem(
                        value: AppTaskStatus.completed,
                        child: Text('Выполненные'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _filterStatus = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Активные'),
                  selected: !_showArchive,
                  onSelected: (_) => setState(() => _showArchive = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Архив'),
                  selected: _showArchive,
                  onSelected: (_) => setState(() => _showArchive = true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Task> tasks = _showArchive
            ? controller.tasks.where((t) => !t.isActive).toList()
            : controller.tasks.where((t) => t.isActive).toList();

        if (_searchCtrl.text.isNotEmpty) {
          final query = _searchCtrl.text.toLowerCase();
          tasks = tasks.where((t) {
            final title = t.title.toLowerCase();
            final desc = (t.description ?? '').toLowerCase();
            return title.contains(query) || desc.contains(query);
          }).toList();
        }

        if (_filterStatus != 'ALL') {
          tasks = tasks.where((t) => t.status == _filterStatus).toList();
        }

        if (tasks.isEmpty) {
          return Center(
            child: Text(_showArchive ? 'Архив пуст' : 'Задачи не найдены'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              onDelete: !_showArchive && task.isActive
                  ? () => _archiveTask(task.id!)
                  : null,
              onRestore: _showArchive && !task.isActive
                  ? () => _restoreTask(task.id!)
                  : null,
              onHardDelete: () => _deleteTaskPermanently(task.id!),
            );
          },
        );
      },
    );
  }

  Future<void> _archiveTask(int taskId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('В архив'),
        content: const Text('Переместить задачу в архив?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('В архив'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final taskRepo = context.read<TaskRepository>();
      final taskCtrl = context.read<TaskController>();
      await taskRepo.deleteTask(taskId);
      await taskCtrl.loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Задача перемещена в архив')),
        );
      }
    }
  }

  Future<void> _restoreTask(int taskId) async {
    final taskRepo = context.read<TaskRepository>();
    final taskCtrl = context.read<TaskController>();
    await taskRepo.restoreTask(taskId);
    await taskCtrl.loadTasks();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Задача восстановлена')));
    }
  }

  Future<void> _deleteTaskPermanently(int taskId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удаление задачи'),
        content: const Text(
          'Вы уверены, что хотите полностью удалить задачу? Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final taskRepo = context.read<TaskRepository>();
      final taskCtrl = context.read<TaskController>();
      await taskRepo.hardDeleteTask(taskId);
      await taskCtrl.loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Задача удалена')));
      }
    }
  }
}

/// Кастомный форматтер для даты dd.mm.yyyy
class _DeadlineFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Получаем только цифры из нового значения
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Ограничиваем 8 цифрами (ddmmyyyy)
    final trimmed = digits.length > 8 ? digits.substring(0, 8) : digits;

    if (trimmed.isEmpty) return TextEditingValue.empty;

    // Формируем строку с точками
    String result = '';
    for (int i = 0; i < trimmed.length; i++) {
      if (i == 2 || i == 4) result += '.';
      result += trimmed[i];
    }

    // Проверяем дату, если ввели все 8 цифр
    if (trimmed.length == 8) {
      final dateStr = result;
      if (!_isValidDate(dateStr)) return oldValue;
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  bool _isValidDate(String dateStr) {
    if (dateStr.length != 10) return true;
    try {
      final parts = dateStr.split('.');
      if (parts.length != 3) return true;
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return true;
      final date = DateTime(year, month, day);
      return !date.isAfter(DateTime.now());
    } catch (_) {
      return true;
    }
  }
}

// Виджет звездочки с анимацией
class _StarToggle extends StatefulWidget {
  final bool isImportant;
  final ValueChanged<bool> onChanged;

  const _StarToggle({required this.isImportant, required this.onChanged});

  @override
  State<_StarToggle> createState() => _StarToggleState();
}

class _StarToggleState extends State<_StarToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.isImportant);
        _controller.forward().then((_) => _controller.reverse());
      },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            widget.isImportant ? Icons.star : Icons.star_border,
            key: ValueKey(widget.isImportant),
            color: widget.isImportant ? Colors.amber : Colors.grey,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onDelete;
  final VoidCallback? onRestore;
  final VoidCallback? onHardDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onDelete,
    this.onRestore,
    this.onHardDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(task.status);
    final statusLabel = _getStatusLabel(task.status);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (task.category != null)
                  Chip(
                    label: Text(task.category!),
                    visualDensity: VisualDensity.compact,
                  ),
                if (task.priority == 'HIGH')
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.star, color: Colors.amber, size: 18),
                  ),
                if (task.deadline != null)
                  Chip(
                    label: Text('Срок: ${_formatDeadline(task.deadline)}'),
                    visualDensity: VisualDensity.compact,
                  ),
                const Spacer(),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.archive_outlined, size: 20),
                    onPressed: onDelete,
                    tooltip: 'В архив',
                  ),
                if (onRestore != null)
                  IconButton(
                    icon: const Icon(Icons.restore, size: 20),
                    onPressed: onRestore,
                    tooltip: 'Восстановить',
                  ),
                if (onHardDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: onHardDelete,
                    tooltip: 'Удалить навсегда',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppTaskStatus.newTask:
        return Colors.blue;
      case AppTaskStatus.inProgress:
        return Colors.orange;
      case AppTaskStatus.completed:
        return Colors.green;
      case AppTaskStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case AppTaskStatus.newTask:
        return 'Новая';
      case AppTaskStatus.inProgress:
        return 'В процессе';
      case AppTaskStatus.completed:
        return 'Выполнена';
      case AppTaskStatus.failed:
        return 'Провалена';
      default:
        return status;
    }
  }

  String _formatDeadline(String? deadline) {
    if (deadline == null || deadline.isEmpty) return '';
    final parts = deadline.split('-');
    if (parts.length == 3) {
      return '${parts[2]}.${parts[1]}.${parts[0]}';
    }
    return deadline;
  }
}
