import 'dart:typed_data';

/// No-op on phones. Web replaces this with a file download.
void downloadPhoto(Uint8List bytes, String filename) {}
