import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylist/main.dart';

void main() {
  testWidgets('shows todos returned from Supabase', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          todos: Future.value([
            {'name': 'Buy groceries'},
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buy groceries'), findsOneWidget);
  });

  testWidgets('shows Supabase query errors', (WidgetTester tester) async {
    final todos = Completer<List<Map<String, dynamic>>>();
    await tester.pumpWidget(MaterialApp(home: HomePage(todos: todos.future)));
    todos.completeError(StateError('Table not found'));
    await tester.pump();

    expect(find.textContaining('Could not load todos'), findsOneWidget);
  });
}
