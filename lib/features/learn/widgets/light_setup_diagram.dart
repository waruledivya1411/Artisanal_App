import 'package:flutter/material.dart';

/// Where the window, the cloth, and the shine sit for a light lesson.
enum LightSetupKind {
  /// A white sheet on the window, so the sun reaches the silk softened.
  sheet,

  /// The shine runs along the far edge of the silk, away from the phone.
  turn,
}

/// A wordless setup drawing for the cotton and silk light lessons.
class LightSetupDiagram extends StatelessWidget {
  const LightSetupDiagram({super.key, required this.kind});

  final LightSetupKind kind;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LightSetupPainter(kind),
      child: const SizedBox.expand(),
    );
  }
}

class _LightSetupPainter extends CustomPainter {
  _LightSetupPainter(this.kind);

  final LightSetupKind kind;

  static const _bg = Color(0xFFE7EEEC);
  static const _teal = Color(0xFF1B7574);
  static const _cream = Color(0xFFFFF6E4);
  static const _sheet = Color(0xFFF3E6C8);
  static const _ray = Color(0xFFE0A84A);
  static const _cloth = Color(0xFFF8F4EE);
  static const _weave = Color(0xFFE6D7C4);
  static const _pink = Color(0xFFD4537E);
  static const _gold = Color(0xFFC4A15A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    if (kind == LightSetupKind.sheet) {
      _sheetScene(canvas, size);
    } else {
      _turnScene(canvas, size);
    }
  }

  void _sheetScene(Canvas canvas, Size size) {
    final window = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.16,
        size.width * 0.28,
        size.height * 0.68,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(window, Paint()..color = _cream);
    canvas.save();
    canvas.clipRRect(window);
    final stripe = window.width / 6;
    for (var i = 0; i < 6; i++) {
      if (i.isOdd) {
        canvas.drawRect(
          Rect.fromLTWH(window.left + i * stripe, window.top, stripe, window.height),
          Paint()..color = _sheet,
        );
      }
    }
    canvas.restore();
    canvas.drawRRect(
      window,
      Paint()
        ..color = _teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final cloth = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.54,
        size.height * 0.16,
        size.width * 0.38,
        size.height * 0.68,
      ),
      const Radius.circular(8),
    );
    _clothRect(canvas, cloth);
    _diamond(canvas, cloth.center, 13);

    final ray = Paint()
      ..color = _ray
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final t in [0.32, 0.50, 0.68]) {
      canvas.drawLine(
        Offset(window.right + 8, size.height * t),
        Offset(cloth.left - 8, size.height * t),
        ray,
      );
    }
  }

  void _turnScene(Canvas canvas, Size size) {
    final cloth = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.16,
        size.width * 0.76,
        size.height * 0.48,
      ),
      const Radius.circular(10),
    );
    _clothRect(canvas, cloth);

    final shine = RRect.fromRectAndRadius(
      Rect.fromLTWH(cloth.left + 10, cloth.top + 10, cloth.width - 20, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(shine, Paint()..color = _gold);
    final arrow = Paint()
      ..color = const Color(0xFF8A6A2F)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final y = shine.center.dy;
    canvas.drawLine(
      Offset(shine.left + 12, y),
      Offset(shine.right - 18, y),
      arrow,
    );
    final tip = Offset(shine.right - 10, y);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 8, tip.dy - 4.5)
        ..lineTo(tip.dx - 8, tip.dy + 4.5)
        ..close(),
      Paint()..color = const Color(0xFF8A6A2F),
    );

    _diamond(canvas, Offset(cloth.center.dx, cloth.bottom - 34), 12);
    _phone(canvas, Offset(size.width / 2, size.height * 0.84));
  }

  void _clothRect(Canvas canvas, RRect cloth) {
    canvas.drawRRect(cloth, Paint()..color = _cloth);
    canvas.save();
    canvas.clipRRect(cloth);
    final weave = Paint()
      ..color = _weave
      ..strokeWidth = 1;
    for (var y = cloth.top + 6; y < cloth.bottom; y += 7) {
      canvas.drawLine(Offset(cloth.left, y), Offset(cloth.right, y), weave);
    }
    canvas.restore();
  }

  void _diamond(Canvas canvas, Offset center, double radius) {
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius * 0.85, center.dy)
        ..lineTo(center.dx, center.dy + radius)
        ..lineTo(center.dx - radius * 0.85, center.dy)
        ..close(),
      Paint()..color = _pink,
    );
  }

  void _phone(Canvas canvas, Offset center) {
    final phone = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 34, height: 50),
      const Radius.circular(6),
    );
    canvas.drawRRect(phone, Paint()..color = _teal);
    canvas.drawCircle(
      Offset(center.dx, phone.top + 12),
      4.5,
      Paint()..color = _bg,
    );
  }

  @override
  bool shouldRepaint(covariant _LightSetupPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
