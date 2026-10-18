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

  });
}
