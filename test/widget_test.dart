import 'package:material_ui/material_ui.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylist/home_page.dart';
import 'package:daylist/main.dart';
import 'package:daylist/screens/profile_page.dart';
import 'package:daylist/screens/settings_page.dart';

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

  testWidgets('settings account button opens the profile page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    final accountPanel = find.byType(LiquidGlassLens);
    expect(accountPanel, findsOneWidget);
    expect(
      find.descendant(of: accountPanel, matching: find.text('Account')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: accountPanel, matching: find.text('Account details')),
      findsOneWidget,
    );
    await tester.tap(find.text('Account details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(ProfilePage), findsOneWidget);
  });
}
