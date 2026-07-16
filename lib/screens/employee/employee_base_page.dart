import 'package:flutter/material.dart';

class EmployeeBasePage extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onLogout;

  const EmployeeBasePage({
    super.key,
    required this.title,
    required this.child,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: onLogout != null
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Выйти',
                  onPressed: onLogout,
                ),
              ]
            : null,
      ),
      body: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}
