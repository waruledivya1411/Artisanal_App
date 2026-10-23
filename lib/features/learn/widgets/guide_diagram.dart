import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The line drawing that shows how to set a shot up.
enum GuideArt {
  /// A rod with the piece hanging straight off it.
  hang,

  /// The whole piece laid flat, every edge in view.
  spread,

  /// Mekhala and sador laid side by side.
  mekhalaSpread,

  /// Thirds grid with the piece squared to it.
  grid,

  /// Phone held a hand-span above the cloth.
  distance,

  /// A detail filling the centre of the frame.
  close,

  /// The border band along one edge.
  border,

  /// Folded stack — one sari, border down the right edge.
  foldedStackInBox,

  /// Hanging display step 1 — centre on the vertical axis.
  hangingDisplayCentre,

  /// Hanging display step 2 — fringe and symmetric edges.
  hangingDisplayFringe,

  /// Mekhala and sador on two hangers: short piece left, long piece right.
  mekhalaHanging,

  /// Mekhala folded on top of the sador, border and tassels along the bottom.
  mekhalaFolded,

  /// Stole hanging straight off a rod, tassels along the bottom.
  stoleFull,

  /// One folded stole, border and tassels along the front edge.
  stoleFolded,

  /// Shawl hanging off a rod, border on the side and tassels along the hem.
  shawlFull,

  /// One folded shawl, side border and tassels along the front.
  shawlFolded,

  /// Close view: cushion on one side of a sofa, not the whole sofa.
  cushionSofa,

  /// Cushion cover laid flat and shot from above.
  cushionFlat,

  /// Gamusa hanging on a rod, borders both sides and tassels at the hem.
  gamusaFull,

  /// One folded gamusa, end border across and tassels along the front.
  gamusaFolded,

  /// Jod kappur on a rod: wide cloth on the left, narrow piece with tassels.
  jodHanging,

  /// Jod kappur folded: wide cloth beside the smaller tasseled piece.
  jodFolded,

  /// Yardage on a rod: wide plain cloth, motifs scattered across it.
  yardageHanging,

  /// Close on yardage: the weave and scattered motifs fill the frame.
  yardageClose,
}

class GuideDiagram extends StatelessWidget {
  const GuideDiagram({super.key, required this.art});

  final GuideArt art;

  static const Color ink = Color(0xFF152322);
  static const Color teal = Color(0xFF1B7574);

  @override
  Widget build(BuildContext context) {
        return CustomPaint(
          painter: _GuidePainter(art),
          size: Size.infinite,
          isComplex: true,
        );
  }
}

class _GuidePainter extends CustomPainter {
  const _GuidePainter(this.art);

  final GuideArt art;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw in a 100x100 space and scale, so every diagram lines up.
    final side = size.shortestSide;
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);

    final solid = Paint()
      ..color = GuideDiagram.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final accent = Paint()
      ..color = GuideDiagram.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final faint = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final fill = Paint()..color = const Color(0x141B7574);

    switch (art) {
      case GuideArt.hang:
        // rod, then the piece hanging square off it
        canvas.drawLine(const Offset(14, 22), const Offset(86, 22), solid);
        final cloth = Rect.fromLTRB(36, 22, 64, 86);
        canvas.drawRect(cloth, fill);
        canvas.drawRect(cloth, accent);
        canvas.drawLine(const Offset(50, 22), const Offset(50, 86), faint);
        _tick(canvas, faint, 36, 64, 86);

      case GuideArt.spread:
        // plain sheet, the whole piece laid flat inside it
        // An upright rectangle, the same shape as the camera frame for this
        // shot (0.70), so the step and the shot match.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(18, 8, 82, 92),
            const Radius.circular(3),
          ),
          faint,
        );
        final flat = Rect.fromLTRB(27, 17, 73, 83);
        canvas.drawRect(flat, fill);
        canvas.drawRect(flat, accent);
        // border down the side, pallu across the end
        canvas.drawLine(const Offset(64, 17), const Offset(64, 83), faint);
        canvas.drawLine(const Offset(27, 72), const Offset(73, 72), faint);

      case GuideArt.mekhalaSpread:
        _mekhalaPair(canvas, fill, accent, faint);

      case GuideArt.foldedStackInBox:
        _foldedSari(canvas, fill, accent, faint);

      case GuideArt.grid:
        _thirds(canvas, faint);
        final piece = Rect.fromLTRB(33.3, 25, 66.6, 80);
        canvas.drawRect(piece, fill);
        canvas.drawRect(piece, accent);

      case GuideArt.distance:
        // phone above, cloth below, the gap called out
        final phone = Rect.fromLTRB(38, 10, 62, 34);
        canvas.drawRRect(
          RRect.fromRectAndRadius(phone, const Radius.circular(4)),
          solid,
        );
        canvas.drawLine(const Offset(12, 82), const Offset(88, 82), solid);
        _arrow(canvas, accent, const Offset(50, 38), const Offset(50, 78));

      case GuideArt.close:
        _closeTexture(canvas, fill, accent, faint);

      case GuideArt.border:
        // Same layout as the camera frame for this shot: upright piece,
        // motif window top left, border strip down the right.
        const frame = Rect.fromLTRB(18, 11, 82, 89);
        Rect inside(double l, double t, double r, double b) => Rect.fromLTRB(
          frame.left + frame.width * l,
          frame.top + frame.height * t,
          frame.left + frame.width * r,
          frame.top + frame.height * b,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(frame, const Radius.circular(3)),
          solid,
        );

        final strip = inside(0.74, 0.05, 0.93, 0.95);
        canvas.drawRect(strip, fill);
        canvas.drawRect(strip, accent);
        for (var y = strip.top + 6; y < strip.bottom - 3; y += 6) {
          canvas.drawLine(
            Offset(strip.left + 1.5, y),
            Offset(strip.right - 1.5, y),
            faint,
          );
        }

        final window = inside(0.07, 0.07, 0.62, 0.48);
        canvas.drawRRect(
          RRect.fromRectAndRadius(window, const Radius.circular(2.5)),
          accent,
        );
        _label(canvas, 'Motif', window.center);
        _label(canvas, 'Border', strip.center, boxed: true, vertical: true);

      case GuideArt.hangingDisplayCentre:
        _hangingSari(canvas, fill, accent, faint, showEnd: false);
      case GuideArt.hangingDisplayFringe:
        _hangingSari(canvas, fill, accent, faint, showEnd: true);
      case GuideArt.mekhalaHanging:
        _mekhalaHanging(canvas, fill, accent, faint);
      case GuideArt.mekhalaFolded:
        _mekhalaFolded(canvas, fill, accent, faint);
      case GuideArt.stoleFull:
        _stoleFull(canvas, fill, accent, faint);
      case GuideArt.stoleFolded:
        _stoleFolded(canvas, fill, accent, faint);
      case GuideArt.shawlFull:
        _shawlFull(canvas, fill, accent, faint);
      case GuideArt.shawlFolded:
        _shawlFolded(canvas, fill, accent, faint);
      case GuideArt.cushionSofa:
        _cushionSofa(canvas, fill, accent, faint);
      case GuideArt.cushionFlat:
        _cushionFlat(canvas, fill, accent, faint);
      case GuideArt.gamusaFull:
        _gamusaFull(canvas, fill, accent, faint);
      case GuideArt.gamusaFolded:
        _gamusaFolded(canvas, fill, accent, faint);
      case GuideArt.jodHanging:
        _jodHanging(canvas, fill, accent, faint);
      case GuideArt.jodFolded:
        _jodFolded(canvas, fill, accent, faint);
      case GuideArt.yardageHanging:
        _yardageHanging(canvas, fill, accent, faint);
      case GuideArt.yardageClose:
        _yardageClose(canvas, fill, accent, faint);
    }
  }

  /// Straight sari on a rod, matching the hanging cotton shot: side border
  /// on the left, small motifs, end border across the bottom.
  void _hangingSari(
    Canvas canvas,
    Paint fill,
    Paint accent,
    Paint faint, {
    required bool showEnd,
  }) {
    const frame = Rect.fromLTRB(18, 8, 82, 92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    const cloth = Rect.fromLTRB(34, 20, 66, 86);
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, accent);

    canvas.drawLine(const Offset(30, 18), const Offset(70, 18), accent);
    canvas.drawCircle(
      const Offset(50, 18),
      1.8,
      Paint()..color = GuideDiagram.teal,
    );

    final borderRight = cloth.left + cloth.width * 0.22;
    final side = Rect.fromLTRB(cloth.left, cloth.top, borderRight, cloth.bottom);
    canvas.drawRect(
      side,
      Paint()..color = const Color(0x331B7574),
    );
    canvas.drawLine(Offset(borderRight, cloth.top), Offset(borderRight, cloth.bottom), accent);
    final band = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.7)
      ..strokeWidth = 1.2;
    final inner = cloth.left + side.width * 0.35;
    final outer = cloth.left + side.width * 0.7;
    canvas.drawLine(Offset(inner, cloth.top + 1), Offset(inner, cloth.bottom - 1), band);
    canvas.drawLine(Offset(outer, cloth.top + 1), Offset(outer, cloth.bottom - 1), band);

    _foldedMotifs(
      canvas,
      Rect.fromLTRB(borderRight, cloth.top, cloth.right, cloth.bottom - 16),
    );

    final palluTop = cloth.top + cloth.height * (showEnd ? 0.68 : 0.74);
    canvas.drawRect(
      Rect.fromLTRB(cloth.left, palluTop, cloth.right, cloth.bottom),
      Paint()..color = showEnd ? const Color(0x401B7574) : const Color(0x221B7574),
    );
    final lines = showEnd ? 4 : 2;
    for (var i = 1; i <= lines; i++) {
      final y = palluTop + (cloth.bottom - palluTop) * i / (lines + 1);
      canvas.drawLine(
        Offset(cloth.left, y),
        Offset(cloth.right, y),
        showEnd ? accent : faint,
      );
    }

    if (!showEnd) {
      canvas.drawLine(
        Offset(cloth.center.dx, cloth.top),
        Offset(cloth.center.dx, cloth.bottom),
        faint,
      );
    }
  }

  /// Shawl on a rod: wider than a stole, border down the right, band and tassels.
  void _shawlFull(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(12, 8, 88, 92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );
    canvas.drawLine(const Offset(18, 16), const Offset(82, 16), accent);

    const cloth = Rect.fromLTRB(24, 18, 76, 78);
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, accent);
    canvas.drawLine(const Offset(30, 18), const Offset(30, 78), faint);
    canvas.drawRect(
      const Rect.fromLTRB(64, 18, 76, 78),
      Paint()..color = const Color(0x221B7574),
    );
    canvas.drawLine(const Offset(64, 18), const Offset(64, 78), accent);
    canvas.drawLine(const Offset(70, 18), const Offset(70, 78), faint);
    _foldedMotifs(canvas, const Rect.fromLTRB(32, 22, 62, 58));
    canvas.drawLine(const Offset(24, 60), const Offset(76, 60), accent);
    canvas.drawLine(const Offset(24, 68), const Offset(76, 68), faint);
    for (final x in [30.0, 38.0, 46.0, 54.0, 62.0, 70.0]) {
      canvas.drawLine(Offset(x, 78), Offset(x, 84), accent);
    }
  }

  /// One folded shawl: border down the right side, band and tassels at the front.
  void _shawlFolded(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(12, 10, 88, 90);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    const shawl = Rect.fromLTRB(14, 24, 86, 70);
    canvas.drawRect(shawl, fill);
    canvas.drawRect(shawl, accent);
    canvas.drawLine(const Offset(22, 24), const Offset(22, 70), faint);
    canvas.drawRect(
      const Rect.fromLTRB(70, 24, 86, 70),
      Paint()..color = const Color(0x221B7574),
    );
    canvas.drawLine(const Offset(70, 24), const Offset(70, 70), accent);
    canvas.drawLine(const Offset(78, 24), const Offset(78, 70), faint);
    _foldedMotifs(canvas, const Rect.fromLTRB(24, 28, 68, 50));
    canvas.drawLine(const Offset(14, 54), const Offset(86, 54), accent);
    canvas.drawLine(const Offset(14, 62), const Offset(86, 62), faint);
    for (final x in [22.0, 32.0, 42.0, 52.0, 62.0, 72.0, 80.0]) {
      canvas.drawLine(Offset(x, 70), Offset(x, 78), accent);
    }
  }

  /// One side of a sofa: left arm, back behind, seat under, pillow in front.
  /// The right side runs off the frame, so it is not a whole sofa.
  void _cushionSofa(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(8, 8, 92, 92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    final back = Path()
      ..moveTo(24, 48)
      ..lineTo(24, 22)
      ..quadraticBezierTo(24, 14, 32, 14)
      ..lineTo(92, 14)
      ..lineTo(92, 48)
      ..close();
    canvas.drawPath(back, fill);
    canvas.drawPath(back, accent);

    final seat = Path()
      ..moveTo(28, 60)
      ..lineTo(92, 60)
      ..lineTo(92, 84)
      ..lineTo(20, 84)
      ..quadraticBezierTo(20, 68, 28, 60)
      ..close();
    canvas.drawPath(seat, fill);
    canvas.drawPath(seat, accent);

    final arm = RRect.fromRectAndRadius(
      const Rect.fromLTRB(12, 38, 32, 82),
      const Radius.circular(6),
    );
    canvas.drawRRect(arm, Paint()..color = Colors.white);
    canvas.drawRRect(arm, fill);
    canvas.drawRRect(arm, accent);

    final pillow = RRect.fromRectAndRadius(
      const Rect.fromLTRB(34, 26, 80, 68),
      const Radius.circular(10),
    );
    canvas.drawRRect(pillow, Paint()..color = Colors.white);
    canvas.drawRRect(pillow, fill);
    canvas.drawRRect(pillow, accent);
    canvas.drawLine(const Offset(42, 40), const Offset(72, 40), faint);
    canvas.drawLine(const Offset(42, 46), const Offset(72, 46), accent);
  }

  /// Plump square cushion from above: piping on all four sides, a motif in the middle.
  void _cushionFlat(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(10, 10, 90, 90);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    final cushion = RRect.fromRectAndRadius(
      const Rect.fromLTRB(18, 20, 82, 80),
      const Radius.circular(12),
    );
    canvas.drawRRect(cushion, fill);
    canvas.drawRRect(cushion, accent);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(26, 28, 74, 72),
        const Radius.circular(8),
      ),
      faint,
    );

    final motif = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    const center = Offset(50, 50);
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - 8)
        ..lineTo(center.dx + 6, center.dy)
        ..lineTo(center.dx, center.dy + 8)
        ..lineTo(center.dx - 6, center.dy)
        ..close(),
      motif,
    );
  }

  /// Gamusa on a rod: borders down both sides, a wide end band, tassels below.
  void _gamusaFull(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(14, 8, 86, 92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );
    const cloth = Rect.fromLTRB(32, 18, 68, 76);
    canvas.drawLine(const Offset(22, 18), const Offset(78, 18), accent);
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, accent);
    canvas.drawLine(const Offset(36, 18), const Offset(36, 76), faint);
    canvas.drawLine(const Offset(40, 18), const Offset(40, 76), accent);
    canvas.drawLine(const Offset(60, 18), const Offset(60, 76), accent);
    canvas.drawLine(const Offset(64, 18), const Offset(64, 76), faint);
    canvas.drawRect(
      const Rect.fromLTRB(32, 54, 68, 70),
      Paint()..color = const Color(0x221B7574),
    );
    canvas.drawLine(const Offset(32, 54), const Offset(68, 54), accent);
    canvas.drawLine(const Offset(32, 58), const Offset(68, 58), faint);
    canvas.drawLine(const Offset(32, 66), const Offset(68, 66), faint);
    canvas.drawLine(const Offset(32, 70), const Offset(68, 70), accent);
    final motif = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    for (final x in [46.0, 54.0]) {
      const y = 62.0;
      canvas.drawPath(
        Path()
          ..moveTo(x, y - 2.6)
          ..lineTo(x + 2.2, y)
          ..lineTo(x, y + 2.6)
          ..lineTo(x - 2.2, y)
          ..close(),
        motif,
      );
    }
    for (final x in [36.0, 42.0, 48.0, 54.0, 60.0, 66.0]) {
      canvas.drawLine(Offset(x, 76), Offset(x, 86), accent);
    }
  }

  /// Folded gamusa from above: end border across, side border on the right, tassels.
  void _gamusaFolded(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(10, 12, 90, 88);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    const cloth = Rect.fromLTRB(14, 28, 86, 68);
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, accent);
    canvas.drawRect(
      const Rect.fromLTRB(14, 42, 68, 58),
      Paint()..color = const Color(0x221B7574),
    );
    canvas.drawLine(const Offset(14, 42), const Offset(68, 42), accent);
    canvas.drawLine(const Offset(14, 46), const Offset(68, 46), faint);
    canvas.drawLine(const Offset(14, 54), const Offset(68, 54), faint);
    canvas.drawLine(const Offset(14, 58), const Offset(68, 58), accent);
    final motif = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    for (final x in [26.0, 38.0, 50.0, 62.0]) {
      const y = 50.0;
      canvas.drawPath(
        Path()
          ..moveTo(x, y - 2.4)
          ..lineTo(x + 2.1, y)
          ..lineTo(x, y + 2.4)
          ..lineTo(x - 2.1, y)
          ..close(),
        motif,
      );
    }
    canvas.drawRect(
      const Rect.fromLTRB(68, 28, 86, 68),
      Paint()..color = const Color(0x221B7574),
    );
    canvas.drawLine(const Offset(68, 28), const Offset(68, 68), accent);
    canvas.drawLine(const Offset(74, 28), const Offset(74, 68), faint);
    canvas.drawLine(const Offset(80, 28), const Offset(80, 68), faint);
    for (final x in [22.0, 32.0, 42.0, 52.0, 62.0, 72.0, 80.0]) {
      canvas.drawLine(Offset(x, 68), Offset(x, 78), accent);
    }
  }

  /// Wide cloth and a narrower tasseled piece, both on one rod.
  void _jodHanging(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(8, 8, 92, 92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );
    canvas.drawLine(const Offset(14, 16), const Offset(86, 16), accent);

    const wide = Rect.fromLTRB(14, 18, 60, 78);
    canvas.drawRect(wide, fill);
    canvas.drawRect(wide, accent);
    canvas.drawLine(const Offset(24, 18), const Offset(24, 58), faint);
    canvas.drawLine(const Offset(32, 18), const Offset(32, 58), accent);
    _templePeaks(canvas, 14, 60, 58, accent);
    canvas.drawRect(
      const Rect.fromLTRB(14, 66, 60, 78),
      Paint()..color = const Color(0x221B7574),
    );
    canvas.drawLine(const Offset(14, 66), const Offset(60, 66), accent);
    canvas.drawLine(const Offset(14, 72), const Offset(60, 72), faint);

    const narrow = Rect.fromLTRB(68, 18, 84, 60);
    canvas.drawRect(narrow, fill);
    canvas.drawRect(narrow, accent);
    canvas.drawLine(const Offset(74, 18), const Offset(74, 46), faint);
    canvas.drawLine(const Offset(68, 46), const Offset(84, 46), accent);
    canvas.drawLine(const Offset(68, 52), const Offset(84, 52), faint);
    for (final x in [70.0, 74.0, 78.0, 82.0]) {
      canvas.drawLine(Offset(x, 60), Offset(x, 70), accent);
    }
  }

  /// Wide folded cloth on the left, smaller tasseled piece beside it.
  void _jodFolded(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(8, 12, 92, 88);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    const wide = Rect.fromLTRB(8, 20, 64, 66);
    canvas.drawRect(wide, fill);
    canvas.drawRect(wide, accent);
    canvas.drawRect(
      const Rect.fromLTRB(8, 50, 64, 66),
      Paint()..color = const Color(0x221B7574),
    );
    canvas.drawLine(const Offset(8, 50), const Offset(64, 50), accent);
    canvas.drawLine(const Offset(8, 58), const Offset(64, 58), faint);
    _templePeaks(canvas, 8, 64, 44, accent, drop: 5);
    for (final x in [24.0, 28.0, 36.0, 40.0]) {
      canvas.drawLine(Offset(x, 20), Offset(x, 66), x == 28 || x == 40 ? accent : faint);
    }

    const small = Rect.fromLTRB(58, 36, 90, 60);
    canvas.drawRect(small, Paint()..color = Colors.white);
    canvas.drawRect(small, fill);
    canvas.drawRect(small, accent);
    canvas.drawLine(const Offset(66, 36), const Offset(66, 60), faint);
    canvas.drawLine(const Offset(70, 36), const Offset(70, 60), accent);
    canvas.drawLine(const Offset(58, 44), const Offset(90, 44), accent);
    canvas.drawLine(const Offset(58, 52), const Offset(90, 52), faint);
    for (final x in [62.0, 68.0, 74.0, 80.0, 86.0]) {
      canvas.drawLine(Offset(x, 60), Offset(x, 74), accent);
    }
  }

  void _templePeaks(
    Canvas canvas,
    double left,
    double right,
    double top,
    Paint paint, {
    double drop = 7,
  }) {
    final path = Path()..moveTo(left, top + drop);
    const count = 6;
    final step = (right - left) / count;
    for (var i = 0; i < count; i++) {
      final x = left + step * i;
      path
        ..lineTo(x + step / 2, top)
        ..lineTo(x + step, top + drop);
    }
    canvas.drawPath(path, paint);
  }

  /// Stole on a rod: side borders, a band near the end, tassels along the hem.
  void _stoleFull(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(14, 8, 86, 92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );
    canvas.drawLine(const Offset(24, 16), const Offset(76, 16), accent);

    const cloth = Rect.fromLTRB(34, 18, 66, 78);
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, accent);
    canvas.drawLine(const Offset(40, 18), const Offset(40, 78), faint);
    canvas.drawLine(const Offset(60, 18), const Offset(60, 78), faint);
    _foldedMotifs(canvas, const Rect.fromLTRB(42, 24, 58, 58));
    canvas.drawLine(const Offset(34, 62), const Offset(66, 62), accent);
    canvas.drawLine(const Offset(34, 68), const Offset(66, 68), faint);
    for (final x in [38.0, 44.0, 50.0, 56.0, 62.0]) {
      canvas.drawLine(Offset(x, 78), Offset(x, 84), accent);
    }
  }

  /// One folded stole from above: borders at the sides, tassels along the front.
  void _stoleFolded(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(12, 10, 88, 90);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    const stole = Rect.fromLTRB(16, 26, 84, 70);
    canvas.drawRect(stole, fill);
    canvas.drawRect(stole, accent);
    canvas.drawLine(const Offset(24, 26), const Offset(24, 70), faint);
    canvas.drawLine(const Offset(76, 26), const Offset(76, 70), faint);
    _foldedMotifs(canvas, const Rect.fromLTRB(28, 30, 72, 52));
    canvas.drawLine(const Offset(16, 54), const Offset(84, 54), accent);
    canvas.drawLine(const Offset(16, 60), const Offset(84, 60), faint);
    for (final x in [24.0, 34.0, 44.0, 54.0, 64.0, 74.0]) {
      canvas.drawLine(Offset(x, 70), Offset(x, 78), accent);
    }
  }

  /// Shot from above: mekhela folded on top, sador underneath with its border
  /// and tassels along the bottom.
  void _mekhalaFolded(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(12, 10, 88, 90);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    const sador = Rect.fromLTRB(14, 34, 84, 78);
    canvas.drawRect(sador, fill);
    canvas.drawRect(sador, accent);
    _foldedMotifs(canvas, const Rect.fromLTRB(18, 63, 72, 69));
    canvas.drawLine(const Offset(14, 70), const Offset(84, 70), accent);
    canvas.drawLine(const Offset(14, 74), const Offset(84, 74), faint);
    for (final x in [66.0, 70.0, 74.0, 78.0]) {
      canvas.drawLine(Offset(x, 78), Offset(x, 84), accent);
    }

    const mekhela = Rect.fromLTRB(18, 16, 80, 62);
    canvas.drawRect(mekhela, Paint()..color = Colors.white);
    canvas.drawRect(mekhela, fill);
    canvas.drawRect(mekhela, accent);
    _foldedMotifs(canvas, const Rect.fromLTRB(20, 18, 62, 60));
    canvas.drawLine(const Offset(64, 16), const Offset(64, 62), accent);
    canvas.drawLine(const Offset(70, 16), const Offset(70, 62), faint);
    canvas.drawLine(const Offset(75, 16), const Offset(75, 62), faint);
  }

  /// Two hangers on one rod. The mekhela is shorter, with the border folded
  /// across the bottom. The sador hangs longer, with side borders and tassels.
  void _mekhalaHanging(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(10, 8, 90, 92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    canvas.drawLine(const Offset(14, 16), const Offset(86, 16), accent);
    _hanger(canvas, 32, 22, 44);
    _hanger(canvas, 66, 50, 82);

    const mekhela = Rect.fromLTRB(24, 24, 42, 68);
    canvas.drawRect(mekhela, fill);
    canvas.drawRect(mekhela, accent);
    for (final y in [52.0, 56.0, 60.0, 64.0]) {
      canvas.drawLine(Offset(mekhela.left, y), Offset(mekhela.right, y), faint);
    }

    const sador = Rect.fromLTRB(50, 24, 80, 80);
    canvas.drawRect(sador, fill);
    canvas.drawRect(sador, accent);
    canvas.drawLine(const Offset(56, 24), const Offset(56, 80), faint);
    canvas.drawLine(const Offset(74, 24), const Offset(74, 80), faint);
    _foldedMotifs(canvas, const Rect.fromLTRB(56, 28, 74, 66));
    canvas.drawLine(const Offset(50, 68), const Offset(80, 68), accent);
    canvas.drawLine(const Offset(50, 74), const Offset(80, 74), faint);
    for (final x in [56.0, 62.0, 68.0, 74.0]) {
      canvas.drawLine(Offset(x, 80), Offset(x, 86), accent);
    }
  }

  void _hanger(Canvas canvas, double cx, double left, double right) {
    final hook = Paint()
      ..color = GuideDiagram.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, 16), Offset(cx, 19.2), hook);
    canvas.drawLine(Offset(left, 24), Offset(cx, 18.4), hook);
    canvas.drawLine(Offset(right, 24), Offset(cx, 18.4), hook);
    canvas.drawLine(Offset(left, 24), Offset(right, 24), hook);
  }

  /// Two pieces side by side, each with a border along the bottom.
  void _mekhalaPair(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(14, 10, 86, 90);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );
    const mekhela = Rect.fromLTRB(20, 16, 46, 78);
    const sador = Rect.fromLTRB(52, 16, 80, 78);
    canvas.drawRect(mekhela, fill);
    canvas.drawRect(sador, fill);
    canvas.drawRect(mekhela, accent);
    canvas.drawRect(sador, accent);
    canvas.drawLine(const Offset(20, 64), const Offset(46, 64), accent);
    canvas.drawLine(const Offset(52, 58), const Offset(80, 58), accent);
    for (final x in [58.0, 64.0, 70.0, 76.0]) {
      canvas.drawLine(Offset(x, 78), Offset(x, 84), accent);
    }
  }

  /// Yardage on a rod: wide cloth, soft folds, stars scattered across. No border.
  void _yardageHanging(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(8, 8, 92, 92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );
    const cloth = Rect.fromLTRB(16, 16, 84, 82);
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, accent);
    canvas.drawLine(const Offset(10, 16), const Offset(90, 16), accent);
    canvas.drawLine(const Offset(36, 16), const Offset(36, 82), faint);
    canvas.drawLine(const Offset(58, 16), const Offset(58, 82), faint);
    final star = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final dim = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    const spots = <List<double>>[
      [0.22, 0.14],
      [0.7, 0.18],
      [0.46, 0.3],
      [0.18, 0.4],
      [0.82, 0.46],
      [0.36, 0.54],
      [0.64, 0.62],
      [0.24, 0.72],
      [0.78, 0.76],
      [0.5, 0.84],
      [0.16, 0.9],
      [0.68, 0.92],
    ];
    for (var i = 0; i < spots.length; i++) {
      final c = Offset(
        cloth.left + cloth.width * spots[i][0],
        cloth.top + cloth.height * spots[i][1],
      );
      _star(canvas, c, i.isEven ? 2.4 : 1.8, i.isEven ? star : dim);
    }
  }

  /// Close-up of yardage: weave and scattered stars fill the whole frame.
  void _yardageClose(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(10, 10, 90, 90);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );
    const cloth = Rect.fromLTRB(14, 14, 86, 86);
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, accent);
    for (final x in [28.0, 42.0, 56.0, 70.0]) {
      canvas.drawLine(Offset(x, cloth.top), Offset(x, cloth.bottom), faint);
    }
    for (final y in [28.0, 42.0, 56.0, 70.0]) {
      canvas.drawLine(Offset(cloth.left, y), Offset(cloth.right, y), faint);
    }
    final star = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final dim = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    const spots = <List<double>>[
      [0.2, 0.18],
      [0.78, 0.16],
      [0.48, 0.34],
      [0.14, 0.48],
      [0.84, 0.52],
      [0.36, 0.62],
      [0.66, 0.74],
      [0.22, 0.84],
    ];
    for (var i = 0; i < spots.length; i++) {
      final c = Offset(
        cloth.left + cloth.width * spots[i][0],
        cloth.top + cloth.height * spots[i][1],
      );
      _star(canvas, c, i.isEven ? 3.2 : 2.4, i.isEven ? star : dim);
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final arm = r * 0.32;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + arm, c.dy - arm)
        ..lineTo(c.dx + r, c.dy)
        ..lineTo(c.dx + arm, c.dy + arm)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - arm, c.dy + arm)
        ..lineTo(c.dx - r, c.dy)
        ..lineTo(c.dx - arm, c.dy - arm)
        ..close(),
      paint,
    );
  }

  /// Close-up: the weave fills the frame, threads parallel to the edges.
  void _closeTexture(Canvas canvas, Paint fill, Paint accent, Paint faint) {
    const frame = Rect.fromLTRB(16, 12, 84, 88);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    const cloth = Rect.fromLTRB(22, 20, 78, 80);
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, accent);

    for (final x in [36.0, 50.0, 64.0]) {
      canvas.drawLine(Offset(x, cloth.top), Offset(x, cloth.bottom), faint);
    }
    for (final y in [35.0, 50.0, 65.0]) {
      canvas.drawLine(Offset(cloth.left, y), Offset(cloth.right, y), faint);
    }
    _foldedMotifs(canvas, cloth);
  }

  /// One folded sari from above, matching the cotton folded shot: a single
  /// stack, small motifs on the body, patterned border down the right edge.
  void _foldedSari(
    Canvas canvas,
    Paint fill,
    Paint accent,
    Paint faint,
  ) {
    const frame = Rect.fromLTRB(18, 8, 82, 92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(3)),
      faint,
    );

    // Wide single stack, the same shape as the folded photo.
    final saree = Rect.fromCenter(
      center: frame.center,
      width: frame.width * 0.86,
      height: frame.height * 0.58,
    );
    final radius = RRect.fromRectAndRadius(saree, const Radius.circular(2));
    canvas.drawRRect(radius, fill);
    canvas.drawRRect(radius, accent);

    final borderLeft = saree.left + saree.width * 0.74;
    final body = Rect.fromLTRB(saree.left, saree.top, borderLeft, saree.bottom);
    _foldedMotifs(canvas, body);

    final strip = RRect.fromRectAndCorners(
      Rect.fromLTRB(borderLeft, saree.top, saree.right, saree.bottom),
      topRight: const Radius.circular(2),
      bottomRight: const Radius.circular(2),
    );
    canvas.drawRRect(
      strip,
      Paint()..color = const Color(0x331B7574),
    );
    canvas.drawLine(
      Offset(borderLeft, saree.top),
      Offset(borderLeft, saree.bottom),
      accent,
    );
    // Patterned border: two bands inside the right-hand strip.
    final band = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final inner = borderLeft + (saree.right - borderLeft) * 0.28;
    final outer = borderLeft + (saree.right - borderLeft) * 0.72;
    canvas.drawLine(Offset(inner, saree.top + 2), Offset(inner, saree.bottom - 2), band);
    canvas.drawLine(Offset(outer, saree.top + 2), Offset(outer, saree.bottom - 2), band);
  }

  void _foldedMotifs(Canvas canvas, Rect body) {
    final motif = Paint()
      ..color = GuideDiagram.teal.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    const spots = <List<double>>[
      [0.22, 0.28],
      [0.48, 0.22],
      [0.72, 0.34],
      [0.30, 0.55],
      [0.58, 0.62],
      [0.78, 0.72],
      [0.18, 0.78],
    ];
    for (final spot in spots) {
      final c = Offset(
        body.left + body.width * spot[0],
        body.top + body.height * spot[1],
      );
      final diamond = Path()
        ..moveTo(c.dx, c.dy - 1.6)
        ..lineTo(c.dx + 1.3, c.dy)
        ..lineTo(c.dx, c.dy + 1.6)
        ..lineTo(c.dx - 1.3, c.dy)
        ..close();
      canvas.drawPath(diamond, motif);
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset centre, {
    bool boxed = false,
    bool vertical = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: GuideDiagram.ink,
          fontSize: 5.5,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    // Run up a narrow strip rather than spilling across it.
    if (vertical) canvas.rotate(-math.pi / 2);
    final topLeft = Offset(-painter.width / 2, -painter.height / 2);
    if (boxed) {
      // Sits on the strip's ticks, so give it a plain backing.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            topLeft.dx - 1.2,
            topLeft.dy - 1,
            painter.width + 2.4,
            painter.height + 2,
          ),
          const Radius.circular(1.2),
        ),
        Paint()..color = Colors.white,
      );
    }
    painter.paint(canvas, topLeft);
    canvas.restore();
  }

  void _thirds(Canvas canvas, Paint p) {
    for (final v in [33.3, 66.6]) {
      canvas.drawLine(Offset(v, 8), Offset(v, 92), p);
      canvas.drawLine(Offset(8, v), Offset(92, v), p);
    }
  }

  void _tick(Canvas canvas, Paint p, double x1, double x2, double y) {
    canvas.drawLine(Offset(x1, y + 6), Offset(x2, y + 6), p);
  }

  void _arrow(Canvas canvas, Paint p, Offset from, Offset to) {
    canvas.drawLine(from, to, p);
    final dir = (to - from) / (to - from).distance;
    final back = to - dir * 8;
    final side = Offset(-dir.dy, dir.dx) * 4;
    canvas.drawLine(to, back + side, p);
    canvas.drawLine(to, back - side, p);
  }

  @override
  bool shouldRepaint(covariant _GuidePainter oldDelegate) =>
      oldDelegate.art != art;
}
