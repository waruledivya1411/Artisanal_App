import 'dart:html' as html;
import 'dart:typed_data';

void downloadPhoto(Uint8List bytes, String filename) {
  final blob = html.Blob([bytes], 'image/jpeg');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = filename
    ..click();
  html.Url.revokeObjectUrl(url);
}
