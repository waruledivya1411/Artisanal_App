import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/widgets/app_bottom_nav.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';

class LearnHomeScreen extends StatefulWidget {
  const LearnHomeScreen({super.key, required this.locale});

  final String locale;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color mint = Color(0xFFEAF1EE);
  static const Color online = Color(0xFF1E8A4C);

  static const String spoken = 'Hello, Divya Warule. Sualkuchi, Assam.';

  @override
  State<LearnHomeScreen> createState() => _LearnHomeScreenState();
}

class _Task {
  const _Task({
    required this.number,
    required this.title,
    required this.detail,
    this.active = false,
  });

  final String number;
  final String title;
  final String detail;
  final bool active;
}

class _LearnHomeScreenState extends State<LearnHomeScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  static const _tasks = <_Task>[
    _Task(
      number: '01',
      title: 'Photography',
      detail: 'Continue · Window light',
      active: true,
    ),
    _Task(
      number: '02',
      title: 'Set up your page',
      detail: 'On Instagram · 7 min',
    ),
    _Task(
      number: '03',
      title: 'Create a post',
      detail: 'Post and story · 6 min',
    ),
    _Task(number: '04', title: 'Posting plan', detail: 'What and when · 5 min'),
    _Task(
      number: '05',
      title: 'Read the numbers',
      detail: 'Views, likes, saves · 4 min',
    ),
  ];

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void _openPhotography() => _open(photographyTask(widget.locale));

  void _open(Widget screen) {
    _speech.stop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  VoidCallback? _openerFor(_Task task) {
    return switch (task.number) {
      '02' => () => _open(setUpPageTask(widget.locale)),
      '04' => () => _open(postingPlanTask(widget.locale)),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LearnHomeScreen.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _Header(
                      onSpeak: () => _speech.toggle(
                        locale: widget.locale,
                        text: LearnHomeScreen.spoken,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Hello, Divya Warule',
                      style: GoogleFonts.plusJakartaSans(
                        color: LearnHomeScreen.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _LocationCard(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '0 OF 5 TASKS DONE',
                          style: GoogleFonts.plusJakartaSans(
                            color: LearnHomeScreen.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '10%',
                          style: GoogleFonts.plusJakartaSans(
                            color: LearnHomeScreen.teal,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 0.1,
                        minHeight: 8,
                        backgroundColor: LearnHomeScreen.mint,
                        color: LearnHomeScreen.teal,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final task in _tasks) ...[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _openerFor(task),
                        child: _TaskCard(task: task),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              AppBottomNav(onLearnTap: _openPhotography),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSpeak});

  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _LogoMark(),
        const SizedBox(width: 8),
        Text(
          'Click & Social',
          style: GoogleFonts.plusJakartaSans(
            color: LearnHomeScreen.teal,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F6EE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: LearnHomeScreen.online,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'OFFLINE',
                style: GoogleFonts.plusJakartaSans(
                  color: LearnHomeScreen.online,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSpeak,
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Center(
                  child: Image(
                    image: AssetImage('assets/images/icons/speaker.png'),
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: LearnHomeScreen.teal,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: CustomPaint(size: const Size(16, 16), painter: _GemPainter()),
    );
  }
}

class _GemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF4EBDD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationCard extends StatelessWidget {
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LearnHomeScreen.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: LearnHomeScreen.teal,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sualkuchi, Assam',
                style: GoogleFonts.plusJakartaSans(
                  color: LearnHomeScreen.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Change',
              style: GoogleFonts.plusJakartaSans(
                color: LearnHomeScreen.teal,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final _Task task;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.active ? LearnHomeScreen.teal : const Color(0xFFE4EEEC),
          width: task.active ? 1.6 : 1,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: task.active
                    ? LearnHomeScreen.teal
                    : LearnHomeScreen.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.number,
                style: GoogleFonts.plusJakartaSans(
                  color: task.active ? Colors.white : LearnHomeScreen.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: LearnHomeScreen.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.detail,
                    style: GoogleFonts.plusJakartaSans(
                      color: task.active
                          ? LearnHomeScreen.teal
                          : LearnHomeScreen.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (task.active)
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: LearnHomeScreen.teal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AABA8),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
