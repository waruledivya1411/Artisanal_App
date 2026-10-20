import 'dart:math' as math;

import 'package:flutter/material.dart';

class CelebrationConfetti extends StatelessWidget {
  const CelebrationConfetti({super.key, required this.animation});

  final Animation<double> animation;

  static final List<_Piece> _pieces = List.generate(46, (i) {
    final random = math.Random(i + 3);
    const colors = [
      Color(0xFF1B7574),
      Color(0xFFC5922E),
      Color(0xFF7A1F2B),
      Color(0xFFF4EBDD),
      Color(0xFF1E7B45),
      Colors.white,
    ];
    return _Piece(
      x: random.nextDouble(),
      delay: random.nextDouble() * 0.22,
      drift: (random.nextDouble() - 0.5) * 0.16,
      spin: random.nextDouble() * 6,
      color: colors[i % colors.length],
      width: 6 + random.nextDouble() * 7,
      height: 8 + random.nextDouble() * 8,
      round: i.isEven,
    );
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(t: animation.value, pieces: _pieces),
        );
      },
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.drift,
    required this.spin,
    required this.color,
    required this.width,
    required this.height,
    required this.round,
  });

  final double x;
  final double delay;
  final double drift;
  final double spin;
  final Color color;
  final double width;
  final double height;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.t, required this.pieces});

  final double t;
  final List<_Piece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final local = (t + piece.delay) % 1.0;
      final fadeOut = local > 0.9 ? (1.0 - local) / 0.1 : 1.0;
      final fadeIn = local < 0.06 ? local / 0.06 : 1.0;
      final fade = (fadeOut * fadeIn).clamp(0.0, 1.0);
      final paint = Paint()..color = piece.color.withValues(alpha: fade);
      final dx =
          (piece.x + math.sin(local * math.pi * 3) * piece.drift) * size.width;
      final dy = (-0.12 + local * 1.3) * size.height;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(local * piece.spin);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: piece.width,
        height: piece.height,
      );
      if (piece.round) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          paint,
        );
      } else {
        canvas.drawOval(rect, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
