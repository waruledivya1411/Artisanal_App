import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Adjustments applied on the edit screen, then baked into the saved photo.
class PhotoEdits {
  const PhotoEdits({
    this.crop = 0,
    this.quarterTurns = 0,
    this.brightness = 0,
    this.white = 0,
  });

  /// Share cropped off each edge, 0 to about 0.35.
  final double crop;

  final int quarterTurns;

  /// Added light. 0 is unchanged. About -0.35 to 0.45.
  final double brightness;

  /// Cool (−1) to warm (1). 0 is unchanged.
  final double white;

  bool get isIdentity =>
      crop < 0.01 &&
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

  if (edits.crop >= 0.01) {
    final dx = (out.width * edits.crop).round();
    final dy = (out.height * edits.crop).round();
    final width = out.width - dx * 2;
    final height = out.height - dy * 2;
    if (width > 8 && height > 8) {
      out = img.copyCrop(out, x: dx, y: dy, width: width, height: height);
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
