import 'package:flutter/material.dart';

import 'admin_sidebar.dart';

class AdminBasePage extends StatelessWidget {
  final String selectedRoute;
  final String title;
  final Widget child;

  const AdminBasePage({
    super.key,
    required this.selectedRoute,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(selectedRoute: selectedRoute),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
