import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeSpeech {
  WelcomeSpeech(this.onPlayingChanged);

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

class ListenPlayingButton extends StatelessWidget {
  const ListenPlayingButton({
    super.key,
    required this.playing,
    required this.onTap,
  });

  final bool playing;
  final VoidCallback onTap;

  static const Color teal = Color(0xFF1B7574);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: playing ? const Color(0x591B7574) : const Color(0x33000000),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: playing ? teal : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              height: 46,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (playing) ...[
                    const _WaveBars(),
                    const SizedBox(width: 8),
                    Text(
                      'Playing',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else ...[
                    const Image(
                      image: AssetImage('assets/images/speaker.png'),
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Listen',
                      style: GoogleFonts.plusJakartaSans(
                        color: teal,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveBars extends StatelessWidget {
  const _WaveBars();

  @override
  Widget build(BuildContext context) {
    const heights = <double>[8, 14, 10, 16];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < heights.length; i++) ...[
          Container(
            width: 2.5,
            height: heights[i],
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (i != heights.length - 1) const SizedBox(width: 2),
        ],
      ],
    );
  }
}
