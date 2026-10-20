import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/widgets/ig_profile_preview.dart';
import 'package:artisnal_app/features/learn/widgets/lesson_step.dart';

class FindNumbersScreen extends StatefulWidget {
  const FindNumbersScreen({
    super.key,
    required this.locale,
    required this.taskId,
    required this.partCount,
  });

  final String locale;
  final String taskId;
  final int partCount;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color gold = Color(0xFFC5922E);

  static const String spoken =
      'Find your numbers. Open your page. '
      'Tap Professional dashboard. Tap a post, then View insights.';

  static final Uri instagram = Uri.parse('https://www.instagram.com/');

  @override
  State<FindNumbersScreen> createState() => _FindNumbersScreenState();
}

class _FindNumbersScreenState extends State<FindNumbersScreen>
    with SingleTickerProviderStateMixin {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  bool _earned = false;

  @override
  void dispose() {
    _confetti.dispose();
    _speech.stop();
    super.dispose();
  }

  void _complete() {
    if (_earned) return;
    _speech.stop();
    LearnProgress.instance.finishTask(widget.taskId, widget.partCount);
    setState(() => _earned = true);
    _confetti.repeat();
  }

  void _leave() {
    _speech.stop();
    final step = LessonStep.maybeOf(context);
    step == null ? Navigator.of(context).maybePop() : step.onFinished();
  }

  Future<void> _openInstagram() async {
    _speech.stop();
    await launchUrl(
      FindNumbersScreen.instagram,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: FindNumbersScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: FindNumbersScreen.background,
        body: Stack(
          children: [
            SafeArea(
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
                              color: FindNumbersScreen.ink,
                              iconSize: 24,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ),
                          Text(
                            'TASK 5 · 2 OF 2',
                            style: GoogleFonts.plusJakartaSans(
                              color: FindNumbersScreen.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SpeakCircleButton(
                              playing: _speech.playing,
                              onTap: () => _speech.toggle(
                                locale: widget.locale,
                                text: FindNumbersScreen.spoken,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Read the numbers',
                      style: GoogleFonts.plusJakartaSans(
                        color: FindNumbersScreen.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _StepBar(filled: 2),
                    const SizedBox(height: 14),
                    Text(
                      'Find your numbers',
                      style: GoogleFonts.plusJakartaSans(
                        color: FindNumbersScreen.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const IgProfilePreview(
                              variant: IgProfileVariant.business,
                            ),
                            SizedBox(height: 12),
                            _Steps(),
                          ],
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
                        color: FindNumbersScreen.teal,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: _openInstagram,
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.open_in_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Open Instagram',
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
                    const SizedBox(height: 10),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: _complete,
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 56,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: FindNumbersScreen.teal,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Complete',
                                style: GoogleFonts.plusJakartaSans(
                                  color: FindNumbersScreen.teal,
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
            if (_earned) ...[
              const ColoredBox(
                color: Color(0x66152322),
                child: SizedBox.expand(),
              ),
              Center(child: _BadgeCard(onContinue: _leave)),
              Positioned.fill(
                child: IgnorePointer(child: _Confetti(animation: _confetti)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    colors: [Color(0xFFF6E7C8), Color(0xFFC5922E)],
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
                  color: FindNumbersScreen.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Read the numbers',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: FindNumbersScreen.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can read views, likes, saves and messages.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: FindNumbersScreen.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Material(
                color: FindNumbersScreen.teal,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onContinue,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Confetti extends StatelessWidget {
  const _Confetti({required this.animation});

  final Animation<double> animation;

  static final List<_Piece> _pieces = List.generate(46, (i) {
    final random = math.Random(i + 3);
    const colors = [
      Color(0xFF1B7574),
      Color(0xFFC5922E),
      Color(0xFF7A1F2B),
      Color(0xFFF4EBDD),
      Color(0xFF1E7B45),
      Colors.white,
    ];
    return _Piece(
      x: random.nextDouble(),
      delay: random.nextDouble() * 0.22,
      drift: (random.nextDouble() - 0.5) * 0.16,
      spin: random.nextDouble() * 6,
      color: colors[i % colors.length],
      width: 6 + random.nextDouble() * 7,
      height: 8 + random.nextDouble() * 8,
      round: i.isEven,
    );
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(t: animation.value, pieces: _pieces),
        );
      },
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.drift,
    required this.spin,
    required this.color,
    required this.width,
    required this.height,
    required this.round,
  });

  final double x;
  final double delay;
  final double drift;
  final double spin;
  final Color color;
  final double width;
  final double height;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.t, required this.pieces});

  final double t;
  final List<_Piece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final local = (t + piece.delay) % 1.0;
      final fadeOut = local > 0.9 ? (1.0 - local) / 0.1 : 1.0;
      final fadeIn = local < 0.06 ? local / 0.06 : 1.0;
      final fade = (fadeOut * fadeIn).clamp(0.0, 1.0);
      final paint = Paint()..color = piece.color.withValues(alpha: fade);
      final dx =
          (piece.x + math.sin(local * math.pi * 3) * piece.drift) * size.width;
      final dy = (-0.12 + local * 1.3) * size.height;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(local * piece.spin);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: piece.width,
        height: piece.height,
      );
      if (piece.round) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          paint,
        );
      } else {
        canvas.drawOval(rect, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            _Step(number: '1', text: 'Open your page'),
            _Step(
              number: '2',
              text: 'Tap Professional dashboard',
              current: true,
            ),
            _Step(number: '3', text: 'Tap a post · View insights'),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text, this.current = false});

  final String number;
  final String text;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final color = current ? FindNumbersScreen.gold : const Color(0xFFD5DEDB);
    final ink = current ? FindNumbersScreen.ink : FindNumbersScreen.muted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                color: current ? Colors.white : FindNumbersScreen.muted,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                color: ink,
                fontSize: 15,
                fontWeight: current ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 2; i++) ...[
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: i < filled
                    ? FindNumbersScreen.teal
                    : const Color(0xFFEDF2EF),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (i != 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
