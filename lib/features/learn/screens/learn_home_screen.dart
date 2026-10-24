import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/widgets/app_bottom_nav.dart';
import 'package:artisnal_app/features/learn/data/displays.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/data/materials.dart';
import 'package:artisnal_app/features/learn/data/products.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/me/screens/me_screen.dart';
import 'package:artisnal_app/features/learn/screens/photo_access_screen.dart';
import 'package:artisnal_app/features/learn/screens/choose_content_type_screen.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class LearnHomeScreen extends StatefulWidget {
  const LearnHomeScreen({
    super.key,
    required this.locale,
    this.showBottomNav = true,
  });

  final String locale;
  final bool showBottomNav;

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
    required this.image,
    this.active = false,
  });

  final String number;
  final String title;
  final String detail;
  final String image;
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
      detail: 'Continue · Hold steady',
      image: 'assets/images/lessons/photography/try_it_art.jpg',
      active: true,
    ),
    _Task(
      number: '02',
      title: 'Set up your page',
      detail: 'On Instagram',
      image: 'assets/images/lessons/set_up_page/good_name_art.jpg',
    ),
    _Task(
      number: '03',
      title: 'Create a post',
      detail: 'Post and story',
      image: 'assets/images/lessons/create_post/create_post_art.jpg',
    ),
    _Task(
      number: '04',
      title: 'Posting plan',
      detail: 'What and when',
      image: 'assets/images/lessons/posting_plan/post_often_art.jpg',
    ),
    _Task(
      number: '05',
      title: 'Read the numbers',
      detail: 'Views, likes, saves',
      image: 'assets/images/lessons/read_numbers/read_numbers_art.jpg',
    ),
  ];

  final _progress = LearnProgress.instance;

  /// The setup pickers replace one another, so the push future completes
  /// early; listen to the choices themselves to keep the card current.
  late final List<Listenable> _sources = [
    _progress,
    SelectedProduct.instance,
    SelectedMaterial.instance,
    SelectedDisplay.instance,
  ];

  @override
  void initState() {
    super.initState();
    for (final source in _sources) {
      source.addListener(_onProgress);
    }
  }

  @override
  void dispose() {
    for (final source in _sources) {
      source.removeListener(_onProgress);
    }
    _speech.stop();
    super.dispose();
  }

  void _onProgress() {
    if (mounted) setState(() {});
  }

  String _photographyDetail() {
    final picked = [
      SelectedProduct.instance.name,
      SelectedMaterial.instance.name,
      SelectedDisplay.instance.name,
    ].whereType<String>().map(tr).toList();
    if (picked.isEmpty) return tr('Choose what to shoot');
    return picked.join(' · ');
  }

  _Task _withProgress(_Task task) {
    if (task.number != '01') return task;
    return _Task(
      number: task.number,
      title: task.title,
      detail: _photographyDetail(),
      image: task.image,
      active: task.active,
    );
  }

  void _open(Widget screen) {
    _speech.stop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openPhotographySetup() {
    _speech.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: photographySetupRoute),
        builder: (_) => photographyEntry(widget.locale),
      ),
    );
  }

  VoidCallback? _openerFor(_Task task) {
    return switch (task.number) {
      '01' => _openPhotographySetup,
      '02' => () => _open(setUpPageTask(widget.locale)),
      '03' => () => _open(
        PhotoAccessScreen(
          locale: widget.locale,
          nextBuilder: (_) => ChooseContentTypeScreen(locale: widget.locale),
        ),
      ),
      '04' => () => _open(postingPlanTask(widget.locale)),
      '05' => () => _open(readNumbersTask(widget.locale)),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tasksDone = _progress.completedLearnTasks;
    final tasksTotal = LearnTaskChain.totalTasks;
    final progressValue = _progress.learnTasksProgress;

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
                        text: tr(LearnHomeScreen.spoken),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tr('Hello, Divya Warule'),
                      style: appType(
                        color: LearnHomeScreen.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          tr('$tasksDone OF $tasksTotal TASKS DONE'),
                          style: appType(
                            color: LearnHomeScreen.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          tr('${(progressValue * 100).round()}%'),
                          style: appType(
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
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 8,
                        backgroundColor: LearnHomeScreen.mint,
                        color: LearnHomeScreen.teal,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _tasks.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.76,
                          ),
                      itemBuilder: (context, index) {
                        final task = _withProgress(_tasks[index]);
                        return _TaskCard(task: task, onTap: _openerFor(task));
                      },
                    ),
                  ],
                ),
              ),
              if (widget.showBottomNav)
                AppBottomNav(
                  locale: widget.locale,
                  selectedTab: AppNavTab.learn,
                  onMeTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MeScreen(locale: widget.locale),
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
          tr('Click & Social'),
          style: appType(
            color: LearnHomeScreen.teal,
            fontSize: 15,
            fontWeight: FontWeight.w700,
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

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, this.onTap});

  final _Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = task.active;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: active ? LearnHomeScreen.teal : const Color(0xFFE4EEEC),
            width: active ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SharpImage(task.image, fit: BoxFit.contain),
                      if (active)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: LearnHomeScreen.teal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active
                            ? LearnHomeScreen.teal
                            : LearnHomeScreen.mint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.number,
                        style: appType(
                          color: active ? Colors.white : LearnHomeScreen.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(task.title),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: appType(
                          color: LearnHomeScreen.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tr(task.detail),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appType(
                    color: active
                        ? LearnHomeScreen.teal
                        : LearnHomeScreen.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
