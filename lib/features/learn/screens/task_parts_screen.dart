import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/widgets/app_bottom_nav.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_task_navigation.dart';
import 'package:artisnal_app/features/learn/widgets/lesson_step.dart';
import 'package:artisnal_app/features/me/screens/me_screen.dart';
import 'package:artisnal_app/features/shell/main_tab_screen.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

enum TaskPartState { done, current, pending }

class TaskPart {
  const TaskPart(
    this.number,
    this.title, {
    this.open,
    this.showOnList = true,
  });

  final String number;
  final String title;
  final WidgetBuilder? open;

  /// When false, the part still runs in order via Next, but has no row on the list.
  final bool showOnList;
}

class TaskPartsScreen extends StatefulWidget {
  const TaskPartsScreen({
    super.key,
    required this.locale,
    required this.taskId,
    required this.taskLabel,
    required this.title,
    required this.parts,
    this.showChevron = false,
  });

  final String locale;
  final String taskId;
  final String taskLabel;
  final String title;
  final List<TaskPart> parts;
  final bool showChevron;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color mint = Color(0xFFEDF4F0);
  static const Color track = Color(0xFFEDF2EF);
  static const Color done = Color(0xFF1E7B45);
  static const Color chevron = Color(0xFF4F5F5D);

  @override
  State<TaskPartsScreen> createState() => _TaskPartsScreenState();
}

class _TaskPartsScreenState extends State<TaskPartsScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  final _progress = LearnProgress.instance;

  @override
  void initState() {
    super.initState();
    _progress.addListener(_onProgress);
  }

  @override
  void dispose() {
    _progress.removeListener(_onProgress);
    _speech.stop();
    super.dispose();
  }

  void _onProgress() {
    if (mounted) setState(() {});
  }

  void _returnHome(AppNavTab tab) {
    final navigator = Navigator.of(context);
    if (MainTabScreen.selectTab == null) return;
    LearnTaskNavigation.popToLearnHome(navigator);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MainTabScreen.selectTab?.call(tab);
    });
  }

  void _openLearn() => _returnHome(AppNavTab.learn);

  void _openPhoto() {
    final navigator = Navigator.of(context);
    final locale = widget.locale;
    LearnTaskNavigation.popToLearnHome(navigator);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MainTabScreen.selectTab?.call(AppNavTab.learn);
      if (!navigator.mounted) return;
      LearnTaskNavigation.openShoot(navigator.context, locale);
    });
  }

  void _openMe() {
    if (MainTabScreen.selectTab != null) {
      _returnHome(AppNavTab.me);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MeScreen(locale: widget.locale)),
    );
  }

  TaskPartState _stateOf(int index) {
    final completed = _progress.completedParts(widget.taskId);
    if (index < completed) return TaskPartState.done;
    if (index == completed) return TaskPartState.current;
    return TaskPartState.pending;
  }

  bool _canOpen(int index) =>
      index < widget.parts.length && widget.parts[index].open != null;

  int? _lastOpenPartIndex() {
    for (var i = widget.parts.length - 1; i >= 0; i--) {
      if (_canOpen(i)) return i;
    }
    return null;
  }

  Route<void> _routeFor(int index) {
    final next = index + 1;
    final isLastPart = _lastOpenPartIndex() == index;
    final hasNext = _canOpen(next);
    final nextHidden = hasNext && !widget.parts[next].showOnList;
    return MaterialPageRoute<void>(
      builder: (_) => LessonStep(
        nextTitle: hasNext ? widget.parts[next].title : null,
        nextPartHidden: nextHidden,
        nextLearnTaskTitle: isLastPart
            ? LearnTaskChain.nextTaskTitle(widget.taskId)
            : null,
        learnTaskId: widget.taskId,
        locale: widget.locale,
        onFinished: () => _finish(index),
        child: Builder(builder: widget.parts[index].open!),
      ),
    );
  }

  void _finish(int index) {
    var done = _progress.completedParts(widget.taskId);
    while (done < index) {
      _progress.completePart(widget.taskId, done);
      done++;
    }
    _progress.completePart(widget.taskId, index);
    if (_lastOpenPartIndex() == index) {
      _progress.finishTask(widget.taskId, widget.parts.length);
    }
    final listRoute = ModalRoute.of(context);
    bool isList(Route<dynamic> route) => route == listRoute;
    final navigator = Navigator.of(context);
    if (_canOpen(index + 1)) {
      navigator.pushAndRemoveUntil(_routeFor(index + 1), isList);
    } else {
      navigator.popUntil(isList);
    }
  }

  bool _mayOpenPart(int index) {
    if (!_canOpen(index)) return false;
    if (widget.taskId == 'set_up_page') return true;
    return _stateOf(index) != TaskPartState.pending;
  }

  VoidCallback? _openerFor(int index) {
    if (!_mayOpenPart(index)) return null;
    return () {
      _speech.stop();
      Navigator.of(context).push(_routeFor(index));
    };
  }

  String get _spokenText {
    return '${tr(widget.title)}. ${widget.parts.where((p) => p.showOnList).map((p) => tr(p.title)).join('. ')}.';
  }

  void _onPartTap(int index) {
    final open = _openerFor(index);
    if (open != null) {
      open();
      return;
    }
    if (!_canOpen(index)) return;
    final completed = _progress.completedParts(widget.taskId);
    if (index > completed && completed < widget.parts.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Finish ${widget.parts[completed].title} first'),
            style: appType(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<int> get _listedPartIndices => [
        for (var i = 0; i < widget.parts.length; i++)
          if (widget.parts[i].showOnList) i,
      ];

  @override
  Widget build(BuildContext context) {
    final parts = widget.parts;
    final listed = _listedPartIndices;
    final completed = _progress.completedParts(widget.taskId);
    final doneCount =
        listed.where((i) => i < completed).length.clamp(0, listed.length);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: TaskPartsScreen.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                              color: TaskPartsScreen.ink,
                              iconSize: 24,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ),
                          Text(
                            tr(widget.taskLabel),
                            style: appType(
                              color: TaskPartsScreen.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _SpeakerCircle(
                              onTap: () => _speech.toggle(
                                locale: widget.locale,
                                text: _spokenText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tr(widget.title),
                      style: appType(
                        color: TaskPartsScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var li = 0; li < listed.length; li++) ...[
                          Expanded(
                            child: Container(
                              height: 7,
                              decoration: BoxDecoration(
                                color: li < doneCount
                                    ? TaskPartsScreen.teal
                                    : TaskPartsScreen.track,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          if (li != listed.length - 1) const SizedBox(width: 6),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (final i in listed) ...[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onPartTap(i),
                        child: _PartCard(
                          part: parts[i],
                          state: _stateOf(i),
                          showChevron:
                              widget.showChevron && _mayOpenPart(i),
                        ),
                      ),
                      const SizedBox(height: 13),
                    ],
                  ],
                ),
              ),
              AppBottomNav(
                locale: widget.locale,
                onLearnTap: _openLearn,
                onPhotoTap: _openPhoto,
                onMeTap: _openMe,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeakerCircle extends StatelessWidget {
  const _SpeakerCircle({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.part,
    required this.state,
    required this.showChevron,
  });

  final TaskPart part;
  final TaskPartState state;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final current = state == TaskPartState.current;
    final isDone = state == TaskPartState.done;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: current ? TaskPartsScreen.teal : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: current ? const Color(0x401B7574) : const Color(0x10000000),
            blurRadius: current ? 16 : 10,
            offset: Offset(0, current ? 6 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: current ? Colors.white : TaskPartsScreen.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      color: TaskPartsScreen.done,
                      size: 22,
                    )
                  : Text(
                      part.number,
                      style: appType(
                        color: TaskPartsScreen.teal,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                tr(part.title),
                style: appType(
                  color: current ? Colors.white : TaskPartsScreen.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isDone)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  tr('Done'),
                  style: appType(
                    color: TaskPartsScreen.done,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (current)
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_outlined,
                  color: TaskPartsScreen.teal,
                  size: 26,
                ),
              ),
            if (!isDone && !current && showChevron)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: TaskPartsScreen.chevron,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
