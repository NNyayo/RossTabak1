import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../controllers/daily_task_controller.dart';
import '../../../controllers/store_controller.dart';
import '../../../models/daily_task_assignment.dart';
import '../../../models/daily_task_template.dart';
import '../admin_base_page.dart';

class AdminDailyTaskTemplatesPage extends StatefulWidget {
  const AdminDailyTaskTemplatesPage({super.key});

  @override
  State<AdminDailyTaskTemplatesPage> createState() =>
      _AdminDailyTaskTemplatesPageState();
}

class _AdminDailyTaskTemplatesPageState
    extends State<AdminDailyTaskTemplatesPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int? _selectedStoreId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyTaskController>().loadTemplates();
      context.read<StoreController>().loadStores();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DailyTaskController>();
    final storeController = context.watch<StoreController>();
    final templates = controller.templates;
    final stores = storeController.stores;

    return AdminBasePage(
      selectedRoute: AppRoutes.adminDailyTasks,
      title: 'Ежедневные задачи',
      showBackButton: true,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Создать задачу для магазина',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedStoreId,
                      decoration: const InputDecoration(
                        labelText: 'Магазин *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Выберите магазин'),
                        ),
                        ...stores.map(
                          (store) => DropdownMenuItem<int>(
                            value: store.id,
                            child: Text(store.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedStoreId = val);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Название *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _createTaskForStore,
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить задачу для магазина'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Список обязательных задач',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (controller.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (templates.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Нет обязательных задач',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: templates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return _TemplateCard(
                    template: template,
                    onDelete: () => _deleteTemplate(template.id!),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTaskForStore() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название задачи')));
      return;
    }

    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите магазин')));
      return;
    }

    final controller = context.read<DailyTaskController>();

    final templateId = await controller.createTemplate(
      DailyTaskTemplate(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
      ),
    );

    final today = _getTodayDate();
    await controller.createAssignmentForStore(
      templateId: templateId,
      storeId: _selectedStoreId!,
      date: today,
    );

    _titleCtrl.clear();
    _descCtrl.clear();
    setState(() => _selectedStoreId = null);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Задача создана для магазина'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteTemplate(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удаление'),
        content: const Text('Удалить эту обязательную задачу?'),
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
      await context.read<DailyTaskController>().deleteTemplate(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Задача удалена')));
      }
    }
  }
}

class _TemplateCard extends StatelessWidget {
  final DailyTaskTemplate template;
  final VoidCallback onDelete;

  const _TemplateCard({required this.template, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.15),
          child: const Icon(Icons.repeat, color: Colors.blue, size: 20),
        ),
        title: Text(
          template.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle:
            template.description != null && template.description!.isNotEmpty
            ? Text(template.description!)
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Удалить',
        ),
      ),
    );
  }
}
