import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';

class LearnPartScreen extends StatefulWidget {
  const LearnPartScreen({
    super.key,
    required this.locale,
    required this.partLabel,
    required this.title,
    required this.image,
    this.nextBuilder,
  });

  final String locale;
  final String partLabel;
  final String title;
  final String image;
  final WidgetBuilder? nextBuilder;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color track = Color(0xFFEDF2EF);

  @override
  State<LearnPartScreen> createState() => _LearnPartScreenState();
}

class _LearnPartScreenState extends State<LearnPartScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void _next() {
    final builder = widget.nextBuilder;
    if (builder == null) return;
    _speech.stop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: LearnPartScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LearnPartScreen.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close_rounded),
                          color: LearnPartScreen.ink,
                          iconSize: 26,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 54),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.partLabel,
                            style: GoogleFonts.plusJakartaSans(
                              color: LearnPartScreen.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SpeakCircleButton(
                          playing: _speech.playing,
                          onTap: () => _speech.toggle(
                            locale: widget.locale,
                            text: '${widget.title}.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: LearnPartScreen.teal,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: LearnPartScreen.track,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Column(
                    children: [
                      Flexible(
                        child: AspectRatio(
                          aspectRatio: 320 / 266,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image(
                                  image: AssetImage(widget.image),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: LearnPartScreen.ink,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kPrimaryButtonShadow,
                  ),
                  child: Material(
                    color: LearnPartScreen.teal,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: _next,
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
            ),
          ),
        ),
      ),
    );
  }
}
