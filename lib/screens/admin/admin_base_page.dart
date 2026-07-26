import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'admin_sidebar.dart';

class AdminBasePage extends StatelessWidget {
  final String selectedRoute;
  final String title;
  final Widget child;
  final bool showBackButton;

  const AdminBasePage({
    super.key,
    required this.selectedRoute,
    required this.title,
    required this.child,
    this.showBackButton = false,
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
                  Row(
                    children: [
                      if (showBackButton) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                          tooltip: 'Назад',
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
