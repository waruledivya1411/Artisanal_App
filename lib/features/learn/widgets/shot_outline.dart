
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
  mekhalaBorder,
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
        (_sareeGuideProducts.contains(product) || product == 'Yardages')) {
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
    if (displayKey == 'embroidery_and_border' && product == 'Mekhala sador') {
      return const ShotOutline(
        widthFactor: 0.88,
        aspectRatio: ShotOutlineOverlay.mekhalaBorderArtAspect,
        kind: ShotOverlayKind.mekhalaBorder,
      );
    }
    if (displayKey == 'full_display' && product == 'Mekhala sador') {
      return const ShotOutline(
        widthFactor: 0.88,
        // The shape of the dotted drawing, so it is not stretched.
        aspectRatio: ShotOutlineOverlay.mekhalaFullArtAspect,
        kind: ShotOverlayKind.mekhalaFull,
      );
    }
    if (displayKey == 'full_display' && product == 'Shawl') {
      return const ShotOutline(
        widthFactor: 0.72,
        // Hangs from a rod: the shape of the dotted drawing.
        aspectRatio: ShotOutlineOverlay.rodHangingArtAspect,
        kind: ShotOverlayKind.shawlFull,
      );
    }
    if (displayKey == 'full_display' && product == 'Stole') {
      return const ShotOutline(
        widthFactor: 0.62,
        // Hangs from a rod: the shape of the dotted drawing.
        aspectRatio: ShotOutlineOverlay.rodHangingArtAspect,
        kind: ShotOverlayKind.stoleFull,
      );
    }
    if (displayKey == 'flat_lay_display') {
      return const ShotOutline(
        widthFactor: 0.86,
        // The shape of the dotted drawing, so it is not stretched.
        aspectRatio: ShotOutlineOverlay.cushionFlatArtAspect,
        kind: ShotOverlayKind.cushionFlat,
      );
    }
    if (displayKey == 'sofa_seated_display') {
      return const ShotOutline(
        widthFactor: 0.86,
        // The shape of the dotted drawing, so it is not stretched.
        aspectRatio: ShotOutlineOverlay.cushionSofaArtAspect,
        kind: ShotOverlayKind.cushionSofa,
      );
    }
    if (displayKey == 'full_display' && product == 'Gamusa') {
      return const ShotOutline(
        widthFactor: 0.62,
        // Hangs from a rod: the shape of the dotted drawing.
        aspectRatio: ShotOutlineOverlay.rodHangingArtAspect,
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
        // The shape of the dotted folded drawing, full width.
        aspectRatio: ShotOutlineOverlay.foldedTasselArtAspect,
        kind: ShotOverlayKind.gamusaFolded,
      );
    }
    if (displayKey == 'folded_stack' && product == 'Jod kappur') {
      return const ShotOutline(
        widthFactor: 0.88,
        // The shape of the dotted drawing, so it is not stretched.
        aspectRatio: ShotOutlineOverlay.jodFoldedArtAspect,
        kind: ShotOverlayKind.jodFolded,
      );
    }
    if (displayKey == 'folded_stack' && product == 'Shawl') {
      return const ShotOutline(
        widthFactor: 0.88,
        // The shape of the dotted folded drawing, full width.
        aspectRatio: ShotOutlineOverlay.foldedTasselArtAspect,
        kind: ShotOverlayKind.shawlFolded,
      );
    }
    if (displayKey == 'folded_stack' && product == 'Stole') {
      return const ShotOutline(
        widthFactor: 0.88,
        // The shape of the dotted folded drawing, full width.
        aspectRatio: ShotOutlineOverlay.foldedTasselArtAspect,
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
        // The shape of the dotted drawing, so it is not stretched.
        aspectRatio: ShotOutlineOverlay.yardageHangingArtAspect,
        kind: ShotOverlayKind.yardageHanging,
      );
    }
    if (displayKey == 'hanging_display' && product == 'Jod kappur') {
      return const ShotOutline(
        widthFactor: 0.88,
        // The shape of the dotted drawing, so it is not stretched.
        aspectRatio: ShotOutlineOverlay.jodHangingArtAspect,
        kind: ShotOverlayKind.jodHanging,
      );
    }
    if (displayKey == 'hanging_display' && product == 'Mekhala sador') {
      return const ShotOutline(
        widthFactor: 0.88,
        // The shape of the dotted drawing, so it is not stretched.
        aspectRatio: ShotOutlineOverlay.mekhalaHangingArtAspect,
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
  static const drapedArt =
      'assets/images/lessons/photography/draped_outline_v2.png';
  static const drapedArtAspect = 900 / 837;

  /// Dotted sari laid flat - motifs on the body, the border down the right -
  /// for the embroidery and border shot. Drawn the same way as [drapedArt].
  static const embroideryArt =
      'assets/images/lessons/photography/embroidery_outline_v2.png';

  /// Dotted sari laid flat, a border down each side, for the full display
  /// shot. Drawn the same way as [drapedArt].
  static const fullDisplayArt =
      'assets/images/lessons/photography/full_display_outline_v3.png';
  static const fullDisplayArtAspect = 900 / 1286;

  /// Dotted sari hanging from a hanger, for the hanging shot. Drawn the same
  /// way as [drapedArt], borders kept in gold.
  static const hangingArt =
      'assets/images/lessons/photography/hanging_outline_v2.png';

  /// Dotted folded sari seen from the front, border down the right, for the
  /// folded stack shot. Drawn the same way as [drapedArt].
  static const foldedArt =
      'assets/images/lessons/photography/folded_outline_v2.png';

  /// Dotted mekhela and sador laid side by side, borders and tassels at the
  /// foot, for the Mekhala sador full display shot.
  static const mekhalaFullArt =
      'assets/images/lessons/photography/mekhala_full_outline_v2.png';
  static const mekhalaFullArtAspect = 1000 / 1095;

  /// Dotted mekhela corner: plain body, paisley borders down the side and
  /// across the foot, for the Mekhala sador embroidery and border shot.
  static const mekhalaBorderArt =
      'assets/images/lessons/photography/mekhala_border_outline.png';
  static const mekhalaBorderArtAspect = 900 / 1220;

  /// Dotted mekhela and sador folded together, paisley borders and tassels,
  /// for the Mekhala sador folded stack shot.
  static const mekhalaFoldedArt =
      'assets/images/lessons/photography/mekhala_folded_outline.png';
  static const mekhalaFoldedArtAspect = 1000 / 710;

  /// Dotted mekhela and sador on hangers from one rod, for the Mekhala
  /// sador hanging shot.
  static const mekhalaHangingArt =
      'assets/images/lessons/photography/mekhala_hanging_outline_v2.png';
  static const mekhalaHangingArtAspect = 1000 / 1014;

  /// Dotted stole on a rod, borders down the sides, a woven band and
  /// tassels at the foot. Stole, shawl and gamusa all hang this way for
  /// their full display shot.
  static const rodHangingArt =
      'assets/images/lessons/photography/stole_hanging_outline_v2.png';
  static const rodHangingArtAspect = 900 / 1313;

  /// Dotted folded stole: a woven band across, a border down the side and
  /// tassels along the front. Stole, shawl and gamusa all fold this way.
  static const foldedTasselArt =
      'assets/images/lessons/photography/stole_folded_outline.png';
  static const foldedTasselArtAspect = 1000 / 641;

  /// A cushion with an embroidered edge sitting in the corner of a sofa,
  /// for the cushion cover sofa-seated shot.
  static const cushionSofaArt =
      'assets/images/lessons/photography/cushion_sofa_outline.png';
  static const cushionSofaArtAspect = 1000 / 914;

  /// A cushion laid flat, seen from above, with an embroidered edge, for
  /// the cushion cover flat-lay shot.
  static const cushionFlatArt =
      'assets/images/lessons/photography/cushion_flat_outline.png';
  static const cushionFlatArtAspect = 1000 / 892;

  /// Jod kappur on one rod, the wide cloth beside the narrow tasseled piece,
  /// for the hanging shot.
  static const jodHangingArt =
      'assets/images/lessons/photography/jod_hanging_outline_v3.png';
  static const jodHangingArtAspect = 1000 / 991;

  /// Jod kappur folded, the wide cloth behind the smaller tasseled piece, for
  /// the folded shot.
  static const jodFoldedArt =
      'assets/images/lessons/photography/jod_folded_outline_v2.png';
  static const jodFoldedArtAspect = 1000 / 897;

  /// Yardage gathered over a rod, motifs scattered across it, for the hanging
  /// shot.
  static const yardageHangingArt =
      'assets/images/lessons/photography/yardage_hanging_outline.png';
  static const yardageHangingArtAspect = 900 / 1286;

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
        ShotOverlayKind.mekhalaFull => mekhalaFullArt,
        ShotOverlayKind.embroideryBorder => embroideryArt,
        ShotOverlayKind.mekhalaBorder => mekhalaBorderArt,
        ShotOverlayKind.mekhalaFolded => mekhalaFoldedArt,
        ShotOverlayKind.mekhalaHanging => mekhalaHangingArt,
        ShotOverlayKind.jodHanging => jodHangingArt,
        ShotOverlayKind.jodFolded => jodFoldedArt,
        ShotOverlayKind.yardageHanging => yardageHangingArt,
        ShotOverlayKind.stoleFull ||
        ShotOverlayKind.shawlFull ||
        ShotOverlayKind.gamusaFull => rodHangingArt,
        ShotOverlayKind.stoleFolded ||
        ShotOverlayKind.shawlFolded ||
        ShotOverlayKind.gamusaFolded => foldedTasselArt,
        ShotOverlayKind.cushionSofa => cushionSofaArt,
        ShotOverlayKind.cushionFlat => cushionFlatArt,
        _ => null,
      };

  /// The draped drawing has no box around it. It spans the photo's width and
  /// 80% of its height, so the sari fills most of the photo.
  static Rect drapedArtRect(Size screen, double? clearTop, double? clearBottom) {
    final photo = ShotOutline.photoRect(screen);
    return ShotOutline.fitBetween(
      Rect.fromCenter(
        center: photo.center,
        width: photo.width - 8,
        height: photo.height * 0.8,
      ),
      clearTop,
      clearBottom,
    );
  }

  /// A tall drawing in its own shape at 88% of the photo's height, so the
  /// piece sits inside the photo with room around it.
  static Rect tallArtRect(
    Size screen,
    double aspect,
    double? clearTop,
    double? clearBottom,
  ) {
    final photo = ShotOutline.photoRect(screen);
    final height = photo.height * 0.88;
    return ShotOutline.fitBetween(
      Rect.fromCenter(
        center: photo.center,
        width: height * aspect,
        height: height,
      ),
      clearTop,
      clearBottom,
    );
  }

  /// Both Jod kappur pieces on their rod: the full width of the photo and
  /// about 70% of its height, sitting towards the top.
  static Rect jodHangingArtRect(Size screen) {
    final photo = ShotOutline.photoRect(screen);
    final width = photo.width - 16;
    return Rect.fromLTWH(
      photo.left + 8,
      photo.top + photo.height * 0.08,
      width,
      width / jodHangingArtAspect,
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
  static Rect foldedArtRect(
    Size screen,
    double? clearTop,
    double? clearBottom, {
    double aspect = 1.25,
  }) {
    final photo = ShotOutline.photoRect(screen);
    final width = photo.width - 8;
    return ShotOutline.fitBetween(
      Rect.fromCenter(center: photo.center, width: width, height: width / aspect),
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
            ShotOverlayKind.sariFull => tallArtRect(
                screen,
                fullDisplayArtAspect,
                clearTop,
                clearBottom,
              ),
            ShotOverlayKind.yardageHanging => tallArtRect(
                screen,
                yardageHangingArtAspect,
                clearTop,
                clearBottom,
              ),
            ShotOverlayKind.stoleFull ||
            ShotOverlayKind.shawlFull ||
            ShotOverlayKind.gamusaFull => tallArtRect(
                screen,
                rodHangingArtAspect,
                clearTop,
                clearBottom,
              ),
            ShotOverlayKind.jodHanging => jodHangingArtRect(screen),
            ShotOverlayKind.sariDraped =>
              drapedArtRect(screen, clearTop, clearBottom),
            ShotOverlayKind.hangingDisplay =>
              hangingArtRect(screen, clearTop, clearBottom),
            ShotOverlayKind.foldedStack =>
              foldedArtRect(screen, clearTop, clearBottom),
            ShotOverlayKind.mekhalaFolded => foldedArtRect(
                screen,
                clearTop,
                clearBottom,
                aspect: mekhalaFoldedArtAspect,
              ),
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
      case ShotOverlayKind.mekhalaFull:
      case ShotOverlayKind.mekhalaFolded:
      case ShotOverlayKind.mekhalaHanging:
      case ShotOverlayKind.jodHanging:
      case ShotOverlayKind.jodFolded:
      case ShotOverlayKind.yardageHanging:
      case ShotOverlayKind.stoleFull:
      case ShotOverlayKind.shawlFull:
      case ShotOverlayKind.gamusaFull:
      case ShotOverlayKind.stoleFolded:
      case ShotOverlayKind.shawlFolded:
      case ShotOverlayKind.gamusaFolded:
      case ShotOverlayKind.cushionSofa:
      case ShotOverlayKind.cushionFlat:
      case ShotOverlayKind.mekhalaBorder:
      case ShotOverlayKind.embroideryBorder:
      case ShotOverlayKind.sariDraped:
        // Drawn from an image by ShotOutlineOverlay; never reached.
        break;
      case ShotOverlayKind.sariClose:
        // Motifs are an image laid on by ShotOutlineOverlay.
      case ShotOverlayKind.standard:
        break;
    }
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
