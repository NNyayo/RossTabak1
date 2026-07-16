import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';
import '../lib/screens/admin/admin_history.dart';
import '../lib/controllers/system_log_controller.dart';

void main() {
  setupTestDatabase();

  testWidgets('AdminHistoryPage shows empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => SystemLogController(),
          child: const AdminHistoryPage(),
        ),
      ),
    );

    expect(find.text('История действий'), findsOneWidget);
  });
}
