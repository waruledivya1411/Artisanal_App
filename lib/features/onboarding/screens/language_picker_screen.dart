import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/features/onboarding/screens/welcome_learn_screen.dart';

class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color hint = Color(0xFF647270);
  static const Color selectedFill = Color(0xFFEAF1EE);
  static const Color cardBorder = Color(0xFFC1DAD9);

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

enum _Script { bengali, latin, oriya, telugu }

class _LanguageOption {
  const _LanguageOption({
    required this.id,
    required this.native,
    required this.english,
    required this.locale,
    required this.singleLine,
    required this.script,
  });

  final String id;
  final String native;
  final String english;
  final String locale;
  final bool singleLine;
  final _Script script;

  TextStyle nativeTextStyle() {
    const color = LanguagePickerScreen.ink;
    switch (script) {
      case _Script.bengali:
        return GoogleFonts.notoSansBengali(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.15,
        );
      case _Script.oriya:
        return GoogleFonts.notoSansOriya(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.15,
        );
      case _Script.telugu:
        return GoogleFonts.notoSansTelugu(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.15,
        );
      case _Script.latin:
        return GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.15,
        );
    }
  }
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen> {
  static const _languages = <_LanguageOption>[
    _LanguageOption(
      id: 'as',
      native: 'অসমীয়া',
      english: 'Assamese',
      locale: 'as-IN',
      singleLine: false,
      script: _Script.bengali,
    ),
    _LanguageOption(
      id: 'en',
      native: 'English',
      english: 'English',
      locale: 'en-US',
      singleLine: true,
      script: _Script.latin,
    ),
    _LanguageOption(
      id: 'or',
      native: 'ଓଡ଼ିଆ',
      english: 'Odia',
      locale: 'or-IN',
      singleLine: false,
      script: _Script.oriya,
    ),
    _LanguageOption(
      id: 'te',
      native: 'తెలుగు',
      english: 'Telugu',
      locale: 'te-IN',
      singleLine: false,
      script: _Script.telugu,
    ),
  ];

  String _selectedId = 'as';
  FlutterTts? _tts;

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }

  Future<void> _speak(_LanguageOption language) async {
    setState(() => _selectedId = language.id);
    try {
      final tts = _tts ??= FlutterTts();
      await tts.stop();
      await tts.setLanguage(language.locale);
      await tts.setSpeechRate(0.45);
      await tts.speak(language.native);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: LanguagePickerScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LanguagePickerScreen.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TranslateBadge(),
                const SizedBox(height: 20),
                Text(
                  'Choose your language',
                  style: GoogleFonts.plusJakartaSans(
                    color: LanguagePickerScreen.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Tap your language. Tap the speaker to hear\nit.',
                  style: GoogleFonts.plusJakartaSans(
                    color: LanguagePickerScreen.muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _languages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      final selected = language.id == _selectedId;
                      return _LanguageCard(
                        language: language,
                        selected: selected,
                        onSelect: () =>
                            setState(() => _selectedId = language.id),
                        onSpeak: () => _speak(language),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'You can change this later in Settings',
                    style: GoogleFonts.plusJakartaSans(
                      color: LanguagePickerScreen.hint,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kPrimaryButtonShadow,
                  ),
                  child: Material(
                    color: LanguagePickerScreen.teal,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: () {
                        final language = _languages.firstWhere(
                          (item) => item.id == _selectedId,
                        );
                        _tts?.stop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                WelcomeLearnScreen(locale: language.locale),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Continue',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

class _TranslateBadge extends StatelessWidget {
  const _TranslateBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: LanguagePickerScreen.selectedFill,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.translate,
        color: LanguagePickerScreen.teal,
        size: 24,
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.selected,
    required this.onSelect,
    required this.onSpeak,
  });

  final _LanguageOption language;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? LanguagePickerScreen.selectedFill : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        hoverColor: Colors.transparent,
        highlightColor: const Color(0x141B7574),
        splashColor: const Color(0x221B7574),
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? LanguagePickerScreen.teal
                  : LanguagePickerScreen.cardBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.native, style: language.nativeTextStyle()),
                    if (!language.singleLine) ...[
                      const SizedBox(height: 2),
                      Text(
                        language.english,
                        style: GoogleFonts.plusJakartaSans(
                          color: LanguagePickerScreen.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected) ...[const _CheckBadge(), const SizedBox(width: 12)],
              _SpeakButton(selected: selected, onTap: onSpeak),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: LanguagePickerScreen.teal,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
    );
  }
}

class _SpeakButton extends StatelessWidget {
  const _SpeakButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x2E1B7574),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: selected ? LanguagePickerScreen.teal : Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: selected
                  ? const _WaveBars(color: Colors.white)
                  : const Image(
                      image: AssetImage('assets/images/icons/speaker.png'),
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveBars extends StatelessWidget {
  const _WaveBars({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const heights = <double>[12, 20, 15, 22];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < heights.length; i++) ...[
          Container(
            width: 3,
            height: heights[i],
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (i != heights.length - 1) const SizedBox(width: 2.5),
        ],
      ],
    );
  }
}
