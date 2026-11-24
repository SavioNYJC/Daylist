import 'package:material_ui/material_ui.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylist/home_page.dart';
import 'package:daylist/main.dart';
import 'package:daylist/screens/pending_blends_page.dart';
import 'package:daylist/screens/profile_page.dart';
import 'package:daylist/screens/settings_page.dart';
import 'package:daylist/services/blend_service.dart';

void main() {
  testWidgets('shows the frontend home sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(blendLoader: () async => const BlendHomeData()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Upcoming playlists'), findsOneWidget);
    expect(find.text('Blends'), findsOneWidget);
  });

  testWidgets('shows accepted blends and their event previews', (
    WidgetTester tester,
  ) async {
    const connection = BlendConnection(
      user1Id: 'current-user',
      user2Id: 'friend-user',
      otherUserId: 'friend-user',
      otherUsername: 'Edward',
      status: 'accepted',
      isIncoming: false,
      myPreviewEvent: 'Travel to school',
      otherPreviewEvent: 'Study physics',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          blendLoader: () async => const BlendHomeData(accepted: [connection]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edward'), findsOneWidget);
    expect(find.text('Travel to school'), findsNWidgets(2));
    expect(find.text('Study physics'), findsOneWidget);
  });

  testWidgets('quick action button expands to the three home actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(blendLoader: () async => const BlendHomeData()),
      ),
    );
    await tester.pumpAndSettle();

    final initialButtonRect = tester.getRect(find.byType(FloatingActionButton));
    await tester.tap(find.byTooltip('Open quick actions'));
    await tester.pumpAndSettle();

    expect(find.text('New playlist'), findsOneWidget);
    expect(find.text('Pending blends'), findsOneWidget);
    expect(find.text('New blend'), findsOneWidget);
    expect(
      tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
      0.125,
    );
    expect(
      tester.getRect(find.byType(FloatingActionButton)),
      initialButtonRect,
    );
    expect(
      find.descendant(
        of: find.byType(AnimatedRotation),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
    );
  });

  testWidgets('pending blend action opens the invitations page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(blendLoader: () async => const BlendHomeData()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open quick actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending blends'));
    await tester.pumpAndSettle();

    expect(find.byType(PendingBlendsPage), findsOneWidget);
    expect(find.text('No pending invitations'), findsOneWidget);
  });

  testWidgets('incoming invitations can be accepted from the pending page', (
    WidgetTester tester,
  ) async {
    var responded = false;
    final invitation = BlendConnection(
      user1Id: 'inviter-id',
      user2Id: 'current-user',
      otherUserId: 'inviter-id',
      otherUsername: 'Edward',
      status: 'pending',
      isIncoming: true,
      selectedDates: [DateTime(2026, 11, 25)],
      description: 'Study together',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PendingBlendsPage(
          blendLoader: () async => responded
              ? const BlendHomeData()
              : BlendHomeData(incoming: [invitation]),
          responder: (invitation, {required accept}) async {
            responded = accept;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edward'), findsOneWidget);
    expect(find.text('25 Nov'), findsOneWidget);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(responded, isTrue);
    expect(find.text('No pending invitations'), findsOneWidget);
  });

  testWidgets('creates a username blend invitation with dates and a note', (
    WidgetTester tester,
  ) async {
    String? createdUsername;
    List<DateTime>? createdDates;
    String? createdDescription;

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          blendLoader: () async => const BlendHomeData(),
          blendCreator: (username, dates, description) async {
            createdUsername = username;
            createdDates = dates;
            createdDescription = description;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open quick actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New blend'));
    await tester.pumpAndSettle();

    expect(find.text('Create new blend'), findsOneWidget);
    final bottomSheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(
      bottomSheet.shape,
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
    expect(
      tester.widget<Text>(find.text('Create new blend')).style?.fontSize,
      27,
    );
    expect(find.text('Username'), findsOneWidget);
    await tester.ensureVisible(find.text('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    final usernameError = tester.widget<Text>(find.text('Enter a username.'));
    expect(usernameError.style?.color, const Color(0xFFB3261E));
    expect(usernameError.style?.fontSize, 15);

    await tester.ensureVisible(find.text('Add date'));
    await tester.tap(find.text('Add date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'edward');
    await tester.enterText(find.byType(TextField).last, 'Study together');
    await tester.ensureVisible(find.text('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(createdUsername, 'edward');
    expect(createdDates, hasLength(1));
    expect(createdDescription, 'Study together');
  });

  testWidgets('debug preview opens blend page without another account', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(blendLoader: () async => const BlendHomeData()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview sample blend'));
    await tester.pumpAndSettle();

    expect(find.text('You + Edward'), findsOneWidget);
    expect(find.text('Travel to school'), findsOneWidget);
    expect(find.text('Study physics'), findsOneWidget);
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
