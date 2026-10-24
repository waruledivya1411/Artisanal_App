import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';

import 'package:artisnal_app/features/learn/widgets/folded_stack_diagram.dart';

/// Setup-guide emphasis for hanging-display steps before the camera.
enum HangingDisplayGuideAccent {
  /// Rod and centre vertical — piece on the axis.
  centreOnAxis,

  /// Even fringes and symmetric side edges.
  fringeSymmetric,
}

/// Shared hanging overlay for the live camera and setup guides.
class HangingDisplayOverlay {
  static const Color teal = Color(0xFF1B7574);

  static void paintFrame(Canvas canvas, Rect frame) {
    FoldedStackOverlay.paintFrame(canvas, frame);
  }

  static void paintContent(
    Canvas canvas,
    Rect frame, {
    HangingDisplayGuideAccent? guideAccent,
  }) {
    final cx = frame.center.dx;
    final midY = frame.center.dy;
    final rodY = frame.top + 10;
    final rodOverhang = frame.width * 0.07;

    final faintCross = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.4;
    final centreAxis = Paint()
      ..color = teal
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    if (guideAccent == HangingDisplayGuideAccent.centreOnAxis) {
      canvas.drawLine(
        Offset(frame.left, midY),
        Offset(frame.right, midY),
        Paint()
          ..color = const Color(0x66FFFFFF)
          ..strokeWidth = 1.4,
      );
      canvas.drawLine(
        Offset(cx, frame.top),
        Offset(cx, frame.bottom),
        centreAxis,
      );
    } else {
      canvas.drawLine(
        Offset(frame.left, midY),
        Offset(frame.right, midY),
        faintCross,
      );
      canvas.drawLine(
        Offset(cx, frame.top),
        Offset(cx, frame.bottom),
        faintCross,
      );
    }

    final rod = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(frame.left - rodOverhang, rodY),
      Offset(frame.right + rodOverhang, rodY),
      rod,
    );
    canvas.drawCircle(
      Offset(cx, rodY),
      5.5,
      Paint()
        ..color = guideAccent == HangingDisplayGuideAccent.centreOnAxis
            ? teal
            : const Color(0xE6FFFFFF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, rodY),
      5.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    final cloth = _clothPath(frame, cx, rodY);
    final clothFill = Paint()..color = const Color(0x24FFFFFF);
    final clothStroke = Paint()
      ..color = const Color(0xE6FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round;

    if (guideAccent == HangingDisplayGuideAccent.centreOnAxis) {
      clothFill.color = const Color(0x18FFFFFF);
      clothStroke.color = const Color(0x99FFFFFF);
    }

    canvas.drawPath(cloth, clothFill);
    canvas.drawPath(cloth, clothStroke);

    if (guideAccent == HangingDisplayGuideAccent.centreOnAxis) {
      _label(canvas, 'Centre line', Offset(cx, frame.bottom - 14), highlight: true);
    }

    if (guideAccent == HangingDisplayGuideAccent.fringeSymmetric) {
      _paintFringeAccent(canvas, cloth, frame);
      _paintSymmetricEdges(canvas, cloth, frame);
      _label(canvas, 'Fringe', Offset(cx, frame.bottom - 10), highlight: true);
    }
  }

  static Path _clothPath(Rect frame, double cx, double rodY) {
    final hangTop = rodY + 5;
    final hangBottom = frame.bottom - frame.height * 0.07;
    final halfTop = frame.width * 0.09;
    final halfLower = frame.width * 0.34;
    final fringeDepth = frame.height * 0.035;
    final fringeCount = 9;
    final fringeSpan = halfLower * 2;
    final fringeStep = fringeSpan / fringeCount;

    final cloth = Path()
      ..moveTo(cx - halfTop, hangTop)
      ..lineTo(cx + halfTop, hangTop)
      ..lineTo(cx + halfLower, hangBottom - fringeDepth);

    var x = cx + halfLower;
    for (var i = 0; i < fringeCount; i++) {
      final nextX = x - fringeStep;
      final tipY = hangBottom + (i.isEven ? fringeDepth * 0.55 : 0);
      cloth.lineTo(x, hangBottom);
      cloth.lineTo((x + nextX) / 2, tipY);
      cloth.lineTo(nextX, hangBottom);
      x = nextX;
    }

    cloth
      ..lineTo(cx - halfLower, hangBottom - fringeDepth)
      ..close();
    return cloth;
  }

  static void _paintFringeAccent(Canvas canvas, Path cloth, Rect frame) {
    final bounds = cloth.getBounds();
    final fringeTop = bounds.bottom - frame.height * 0.12;
    final fringeRect = Rect.fromLTRB(
      bounds.left,
      fringeTop,
      bounds.right,
      bounds.bottom + frame.height * 0.04,
    );
    canvas.save();
    canvas.clipRect(fringeRect);
    canvas.drawPath(
      cloth,
      Paint()
        ..color = const Color(0x551B7574)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.restore();
  }

  static void _paintSymmetricEdges(Canvas canvas, Path cloth, Rect frame) {
    final bounds = cloth.getBounds();
    final y = bounds.bottom - frame.height * 0.09;
    final tick = Paint()
      ..color = teal
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    const tickLen = 10.0;
    canvas.drawLine(
      Offset(bounds.left, y),
      Offset(bounds.left, y + tickLen),
      tick,
    );
    canvas.drawLine(
      Offset(bounds.right, y),
      Offset(bounds.right, y + tickLen),
      tick,
    );
    _label(canvas, 'Edge', Offset(bounds.left, y + tickLen + 10), fontSize: 9);
    _label(canvas, 'Edge', Offset(bounds.right, y + tickLen + 10), fontSize: 9);
  }

  static void _label(
    Canvas canvas,
    String text,
    Offset center, {
    bool highlight = false,
    double fontSize = 11,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tr(text),
        style: appType(
          color: highlight ? teal : Colors.white,
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
    )..layout(maxWidth: 100);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }
}

class HangingDisplayGuideDiagram extends StatelessWidget {
  const HangingDisplayGuideDiagram({super.key, required this.accent});

  final HangingDisplayGuideAccent accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HangingDisplayGuidePainter(accent),
      size: Size.infinite,
    );
  }
}

class _HangingDisplayGuidePainter extends CustomPainter {
  const _HangingDisplayGuidePainter(this.accent);

  final HangingDisplayGuideAccent accent;

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

    HangingDisplayOverlay.paintFrame(canvas, frame);
    HangingDisplayOverlay.paintContent(
      canvas,
      frame,
      guideAccent: accent,
    );
  }

  @override
  bool shouldRepaint(covariant _HangingDisplayGuidePainter oldDelegate) =>
      oldDelegate.accent != accent;
}
