import 'package:flutter/material.dart';

import 'package:artisnal_app/features/learn/widgets/folded_stack_diagram.dart';

/// A plain shape drawn inside the frame showing roughly how the piece should
/// sit. Deliberately one outline with no labels: the artisan reads the shape,
/// not words.
enum ShotSilhouette { draped, foldedSari }

/// Camera overlay drawn on top of the live preview.
enum ShotOverlayKind {
  standard,
  embroideryBorder,
  foldedStack,
  hangingDisplay,
}

/// How the outer dashed frame is placed on the preview.
enum ShotFramePlacement {
  /// Centered box sized from [ShotOutline.widthFactor] and [aspectRatio].
  centered,

  /// Tall frame inset from the screen edges (embroidery & border).
  inset,
}

/// The dotted box the product should sit inside, shaped for the display being
/// shot: tall for a hanging piece, square for a close-up, a wide band for a
/// border.
class ShotOutline {
  const ShotOutline({
    required this.widthFactor,
    required this.aspectRatio,
    this.silhouette,
    this.window,
    this.windowLabel,
    this.strip,
    this.stripLabel,
    this.placement = ShotFramePlacement.centered,
    this.inset = const EdgeInsets.fromLTRB(22, 112, 22, 196),
    this.kind = ShotOverlayKind.standard,
  });

  /// Share of the preview width the box takes.
  final double widthFactor;

  /// Box width / height.
  final double aspectRatio;

  final ShotSilhouette? silhouette;

  /// A smaller solid box inside the frame, as fractions of it, for the part
  /// of the piece that matters. Null when the whole frame is the target.
  final Rect? window;

  /// Short word shown inside [window], naming what goes there.
  final String? windowLabel;

  /// A tall band inside the frame, as fractions of it, for a part that runs
  /// along an edge - the border of a sari.
  final Rect? strip;

  final String? stripLabel;

  final ShotFramePlacement placement;

  /// Margins for [ShotFramePlacement.inset].
  final EdgeInsets inset;

  final ShotOverlayKind kind;

  static const _byDisplay = <String, ShotOutline>{
    'full_display': ShotOutline(widthFactor: 0.62, aspectRatio: 0.70),
    'close-up_texture': ShotOutline(widthFactor: 0.72, aspectRatio: 1.00),
    'draped_look': ShotOutline(widthFactor: 0.68, aspectRatio: 0.70),
    'embroidery_and_border': ShotOutline(
      widthFactor: 0.88,
      aspectRatio: 0.58,
      placement: ShotFramePlacement.inset,
      kind: ShotOverlayKind.embroideryBorder,
      window: Rect.fromLTRB(0.07, 0.07, 0.62, 0.48),
      windowLabel: 'Motif',
      strip: Rect.fromLTRB(0.74, 0.05, 0.93, 0.95),
      stripLabel: 'Border',
    ),
    'folded_stack': ShotOutline(widthFactor: 0.80, aspectRatio: 0.78),
    'hanging_display': ShotOutline(widthFactor: 0.55, aspectRatio: 0.55),
  };

  static ShotOutline forDisplay(String displayKey) =>
      _byDisplay[displayKey] ??
      const ShotOutline(widthFactor: 0.70, aspectRatio: 0.75);

  static const _sareeGuideProducts = {'Saree', 'Mekhala sador'};

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
    if (displayKey == 'folded_stack' &&
        _sareeGuideProducts.contains(product)) {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.foldedStack,
      );
    }
    if (displayKey == 'hanging_display' &&
        _sareeGuideProducts.contains(product)) {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.hangingDisplay,
      );
    }
    if (displayKey == 'folded_stack') {
      return const ShotOutline(
        widthFactor: 0.80,
        aspectRatio: 0.78,
        silhouette: ShotSilhouette.foldedSari,
      );
    }
    return forDisplay(displayKey);
  }

  /// Outer dashed frame in preview coordinates.
  static Rect outerFrame(Size size, ShotOutline outline) {
    if (outline.placement == ShotFramePlacement.inset) {
      final left = outline.inset.left;
      final top = outline.inset.top;
      final right = size.width - outline.inset.right;
      final bottom = size.height - outline.inset.bottom;
      return Rect.fromLTRB(left, top, right, bottom);
    }
    final boxWidth = size.width * outline.widthFactor;
    final boxHeight = (boxWidth / outline.aspectRatio).clamp(
      80.0,
      size.height * 0.80,
    );
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: boxWidth,
      height: boxHeight,
    );
  }

  static Rect? innerWindow(Rect frame, ShotOutline outline) {
    final fractions = outline.window;
    if (fractions == null) return null;
    return Rect.fromLTRB(
      frame.left + frame.width * fractions.left,
      frame.top + frame.height * fractions.top,
      frame.left + frame.width * fractions.right,
      frame.top + frame.height * fractions.bottom,
    );
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
    final rect = ShotOutline.outerFrame(size, outline);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    // Dim everything outside the box so the box reads as the target.
    final shade = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(rrect);
    canvas.drawPath(shade, Paint()..color = const Color(0x66000000));

    _dashedPath(canvas, Path()..addRRect(rrect), _blue, 2.5);
    _corners(canvas, rect);

    switch (outline.silhouette) {
      case ShotSilhouette.draped:
        _thirds(canvas, rect);
        _drapedCloth(canvas, rect);
      case ShotSilhouette.foldedSari:
        _foldedGuides(canvas, rect);
        _foldedSari(canvas, rect);
      case null:
        break;
    }

    switch (outline.kind) {
      case ShotOverlayKind.embroideryBorder:
        final strip = outline.strip;
        if (strip != null) {
          _strip(canvas, _inside(rect, strip), outline.stripLabel);
        }
        final inner = ShotOutline.innerWindow(rect, outline);
        if (inner != null) _window(canvas, inner, outline.windowLabel);
      case ShotOverlayKind.foldedStack:
        _foldedStackGuide(canvas, rect);
      case ShotOverlayKind.hangingDisplay:
        _hangingDisplayGuide(canvas, rect);
      case ShotOverlayKind.standard:
        break;
    }
  }

  /// Rod at the top, centre cross, sari hanging with even fringes at the bottom.
  void _hangingDisplayGuide(Canvas canvas, Rect frame) {
    final cx = frame.center.dx;
    final midY = frame.center.dy;

    final cross = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(frame.left, midY),
      Offset(frame.right, midY),
      cross,
    );
    canvas.drawLine(
      Offset(cx, frame.top),
      Offset(cx, frame.bottom),
      cross,
    );

    final rodY = frame.top + 10;
    final rodOverhang = frame.width * 0.07;
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
        ..color = const Color(0xE6FFFFFF)
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

    canvas.drawPath(cloth, Paint()..color = const Color(0x24FFFFFF));
    canvas.drawPath(
      cloth,
      Paint()
        ..color = const Color(0xE6FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Top-down folded sari: one rectangle with a border strip.
  void _foldedStackGuide(Canvas canvas, Rect frame) {
    FoldedStackOverlay.paintContent(canvas, frame);
  }

  Rect _inside(Rect frame, Rect f) => Rect.fromLTRB(
    frame.left + frame.width * f.left,
    frame.top + frame.height * f.top,
    frame.left + frame.width * f.right,
    frame.top + frame.height * f.bottom,
  );

  /// The motif window, top left.
  void _window(Canvas canvas, Rect box, String? label) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(8)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    if (label != null) _centredLabel(canvas, label, box.center);
  }

  /// The border band down the right: faintly filled, with a few cross-ticks
  /// so it reads as a woven strip rather than an empty box.
  void _strip(Canvas canvas, Rect band, String? label) {
    final rrect = RRect.fromRectAndRadius(band, const Radius.circular(6));
    canvas.drawRRect(rrect, Paint()..color = const Color(0x26FFFFFF));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    final tick = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1.5;
    for (var y = band.top + 18; y < band.bottom - 10; y += 18) {
      canvas.drawLine(
        Offset(band.left + 6, y),
        Offset(band.right - 6, y),
        tick,
      );
    }
    if (label != null) _centredLabel(canvas, label, band.center, boxed: true);
  }

  void _centredLabel(
    Canvas canvas,
    String text,
    Offset centre, {
    bool boxed = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1,
          shadows: [Shadow(color: Color(0xCC000000), blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final topLeft = centre - Offset(painter.width / 2, painter.height / 2);
    if (boxed) {
      // Sits over the ticks, so give it a backing to stay legible.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            topLeft.dx - 4,
            topLeft.dy - 3,
            painter.width + 8,
            painter.height + 6,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xB3000000),
      );
    }
    painter.paint(canvas, topLeft);
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

  /// Shot from above: two horizontals to square the piece up against.
  void _foldedGuides(Canvas canvas, Rect r) {
    Offset at(double x, double y) =>
        Offset(r.left + r.width * x / 100, r.top + r.height * y / 100);
    final guide = Paint()
      ..color = const Color(0x8CFFFFFF)
      ..strokeWidth = 1.4;
    canvas.drawLine(at(0, 33), at(100, 33), guide);
    canvas.drawLine(at(0, 66), at(100, 66), guide);
  }

  /// One sari folded into a rectangle, border along the edge facing the
  /// camera - not a pile.
  void _foldedSari(Canvas canvas, Rect r) {
    Offset at(double x, double y) =>
        Offset(r.left + r.width * x / 100, r.top + r.height * y / 100);

    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // 78% of the box wide, 52% tall, centred.
    const left = (100 - 78) / 2;
    const right = left + 78;
    const top = (100 - 52) / 2;
    const bottom = top + 52;
    final body = Rect.fromPoints(at(left, top), at(right, bottom));
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(8)),
      line,
    );
    _label(canvas, 'Folded sari', at(left, top - 7));

    // The border is the right 22% of the piece; show where it starts.
    const borderLeft = right - 78 * 0.22;
    canvas.drawLine(at(borderLeft, top), at(borderLeft, bottom), line);
    _label(canvas, 'Border', at(borderLeft + 1, bottom + 2.5));
  }

  void _label(Canvas canvas, String text, Offset at) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1,
          shadows: [Shadow(color: Color(0xCC000000), blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at);
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
      oldDelegate.outline.window != outline.window ||
      oldDelegate.outline.strip != outline.strip ||
      oldDelegate.outline.placement != outline.placement ||
      oldDelegate.outline.inset != outline.inset ||
      oldDelegate.outline.kind != outline.kind;
}

/// Hint pills anchored to the lower area inside the dashed frame.
class ShotFrameHintOverlay extends StatelessWidget {
  const ShotFrameHintOverlay({
    super.key,
    required this.outline,
    this.hint,
    required this.prompt,
    required this.hintStyle,
    required this.promptStyle,
  });

  final ShotOutline outline;

  /// Dark caption pill; left out when null, and the prompt takes its place.
  final String? hint;
  final String prompt;
  final TextStyle hintStyle;
  final TextStyle promptStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final frame = ShotOutline.outerFrame(size, outline);
        final top = frame.top + frame.height * 0.58;
        final horizontal = frame.left + 10;
        final width = frame.width - 20;

        final hint = this.hint;
        return Stack(
          children: [
            if (hint != null)
              Positioned(
                left: horizontal,
                top: top,
                width: width,
                child: _pill(
                  color: const Color(0xCC0E1413),
                  child: Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: hintStyle,
                  ),
                ),
              ),
            Positioned(
              left: horizontal,
              top: hint == null ? top : top + 46,
              width: width,
              child: _pill(
                color: const Color(0xFFF5C84C),
                child: Text(
                  prompt,
                  textAlign: TextAlign.center,
                  style: promptStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _pill({required Color color, required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: child,
      ),
    );
  }
}
