import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:artisnal_app/core/speech/speech_player.dart';
import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
class TryItDidItWorkScreen extends StatefulWidget {
  const TryItDidItWorkScreen({
    super.key,
    required this.locale,
    required this.photoBytes,
    required this.onYesItWorked,
  });

  final String locale;
  final Uint8List photoBytes;
  final VoidCallback onYesItWorked;

  static const Color sheetGrey = Color(0xFF8E9895);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);

  static const String spoken = 'Did it work? Is it bright and straight?';

  @override
  State<TryItDidItWorkScreen> createState() => _TryItDidItWorkScreenState();
}

class _TryItDidItWorkScreenState extends State<TryItDidItWorkScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void _showAgain() => Navigator.of(context).pop();

  void _yesItWorked() {
    _speech.stop();
    widget.onYesItWorked();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: TryItDidItWorkScreen.sheetGrey,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: TryItDidItWorkScreen.sheetGrey,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                child: SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _showAgain,
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Colors.white,
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Try it',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      SpeakCircleButton(
                        playing: _speech.playing,
                        onTap: () => _speech.toggle(
                          locale: widget.locale,
                          text: TryItDidItWorkScreen.spoken,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 11,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              width: 168,
                              height: 200,
                              child: Image.memory(
                                widget.photoBytes,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Did it work?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: TryItDidItWorkScreen.ink,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bright and straight?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: TryItDidItWorkScreen.muted,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: kPrimaryButtonShadow,
                          ),
                          child: Material(
                            color: TryItDidItWorkScreen.teal,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: _yesItWorked,
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Yes, it worked',
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
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFD5DEDB)),
                          ),
                          child: InkWell(
                            onTap: _showAgain,
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.replay_rounded,
                                    color: TryItDidItWorkScreen.teal,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Show me again',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: TryItDidItWorkScreen.teal,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
