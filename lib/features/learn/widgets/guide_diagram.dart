import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:artisnal_app/features/learn/widgets/folded_stack_diagram.dart';

/// The line drawing that shows how to set a shot up.
enum GuideArt {
  /// A rod with the piece hanging straight off it.
  hang,

  /// The whole piece laid flat, every edge in view.
  spread,

  /// Thirds grid with the piece squared to it.
  grid,

  /// Phone held a hand-span above the cloth.
  distance,

  /// Low light raking across the weave at about 30 degrees.
  rake,

  /// A detail filling the centre of the frame.
  close,

  /// Cloth thrown over a form, falling in folds.
  drape,

  /// The border band along one edge.
  border,

  /// Folded stack — same overlay as the live camera (plain).
  foldedStack,
}

class GuideDiagram extends StatelessWidget {
  const GuideDiagram({super.key, required this.art});

  final GuideArt art;

  static const Color ink = Color(0xFF152322);
  static const Color teal = Color(0xFF1B7574);

  @override
  Widget build(BuildContext context) {
    switch (art) {
      case GuideArt.foldedStack:
        return const FoldedStackGuideDiagram();
      default:
        return CustomPaint(
          painter: _GuidePainter(art),
          size: Size.infinite,
          isComplex: true,
        );
    }
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
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(8, 12, 92, 88),
            const Radius.circular(3),
          ),
          faint,
        );
        final flat = Rect.fromLTRB(18, 20, 82, 80);
        canvas.drawRect(flat, fill);
        canvas.drawRect(flat, accent);
        canvas.drawLine(const Offset(68, 20), const Offset(68, 80), faint);
        canvas.drawLine(const Offset(18, 66), const Offset(82, 66), faint);

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

      case GuideArt.rake:
        // cloth flat, light coming in low from one side
        canvas.drawLine(const Offset(10, 74), const Offset(90, 74), solid);
        _arrow(canvas, accent, const Offset(16, 28), const Offset(60, 72));
        for (var x = 36.0; x <= 78; x += 10) {
          canvas.drawLine(Offset(x, 74), Offset(x + 5, 80), faint);
        }

      case GuideArt.close:
        canvas.drawRect(Rect.fromLTRB(10, 16, 90, 84), solid);
        final detail = Rect.fromLTRB(32, 34, 68, 66);
        canvas.drawRect(detail, fill);
        canvas.drawRect(detail, accent);

      case GuideArt.drape:
        // thrown over a form, falling away in folds
        canvas.drawLine(const Offset(18, 26), const Offset(82, 26), solid);
        final folds = Path()
          ..moveTo(30, 26)
          ..cubicTo(34, 50, 44, 62, 42, 84)
          ..moveTo(50, 26)
          ..cubicTo(54, 52, 62, 64, 58, 86)
          ..moveTo(68, 26)
          ..cubicTo(72, 48, 78, 60, 74, 80);
        canvas.drawPath(folds, accent);

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

      case GuideArt.foldedStack:
        break;
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
