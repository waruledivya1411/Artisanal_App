
import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:flutter/material.dart';


/// A plain shape drawn inside the frame showing roughly how the piece should
/// sit. Deliberately one outline with no labels: the artisan reads the shape,
/// not words.
enum ShotSilhouette { draped, foldedSari }

/// Camera overlay drawn on top of the live preview.
enum ShotOverlayKind {
  standard,
  sariFull,
  sariClose,
  embroideryBorder,
  foldedStack,
  hangingDisplay,
  mekhalaFull,
  mekhalaHanging,
  mekhalaFolded,
  stoleFull,
  stoleFolded,
  shawlFull,
  shawlFolded,
  cushionSofa,
  cushionFlat,
  gamusaFull,
  gamusaFolded,
  sariDraped,
  jodHanging,
  jodFolded,
  yardageHanging,
  yardageClose,
}

/// How the outer dashed frame is placed on the preview.
enum ShotFramePlacement {
  /// Centered box sized from [ShotOutline.widthFactor] and [aspectRatio].
  centered,

  /// Fills the whole photo area, less a small margin.
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
    this.placement = ShotFramePlacement.centered,
    this.inset = const EdgeInsets.fromLTRB(14, 108, 14, 196),
    this.kind = ShotOverlayKind.standard,
  });

  /// Share of the preview width the box takes.
  final double widthFactor;

  /// Box width / height.
  final double aspectRatio;

  final ShotSilhouette? silhouette;

  final ShotFramePlacement placement;

  /// Margins for [ShotFramePlacement.inset].
  final EdgeInsets inset;

  final ShotOverlayKind kind;

  static const _byDisplay = <String, ShotOutline>{
    'full_display': ShotOutline(widthFactor: 0.80, aspectRatio: 0.70),
    'close-up_texture': ShotOutline(
      widthFactor: 0.72,
      aspectRatio: 1.00,
      placement: ShotFramePlacement.inset,
    ),
    'draped_look': ShotOutline(widthFactor: 0.68, aspectRatio: 0.70),
    'embroidery_and_border': ShotOutline(
      widthFactor: 0.88,
      aspectRatio: 0.58,
      placement: ShotFramePlacement.inset,
      kind: ShotOverlayKind.embroideryBorder,
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
    if (displayKey == 'close-up_texture' &&
        _sareeGuideProducts.contains(product)) {
      return const ShotOutline(
        widthFactor: 0.72,
        aspectRatio: 0.75,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.sariClose,
      );
    }
    if (displayKey == 'full_display' && product == 'Saree') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.72,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.sariFull,
      );
    }
    if (displayKey == 'full_display' && product == 'Mekhala sador') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.92,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.mekhalaFull,
      );
    }
    if (displayKey == 'full_display' && product == 'Shawl') {
      return const ShotOutline(
        widthFactor: 0.72,
        aspectRatio: 0.62,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.shawlFull,
      );
    }
    if (displayKey == 'full_display' && product == 'Stole') {
      return const ShotOutline(
        widthFactor: 0.62,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.stoleFull,
      );
    }
    if (displayKey == 'flat_lay_display') {
      return const ShotOutline(
        widthFactor: 0.86,
        aspectRatio: 0.92,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.cushionFlat,
      );
    }
    if (displayKey == 'sofa_seated_display') {
      return const ShotOutline(
        widthFactor: 0.86,
        aspectRatio: 0.92,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.cushionSofa,
      );
    }
    if (displayKey == 'full_display' && product == 'Gamusa') {
      return const ShotOutline(
        widthFactor: 0.62,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.gamusaFull,
      );
    }
    // Saree and Mekhala sador share the dotted chair drawing, so the frame
    // takes that drawing's shape.
    if (displayKey == 'draped_look' &&
        (product == 'Saree' || product == 'Mekhala sador')) {
      return const ShotOutline(
        widthFactor: 0.94,
        aspectRatio: ShotOutlineOverlay.drapedArtAspect,
        // As wide as the screen allows; the drawing is nearly square, so
        // the width is what limits it.
        inset: EdgeInsets.symmetric(horizontal: 8),
        kind: ShotOverlayKind.sariDraped,
      );
    }
    if (displayKey == 'draped_look') {
      return const ShotOutline(
        widthFactor: 0.74,
        aspectRatio: 0.66,
        silhouette: ShotSilhouette.draped,
      );
    }
    if (displayKey == 'folded_stack' && product == 'Gamusa') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.gamusaFolded,
      );
    }
    if (displayKey == 'folded_stack' && product == 'Jod kappur') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.jodFolded,
      );
    }
    if (displayKey == 'folded_stack' && product == 'Shawl') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.shawlFolded,
      );
    }
    if (displayKey == 'folded_stack' && product == 'Stole') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.stoleFolded,
      );
    }
    if (displayKey == 'folded_stack' && product == 'Mekhala sador') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.mekhalaFolded,
      );
    }
    if (displayKey == 'folded_stack' &&
        _sareeGuideProducts.contains(product)) {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        // As large as fits between the pills and the two-line caption, with
        // an equal 16px gap each side; the default ran under both.
        inset: EdgeInsets.fromLTRB(14, 134, 14, 226),
        kind: ShotOverlayKind.foldedStack,
      );
    }
    if (displayKey == 'hanging_display' && product == 'Yardages') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.yardageHanging,
      );
    }
    if (displayKey == 'close-up_texture' && product == 'Yardages') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.9,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.yardageClose,
      );
    }
    if (displayKey == 'hanging_display' && product == 'Jod kappur') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.jodHanging,
      );
    }
    if (displayKey == 'hanging_display' && product == 'Mekhala sador') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: 0.58,
        placement: ShotFramePlacement.inset,
        kind: ShotOverlayKind.mekhalaHanging,
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

  /// The part of the screen the saved photo covers: an upright 4:3 photo,
  /// as wide as the screen and centred on it. The shot is cropped to this.
  static Rect photoRect(Size screen) {
    var width = screen.width;
    var height = width * 4 / 3;
    if (height > screen.height) {
      height = screen.height;
      width = height * 3 / 4;
    }
    return Rect.fromCenter(
      center: screen.center(Offset.zero),
      width: width,
      height: height,
    );
  }

  /// Outer dashed frame, in screen coordinates.
  ///
  /// The box is centred on the photo, as large as fits with a small margin.
  /// An [ShotFramePlacement.inset] box fills the whole photo; a centred one
  /// keeps its [aspectRatio]. When [clearTop] and [clearBottom] are given -
  /// where the controls above and below end - the box shrinks about its
  /// centre to stay clear of them.
  static Rect outerFrame(
    Size screen,
    ShotOutline outline, {
    double? clearTop,
    double? clearBottom,
  }) {
    final area = photoRect(screen).deflate(_photoMargin);
    var rect = area;
    if (outline.placement != ShotFramePlacement.inset) {
      var width = area.width;
      var height = width / outline.aspectRatio;
      if (height > area.height) {
        height = area.height;
        width = height * outline.aspectRatio;
      }
      rect = Rect.fromCenter(center: area.center, width: width, height: height);
    }
    return fitBetween(rect, clearTop, clearBottom);
  }

  /// [rect] scaled down about its centre so it sits between [clearTop] and
  /// [clearBottom], keeping its shape.
  static Rect fitBetween(Rect rect, double? clearTop, double? clearBottom) {
    if (clearTop == null || clearBottom == null) return rect;
    final centre = rect.center;
    final half = (centre.dy - clearTop) < (clearBottom - centre.dy)
        ? centre.dy - clearTop
        : clearBottom - centre.dy;
    if (half <= 60 || half >= rect.height / 2) return rect;
    final scale = half / (rect.height / 2);
    return Rect.fromCenter(
      center: centre,
      width: rect.width * scale,
      height: rect.height * scale,
    );
  }

  static const double _photoMargin = 8;

}

/// Draws the outline over a camera preview.
class ShotOutlineOverlay extends StatelessWidget {
  const ShotOutlineOverlay({
    super.key,
    required this.outline,
    this.clearTop,
    this.clearBottom,
    this.locale,
  });

  final ShotOutline outline;
  final String? locale;

  /// Where the controls above and below the box end, in this overlay's
  /// coordinates. See [ShotOutline.outerFrame].
  final double? clearTop;
  final double? clearBottom;

  /// Dotted saree-on-a-chair drawing for the draped shot, light lines on a
  /// clear background so it reads over the live camera.
  static const drapedArt = 'assets/images/lessons/photography/draped_outline.png';
  static const drapedArtAspect = 900 / 979;

  /// Dotted sari laid flat - motifs on the body, the border down the right -
  /// for the embroidery and border shot. Drawn the same way as [drapedArt].
  static const embroideryArt =
      'assets/images/lessons/photography/embroidery_outline.png';

  /// Dotted sari laid flat, a border down each side, for the full display
  /// shot. Drawn the same way as [drapedArt].
  static const fullDisplayArt =
      'assets/images/lessons/photography/full_display_outline.png';

  /// Dotted sari hanging from a hanger, for the hanging shot. Drawn the same
  /// way as [drapedArt], borders kept in gold.
  static const hangingArt =
      'assets/images/lessons/photography/hanging_outline.png';

  /// Dotted folded sari seen from the front, border down the right, for the
  /// folded stack shot. Drawn the same way as [drapedArt].
  static const foldedArt =
      'assets/images/lessons/photography/folded_outline.png';

  /// The motifs of a close-up, light on a clear background, laid inside the
  /// dashed box - the box itself is the texture to fill.
  static const closeUpArt =
      'assets/images/lessons/photography/closeup_outline.png';

  /// A drawing laid inside the dashed box, for shots that keep their box.
  static String? innerArtFor(ShotOverlayKind kind) =>
      kind == ShotOverlayKind.sariClose ? closeUpArt : null;

  /// The drawing used in place of a dashed box, for the shots that have one.
  /// It carries its own dotted outline, so no box is drawn around it.
  static String? artFor(ShotOverlayKind kind) => switch (kind) {
        ShotOverlayKind.sariDraped => drapedArt,
        ShotOverlayKind.sariFull => fullDisplayArt,
        ShotOverlayKind.hangingDisplay => hangingArt,
        ShotOverlayKind.foldedStack => foldedArt,
        ShotOverlayKind.embroideryBorder => embroideryArt,
        _ => null,
      };

  /// The draped drawing has no box around it. It spans the photo's width and
  /// 88% of its height, so the sari fills most of the photo.
  static Rect drapedArtRect(Size screen, double? clearTop, double? clearBottom) {
    final photo = ShotOutline.photoRect(screen);
    return ShotOutline.fitBetween(
      Rect.fromCenter(
        center: photo.center,
        width: photo.width - 8,
        height: photo.height * 0.88,
      ),
      clearTop,
      clearBottom,
    );
  }

  /// The hanging drawing is tall and narrow; it runs 94% of the photo's
  /// height and is widened a little so the sari does not look thin.
  static Rect hangingArtRect(Size screen, double? clearTop, double? clearBottom) {
    final photo = ShotOutline.photoRect(screen);
    final height = photo.height * 0.94;
    return ShotOutline.fitBetween(
      Rect.fromCenter(
        center: photo.center,
        width: (height * 0.58).clamp(0, photo.width - 8).toDouble(),
        height: height,
      ),
      clearTop,
      clearBottom,
    );
  }

  /// The folded drawing is wide; it spans the photo's width and is made a
  /// little taller than drawn so the sari fills more of the photo.
  static Rect foldedArtRect(Size screen, double? clearTop, double? clearBottom) {
    final photo = ShotOutline.photoRect(screen);
    final width = photo.width - 8;
    return ShotOutline.fitBetween(
      Rect.fromCenter(center: photo.center, width: width, height: width / 1.25),
      clearTop,
      clearBottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final painted = CustomPaint(
      painter: _OutlinePainter(outline, clearTop, clearBottom, locale),
      size: Size.infinite,
    );
    final art = artFor(outline.kind) ?? innerArtFor(outline.kind);
    if (art == null) return IgnorePointer(child: painted);
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screen = constraints.biggest;
          final rect = switch (outline.kind) {
            ShotOverlayKind.sariDraped =>
              drapedArtRect(screen, clearTop, clearBottom),
            ShotOverlayKind.hangingDisplay =>
              hangingArtRect(screen, clearTop, clearBottom),
            ShotOverlayKind.foldedStack =>
              foldedArtRect(screen, clearTop, clearBottom),
            _ => ShotOutline.outerFrame(
                screen,
                outline,
                clearTop: clearTop,
                clearBottom: clearBottom,
              ),
          };
          return Stack(
            fit: StackFit.expand,
            children: [
              painted,
              Positioned.fromRect(
                rect: rect,
                child: Image.asset(art, fit: BoxFit.fill),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OutlinePainter extends CustomPainter {
  const _OutlinePainter(
    this.outline,
    this.clearTop,
    this.clearBottom,
    this.locale,
  );

  final ShotOutline outline;
  final double? clearTop;
  final double? clearBottom;
  final String? locale;

  static const Color _blue = Color(0xFF7EAADB);
  static const Color _brightBlue = Color(0xFFA9CCF0);

  @override
  void paint(Canvas canvas, Size size) {
    // A shot drawn from an image has no box; ShotOutlineOverlay lays the
    // image on.
    if (ShotOutlineOverlay.artFor(outline.kind) != null) return;

    final rect = ShotOutline.outerFrame(
      size,
      outline,
      clearTop: clearTop,
      clearBottom: clearBottom,
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
      case ShotOverlayKind.sariFull:
      case ShotOverlayKind.hangingDisplay:
      case ShotOverlayKind.foldedStack:
      case ShotOverlayKind.embroideryBorder:
      case ShotOverlayKind.sariDraped:
        // Drawn from an image by ShotOutlineOverlay; never reached.
        break;
      case ShotOverlayKind.mekhalaFull:
        _mekhalaPair(canvas, rect);
      case ShotOverlayKind.mekhalaHanging:
        _mekhalaHanging(canvas, rect);
      case ShotOverlayKind.mekhalaFolded:
        _mekhalaFolded(canvas, rect);
      case ShotOverlayKind.stoleFull:
        _stoleFull(canvas, rect);
      case ShotOverlayKind.stoleFolded:
        _stoleFolded(canvas, rect);
      case ShotOverlayKind.shawlFull:
        _shawlFull(canvas, rect);
      case ShotOverlayKind.shawlFolded:
        _shawlFolded(canvas, rect);
      case ShotOverlayKind.cushionSofa:
        _cushionSofa(canvas, rect);
      case ShotOverlayKind.cushionFlat:
        _cushionFlat(canvas, rect);
      case ShotOverlayKind.gamusaFull:
        _gamusaFull(canvas, rect);
      case ShotOverlayKind.gamusaFolded:
        _gamusaFolded(canvas, rect);
      case ShotOverlayKind.jodHanging:
        _jodHanging(canvas, rect);
      case ShotOverlayKind.jodFolded:
        _jodFolded(canvas, rect);
      case ShotOverlayKind.yardageHanging:
        _yardageHanging(canvas, rect);
      case ShotOverlayKind.yardageClose:
        _yardageClose(canvas, rect);
      case ShotOverlayKind.sariClose:
        // Motifs are an image laid on by ShotOutlineOverlay.
      case ShotOverlayKind.standard:
        break;
    }
  }

  /// Wide cloth and a narrower tasseled piece on one rod.
  void _jodHanging(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Offset at(double x, double y) => Offset(
          frame.left + frame.width * x,
          frame.top + frame.height * y,
        );

    canvas.drawLine(
      at(0.02, 0.035),
      at(0.98, 0.035),
      Paint()
        ..color = const Color(0xE8FFFFFF)
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );

    final wide = Rect.fromLTRB(
      at(0.03, 0.055).dx,
      at(0.03, 0.055).dy,
      at(0.66, 0.97).dx,
      at(0.66, 0.97).dy,
    );
    canvas.drawRect(wide, fill);
    canvas.drawRect(wide, stroke);
    canvas.drawLine(
      Offset(wide.left + wide.width * 0.22, wide.top),
      Offset(wide.left + wide.width * 0.22, wide.top + wide.height * 0.62),
      faint,
    );
    canvas.drawLine(
      Offset(wide.left + wide.width * 0.38, wide.top),
      Offset(wide.left + wide.width * 0.38, wide.top + wide.height * 0.62),
      stroke,
    );
    _templePeaks(
      canvas,
      wide.left,
      wide.right,
      wide.top + wide.height * 0.62,
      stroke,
    );
    final band = wide.top + wide.height * 0.76;
    canvas.drawLine(Offset(wide.left, band), Offset(wide.right, band), stroke);
    canvas.drawLine(
      Offset(wide.left, wide.top + wide.height * 0.88),
      Offset(wide.right, wide.top + wide.height * 0.88),
      faint,
    );

    final narrow = Rect.fromLTRB(
      at(0.72, 0.055).dx,
      at(0.72, 0.055).dy,
      at(0.97, 0.78).dx,
      at(0.97, 0.78).dy,
    );
    canvas.drawRect(narrow, fill);
    canvas.drawRect(narrow, stroke);
    canvas.drawLine(
      Offset(narrow.left + narrow.width * 0.4, narrow.top),
      Offset(narrow.left + narrow.width * 0.4, narrow.top + narrow.height * 0.62),
      faint,
    );
    canvas.drawLine(
      Offset(narrow.left, narrow.top + narrow.height * 0.68),
      Offset(narrow.right, narrow.top + narrow.height * 0.68),
      stroke,
    );
    canvas.drawLine(
      Offset(narrow.left, narrow.top + narrow.height * 0.82),
      Offset(narrow.right, narrow.top + narrow.height * 0.82),
      faint,
    );
    for (var i = 0; i < 4; i++) {
      final x = narrow.left + narrow.width * (0.16 + i * 0.22);
      canvas.drawLine(
        Offset(x, narrow.bottom),
        Offset(x, narrow.bottom + frame.height * 0.08),
        stroke,
      );
    }
  }

  /// Wide fold on the left, smaller tasseled piece on the right.
  void _jodFolded(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final wide = Rect.fromLTRB(
      frame.left + frame.width * 0.02,
      frame.top + frame.height * 0.03,
      frame.left + frame.width * 0.72,
      frame.top + frame.height * 0.86,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(wide, const Radius.circular(6)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(wide, const Radius.circular(6)),
      stroke,
    );
    final bandTop = wide.top + wide.height * 0.62;
    canvas.drawRect(
      Rect.fromLTRB(wide.left, bandTop, wide.right, wide.bottom),
      Paint()..color = const Color(0x18FFFFFF),
    );
    canvas.drawLine(Offset(wide.left, bandTop), Offset(wide.right, bandTop), stroke);
    canvas.drawLine(
      Offset(wide.left, wide.top + wide.height * 0.8),
      Offset(wide.right, wide.top + wide.height * 0.8),
      faint,
    );
    _templePeaks(
      canvas,
      wide.left,
      wide.right,
      bandTop - wide.height * 0.14,
      stroke,
      drop: wide.height * 0.12,
    );
    for (final fraction in [0.32, 0.4, 0.52, 0.6]) {
      canvas.drawLine(
        Offset(wide.left + wide.width * fraction, wide.top),
        Offset(wide.left + wide.width * fraction, wide.bottom),
        fraction == 0.4 || fraction == 0.6 ? stroke : faint,
      );
    }

    final small = Rect.fromLTRB(
      frame.left + frame.width * 0.56,
      frame.top + frame.height * 0.42,
      frame.right - frame.width * 0.02,
      frame.top + frame.height * 0.88,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(small, const Radius.circular(6)), fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(small, const Radius.circular(6)),
      stroke,
    );
    canvas.drawLine(
      Offset(small.left + small.width * 0.22, small.top),
      Offset(small.left + small.width * 0.22, small.bottom),
      faint,
    );
    canvas.drawLine(
      Offset(small.left + small.width * 0.36, small.top),
      Offset(small.left + small.width * 0.36, small.bottom),
      stroke,
    );
    canvas.drawLine(
      Offset(small.left, small.top + small.height * 0.36),
      Offset(small.right, small.top + small.height * 0.36),
      stroke,
    );
    canvas.drawLine(
      Offset(small.left, small.top + small.height * 0.64),
      Offset(small.right, small.top + small.height * 0.64),
      faint,
    );
    for (var i = 0; i < 6; i++) {
      final x = small.left + small.width * (0.1 + i * 0.15);
      canvas.drawLine(
        Offset(x, small.bottom),
        Offset(x, small.bottom + frame.height * 0.08),
        stroke,
      );
    }
  }

  void _templePeaks(
    Canvas canvas,
    double left,
    double right,
    double top,
    Paint paint, {
    double? drop,
  }) {
    const count = 6;
    final step = (right - left) / count;
    final peak = drop ?? step * 0.7;
    final path = Path()..moveTo(left, top + peak);
    for (var i = 0; i < count; i++) {
      final x = left + step * i;
      path
        ..lineTo(x + step / 2, top)
        ..lineTo(x + step, top + peak);
    }
    canvas.drawPath(path, paint);
  }


  /// One side of a sofa: left arm, back behind the pillow, seat underneath.
  /// The right side runs off the frame.
  void _cushionSofa(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final solid = Paint()..color = const Color(0x55101414);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Offset p(double x, double y) => Offset(
          frame.left + frame.width * x,
          frame.top + frame.height * y,
        );

    final back = Path()
      ..moveTo(p(0.22, 0.50).dx, p(0.22, 0.50).dy)
      ..lineTo(p(0.22, 0.16).dx, p(0.22, 0.16).dy)
      ..quadraticBezierTo(
        p(0.22, 0.06).dx,
        p(0.22, 0.06).dy,
        p(0.32, 0.06).dx,
        p(0.32, 0.06).dy,
      )
      ..lineTo(p(1, 0.06).dx, p(1, 0.06).dy)
      ..lineTo(p(1, 0.50).dx, p(1, 0.50).dy)
      ..close();
    canvas.drawPath(back, solid);
    canvas.drawPath(back, fill);
    canvas.drawPath(back, stroke);

    final seat = Path()
      ..moveTo(p(0.26, 0.62).dx, p(0.26, 0.62).dy)
      ..lineTo(p(1, 0.62).dx, p(1, 0.62).dy)
      ..lineTo(p(1, 0.94).dx, p(1, 0.94).dy)
      ..lineTo(p(0.16, 0.94).dx, p(0.16, 0.94).dy)
      ..quadraticBezierTo(
        p(0.16, 0.72).dx,
        p(0.16, 0.72).dy,
        p(0.26, 0.62).dx,
        p(0.26, 0.62).dy,
      )
      ..close();
    canvas.drawPath(seat, solid);
    canvas.drawPath(seat, fill);
    canvas.drawPath(seat, stroke);

    final arm = RRect.fromRectAndRadius(
      Rect.fromLTRB(p(0.04, 0.36).dx, p(0.04, 0.36).dy, p(0.28, 0.90).dx, p(0.28, 0.90).dy),
      const Radius.circular(14),
    );
    canvas.drawRRect(arm, solid);
    canvas.drawRRect(arm, fill);
    canvas.drawRRect(arm, stroke);

    final pillow = RRect.fromRectAndRadius(
      Rect.fromLTRB(p(0.3, 0.14).dx, p(0.3, 0.14).dy, p(0.96, 0.8).dx, p(0.3, 0.8).dy),
      const Radius.circular(18),
    );
    canvas.drawRRect(pillow, solid);
    canvas.drawRRect(pillow, fill);
    canvas.drawRRect(pillow, stroke);
    final face = pillow.outerRect.deflate(pillow.outerRect.width * 0.12);
    canvas.drawLine(
      Offset(face.left, face.top + face.height * 0.32),
      Offset(face.right, face.top + face.height * 0.32),
      faint,
    );
    canvas.drawLine(
      Offset(face.left, face.top + face.height * 0.46),
      Offset(face.right, face.top + face.height * 0.46),
      stroke,
    );
  }

  /// Gamusa on a rod: side borders, wide end band, tassels along the hem.
  void _gamusaFull(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cloth = Rect.fromLTRB(
      frame.left + frame.width * 0.06,
      frame.top + frame.height * 0.04,
      frame.right - frame.width * 0.06,
      frame.top + frame.height * 0.92,
    );
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, stroke);
    canvas.drawLine(
      Offset(frame.left + frame.width * 0.02, cloth.top),
      Offset(frame.right - frame.width * 0.02, cloth.top),
      Paint()
        ..color = const Color(0xE8FFFFFF)
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cloth.left + cloth.width * 0.1, cloth.top),
      Offset(cloth.left + cloth.width * 0.1, cloth.bottom),
      faint,
    );
    canvas.drawLine(
      Offset(cloth.left + cloth.width * 0.2, cloth.top),
      Offset(cloth.left + cloth.width * 0.2, cloth.bottom),
      stroke,
    );
    canvas.drawLine(
      Offset(cloth.right - cloth.width * 0.2, cloth.top),
      Offset(cloth.right - cloth.width * 0.2, cloth.bottom),
      stroke,
    );
    canvas.drawLine(
      Offset(cloth.right - cloth.width * 0.1, cloth.top),
      Offset(cloth.right - cloth.width * 0.1, cloth.bottom),
      faint,
    );
    final bandTop = cloth.top + cloth.height * 0.58;
    final bandBottom = cloth.top + cloth.height * 0.86;
    canvas.drawRect(
      Rect.fromLTRB(cloth.left, bandTop, cloth.right, bandBottom),
      Paint()..color = const Color(0x18FFFFFF),
    );
    canvas.drawLine(Offset(cloth.left, bandTop), Offset(cloth.right, bandTop), stroke);
    canvas.drawLine(
      Offset(cloth.left, cloth.top + cloth.height * 0.66),
      Offset(cloth.right, cloth.top + cloth.height * 0.66),
      faint,
    );
    canvas.drawLine(
      Offset(cloth.left, cloth.top + cloth.height * 0.78),
      Offset(cloth.right, cloth.top + cloth.height * 0.78),
      faint,
    );
    canvas.drawLine(Offset(cloth.left, bandBottom), Offset(cloth.right, bandBottom), stroke);
    _diamonds(
      canvas,
      Rect.fromLTRB(
        cloth.left + cloth.width * 0.22,
        bandTop,
        cloth.right - cloth.width * 0.22,
        bandBottom,
      ),
      Paint()..color = const Color(0xCCFFFFFF),
    );
    for (var i = 0; i < 7; i++) {
      final x = cloth.left + cloth.width * (0.08 + i * 0.14);
      canvas.drawLine(
        Offset(x, cloth.bottom),
        Offset(x, cloth.bottom + frame.height * 0.06),
        stroke,
      );
    }
  }

  /// Folded gamusa: end border across, side border on the right, tassels in front.
  void _gamusaFolded(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cloth = Rect.fromLTRB(
      frame.left + frame.width * 0.03,
      frame.top + frame.height * 0.04,
      frame.right - frame.width * 0.03,
      frame.top + frame.height * 0.9,
    );
    final radius = RRect.fromRectAndRadius(cloth, const Radius.circular(8));
    canvas.drawRRect(radius, fill);
    canvas.drawRRect(radius, stroke);

    final split = cloth.left + cloth.width * 0.74;
    final bandTop = cloth.top + cloth.height * 0.38;
    final bandBottom = cloth.top + cloth.height * 0.7;
    canvas.drawRect(
      Rect.fromLTRB(cloth.left, bandTop, split, bandBottom),
      Paint()..color = const Color(0x18FFFFFF),
    );
    canvas.drawLine(Offset(cloth.left, bandTop), Offset(split, bandTop), stroke);
    canvas.drawLine(
      Offset(cloth.left, cloth.top + cloth.height * 0.48),
      Offset(split, cloth.top + cloth.height * 0.48),
      faint,
    );
    canvas.drawLine(
      Offset(cloth.left, cloth.top + cloth.height * 0.6),
      Offset(split, cloth.top + cloth.height * 0.6),
      faint,
    );
    canvas.drawLine(Offset(cloth.left, bandBottom), Offset(split, bandBottom), stroke);
    _diamonds(
      canvas,
      Rect.fromLTRB(cloth.left + cloth.width * 0.08, bandTop, split, bandBottom),
      Paint()..color = const Color(0xCCFFFFFF),
    );
    canvas.drawRect(
      Rect.fromLTRB(split, cloth.top, cloth.right, cloth.bottom),
      Paint()..color = const Color(0x18FFFFFF),
    );
    canvas.drawLine(Offset(split, cloth.top), Offset(split, cloth.bottom), stroke);
    canvas.drawLine(
      Offset(cloth.left + cloth.width * 0.86, cloth.top),
      Offset(cloth.left + cloth.width * 0.86, cloth.bottom),
      faint,
    );
    for (var i = 0; i < 8; i++) {
      final x = cloth.left + cloth.width * (0.08 + i * 0.11);
      canvas.drawLine(
        Offset(x, cloth.bottom),
        Offset(x, cloth.bottom + frame.height * 0.06),
        stroke,
      );
    }
  }

  /// Plump square cushion from above, piping on every side, motif in the middle.
  void _cushionFlat(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final side = (frame.width < frame.height ? frame.width : frame.height) * 0.96;
    final cover = RRect.fromRectAndRadius(
      Rect.fromCenter(center: frame.center, width: side, height: side),
      const Radius.circular(22),
    );
    canvas.drawRRect(cover, fill);
    canvas.drawRRect(cover, stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        cover.outerRect.deflate(cover.outerRect.width * 0.1),
        const Radius.circular(16),
      ),
      faint,
    );

    final face = cover.outerRect.deflate(cover.outerRect.width * 0.28);
    final c = face.center;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - face.height * 0.28)
        ..lineTo(c.dx + face.width * 0.22, c.dy)
        ..lineTo(c.dx, c.dy + face.height * 0.28)
        ..lineTo(c.dx - face.width * 0.22, c.dy)
        ..close(),
      Paint()..color = const Color(0xCCFFFFFF),
    );
  }

  /// Shawl hanging under a rod: wider cloth, border on the right, tassels below.
  void _shawlFull(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rodY = frame.top + frame.height * 0.025;
    canvas.drawLine(
      Offset(frame.left + frame.width * 0.015, rodY),
      Offset(frame.right - frame.width * 0.015, rodY),
      Paint()
        ..color = const Color(0xE8FFFFFF)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    final cloth = Rect.fromLTRB(
      frame.left + frame.width * 0.04,
      rodY + frame.height * 0.025,
      frame.right - frame.width * 0.04,
      frame.top + frame.height * 0.94,
    );
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, stroke);
    canvas.drawLine(
      Offset(cloth.left + cloth.width * 0.1, cloth.top),
      Offset(cloth.left + cloth.width * 0.1, cloth.bottom),
      faint,
    );
    final borderX = cloth.left + cloth.width * 0.74;
    canvas.drawRect(
      Rect.fromLTRB(borderX, cloth.top, cloth.right, cloth.bottom),
      Paint()..color = const Color(0x18FFFFFF),
    );
    canvas.drawLine(Offset(borderX, cloth.top), Offset(borderX, cloth.bottom), stroke);
    canvas.drawLine(
      Offset(cloth.left + cloth.width * 0.86, cloth.top),
      Offset(cloth.left + cloth.width * 0.86, cloth.bottom),
      faint,
    );
    _diamonds(
      canvas,
      Rect.fromLTRB(cloth.left, cloth.top, borderX, cloth.top + cloth.height * 0.6),
      Paint()..color = const Color(0xCCFFFFFF),
    );
    final bandY = cloth.top + cloth.height * 0.68;
    canvas.drawLine(Offset(cloth.left, bandY), Offset(cloth.right, bandY), stroke);
    canvas.drawLine(
      Offset(cloth.left, cloth.top + cloth.height * 0.82),
      Offset(cloth.right, cloth.top + cloth.height * 0.82),
      faint,
    );
    for (var i = 0; i < 7; i++) {
      final x = cloth.left + cloth.width * (0.08 + i * 0.14);
      canvas.drawLine(
        Offset(x, cloth.bottom),
        Offset(x, cloth.bottom + frame.height * 0.045),
        stroke,
      );
    }
  }

  /// One folded shawl: border down the right, band and tassels along the front.
  void _shawlFolded(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final shawl = Rect.fromLTRB(
      frame.left + frame.width * 0.03,
      frame.top + frame.height * 0.04,
      frame.right - frame.width * 0.03,
      frame.top + frame.height * 0.9,
    );
    final radius = RRect.fromRectAndRadius(shawl, const Radius.circular(10));
    canvas.drawRRect(radius, fill);
    canvas.drawRRect(radius, stroke);
    canvas.drawLine(
      Offset(shawl.left + shawl.width * 0.08, shawl.top),
      Offset(shawl.left + shawl.width * 0.08, shawl.bottom),
      faint,
    );
    final borderX = shawl.left + shawl.width * 0.76;
    canvas.drawRect(
      Rect.fromLTRB(borderX, shawl.top, shawl.right, shawl.bottom),
      Paint()..color = const Color(0x18FFFFFF),
    );
    canvas.drawLine(Offset(borderX, shawl.top), Offset(borderX, shawl.bottom), stroke);
    canvas.drawLine(
      Offset(shawl.left + shawl.width * 0.88, shawl.top),
      Offset(shawl.left + shawl.width * 0.88, shawl.bottom),
      faint,
    );
    final bandY = shawl.top + shawl.height * 0.62;
    _diamonds(
      canvas,
      Rect.fromLTRB(shawl.left, shawl.top, borderX, bandY),
      Paint()..color = const Color(0xCCFFFFFF),
    );
    canvas.drawLine(Offset(shawl.left, bandY), Offset(shawl.right, bandY), stroke);
    canvas.drawLine(
      Offset(shawl.left, shawl.top + shawl.height * 0.8),
      Offset(shawl.right, shawl.top + shawl.height * 0.8),
      faint,
    );
    for (var i = 0; i < 8; i++) {
      final x = shawl.left + shawl.width * (0.08 + i * 0.11);
      canvas.drawLine(
        Offset(x, shawl.bottom),
        Offset(x, shawl.bottom + frame.height * 0.06),
        stroke,
      );
    }
  }

  /// Stole hanging under a rod, with side borders and tassels along the hem.
  void _stoleFull(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rodY = frame.top + frame.height * 0.025;
    canvas.drawLine(
      Offset(frame.left + frame.width * 0.03, rodY),
      Offset(frame.right - frame.width * 0.03, rodY),
      Paint()
        ..color = const Color(0xE8FFFFFF)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    final cloth = Rect.fromLTRB(
      frame.left + frame.width * 0.08,
      rodY + frame.height * 0.025,
      frame.right - frame.width * 0.08,
      frame.top + frame.height * 0.94,
    );
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, stroke);
    final leftBorder = cloth.left + cloth.width * 0.16;
    final rightBorder = cloth.right - cloth.width * 0.16;
    canvas.drawLine(Offset(leftBorder, cloth.top), Offset(leftBorder, cloth.bottom), faint);
    canvas.drawLine(Offset(rightBorder, cloth.top), Offset(rightBorder, cloth.bottom), faint);
    _diamonds(
      canvas,
      Rect.fromLTRB(leftBorder, cloth.top, rightBorder, cloth.top + cloth.height * 0.62),
      Paint()..color = const Color(0xCCFFFFFF),
    );
    final bandY = cloth.top + cloth.height * 0.7;
    canvas.drawLine(Offset(cloth.left, bandY), Offset(cloth.right, bandY), stroke);
    canvas.drawLine(
      Offset(cloth.left, cloth.top + cloth.height * 0.82),
      Offset(cloth.right, cloth.top + cloth.height * 0.82),
      faint,
    );
    for (var i = 0; i < 6; i++) {
      final x = cloth.left + cloth.width * (0.12 + i * 0.15);
      canvas.drawLine(
        Offset(x, cloth.bottom),
        Offset(x, cloth.bottom + frame.height * 0.045),
        stroke,
      );
    }
  }

  /// One folded stole: side borders, a band, tassels along the front edge.
  void _stoleFolded(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final stole = Rect.fromLTRB(
      frame.left + frame.width * 0.03,
      frame.top + frame.height * 0.04,
      frame.right - frame.width * 0.03,
      frame.top + frame.height * 0.9,
    );
    final radius = RRect.fromRectAndRadius(stole, const Radius.circular(10));
    canvas.drawRRect(radius, fill);
    canvas.drawRRect(radius, stroke);
    final leftBorder = stole.left + stole.width * 0.1;
    final rightBorder = stole.right - stole.width * 0.1;
    canvas.drawLine(Offset(leftBorder, stole.top), Offset(leftBorder, stole.bottom), faint);
    canvas.drawLine(Offset(rightBorder, stole.top), Offset(rightBorder, stole.bottom), faint);
    final bandY = stole.top + stole.height * 0.62;
    _diamonds(
      canvas,
      Rect.fromLTRB(leftBorder, stole.top, rightBorder, bandY),
      Paint()..color = const Color(0xCCFFFFFF),
    );
    canvas.drawLine(Offset(stole.left, bandY), Offset(stole.right, bandY), stroke);
    canvas.drawLine(
      Offset(stole.left, stole.top + stole.height * 0.8),
      Offset(stole.right, stole.top + stole.height * 0.8),
      faint,
    );
    for (var i = 0; i < 7; i++) {
      final x = stole.left + stole.width * (0.1 + i * 0.13);
      canvas.drawLine(
        Offset(x, stole.bottom),
        Offset(x, stole.bottom + frame.height * 0.06),
        stroke,
      );
    }
  }

  /// Top-down stack: mekhela on top with a side border, sador below with a
  /// bottom border and tassels.
  void _mekhalaFolded(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final motif = Paint()..color = const Color(0xCCFFFFFF);

    final sador = Rect.fromLTRB(
      frame.left + frame.width * 0.03,
      frame.top + frame.height * 0.3,
      frame.left + frame.width * 0.97,
      frame.top + frame.height * 0.92,
    );
    final mekhela = Rect.fromLTRB(
      frame.left + frame.width * 0.06,
      frame.top + frame.height * 0.03,
      frame.left + frame.width * 0.94,
      frame.top + frame.height * 0.66,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(sador, const Radius.circular(10)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sador, const Radius.circular(10)),
      stroke,
    );
    final bandY = sador.top + sador.height * 0.78;
    _diamonds(
      canvas,
      Rect.fromLTRB(
        sador.left + sador.width * 0.08,
        mekhela.bottom + 8,
        sador.right - sador.width * 0.12,
        bandY - 6,
      ),
      motif,
    );
    canvas.drawLine(Offset(sador.left, bandY), Offset(sador.right, bandY), stroke);
    canvas.drawLine(
      Offset(sador.left, sador.top + sador.height * 0.8),
      Offset(sador.right, sador.top + sador.height * 0.8),
      faint,
    );
    for (var i = 0; i < 4; i++) {
      final x = sador.right - sador.width * (0.06 + i * 0.08);
      canvas.drawLine(
        Offset(x, sador.bottom),
        Offset(x, sador.bottom + frame.height * 0.045),
        stroke,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(mekhela, const Radius.circular(10)),
      Paint()..color = const Color(0x331B1B1B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mekhela, const Radius.circular(10)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mekhela, const Radius.circular(10)),
      stroke,
    );
    final borderX = mekhela.left + mekhela.width * 0.72;
    _diamonds(
      canvas,
      Rect.fromLTRB(mekhela.left, mekhela.top, borderX, mekhela.bottom),
      motif,
    );
    canvas.drawLine(Offset(borderX, mekhela.top), Offset(borderX, mekhela.bottom), stroke);
    canvas.drawLine(
      Offset(mekhela.left + mekhela.width * 0.84, mekhela.top),
      Offset(mekhela.left + mekhela.width * 0.84, mekhela.bottom),
      faint,
    );

    _centredLabel(canvas, 'Mekhela', mekhela.center - Offset(mekhela.width * 0.12, 0));
    _centredLabel(
      canvas,
      'Sador',
      Offset(sador.center.dx, (mekhela.bottom + bandY) / 2),
    );
  }

  void _diamonds(Canvas canvas, Rect body, Paint motif) {
    for (final spot in const [
      [0.28, 0.32],
      [0.58, 0.28],
      [0.42, 0.62],
      [0.72, 0.7],
    ]) {
      final c = Offset(
        body.left + body.width * spot[0],
        body.top + body.height * spot[1],
      );
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - 4)
          ..lineTo(c.dx + 3.2, c.dy)
          ..lineTo(c.dx, c.dy + 4)
          ..lineTo(c.dx - 3.2, c.dy)
          ..close(),
        motif,
      );
    }
  }

  /// Two hangers on a rod: shorter mekhela on the left, longer sador on the right.
  void _mekhalaHanging(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rodY = frame.top + frame.height * 0.035;
    canvas.drawLine(
      Offset(frame.left + frame.width * 0.015, rodY),
      Offset(frame.right - frame.width * 0.015, rodY),
      Paint()
        ..color = const Color(0xE8FFFFFF)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    void hanger(double cxFrac, double leftFrac, double rightFrac) {
      final cx = frame.left + frame.width * cxFrac;
      final left = frame.left + frame.width * leftFrac;
      final right = frame.left + frame.width * rightFrac;
      final barY = rodY + frame.height * 0.065;
      canvas.drawLine(Offset(cx, rodY), Offset(cx, rodY + frame.height * 0.022), stroke);
      canvas.drawLine(Offset(left, barY), Offset(cx, rodY + frame.height * 0.018), stroke);
      canvas.drawLine(Offset(right, barY), Offset(cx, rodY + frame.height * 0.018), stroke);
      canvas.drawLine(Offset(left, barY), Offset(right, barY), stroke);
    }

    hanger(0.22, 0.03, 0.41);
    hanger(0.72, 0.48, 0.97);

    final top = rodY + frame.height * 0.075;
    final mekhela = Rect.fromLTRB(
      frame.left + frame.width * 0.04,
      top,
      frame.left + frame.width * 0.41,
      frame.top + frame.height * 0.78,
    );
    final sador = Rect.fromLTRB(
      frame.left + frame.width * 0.49,
      top,
      frame.left + frame.width * 0.96,
      frame.top + frame.height * 0.94,
    );
    canvas.drawRect(mekhela, fill);
    canvas.drawRect(sador, fill);
    canvas.drawRect(mekhela, stroke);
    canvas.drawRect(sador, stroke);

    for (final fraction in [0.55, 0.68, 0.80, 0.92]) {
      final y = mekhela.top + mekhela.height * fraction;
      canvas.drawLine(Offset(mekhela.left, y), Offset(mekhela.right, y), faint);
    }

    final leftBorder = sador.left + sador.width * 0.16;
    final rightBorder = sador.right - sador.width * 0.16;
    canvas.drawLine(Offset(leftBorder, sador.top), Offset(leftBorder, sador.bottom), faint);
    canvas.drawLine(Offset(rightBorder, sador.top), Offset(rightBorder, sador.bottom), faint);
    final motif = Paint()..color = const Color(0xCCFFFFFF);
    for (final spot in const [
      [0.35, 0.22],
      [0.62, 0.34],
      [0.42, 0.48],
      [0.70, 0.58],
    ]) {
      final c = Offset(
        sador.left + sador.width * spot[0],
        sador.top + sador.height * spot[1],
      );
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - 5)
          ..lineTo(c.dx + 4, c.dy)
          ..lineTo(c.dx, c.dy + 5)
          ..lineTo(c.dx - 4, c.dy)
          ..close(),
        motif,
      );
    }
    final bandY = sador.top + sador.height * 0.78;
    canvas.drawLine(Offset(sador.left, bandY), Offset(sador.right, bandY), stroke);
    for (var i = 0; i < 5; i++) {
      final x = sador.left + sador.width * (0.18 + i * 0.16);
      canvas.drawLine(
        Offset(x, sador.bottom),
        Offset(x, sador.bottom + frame.height * 0.045),
        stroke,
      );
    }
  }

  /// Mekhala and sador laid side by side, borders at the bottom.
  void _mekhalaPair(Canvas canvas, Rect frame) {
    final gap = frame.width * 0.025;
    final top = frame.top + frame.height * 0.03;
    final bottom = frame.bottom - frame.height * 0.06;
    final left = frame.left + frame.width * 0.03;
    final right = frame.right - frame.width * 0.03;
    final mid = (left + right) / 2;
    final mekhela = Rect.fromLTRB(left, top, mid - gap, bottom);
    final sador = Rect.fromLTRB(mid + gap, top, right, bottom);
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawRect(mekhela, Paint()..color = const Color(0x22FFFFFF));
    canvas.drawRect(sador, Paint()..color = const Color(0x22FFFFFF));
    canvas.drawRect(mekhela, stroke);
    canvas.drawRect(sador, stroke);
    _bottomBand(canvas, mekhela, 0.16, stroke);
    _bottomBand(canvas, sador, 0.22, stroke);
    for (var i = 0; i < 6; i++) {
      final x = sador.left + sador.width * (0.18 + i * 0.12);
      canvas.drawLine(
        Offset(x, sador.bottom),
        Offset(x, sador.bottom + frame.height * 0.045),
        stroke,
      );
    }
  }

  void _bottomBand(Canvas canvas, Rect panel, double fraction, Paint stroke) {
    final y = panel.bottom - panel.height * fraction;
    canvas.drawLine(Offset(panel.left, y), Offset(panel.right, y), stroke);
  }

  void _centredLabel(
    Canvas canvas,
    String text,
    Offset centre, {
    bool boxed = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tr(text),
        style: appType(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1,
        ).copyWith(
          shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 3)],
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
        text: tr(text),
        style: appType(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1,
        ).copyWith(
          shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 3)],
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

  /// Wide yardage on a rod: soft folds, stars across the cloth, no border.
  void _yardageHanging(Canvas canvas, Rect frame) {
    final stroke = Paint()
      ..color = const Color(0xE8FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = const Color(0x22FFFFFF);
    final faint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final cloth = Rect.fromLTRB(
      frame.left + frame.width * 0.04,
      frame.top + frame.height * 0.05,
      frame.right - frame.width * 0.04,
      frame.top + frame.height * 0.96,
    );
    canvas.drawRect(cloth, fill);
    canvas.drawRect(cloth, stroke);
    canvas.drawLine(
      Offset(frame.left + frame.width * 0.015, cloth.top),
      Offset(frame.right - frame.width * 0.015, cloth.top),
      Paint()
        ..color = const Color(0xE8FFFFFF)
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cloth.left + cloth.width * 0.34, cloth.top),
      Offset(cloth.left + cloth.width * 0.34, cloth.bottom),
      faint,
    );
    canvas.drawLine(
      Offset(cloth.left + cloth.width * 0.62, cloth.top),
      Offset(cloth.left + cloth.width * 0.62, cloth.bottom),
      faint,
    );
    final star = Paint()..color = const Color(0xE8FFFFFF);
    final dim = Paint()..color = const Color(0x99FFFFFF);
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
    final radius = frame.width * 0.018;
    for (var i = 0; i < spots.length; i++) {
      _star(
        canvas,
        Offset(
          cloth.left + cloth.width * spots[i][0],
          cloth.top + cloth.height * spots[i][1],
        ),
        i.isEven ? radius : radius * 0.75,
        i.isEven ? star : dim,
      );
    }
  }

  /// Close-up: the weave and a few stars fill the whole frame.
  void _yardageClose(Canvas canvas, Rect frame) {
    final faint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final cloth = Rect.fromLTRB(
      frame.left + frame.width * 0.03,
      frame.top + frame.height * 0.03,
      frame.right - frame.width * 0.03,
      frame.top + frame.height * 0.97,
    );
    for (var i = 1; i <= 4; i++) {
      final x = cloth.left + cloth.width * i / 5;
      final y = cloth.top + cloth.height * i / 5;
      canvas.drawLine(Offset(x, cloth.top), Offset(x, cloth.bottom), faint);
      canvas.drawLine(Offset(cloth.left, y), Offset(cloth.right, y), faint);
    }
    final star = Paint()..color = const Color(0xE8FFFFFF);
    final dim = Paint()..color = const Color(0x99FFFFFF);
    const spots = <List<double>>[
      [0.2, 0.16],
      [0.78, 0.14],
      [0.48, 0.32],
      [0.14, 0.46],
      [0.84, 0.5],
      [0.36, 0.6],
      [0.66, 0.72],
      [0.22, 0.84],
      [0.56, 0.9],
    ];
    final radius = frame.width * 0.028;
    for (var i = 0; i < spots.length; i++) {
      _star(
        canvas,
        Offset(
          cloth.left + cloth.width * spots[i][0],
          cloth.top + cloth.height * spots[i][1],
        ),
        i.isEven ? radius : radius * 0.72,
        i.isEven ? star : dim,
      );
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

  @override
  bool shouldRepaint(covariant _OutlinePainter oldDelegate) =>
      oldDelegate.clearTop != clearTop ||
      oldDelegate.clearBottom != clearBottom ||
      oldDelegate.outline.widthFactor != outline.widthFactor ||
      oldDelegate.outline.aspectRatio != outline.aspectRatio ||
      oldDelegate.outline.silhouette != outline.silhouette ||
      oldDelegate.outline.placement != outline.placement ||
      oldDelegate.outline.inset != outline.inset ||
      oldDelegate.outline.kind != outline.kind ||
      oldDelegate.locale != locale;
}
