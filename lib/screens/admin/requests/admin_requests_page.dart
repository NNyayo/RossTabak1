import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/employee_request_controller.dart';
import '../../../models/employee_request.dart';
import '../admin_base_page.dart';

class AdminRequestsPage extends StatefulWidget {
  const AdminRequestsPage({super.key});

  @override
  State<AdminRequestsPage> createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  String _filterStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeRequestController>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EmployeeRequestController>();

    return AdminBasePage(
      selectedRoute: '/admin/requests',
      title: 'Заявки сотрудников',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Фильтры
          Row(
            children: [
              ChoiceChip(
                label: const Text('Все'),
                selected: _filterStatus == 'ALL',
                onSelected: (_) => setState(() => _filterStatus = 'ALL'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Новые'),
                selected: _filterStatus == 'NEW',
                onSelected: (_) => setState(() => _filterStatus = 'NEW'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Ожидание'),
                selected: _filterStatus == 'IN_PROGRESS',
                onSelected: (_) =>
                    setState(() => _filterStatus = 'IN_PROGRESS'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Готово'),
                selected: _filterStatus == 'COMPLETED',
                onSelected: (_) => setState(() => _filterStatus = 'COMPLETED'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Отказано'),
                selected: _filterStatus == 'FAILED',
                onSelected: (_) => setState(() => _filterStatus = 'FAILED'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildRequestList(controller.requests),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<EmployeeRequest> requests) {
    List<EmployeeRequest> filtered = requests;

    if (_filterStatus != 'ALL') {
      filtered = requests.where((r) => r.status == _filterStatus).toList();
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'Заявок нет',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final request = filtered[index];
        return RequestCard(
          request: request,
          onStatusChange: (newStatus) {
            context.read<EmployeeRequestController>().updateStatus(
              request.id!,
              newStatus,
            );
          },
        );
      },
    );
  }
}

class RequestCard extends StatelessWidget {
  final EmployeeRequest request;
  final ValueChanged<String> onStatusChange;

  const RequestCard({
    super.key,
    required this.request,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и статус
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
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 8),

            // Информация
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  request.employeeName ?? 'Сотрудник',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                if (request.storeName != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.store, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    request.storeName!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            if (request.description != null &&
                request.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.description!,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Создана: ${_formatDate(request.createdAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const Divider(height: 24),

            // Кнопки действий
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Отказано — красный крестик
                _ActionButton(
                  icon: Icons.close,
                  label: 'Отказано',
                  color: Colors.red,
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  isSelected: request.status == 'FAILED',
                  onTap: () => onStatusChange('FAILED'),
                ),
                // Ожидание — жёлтый восклицательный знак
                _ActionButton(
                  icon: Icons.warning_amber_rounded,
                  label: 'Ожидание',
                  color: Colors.amber,
                  backgroundColor: Colors.amber.withValues(alpha: 0.15),
                  isSelected: request.status == 'IN_PROGRESS',
                  onTap: () => onStatusChange('IN_PROGRESS'),
                ),
                // Готово — зелёная галочка
                _ActionButton(
                  icon: Icons.check_circle,
                  label: 'Готово',
                  color: Colors.green,
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  isSelected: request.status == 'COMPLETED',
                  onTap: () => onStatusChange('COMPLETED'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'NEW':
        bgColor = Colors.blue.withValues(alpha: 0.15);
        textColor = Colors.blue;
        label = 'Новая';
        break;
      case 'IN_PROGRESS':
        bgColor = Colors.amber.withValues(alpha: 0.15);
        textColor = Colors.amber[800]!;
        label = 'Ожидание';
        break;
      case 'COMPLETED':
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green;
        label = 'Готово';
        break;
      case 'FAILED':
        bgColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red;
        label = 'Отказано';
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
