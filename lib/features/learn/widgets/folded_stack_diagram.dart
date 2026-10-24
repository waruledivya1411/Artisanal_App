import 'dart:math' as math;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';

/// Setup-guide emphasis for the two folded-stack steps before the camera.
enum FoldedStackGuideAccent {
  /// One rectangle in the dashed box — not a pile.
  singleInBox,

  /// Border strip on the long edge.
  borderOnSide,
}

/// Shared top-down folded sari diagram for the live camera and setup guides.
class FoldedStackOverlay {
  static const Color teal = Color(0xFF1B7574);
  static const Color blue = Color(0xFF7EAADB);
  static const Color brightBlue = Color(0xFFA9CCF0);

  /// Dashed blue frame with corner brackets.
  static void paintFrame(Canvas canvas, Rect frame) {
    final rrect = RRect.fromRectAndRadius(frame, const Radius.circular(10));
    _dashedRRect(canvas, rrect, blue, 2.5);
    _corners(canvas, frame);
  }

  /// A square, as big as fits comfortably in the frame. Fractions of the
  /// frame's width and height stretched it into a wide box on short screens.
  static Rect _sareeRect(Rect frame) {
    final side = math.min(frame.width * 0.92, frame.height * 0.92);
    return Rect.fromCenter(center: frame.center, width: side, height: side);
  }

  /// Folded sari shape with border strip — matches the live camera overlay.
  static void paintContent(
    Canvas canvas,
    Rect frame, {
    bool showLabels = true,
    FoldedStackGuideAccent? guideAccent,
  }) {
    final saree = _sareeRect(frame);
    final sareeRrect = RRect.fromRectAndRadius(saree, const Radius.circular(14));

    if (guideAccent == FoldedStackGuideAccent.singleInBox) {
      _paintSingleInBoxGuide(canvas, saree, sareeRrect);
      return;
    }

    canvas.drawRRect(sareeRrect, Paint()..color = const Color(0x22FFFFFF));
    canvas.drawRRect(
      sareeRrect,
      Paint()
        ..color = const Color(0xE8FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );

    final borderLeft = saree.left + saree.width * 0.78;
    final borderStrip = Rect.fromLTRB(
      borderLeft,
      saree.top,
      saree.right,
      saree.bottom,
    );

    if (guideAccent == FoldedStackGuideAccent.borderOnSide) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(borderStrip, const Radius.circular(0)),
        Paint()..color = const Color(0x661B7574),
      );
      canvas.drawLine(
        Offset(borderLeft, saree.top),
        Offset(borderLeft, saree.bottom),
        Paint()
          ..color = teal
          ..strokeWidth = 3.4,
      );
    } else {
      canvas.drawLine(
        Offset(borderLeft, saree.top),
        Offset(borderLeft, saree.bottom),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.6,
      );
    }

    if (showLabels) {
      final bodyCenter = Offset(
        saree.left + (borderLeft - saree.left) / 2,
        saree.center.dy,
      );
      final borderCenter = Offset(
        borderLeft + (saree.right - borderLeft) / 2,
        saree.center.dy,
      );
      final mutedBody = guideAccent == FoldedStackGuideAccent.borderOnSide;
      if (!mutedBody) {
        _label(canvas, 'Folded sari', bodyCenter);
      } else {
        _label(canvas, 'Folded sari', bodyCenter, muted: true);
      }
      _label(
        canvas,
        'Border',
        borderCenter,
        highlight: guideAccent == FoldedStackGuideAccent.borderOnSide,
      );
    }
  }

  static void _paintSingleInBoxGuide(
    Canvas canvas,
    Rect saree,
    RRect sareeRrect,
  ) {
    canvas.drawRRect(sareeRrect, Paint()..color = const Color(0x331B7574));
    canvas.drawRRect(
      sareeRrect,
      Paint()
        ..color = teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2,
    );
    _label(canvas, 'Folded sari', saree.center, highlight: true);
    _label(
      canvas,
      'One stack',
      Offset(saree.center.dx, saree.bottom + 18),
      highlight: true,
      fontSize: 10,
    );
  }

  static void _label(
    Canvas canvas,
    String text,
    Offset center, {
    bool highlight = false,
    bool muted = false,
    double fontSize = 11,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tr(text),
        style: appType(
          color: muted
              ? const Color(0x99FFFFFF)
              : highlight
                  ? teal
                  : Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ).copyWith(
          shadows: const [
            Shadow(color: Color(0xCC000000), blurRadius: 4),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: 120);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  static void _dashedRRect(Canvas canvas, RRect rrect, Color color, double width) {
    _dashedPath(canvas, Path()..addRRect(rrect), color, width);
  }

  static void _dashedPath(Canvas canvas, Path path, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    const dash = 10.0;
    const gap = 7.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d = end + gap;
      }
    }
  }

  static void _corners(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = brightBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const len = 22.0;
    final corners = <List<Offset>>[
      [
        rect.topLeft + const Offset(0, len),
        rect.topLeft,
        rect.topLeft + const Offset(len, 0),
      ],
      [
        rect.topRight + const Offset(-len, 0),
        rect.topRight,
        rect.topRight + const Offset(0, len),
      ],
      [
        rect.bottomRight + const Offset(0, -len),
        rect.bottomRight,
        rect.bottomRight + const Offset(-len, 0),
      ],
      [
        rect.bottomLeft + const Offset(len, 0),
        rect.bottomLeft,
        rect.bottomLeft + const Offset(0, -len),
      ],
    ];
    for (final c in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(c[0].dx, c[0].dy)
          ..lineTo(c[1].dx, c[1].dy)
          ..lineTo(c[2].dx, c[2].dy),
        paint,
      );
    }
  }
}

/// Setup-guide card: dark preview with the same overlay as the live camera.
class FoldedStackGuideDiagram extends StatelessWidget {
  const FoldedStackGuideDiagram({super.key, required this.accent});

  final FoldedStackGuideAccent accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FoldedStackGuidePainter(accent),
      size: Size.infinite,
    );
  }
}

class _FoldedStackGuidePainter extends CustomPainter {
  const _FoldedStackGuidePainter(this.accent);

  final FoldedStackGuideAccent accent;

  @override
  void paint(Canvas canvas, Size size) {
    final preview = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(preview, const Radius.circular(12)),
      Paint()..color = const Color(0xFF101614),
    );

    final frame = Rect.fromLTRB(
      size.width * 0.08,
      size.height * 0.10,
      size.width * 0.92,
      size.height * 0.88,
    );

    FoldedStackOverlay.paintFrame(canvas, frame);
    FoldedStackOverlay.paintContent(
      canvas,
      frame,
      guideAccent: accent,
    );
  }

  @override
  bool shouldRepaint(covariant _FoldedStackGuidePainter oldDelegate) =>
      oldDelegate.accent != accent;
}
