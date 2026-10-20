import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:artisnal_app/core/widgets/celebration_confetti.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_task_navigation.dart';
import 'package:artisnal_app/features/learn/widgets/next_learn_task_button.dart';

class CreatePostBadgeScreen extends StatefulWidget {
  const CreatePostBadgeScreen({super.key, required this.locale});

  final String locale;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color gold = Color(0xFFC5922E);

  @override
  State<CreatePostBadgeScreen> createState() => _CreatePostBadgeScreenState();
}

class _CreatePostBadgeScreenState extends State<CreatePostBadgeScreen>
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

  void _done() {
    final navigator = Navigator.of(context);
    LearnTaskNavigation.finishLessonAndOpenNext(
      navigator: navigator,
      finishedTaskId: LearnTaskChain.createPostTaskId,
      locale: widget.locale,
      finishLesson: () => navigator.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: CreatePostBadgeScreen.background,
      ),
      child: Scaffold(
        backgroundColor: CreatePostBadgeScreen.background,
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
                                CreatePostBadgeScreen.gold,
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
                          'Badge earned',
                          style: GoogleFonts.plusJakartaSans(
                            color: CreatePostBadgeScreen.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create a post',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: CreatePostBadgeScreen.ink,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You practiced Post, Story, and Reel on Instagram.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: CreatePostBadgeScreen.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Builder(
                          builder: (context) {
                            final nextTask = LearnTaskChain.nextTaskTitle(
                              LearnTaskChain.createPostTaskId,
                            );
                            if (nextTask != null) {
                              return NextLearnTaskButton(
                                nextTaskTitle: nextTask,
                                onTap: _done,
                              );
                            }
                            return Material(
                              color: CreatePostBadgeScreen.teal,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: _done,
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 48,
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
                            );
                          },
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
