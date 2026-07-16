import 'package:flutter/material.dart';

class ShiftInfoCard extends StatelessWidget {
  final String shopNumber;
  final String shiftType;
  final String timeRange;
  final String managerName;

  const ShiftInfoCard({
    super.key,
    required this.shopNumber,
    required this.shiftType,
    required this.timeRange,
    required this.managerName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Магазин:\n$shopNumber',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Смена: $shiftType'),
            const SizedBox(height: 6),
            Text('Время: $timeRange'),
            const SizedBox(height: 6),
            Text('Ответственный: $managerName'),
          ],
        ),
      ),
    );
  }
}
