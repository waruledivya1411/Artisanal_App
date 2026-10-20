import 'package:flutter/material.dart';

/// A plain shape drawn inside the frame showing roughly how the piece should
/// sit. Deliberately one outline with no labels: the artisan reads the shape,
/// not words.
enum ShotSilhouette { draped }

/// The dotted box the product should sit inside, shaped for the display being
/// shot: tall for a hanging piece, square for a close-up, a wide band for a
/// border.
class ShotOutline {
  const ShotOutline({
    required this.widthFactor,
    required this.aspectRatio,
    this.silhouette,
    this.window,
  });

  /// Share of the preview width the box takes.
  final double widthFactor;

  /// Box width / height.
  final double aspectRatio;

  final ShotSilhouette? silhouette;

  /// A smaller solid box inside the frame, as fractions of it, for the part
  /// of the piece that matters. Null when the whole frame is the target.
  final Rect? window;

  static const _byDisplay = <String, ShotOutline>{
    'full_display': ShotOutline(widthFactor: 0.62, aspectRatio: 0.70),
    'close-up_texture': ShotOutline(widthFactor: 0.72, aspectRatio: 1.00),
    'draped_look': ShotOutline(widthFactor: 0.68, aspectRatio: 0.70),
    'embroidery_and_border': ShotOutline(
      widthFactor: 0.82,
      aspectRatio: 0.82,
      window: Rect.fromLTRB(0.45, 0.07, 0.90, 0.48),
    ),
    'folded_stack': ShotOutline(widthFactor: 0.80, aspectRatio: 1.25),
    'hanging_display': ShotOutline(widthFactor: 0.55, aspectRatio: 0.55),
  };

  static ShotOutline forDisplay(String displayKey) =>
      _byDisplay[displayKey] ??
      const ShotOutline(widthFactor: 0.70, aspectRatio: 0.75);

  /// A draped piece gets the cloth-over-a-chair shape; everything else gets
  /// the plain box for its display.
  static ShotOutline forShot(String? product, String displayKey) {
    if (displayKey == 'draped_look') {
      return const ShotOutline(
        widthFactor: 0.74,
        aspectRatio: 0.66,
        silhouette: ShotSilhouette.draped,
      );
    }
    return forDisplay(displayKey);
  }
}

/// Draws the outline over a camera preview.
class ShotOutlineOverlay extends StatelessWidget {
  const ShotOutlineOverlay({super.key, required this.outline});

  final ShotOutline outline;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _OutlinePainter(outline),
        size: Size.infinite,
      ),
    );
  }
}

class _OutlinePainter extends CustomPainter {
  const _OutlinePainter(this.outline);

  final ShotOutline outline;

  static const Color _blue = Color(0xFF7EAADB);
  static const Color _brightBlue = Color(0xFFA9CCF0);

  @override
  void paint(Canvas canvas, Size size) {
    final boxWidth = size.width * outline.widthFactor;
    final boxHeight = (boxWidth / outline.aspectRatio).clamp(
      80.0,
      size.height * 0.80,
    );
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: boxWidth,
      height: boxHeight,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    // Dim everything outside the box so the box reads as the target.
    final shade = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(rrect);
    canvas.drawPath(shade, Paint()..color = const Color(0x66000000));

    _dashedPath(canvas, Path()..addRRect(rrect), _blue, 2.5);
    _corners(canvas, rect);

    if (outline.silhouette != null) {
      _thirds(canvas, rect);
      _drapedCloth(canvas, rect);
    }

    final window = outline.window;
    if (window != null) _window(canvas, rect, window);
  }

  /// The solid box inside the frame that the border or motif must land in.
  void _window(Canvas canvas, Rect frame, Rect fractions) {
    final box = Rect.fromLTRB(
      frame.left + frame.width * fractions.left,
      frame.top + frame.height * fractions.top,
      frame.left + frame.width * fractions.right,
      frame.top + frame.height * fractions.bottom,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(8)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  /// Rule of thirds, white and faint, inside the frame only.
  void _thirds(Canvas canvas, Rect r) {
    final p = Paint()
      ..color = const Color(0x59FFFFFF)
      ..strokeWidth = 1;
    for (final f in [1 / 3, 2 / 3]) {
      canvas.drawLine(
        Offset(r.left + r.width * f, r.top),
        Offset(r.left + r.width * f, r.bottom),
        p,
      );
      canvas.drawLine(
        Offset(r.left, r.top + r.height * f),
        Offset(r.right, r.top + r.height * f),
        p,
      );
    }
  }

  /// A ghost of the finished shot: cloth hanging and flaring to a wavy hem.
  ///
  /// Drawing the chair meant reading a diagram. A soft filled shape does not
  /// need reading - the artisan moves the phone until their cloth covers it.
  void _drapedCloth(Canvas canvas, Rect r) {
    Offset at(double xPercent, double yPercent) => Offset(
      r.left + r.width * xPercent / 100,
      r.top + r.height * yPercent / 100,
    );
    Path curve(List<List<double>> pts) {
      final path = Path()..moveTo(at(pts[0][0], pts[0][1]).dx, at(pts[0][0], pts[0][1]).dy);
      for (var i = 1; i + 2 < pts.length; i += 3) {
        final c1 = at(pts[i][0], pts[i][1]);
        final c2 = at(pts[i + 1][0], pts[i + 1][1]);
        final end = at(pts[i + 2][0], pts[i + 2][1]);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
      }
      return path;
    }

    // Narrow over the shoulder of the chair, widening to a wavy hem.
    final cloth = curve([
      [27, 15],
      [38, 7], [62, 7], [73, 15], // the fold over the chair back
      [80, 37], [85, 61], [86, 87], // right side falling
      [75, 94], [61, 88], [49, 92], // hem, first wave
      [37, 96], [24, 92], [14, 87], // hem, second wave
      [15, 61], [20, 37], [27, 15], // left side back up
    ])..close();

    canvas.drawPath(cloth, Paint()..color = const Color(0x24FFFFFF));
    canvas.drawPath(
      cloth,
      Paint()
        ..color = const Color(0xD9FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round,
    );

    // Two soft folds, so it reads as cloth rather than a blob.
    final fold = Paint()
      ..color = const Color(0x4DFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      curve([
        [42, 18],
        [38, 43], [37, 67], [39, 88],
      ]),
      fold,
    );
    canvas.drawPath(
      curve([
        [59, 18],
        [63, 43], [65, 67], [64, 88],
      ]),
      fold,
    );
  }

  void _dashedPath(Canvas canvas, Path path, Color color, double width) {
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

  /// Solid corner brackets, so the box stays readable over a busy scene.
  void _corners(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = _brightBlue
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

  @override
  bool shouldRepaint(covariant _OutlinePainter oldDelegate) =>
      oldDelegate.outline.widthFactor != outline.widthFactor ||
      oldDelegate.outline.aspectRatio != outline.aspectRatio ||
      oldDelegate.outline.silhouette != outline.silhouette ||
      oldDelegate.outline.window != outline.window;
}
