import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisnal_app/features/learn/widgets/shot_outline.dart';

void main() {
  test('Mekhala sador full and hanging guides fill at least 70%', () {
    for (final key in ['full_display', 'hanging_display']) {
      final outline = ShotOutline.forShot('Mekhala sador', key);
      for (final screen in [
        const Size(320, 427),
        const Size(390, 700),
        const Size(481, 641),
      ]) {
        final photo = ShotOutline.photoRect(screen);
        final art = ShotOutline.outerFrame(screen, outline);
        expect(
          art.height / photo.height,
          greaterThanOrEqualTo(0.70),
          reason: '$key $screen',
        );
        expect(photo.contains(art.topLeft), isTrue, reason: '$key $screen');
        expect(photo.contains(art.bottomRight), isTrue, reason: '$key $screen');
        expect(art.width / art.height, closeTo(outline.aspectRatio, 0.001));
      }
    }
  });
}
