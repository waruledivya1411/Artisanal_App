import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisnal_app/core/widgets/app_bottom_nav.dart';

void main() {
  Future<List<Color>> iconColors(WidgetTester t, AppNavTab tab) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(locale: 'en-US', selectedTab: tab),
        ),
      ),
    );
    return [
      for (final filter in t.widgetList<ColorFiltered>(
        find.byType(ColorFiltered),
      ))
        _colorOf(filter),
    ];
  }

  testWidgets('only the tab in use has a green icon', (t) async {
    expect(await iconColors(t, AppNavTab.learn), [
      AppBottomNav.teal,
      AppBottomNav.muted,
    ]);
    expect(await iconColors(t, AppNavTab.me), [
      AppBottomNav.muted,
      AppBottomNav.teal,
    ]);
  });
}

// ColorFilter does not expose its colour, but its text form names it.
Color _colorOf(ColorFiltered filter) {
  final text = filter.colorFilter.toString();
  for (final color in [AppBottomNav.teal, AppBottomNav.muted]) {
    if (text.contains(color.toString())) return color;
  }
  throw StateError('Unexpected icon colour: $text');
}
