import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisnal_app/main.dart';

void main() {
  testWidgets('Splash leads to the language picker', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.text('Photography'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 1 OF 5'), findsNothing);

    await tester.pumpAndSettle();

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

    expect(find.text('TASK 1 OF 5'), findsOneWidget);
    expect(find.text('Photography'), findsOneWidget);
    expect(find.text('Hold steady'), findsOneWidget);
    expect(find.text('Window light'), findsOneWidget);
    expect(find.text('Try it'), findsOneWidget);
    expect(find.text('Done'), findsNWidgets(2));

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

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plain sheet'));
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

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Window light'));
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

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Straight angle'));
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

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try it'));
    await tester.pumpAndSettle();

    expect(find.text('Now you try'), findsOneWidget);
    expect(find.text('Open camera'), findsOneWidget);
  });
}
