import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/onboarding/screens/splash_screen.dart';

double opacityOf(WidgetTester t, String text) => t
    .widget<Opacity>(
      find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  testWidgets('letters and the tagline come in over time', (t) async {
    AppLang.current = 'en-US';
    await t.pumpWidget(const MaterialApp(home: SplashScreen()));
    await t.pump();

    // At the start nothing has appeared.
    expect(opacityOf(t, 'C'), 0);
    expect(opacityOf(t, 'Show your craft to the world'), 0);

    // Part way through, the first letter is ahead of the last.
    await t.pump(const Duration(milliseconds: 500));
    expect(opacityOf(t, 'C'), 1);
    expect(opacityOf(t, 'l').compareTo(1), lessThanOrEqualTo(0));
    expect(opacityOf(t, 'Show your craft to the world'), 0);

    // Everything is in before the screen moves on.
    await t.pump(const Duration(milliseconds: 1700));
    expect(opacityOf(t, 'C'), 1);
    expect(opacityOf(t, 'Show your craft to the world'), 1);
    expect(find.byType(SplashScreen), findsOneWidget);

    // Then the log in page opens.
    await t.pump(const Duration(milliseconds: 900));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(SplashScreen), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('with less motion the finished screen shows at once', (t) async {
    AppLang.current = 'en-US';
    await t.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: SplashScreen()),
      ),
    );
    await t.pump();
    expect(opacityOf(t, 'C'), 1);
    expect(opacityOf(t, 'Show your craft to the world'), 1);
    await t.pump(const Duration(seconds: 4));
  });

  for (final size in [const Size(320, 568), const Size(390, 844)]) {
    for (final lang in ['en-US', 'as-IN', 'or-IN', 'te-IN']) {
      testWidgets('fits $size $lang', (t) async {
        AppLang.current = lang;
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        await t.pumpWidget(const MaterialApp(home: SplashScreen()));
        await t.pump(const Duration(milliseconds: 2500));
        expect(t.takeException(), isNull);
        await t.pump(const Duration(seconds: 2));
      });
    }
  }
}
