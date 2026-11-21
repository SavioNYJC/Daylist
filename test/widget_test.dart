import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylist/home_page.dart';
import 'package:daylist/main.dart';

void main() {
  testWidgets('shows the frontend home sections', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Upcoming playlists'), findsOneWidget);
    expect(find.text('Blends'), findsOneWidget);
  });

  testWidgets('shows a message after email confirmation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: EmailConfirmedPage(onLogIn: () {})),
    );

    expect(
      find.text('Your email has been confirmed. Log in to continue.'),
      findsOneWidget,
    );
    expect(find.text('Log in'), findsOneWidget);
  });
}
