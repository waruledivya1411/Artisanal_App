import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/widgets/lesson_step.dart';

class NumbersMeanScreen extends StatefulWidget {
  const NumbersMeanScreen({super.key, required this.locale, this.nextBuilder});

  final String locale;
  final WidgetBuilder? nextBuilder;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color gold = Color(0xFFC5922E);
  static const Color goldBorder = Color(0xFFD7B56A);

  static const String spoken =
      'What they mean. Four numbers to watch. '
      'Views are people who saw it. Likes are people who liked it. '
      'Saves mean they want to buy later. Messages are buyers asking.';

  @override
  State<NumbersMeanScreen> createState() => _NumbersMeanScreenState();
}

class _NumbersMeanScreenState extends State<NumbersMeanScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void _next() {
    _speech.stop();
    final step = LessonStep.maybeOf(context);
    final builder = widget.nextBuilder;
    if (builder == null) {
      step == null ? Navigator.of(context).maybePop() : step.onFinished();
      return;
    }
    Navigator.of(context).push(
      step?.routeFor(builder) ?? MaterialPageRoute<void>(builder: builder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: NumbersMeanScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: NumbersMeanScreen.background,
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
                          color: NumbersMeanScreen.ink,
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
                            'TASK 5 · 1 OF 2',
                            style: GoogleFonts.plusJakartaSans(
                              color: NumbersMeanScreen.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
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
                            text: NumbersMeanScreen.spoken,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Read the numbers',
                  style: GoogleFonts.plusJakartaSans(
                    color: NumbersMeanScreen.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const _StepBar(filled: 1),
                const SizedBox(height: 16),
                Text(
                  'What they mean',
                  style: GoogleFonts.plusJakartaSans(
                    color: NumbersMeanScreen.ink,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '4 numbers to watch',
                  style: GoogleFonts.plusJakartaSans(
                    color: NumbersMeanScreen.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio:
                            (constraints.maxWidth / 2 - 6) /
                            (constraints.maxHeight / 2 - 6),
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          _NumberTile(
                            icon: Icons.search_rounded,
                            value: '120',
                            name: 'Views',
                            detail: 'People who saw it',
                          ),
                          _NumberTile(
                            icon: Icons.favorite_border_rounded,
                            value: '24',
                            name: 'Likes',
                            detail: 'People who liked it',
                          ),
                          _NumberTile(
                            icon: Icons.bookmark_border_rounded,
                            value: '18',
                            name: 'Saves',
                            detail: 'Want to buy later',
                            best: true,
                          ),
                          _NumberTile(
                            icon: Icons.chat_bubble_outline_rounded,
                            value: '5',
                            name: 'Messages',
                            detail: 'Buyers asking',
                            best: true,
                          ),
                        ],
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
                    color: NumbersMeanScreen.teal,
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

class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.icon,
    required this.value,
    required this.name,
    required this.detail,
    this.best = false,
  });

  final IconData icon;
  final String value;
  final String name;
  final String detail;
  final bool best;

  @override
  Widget build(BuildContext context) {
    final tint = best ? const Color(0xFFF8F1E4) : const Color(0xFFE7F3F1);
    final iconColor = best ? NumbersMeanScreen.gold : NumbersMeanScreen.teal;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: best ? NumbersMeanScreen.goldBorder : Colors.transparent,
          width: 1.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const Spacer(),
                if (best)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6E7C8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'BEST',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF8A5A12),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: NumbersMeanScreen.ink,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                color: NumbersMeanScreen.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: NumbersMeanScreen.muted,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
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
                    ? NumbersMeanScreen.teal
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
