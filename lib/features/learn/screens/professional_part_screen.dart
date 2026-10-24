import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/screens/check_part_screen.dart';
import 'package:artisnal_app/features/learn/widgets/ig_profile_preview.dart';
import 'package:artisnal_app/features/learn/widgets/lesson_step.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class ProfessionalPartScreen extends StatefulWidget {
  const ProfessionalPartScreen({super.key, required this.locale});

  final String locale;

  static const String partLabel = 'TASK 2 · PART 3 · PROFESSIONAL';
  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);

  static const String spoken =
      'A professional page shows Professional dashboard. Tap it to learn more.';

  @override
  State<ProfessionalPartScreen> createState() => _ProfessionalPartScreenState();
}

class _ProfessionalPartScreenState extends State<ProfessionalPartScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  CheckPartScreen _professionalCheck() {
    return CheckPartScreen(
      locale: widget.locale,
      partLabel: ProfessionalPartScreen.partLabel,
      wrong: const CheckOption(
        profileVariant: IgProfileVariant.personalActionsOnly,
        label: 'Personal',
      ),
      right: const CheckOption(
        profileVariant: IgProfileVariant.business,
        label: 'Professional',
      ),
      rightReason: 'Buyers can message you',
      wrongReason: 'Personal pages miss business tools',
    );
  }

  void _openCheck() {
    _speech.stop();
    final step = LessonStep.maybeOf(context);
    final route = step?.routeFor((_) => _professionalCheck()) ??
        MaterialPageRoute<void>(builder: (_) => _professionalCheck());
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ProfessionalPartScreen.background,
      ),
      child: Scaffold(
        backgroundColor: ProfessionalPartScreen.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: ProfessionalPartScreen.ink,
                          iconSize: 24,
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
                            ProfessionalPartScreen.partLabel,
                            style: appType(
                              color: ProfessionalPartScreen.teal,
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
                            text: ProfessionalPartScreen.spoken,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('Use a professional page'),
                  style: appType(
                    color: ProfessionalPartScreen.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('Tap Professional dashboard on your page.'),
                  style: appType(
                    color: ProfessionalPartScreen.muted,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: IgProfilePreview(
                        variant: IgProfileVariant.business,
                        highlightDashboard: true,
                        onDashboardTap: _openCheck,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kPrimaryButtonShadow,
                  ),
                  child: Material(
                    color: ProfessionalPartScreen.teal,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: _openCheck,
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
                              tr('Next'),
                              style: appType(
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
