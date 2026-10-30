import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:image/image.dart' as img;

/// Adjustments applied on the edit screen, then baked into the saved photo.
class PhotoEdits {
  const PhotoEdits({
    this.crop = fullFrame,
    this.quarterTurns = 0,
    this.brightness = 0,
    this.white = 0,
  });

  /// The whole photo, uncropped.
  static const fullFrame = Rect.fromLTRB(0, 0, 1, 1);

  /// The part of the photo kept, as fractions of it after turning: 0,0 is
  /// the top left and 1,1 the bottom right.
  final Rect crop;

  bool get isCropped =>
      crop.left > 0.005 ||
      crop.top > 0.005 ||
      crop.right < 0.995 ||
      crop.bottom < 0.995;

  final int quarterTurns;

  /// Added light. 0 is unchanged. About -0.35 to 0.45.
  final double brightness;

  /// Cool (−1) to warm (1). 0 is unchanged.
  final double white;

  bool get isIdentity =>
      !isCropped &&
      quarterTurns % 4 == 0 &&
      brightness.abs() < 0.01 &&
      white.abs() < 0.01;
}

/// Returns a JPEG of [bytes] with [edits] applied.
Uint8List bakePhotoEdits(Uint8List bytes, PhotoEdits edits) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  var out = img.bakeOrientation(decoded);
  const maxSide = 2048;
  if (out.width > maxSide || out.height > maxSide) {
    out = out.width >= out.height
        ? img.copyResize(out, width: maxSide)
        : img.copyResize(out, height: maxSide);
  }

  final turns = edits.quarterTurns % 4;
  if (turns != 0) {
    out = img.copyRotate(out, angle: turns * 90);
  }

  if (edits.isCropped) {
    final c = edits.crop;
    final x = (out.width * c.left).round().clamp(0, out.width - 1);
    final y = (out.height * c.top).round().clamp(0, out.height - 1);
    final width = (out.width * c.width).round().clamp(1, out.width - x);
    final height = (out.height * c.height).round().clamp(1, out.height - y);
    if (width > 8 && height > 8) {
      out = img.copyCrop(out, x: x, y: y, width: width, height: height);
    }
  }

  if (edits.brightness.abs() >= 0.01) {
    out = img.adjustColor(
      out,
      brightness: (1 + edits.brightness).clamp(0.25, 1.8),
    );
  }
  if (edits.white.abs() >= 0.01) {
    out = img.colorOffset(
      out,
      red: edits.white * 42,
      blue: -edits.white * 42,
    );
  }

  return img.encodeJpg(out, quality: 92);
}

/// Returns a JPEG of the part of [bytes] that lay between the photo lines on
/// the camera screen.
///
/// [previewAspect] is the width over height of the live picture as shown,
/// and [region] is the photo's share of that picture, 0 to 1 on each side
/// (left, top, right, bottom). A still can be wider or taller than the live
/// picture, so the centred part matching the live picture is found first.
Uint8List cropToPreviewRegion(
  Uint8List bytes,
  double previewAspect,
  (double, double, double, double) region,
) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  var out = img.bakeOrientation(decoded);

  var liveWidth = out.width.toDouble();
  var liveHeight = liveWidth / previewAspect;
  if (liveHeight > out.height) {
    liveHeight = out.height.toDouble();
    liveWidth = liveHeight * previewAspect;
  }
  final liveLeft = (out.width - liveWidth) / 2;
  final liveTop = (out.height - liveHeight) / 2;

  final (left, top, right, bottom) = region;
  final x = (liveLeft + liveWidth * left).round().clamp(0, out.width - 1);
  final y = (liveTop + liveHeight * top).round().clamp(0, out.height - 1);
  final width =
      (liveWidth * (right - left)).round().clamp(1, out.width - x);
  final height =
      (liveHeight * (bottom - top)).round().clamp(1, out.height - y);
  out = img.copyCrop(out, x: x, y: y, width: width, height: height);

  const maxSide = 2048;
  if (out.width > maxSide || out.height > maxSide) {
    out = out.width >= out.height
        ? img.copyResize(out, width: maxSide)
        : img.copyResize(out, height: maxSide);
  }
  return img.encodeJpg(out, quality: 92);
}
