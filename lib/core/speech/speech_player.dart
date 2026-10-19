import 'package:flutter_tts/flutter_tts.dart';

class SpeechPlayer {
  SpeechPlayer(this.onPlayingChanged);

  final void Function(bool playing) onPlayingChanged;

  FlutterTts? _tts;
  bool playing = false;
  int _token = 0;

  Future<void> toggle({required String locale, required String text}) async {
    final tts = _tts ??= FlutterTts();
    if (playing) {
      _token++;
      playing = false;
      onPlayingChanged(false);
      try {
        await tts.stop();
      } catch (_) {}
      return;
    }

    final token = ++_token;
    playing = true;
    onPlayingChanged(true);
    try {
      await tts.stop();
      if (token != _token) return;
      await tts.setLanguage(locale);
      await tts.setSpeechRate(0.45);
      tts.setCompletionHandler(() {
        if (token != _token) return;
        playing = false;
        onPlayingChanged(false);
      });
      tts.setErrorHandler((_) {
        if (token != _token) return;
        playing = false;
        onPlayingChanged(false);
      });
      await tts.speak(text);
    } catch (_) {
      if (token != _token) return;
      playing = false;
      onPlayingChanged(false);
    }
  }

  Future<void> stop() async {
    _token++;
    playing = false;
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
