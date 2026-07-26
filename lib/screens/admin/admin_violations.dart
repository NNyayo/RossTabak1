import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/violation_controller.dart';
import 'admin_base_page.dart';

class AdminViolationsPage extends StatefulWidget {
  const AdminViolationsPage({super.key});

  @override
  State<AdminViolationsPage> createState() => _AdminViolationsPageState();
}

class _AdminViolationsPageState extends State<AdminViolationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViolationController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminBasePage(
      selectedRoute: '/admin/violations',
      title: 'Нарушения',
      child: Consumer<ViolationController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.violations.isEmpty) {
            return const Center(child: Text('Нарушений нет'));
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.violations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final v = controller.violations[index];
              return ViolationCard(violation: v);
            },
          );
        },
      ),
    );
  }
}

class ViolationCard extends StatelessWidget {
  final Map<String, dynamic> violation;

  const ViolationCard({super.key, required this.violation});

  @override
  Widget build(BuildContext context) {
    final type = violation['type'] ?? 'UNKNOWN';
    final description = violation['description'] ?? '';
    final createdAt = violation['created_at'] ?? '';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    createdAt,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
