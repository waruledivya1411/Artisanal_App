import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/learn/screens/photo_edit_screen.dart';

final _pixel = Uint8List.fromList(img.encodePng(img.Image(width: 3, height: 4)));

void main() {
  testWidgets('Save is at the top, once', (t) async {
    AppLang.current = 'en-US';
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    await t.pumpWidget(MaterialApp(home: PhotoEditScreen(imageBytes: _pixel)));
    await t.pump();

    expect(find.text('Save'), findsOneWidget);
    // Up beside the Edit title.
    expect(
      t.getCenter(find.text('Save')).dy,
      closeTo(t.getCenter(find.text('Edit')).dy, 4),
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('Reset undoes the changes and keeps the tool', (t) async {
    AppLang.current = 'en-US';
    t.view.physicalSize = const Size(320, 568);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    await t.pumpWidget(MaterialApp(home: PhotoEditScreen(imageBytes: _pixel)));
    await t.pump();

    double slider() => t.widget<Slider>(find.byType(Slider)).value;
    final start = slider();
    t.widget<Slider>(find.byType(Slider)).onChanged!(0.95);
    await t.pump();
    expect(slider(), isNot(start));

    await t.tap(find.text('Reset'));
    await t.pump();
    expect(slider(), start);
    expect(find.text('Bright — slide to lighten or darken'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
