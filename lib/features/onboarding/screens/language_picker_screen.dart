import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/onboarding/screens/welcome_shoot_screen.dart';

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
        return appType(
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

  @override
  void initState() {
    super.initState();
    AppLang.current = 'as-IN';
  }

  void _choose(_LanguageOption language) {
    setState(() => _selectedId = language.id);
    AppLang.current = language.locale;
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: LanguagePickerScreen.ink,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      tooltip: tr('Back'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  tr('Choose your language'),
                  style: appType(
                    color: LanguagePickerScreen.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  tr('Tap your language.'),
                  style: appType(
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
                        onSelect: () => _choose(language),
                        onSpeak: () => _choose(language),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
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
                        AppLang.current = language.locale;
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                WelcomeShootScreen(locale: language.locale),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            tr('Continue'),
                            style: appType(
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
                        tr(language.english),
                        style: appType(
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
  Widget build(BuildContext context) => const SizedBox.shrink();
}

