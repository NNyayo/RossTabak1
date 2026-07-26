import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/employee_request_controller.dart';
import '../../../controllers/store_controller.dart';
import '../../../models/employee_request.dart';
import '../../../providers/auth_provider.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    final employee = context.read<AuthProvider>().currentEmployee;
    if (employee == null) return;
    await context.read<EmployeeRequestController>().loadByEmployee(employee.id!);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EmployeeRequestController>();
    final employee = context.watch<AuthProvider>().currentEmployee;

    if (employee == null) {
      return const Center(child: Text('Сотрудник не найден'));
    }

    final requests = controller.requests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Кнопка создать заявку
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Создать заявку'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Мои заявки',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (controller.isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (requests.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'У вас нет заявок',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final request = requests[index];
                return _RequestCard(request: request);
              },
            ),
          ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int? selectedStoreId;
    final storeController = context.read<StoreController>();
    final stores = storeController.stores.where((s) => s.isActive).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Создать заявку'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Заголовок *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedStoreId,
                    decoration: const InputDecoration(
                      labelText: 'Магазин',
                      border: OutlineInputBorder(),
                    ),
                    items: stores.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedStoreId = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите заголовок')),
                  );
                  return;
                }
                final employee = context.read<AuthProvider>().currentEmployee;
                if (employee == null) return;

                await context.read<EmployeeRequestController>().createRequest(
                  EmployeeRequest(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim().isEmpty
                        ? null
                        : descCtrl.text.trim(),
                    storeId: selectedStoreId,
                    employeeId: employee.id!,
                    status: 'NEW',
                  ),
                );

                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Заявка создана'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final EmployeeRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(request.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
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
                    request.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (request.description != null &&
                request.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.description!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            if (request.storeName != null &&
                request.storeName!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.store, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    request.storeName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              request.createdAt != null
                  ? _formatDate(request.createdAt!)
                  : '',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}