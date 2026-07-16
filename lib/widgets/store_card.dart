import 'package:flutter/material.dart';

import '../models/store.dart';
import '../core/colors.dart';

class StoreCard extends StatelessWidget {
  final Store store;

  const StoreCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.markerColors[store.markerColor] ?? Colors.white;

    return Card(
      elevation: 3,

      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width: 18,

                  height: 18,

                  decoration: BoxDecoration(
                    color: color,

                    shape: BoxShape.circle,

                    border: Border.all(color: Colors.grey),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    store.name,

                    style: const TextStyle(
                      fontSize: 20,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Icon(Icons.arrow_forward_ios, size: 18),
              ],
            ),

            const SizedBox(height: 10),

            Text('📍 ${store.address}'),

            Text('🚇 ${store.metro}'),
          ],
        ),
      ),
    );
  }
}
