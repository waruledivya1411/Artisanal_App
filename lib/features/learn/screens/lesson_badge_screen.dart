import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/core/widgets/celebration_confetti.dart';
import 'package:artisnal_app/features/learn/widgets/next_learn_task_button.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class LessonBadgeScreen extends StatefulWidget {
  const LessonBadgeScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onContinue,
    this.nextLearnTaskTitle,
  });

  final String title;
  final String subtitle;
  final VoidCallback onContinue;
  final String? nextLearnTaskTitle;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color gold = Color(0xFFC5922E);

  @override
  State<LessonBadgeScreen> createState() => _LessonBadgeScreenState();
}

class _LessonBadgeScreenState extends State<LessonBadgeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    _confetti.repeat();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: LessonBadgeScreen.background,
      ),
      child: Scaffold(
        backgroundColor: LessonBadgeScreen.background,
        body: Stack(
          children: [
            const ColoredBox(
              color: Color(0x66152322),
              child: SizedBox.expand(),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFF6E7C8),
                                LessonBadgeScreen.gold,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.military_tech_rounded,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr('Badge earned'),
                          style: appType(
                            color: LessonBadgeScreen.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tr(widget.title),
                          textAlign: TextAlign.center,
                          style: appType(
                            color: LessonBadgeScreen.ink,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr(widget.subtitle),
                          textAlign: TextAlign.center,
                          style: appType(
                            color: LessonBadgeScreen.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (widget.nextLearnTaskTitle != null)
                          NextLearnTaskButton(
                            nextTaskTitle: widget.nextLearnTaskTitle!,
                            onTap: widget.onContinue,
                          )
                        else
                          Material(
                            color: LessonBadgeScreen.teal,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: widget.onContinue,
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 48,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CelebrationConfetti(animation: _confetti),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
