import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/onboarding/screens/language_picker_screen.dart';
import 'package:artisnal_app/features/shell/main_tab_screen.dart';

void main() {
  testWidgets('change language from Learn', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    AppLang.current = 'as-IN';
    await t.pumpWidget(const MaterialApp(home: MainTabScreen(locale: 'as-IN')));
    await t.pumpAndSettle();
    expect(find.text('অসমীয়া'), findsOneWidget);           // button shows current
    expect(find.text('Hello, Divya Warule'), findsNothing);   // home is in Assamese

    await t.tap(find.text('অসমীয়া'));
    await t.pumpAndSettle();
    expect(find.byType(LanguagePickerScreen), findsOneWidget);
    await t.tap(find.text('English').first);
    await t.pumpAndSettle();
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.byType(LanguagePickerScreen), findsNothing);
    expect(find.text('Hello, Divya Warule'), findsOneWidget);  // now English
    expect(find.text('English'), findsOneWidget);              // button updated
    expect(AppLang.current, 'en-US');
    expect(MainTabScreen.selectTab, isNotNull);

    // Choosing then backing out leaves it as it was.
    await t.tap(find.text('English'));
    await t.pumpAndSettle();
    await t.tap(find.text('Telugu'));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pumpAndSettle();
    expect(AppLang.current, 'en-US');
    expect(find.text('Hello, Divya Warule'), findsOneWidget);
  });
}
