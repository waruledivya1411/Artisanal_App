/// Read-aloud has been removed from the app. This keeps the interface the
/// screens call so they need no changes, but it never makes a sound.
class SpeechPlayer {
  SpeechPlayer(this.onPlayingChanged);

  final void Function(bool playing) onPlayingChanged;

  bool get playing => false;

  Future<void> toggle({required String locale, required String text}) async {}

  Future<void> stop() async {}
}
