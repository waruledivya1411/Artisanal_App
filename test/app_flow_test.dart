import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisnal_app/app/app.dart';

void main() {
  testWidgets('Onboarding and Learn lessons flow', (WidgetTester tester) async {
    await tester.pumpWidget(const ArtisnalApp());
    expect(find.text('Click & Social'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('Assamese'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Odia'), findsOneWidget);
    expect(find.text('Telugu'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pump();

    final selectedCard = find.byWidgetPredicate((widget) {
      if (widget is! Container) return false;
      final decoration = widget.decoration;
      if (decoration is! BoxDecoration) return false;
      final border = decoration.border;
      return border is Border &&
          border.top.color == const Color(0xFF1B7574) &&
          border.top.width > 1;
    });
    expect(selectedCard, findsOneWidget);
    expect(
      find.descendant(of: selectedCard, matching: find.text('English')),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Learn step by step'), findsOneWidget);
    expect(find.text('Listen'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Take beautiful photos'), findsOneWidget);
    expect(find.text('Listen'), findsOneWidget);
    expect(
      find.text('The camera helps you keep the photo\nstraight and bright.'),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Share and sell'), findsOneWidget);
    expect(find.text('Listen'), findsOneWidget);
    expect(
      find.text('Send your photos to Instagram and\nWhatsApp in a few taps.'),
      findsOneWidget,
    );
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Divya Warule'), findsOneWidget);
    expect(find.text('Sualkuchi, Assam'), findsOneWidget);
    expect(find.text('Photography'), findsOneWidget);
    expect(find.text('0 OF 5 TASKS DONE'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);

    expect(find.text('Create a post'), findsOneWidget);
    expect(find.text('Read the numbers'), findsOneWidget);

    await tester.ensureVisible(find.text('Photography'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Photography'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 1 OF 5'), findsNothing);

    await tester.ensureVisible(find.text('Set up your page'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set up your page'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 2 OF 5'), findsOneWidget);
    expect(find.text('Good name'), findsOneWidget);
    expect(find.text('Clear photo'), findsOneWidget);
    expect(find.text('Professional'), findsOneWidget);
    expect(find.text('Try it'), findsOneWidget);
    await tester.tap(find.text('Good name'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 2 · PART 1 · GOOD NAME'), findsOneWidget);
    expect(find.text('Short name with your craft'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('@divya\n.weaves'), findsOneWidget);
    expect(find.text('Easy to say and find'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Easy to say and find'), findsOneWidget);
    expect(find.text('Short'), findsOneWidget);
    expect(find.text('Long'), findsOneWidget);
    await tester.tap(find.text('Next part · Clear photo'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 2 · PART 2 · CLEAR PHOTO'), findsOneWidget);
    expect(find.text('Use your face or your loom'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('divya.weaves'), findsNWidgets(2));
    expect(find.text('Buyers trust a clear face'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Buyers trust a clear face'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Blurry'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNWidgets(2));
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Posting plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Posting plan'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 4 OF 5'), findsOneWidget);
    expect(find.text('Post often'), findsOneWidget);
    expect(find.text('Good time'), findsOneWidget);
    expect(find.text('Mix posts'), findsOneWidget);
    expect(find.text('Try it'), findsOneWidget);
    await tester.tap(find.text('Post often'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 4 · PART 1 · POST OFTEN'), findsOneWidget);
    expect(find.text('Post 3 times a week'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('1 a month'), findsOneWidget);
    expect(find.text('3 a week'), findsOneWidget);
    expect(find.text('People remember you'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('People remember you'), findsOneWidget);
    expect(find.text('Often'), findsOneWidget);
    expect(find.text('Rarely'), findsOneWidget);
    await tester.tap(find.text('Next part · Good time'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 4 · PART 2 · GOOD TIME'), findsOneWidget);
    expect(find.text('Post in the evening'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('More people see it'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('More people see it'), findsOneWidget);
    expect(find.text('Buyers online'), findsOneWidget);
    expect(find.text('All asleep'), findsOneWidget);
    await tester.tap(find.text('Next part · Mix posts'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 4 · PART 3 · MIX POSTS'), findsOneWidget);
    expect(find.text('Cloth, work, then price'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Every post shows something new'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Every post shows something new'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
    expect(find.text('Same photo'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNWidgets(3));
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Read the numbers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read the numbers'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 5 OF 5'), findsOneWidget);
    expect(find.text('Saves matter'), findsOneWidget);
    expect(find.text('Reply fast'), findsOneWidget);
    expect(find.text('What they mean'), findsOneWidget);
    expect(find.text('Best posts'), findsNothing);
    expect(find.text('Try it'), findsNothing);
    await tester.tap(find.text('Saves matter'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 5 · PART 1 · SAVES MATTER'), findsOneWidget);
    expect(find.text('Saves mean buyers'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('120 likes'), findsOneWidget);
    expect(find.text('0 saves'), findsOneWidget);
    expect(find.text('60 likes'), findsOneWidget);
    expect(find.text('18 saves'), findsOneWidget);
    expect(find.text('Saves show they want to buy'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Saves show they want to buy'), findsOneWidget);
    expect(find.text('Many saves'), findsOneWidget);
    expect(find.text('Only likes'), findsOneWidget);
    await tester.tap(find.text('Next part · Reply fast'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 5 · PART 2 · REPLY FAST'), findsOneWidget);
    expect(find.text('Reply the same day'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Price please?'), findsNWidgets(2));
    expect(find.text('After 3 days'), findsOneWidget);
    expect(find.text('In 1 hour'), findsOneWidget);
    expect(find.text('₹4,500'), findsNWidgets(2));
    expect(find.text('Fast replies make sales'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Fast replies make sales'), findsOneWidget);
    expect(find.text('Fast'), findsOneWidget);
    expect(find.text('Late'), findsOneWidget);
    await tester.tap(find.text('Next part · What they mean'));
    await tester.pumpAndSettle();
    expect(find.text('4 numbers to watch'), findsOneWidget);
    expect(find.text('People who saw it'), findsOneWidget);
    expect(find.text('Want to buy later'), findsOneWidget);
    expect(find.text('Buyers asking'), findsOneWidget);
    expect(find.text('BEST'), findsNWidgets(2));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Find your numbers'), findsOneWidget);
    expect(find.text('TASK 5 · 2 OF 2'), findsOneWidget);
    expect(find.text('divya.weaves'), findsOneWidget);
    expect(find.text('Professional dashboard'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Share profile'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Tap Professional dashboard'), findsOneWidget);
    expect(find.text('Open Instagram'), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);
    await tester.tap(find.text('Complete'));
    await tester.pump();
    expect(find.text('Badge earned'), findsOneWidget);
    expect(find.text('Read the numbers'), findsWidgets);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 5 OF 5'), findsOneWidget);
    expect(find.text('Done'), findsNWidgets(3));
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

    expect(find.text('TASK 1 OF 5'), findsOneWidget);
    expect(find.text('Learn'), findsNWidgets(2));
    expect(find.text('Photography'), findsNothing);
    expect(find.text('Hold steady'), findsOneWidget);
    expect(find.text('Window light'), findsOneWidget);
    expect(find.text('Try it'), findsOneWidget);
    expect(find.text('Done'), findsNothing);

    await tester.tap(find.text('Plain sheet'));
    await tester.pumpAndSettle();
    expect(find.text('PART 2 · PLAIN SHEET'), findsNothing);

    await tester.tap(find.text('Hold steady'));
    await tester.pumpAndSettle();

    expect(find.text('PART 1 · HOLD STEADY'), findsOneWidget);
    expect(find.text('Hold with two hands'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Which is better?'), findsOneWidget);
    expect(find.text('Yes! B is better'), findsNothing);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();

    expect(find.text('Yes! B is better'), findsOneWidget);
    expect(find.text('Steady'), findsOneWidget);
    expect(find.text('Shaky'), findsOneWidget);

    await tester.tap(find.text('Next part · Plain sheet'));
    await tester.pumpAndSettle();

    expect(find.text('PART 2 · PLAIN SHEET'), findsOneWidget);
    expect(find.text('Put a plain sheet behind'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Which is better?'), findsOneWidget);
    expect(find.text('Not quite. B is better'), findsNothing);

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(find.text('Not quite. B is better'), findsOneWidget);
    expect(find.text('Messy'), findsOneWidget);
    expect(find.text('Plain'), findsOneWidget);

    await tester.tap(find.text('Next part · Window light'));
    await tester.pumpAndSettle();

    expect(find.text('PART 3 · WINDOW LIGHT'), findsOneWidget);
    expect(find.text('Stand near a window'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Which is better?'), findsOneWidget);
    expect(find.text('Yes! B is better'), findsNothing);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();

    expect(find.text('Yes! B is better'), findsOneWidget);
    expect(find.text('True colours by the window'), findsOneWidget);
    expect(find.text('Near window'), findsOneWidget);
    expect(find.text('Dark corner'), findsOneWidget);

    await tester.tap(find.text('Next part · Straight angle'));
    await tester.pumpAndSettle();

    expect(find.text('PART 4 · STRAIGHT ANGLE'), findsOneWidget);
    expect(find.text('Hold the phone straight'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Which is better?'), findsOneWidget);
    expect(find.text('Shows the full cloth'), findsNothing);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();

    expect(find.text('Shows the full cloth'), findsOneWidget);
    expect(find.text('Straight'), findsOneWidget);
    expect(find.text('Tilted'), findsOneWidget);

    await tester.tap(find.text('Next part · Try it'));
    await tester.pumpAndSettle();

    expect(find.text('Now you try'), findsOneWidget);
    expect(find.text('Open camera'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('TASK 1 OF 5'), findsOneWidget);
    expect(find.text('Done'), findsNWidgets(4));
  });
}
