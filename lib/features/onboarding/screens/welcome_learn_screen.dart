import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/listen_playing_button.dart';
import 'package:artisnal_app/features/onboarding/screens/welcome_shoot_screen.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';

class WelcomeLearnScreen extends StatefulWidget {
  const WelcomeLearnScreen({super.key, required this.locale});

  final String locale;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color dot = Color(0xFFC1DAD9);

  static const String spoken =
      'Learn step by step. Short videos in your language show you how.';

  @override
  State<WelcomeLearnScreen> createState() => _WelcomeLearnScreenState();
}

class _WelcomeLearnScreenState extends State<WelcomeLearnScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: WelcomeLearnScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: WelcomeLearnScreen.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const reserved = 292.0;
                final imageMaxHeight = (constraints.maxHeight - reserved).clamp(
                  180.0,
                  420.0,
                );
                var imageWidth = constraints.maxWidth;
                var imageHeight = imageWidth * 400 / 328;
                if (imageHeight > imageMaxHeight) {
                  imageHeight = imageMaxHeight;
                  imageWidth = imageHeight * 328 / 400;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListenPlayingButton(
                      playing: _speech.playing,
                      onTap: () => _speech.toggle(
                        locale: widget.locale,
                        text: WelcomeLearnScreen.spoken,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.topCenter,
                      child: SharpImage(
                        'assets/images/onboarding/learn_art.png',
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        _PageDash(),
                        SizedBox(width: 8),
                        _PageDot(),
                        SizedBox(width: 8),
                        _PageDot(),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Learn step by step',
                      style: GoogleFonts.plusJakartaSans(
                        color: WelcomeLearnScreen.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Short videos in your language show you\nhow.',
                      style: GoogleFonts.plusJakartaSans(
                        color: WelcomeLearnScreen.muted,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: kPrimaryButtonShadow,
                      ),
                      child: Material(
                        color: WelcomeLearnScreen.teal,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () {
                            _speech.stop();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    WelcomeShootScreen(locale: widget.locale),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Next',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PageDash extends StatelessWidget {
  const _PageDash();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 6,
      decoration: BoxDecoration(
        color: WelcomeLearnScreen.teal,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: WelcomeLearnScreen.dot,
        shape: BoxShape.circle,
      ),
    );
  }
}
