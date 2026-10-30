import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisnal_app/features/learn/data/displays.dart';
import 'package:artisnal_app/features/learn/screens/display_picker_screen.dart';

void main() {
  testWidgets('a new shoot starts with no display ticked', (t) async {
    t.view.physicalSize = const Size(390, 2400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    // As if the artisan shot a stole's full display earlier in the session.
    SelectedDisplay.instance.select('Full display');
    await t.pumpWidget(const MaterialApp(home: DisplayPickerScreen(
        locale: 'en-US', taskLabel: '', product: 'Saree', material: 'Cotton')));
    await t.pumpAndSettle();
    final ticks = find.byIcon(Icons.check_circle_rounded).evaluate().length;
    expect(ticks, 0);
  });
}
