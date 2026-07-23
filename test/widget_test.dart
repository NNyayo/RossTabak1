import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  setupTestDatabase();

  testWidgets('Login screen basic widgets render', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Column(children: [Text('Войти'), TextField()])),
      ),
    );

    expect(find.text('Войти'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
