import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Shared top-down folded sari diagram for the live camera and setup guides.
class FoldedStackOverlay {
  static const Color blue = Color(0xFF7EAADB);
  static const Color brightBlue = Color(0xFFA9CCF0);

  /// Dashed blue frame with corner brackets.
  static void paintFrame(Canvas canvas, Rect frame) {
    final rrect = RRect.fromRectAndRadius(frame, const Radius.circular(10));
    _dashedRRect(canvas, rrect, blue, 2.5);
    _corners(canvas, frame);
  }

  /// Folded sari shape with border strip — matches the live camera overlay.
  static void paintContent(
    Canvas canvas,
    Rect frame, {
    bool showLabels = true,
  }) {
    final saree = Rect.fromCenter(
      center: frame.center,
      width: frame.width * 0.78,
      height: frame.height * 0.52,
    );
    final sareeRrect = RRect.fromRectAndRadius(saree, const Radius.circular(14));

    canvas.drawRRect(sareeRrect, Paint()..color = const Color(0x22FFFFFF));
    canvas.drawRRect(
      sareeRrect,
      Paint()
        ..color = const Color(0xE8FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );

    final borderLeft = saree.left + saree.width * 0.78;
    canvas.drawLine(
      Offset(borderLeft, saree.top),
      Offset(borderLeft, saree.bottom),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.6,
    );

    if (showLabels) {
      final bodyCenter = Offset(
        saree.left + (borderLeft - saree.left) / 2,
        saree.center.dy,
      );
      final borderCenter = Offset(
        borderLeft + (saree.right - borderLeft) / 2,
        saree.center.dy,
      );
      _label(canvas, 'Folded sari', bodyCenter);
      _label(canvas, 'Border', borderCenter);
    }
  }

  static void _label(Canvas canvas, String text, Offset center) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          shadows: [
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
  const FoldedStackGuideDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _FoldedStackGuidePainter(),
      size: Size.infinite,
    );
  }
}

class _FoldedStackGuidePainter extends CustomPainter {
  const _FoldedStackGuidePainter();

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
    FoldedStackOverlay.paintContent(canvas, frame);
  }

  @override
  bool shouldRepaint(covariant _FoldedStackGuidePainter oldDelegate) => false;
}
