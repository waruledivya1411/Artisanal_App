import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

import 'package:artisnal_app/core/gallery/photo_download.dart'
    if (dart.library.js_interop) 'package:artisnal_app/core/gallery/photo_download_web.dart';

enum PhotoSaveKind { gallery, download }

class PhotoSaveResult {
  const PhotoSaveResult(this.kind);

  final PhotoSaveKind kind;
}

/// Saves a JPEG to the phone gallery. On the web it downloads the file.
Future<PhotoSaveResult> savePhotoBytes(Uint8List bytes) async {
  final name = 'artisnal_${DateTime.now().millisecondsSinceEpoch}';
  if (kIsWeb) {
    downloadPhoto(bytes, '$name.jpg');
    return const PhotoSaveResult(PhotoSaveKind.download);
  }
  // Android 6-9 needs storage permission to save, and it is only asked for
  // when requested; elsewhere this is already granted and returns at once.
  if (!await Gal.hasAccess()) await Gal.requestAccess();
  await Gal.putImageBytes(bytes, name: name);
  return const PhotoSaveResult(PhotoSaveKind.gallery);
}
