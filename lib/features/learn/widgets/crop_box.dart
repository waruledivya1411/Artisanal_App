import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A photo with a crop box over it, as on a phone: drag a corner or an edge
/// to resize the box, or drag inside it to move it. The part outside the box
/// is dimmed. [crop] is in fractions of the photo, 0,0 top left.
class CropBox extends StatefulWidget {
  const CropBox({
    super.key,
    required this.photo,
    required this.photoAspect,
    required this.crop,
    required this.onChanged,
  });

  /// The photo, laid out to fill the box it is given.
  final Widget photo;

  /// Width over height of the photo as shown.
  final double photoAspect;

  final Rect crop;
  final ValueChanged<Rect> onChanged;

  @override
  State<CropBox> createState() => _CropBoxState();
}

enum _Grab {
  move,
  left,
  top,
  right,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _CropBoxState extends State<CropBox> {
  /// Smallest the box can get, as a share of each side.
  static const _minSide = 0.12;

  /// How close to a corner or edge a touch must land to grab it.
  static const _reach = 28.0;

  _Grab? _grab;

  _Grab? _hit(Offset at, Rect box) {
    bool near(Offset a, Offset b) => (a - b).distance <= _reach;
    if (near(at, box.topLeft)) return _Grab.topLeft;
    if (near(at, box.topRight)) return _Grab.topRight;
    if (near(at, box.bottomLeft)) return _Grab.bottomLeft;
    if (near(at, box.bottomRight)) return _Grab.bottomRight;
    final inY = at.dy > box.top && at.dy < box.bottom;
    final inX = at.dx > box.left && at.dx < box.right;
    if (inY && (at.dx - box.left).abs() <= _reach) return _Grab.left;
    if (inY && (at.dx - box.right).abs() <= _reach) return _Grab.right;
    if (inX && (at.dy - box.top).abs() <= _reach) return _Grab.top;
    if (inX && (at.dy - box.bottom).abs() <= _reach) return _Grab.bottom;
    if (box.contains(at)) return _Grab.move;
    return null;
  }

  Rect _drag(Rect c, _Grab grab, double dx, double dy) {
    var l = c.left, t = c.top, r = c.right, b = c.bottom;
    switch (grab) {
      case _Grab.move:
        final mx = dx.clamp(-l, 1 - r);
        final my = dy.clamp(-t, 1 - b);
        return c.translate(mx, my);
      case _Grab.left:
        l = (l + dx).clamp(0.0, r - _minSide);
      case _Grab.right:
        r = (r + dx).clamp(l + _minSide, 1.0);
      case _Grab.top:
        t = (t + dy).clamp(0.0, b - _minSide);
      case _Grab.bottom:
        b = (b + dy).clamp(t + _minSide, 1.0);
      case _Grab.topLeft:
        l = (l + dx).clamp(0.0, r - _minSide);
        t = (t + dy).clamp(0.0, b - _minSide);
      case _Grab.topRight:
        r = (r + dx).clamp(l + _minSide, 1.0);
        t = (t + dy).clamp(0.0, b - _minSide);
      case _Grab.bottomLeft:
        l = (l + dx).clamp(0.0, r - _minSide);
        b = (b + dy).clamp(t + _minSide, 1.0);
      case _Grab.bottomRight:
        r = (r + dx).clamp(l + _minSide, 1.0);
        b = (b + dy).clamp(t + _minSide, 1.0);
    }
    return Rect.fromLTRB(l, t, r, b);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The photo, whole, as large as fits.
        var w = constraints.maxWidth;
        var h = w / widget.photoAspect;
        if (h > constraints.maxHeight) {
          h = constraints.maxHeight;
          w = h * widget.photoAspect;
        }
        final c = widget.crop;
        final box = Rect.fromLTRB(
          c.left * w,
          c.top * h,
          c.right * w,
          c.bottom * h,
        );
        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => _grab = _hit(d.localPosition, box),
              onPanUpdate: (d) {
                final grab = _grab;
                if (grab == null) return;
                widget.onChanged(
                  _drag(widget.crop, grab, d.delta.dx / w, d.delta.dy / h),
                );
              },
              onPanEnd: (_) => _grab = null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.photo,
                  CustomPaint(painter: _CropPainter(box)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CropPainter extends CustomPainter {
  _CropPainter(this.box);

  final Rect box;

  @override
  void paint(Canvas canvas, Size size) {
    // Dim what will be cut away.
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addRect(box),
      Paint()..color = const Color(0x99000000),
    );

    // Thirds, to help line the piece up.
    final grid = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final x = box.left + box.width * i / 3;
      final y = box.top + box.height * i / 3;
      canvas.drawLine(Offset(x, box.top), Offset(x, box.bottom), grid);
      canvas.drawLine(Offset(box.left, y), Offset(box.right, y), grid);
    }

    canvas.drawRect(
      box,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Thick corner brackets, the handles.
    final handle = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    final arm = math.min(22.0, math.min(box.width, box.height) / 3);
    for (final (corner, sx, sy) in [
      (box.topLeft, 1.0, 1.0),
      (box.topRight, -1.0, 1.0),
      (box.bottomLeft, 1.0, -1.0),
      (box.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawLine(corner, corner + Offset(arm * sx, 0), handle);
      canvas.drawLine(corner, corner + Offset(0, arm * sy), handle);
    }
  }

  @override
  bool shouldRepaint(_CropPainter old) => old.box != box;
}

/// Shows only the [crop] part of a photo, as large as fits, so the edit
/// screen previews the cropped result.
class CroppedPhoto extends StatelessWidget {
  const CroppedPhoto({
    super.key,
    required this.photo,
    required this.photoAspect,
    required this.crop,
  });

  final Widget photo;
  final double photoAspect;
  final Rect crop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Shape of the kept part, fitted to the space.
        final keptAspect = photoAspect * crop.width / crop.height;
        var w = constraints.maxWidth;
        var h = w / keptAspect;
        if (h > constraints.maxHeight) {
          h = constraints.maxHeight;
          w = h * keptAspect;
        }
        // The whole photo, scaled so the kept part fills that size.
        final fullW = w / crop.width;
        final fullH = h / crop.height;
        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: fullW,
                maxWidth: fullW,
                minHeight: fullH,
                maxHeight: fullH,
                child: Transform.translate(
                  offset: Offset(-crop.left * fullW, -crop.top * fullH),
                  child: SizedBox(width: fullW, height: fullH, child: photo),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
