import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisnal_app/features/learn/widgets/shot_outline.dart';

void main() {
  test('the Jod kappur hanging guide is tall and sits towards the top', () {
    for (final screen in [
      const Size(320, 427),
      const Size(390, 700),
      const Size(481, 641),
    ]) {
      final photo = ShotOutline.photoRect(screen);
      final art = ShotOutlineOverlay.jodHangingArtRect(screen);

      expect(art.height / photo.height, greaterThanOrEqualTo(0.70));
      expect(art.top - photo.top, lessThan(photo.bottom - art.bottom));
      expect(photo.contains(art.topLeft), isTrue);
      expect(photo.contains(art.bottomRight), isTrue);
      expect(
        art.width / art.height,
        closeTo(ShotOutlineOverlay.jodHangingArtAspect, 0.001),
      );
    }
  });
}
