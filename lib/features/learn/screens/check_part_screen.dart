import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/features/learn/widgets/ig_profile_preview.dart';
import 'package:artisnal_app/features/learn/data/learn_task_navigation.dart';
import 'package:artisnal_app/features/learn/widgets/lesson_step.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class CheckOption {
  const CheckOption({
    this.image,
    this.text,
    this.caption,
    this.roundImage = true,
    this.contain = false,
    this.tile,
    this.stats = const [],
    this.chat,
    this.profileVariant,
    required this.label,
  }) : assert(
         image != null ||
             text != null ||
             tile != null ||
             chat != null ||
             profileVariant != null,
       );

  final String? image;
  final String? text;
  final String? caption;
  final bool roundImage;
  final bool contain;
  final CheckTile? tile;
  final List<CheckStat> stats;
  final CheckChat? chat;
  final IgProfileVariant? profileVariant;
  final String label;
}

class CheckStat {
  const CheckStat(this.icon, this.text);

  final IconData icon;
  final String text;
}

class CheckChat {
  const CheckChat({
    required this.question,
    required this.time,
    required this.reply,
    this.image,
  });

  final String question;
  final String time;
  final String reply;
  final String? image;
}

class CheckTile {
  const CheckTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
}

class CheckPartScreen extends StatefulWidget {
  const CheckPartScreen({
    super.key,
    required this.locale,
    required this.partLabel,
    required this.wrong,
    required this.right,
    required this.rightReason,
    required this.wrongReason,
  });

  final String locale;
  final String partLabel;
  final CheckOption wrong;
  final CheckOption right;
  final String rightReason;
  final String wrongReason;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color green = Color(0xFF1E7B45);
  static const Color greenFill = Color(0xFFEDF4F0);
  static const Color red = Color(0xFFC0392B);
  static const Color redFill = Color(0xFFFBEDEB);

  @override
  State<CheckPartScreen> createState() => _CheckPartScreenState();
}

enum _Choice { a, b }

class _CheckPartScreenState extends State<CheckPartScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  _Choice? _choice;

  bool get _correct => _choice == _Choice.b;

  bool get _profileQuiz =>
      widget.wrong.profileVariant != null &&
      widget.right.profileVariant != null;

  String get _spokenText {
    if (_choice == null) return tr('Which is better? Tap one.');
    return _correct
        ? '${tr('Yes! B is better')}. ${tr(widget.rightReason)}.'
        : '${tr('Not quite. B is better')}. ${tr(widget.wrongReason)}.';
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void _select(_Choice choice) {
    HapticFeedback.selectionClick();
    setState(() => _choice = choice);
  }

  void _next() {
    _speech.stop();
    if (_choice == null) return;
    final step = LessonStep.maybeOf(context);
    if (step != null) {
      final goToNextTask = step.nextTitle == null &&
          step.nextLearnTaskTitle != null &&
          step.learnTaskId != null &&
          step.locale != null;
      if (goToNextTask) {
        final navigator = Navigator.of(context);
        LearnTaskNavigation.finishLessonAndOpenNext(
          navigator: navigator,
          finishedTaskId: step.learnTaskId!,
          locale: step.locale!,
          finishLesson: step.onFinished,
        );
        return;
      }
      step.onFinished();
      return;
    }
    Navigator.of(context).maybePop();
  }

  String _nextLabel() {
    final step = LessonStep.maybeOf(context);
    if (step == null) return 'Next';
    final nextTitle = step.nextTitle;
    final nextTask = step.nextLearnTaskTitle;
    if (nextTitle == null && nextTask != null) {
      return 'Next task: $nextTask';
    }
    if (nextTitle == null) return 'Finish';
    if (step.nextPartHidden) return 'Next';
    return 'Next part · $nextTitle';
  }

  @override
  Widget build(BuildContext context) {
    final revealed = _choice != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: CheckPartScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: CheckPartScreen.background,
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
                          color: CheckPartScreen.ink,
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
                            tr(widget.partLabel),
                            style: appType(
                              color: CheckPartScreen.teal,
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
                            text: _spokenText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (var i = 0; i < 2; i++) ...[
                      Expanded(
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: CheckPartScreen.teal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      if (i == 0) const SizedBox(width: 6),
                    ],
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  tr('Which is better?'),
                  style: appType(
                    color: CheckPartScreen.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr('Tap one'),
                  style: appType(
                    color: CheckPartScreen.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: _profileQuiz ? 5 : 3,
                        child: _profileQuiz
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _ChoiceCard(
                                      option: widget.wrong,
                                      letter: 'A',
                                      isRight: false,
                                      revealed: revealed,
                                      selected: _choice == _Choice.a,
                                      onTap: () => _select(_Choice.a),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ChoiceCard(
                                      option: widget.right,
                                      letter: 'B',
                                      isRight: true,
                                      revealed: revealed,
                                      selected: _choice == _Choice.b,
                                      onTap: () => _select(_Choice.b),
                                    ),
                                  ),
                                ],
                              )
                            : AspectRatio(
                                aspectRatio: 320 / 253,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _ChoiceCard(
                                        option: widget.wrong,
                                        letter: 'A',
                                        isRight: false,
                                        revealed: revealed,
                                        selected: _choice == _Choice.a,
                                        onTap: () => _select(_Choice.a),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ChoiceCard(
                                        option: widget.right,
                                        letter: 'B',
                                        isRight: true,
                                        revealed: revealed,
                                        selected: _choice == _Choice.b,
                                        onTap: () => _select(_Choice.b),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: revealed
                            ? _Feedback(
                                key: ValueKey(_choice),
                                correct: _correct,
                                reason: _correct
                                    ? widget.rightReason
                                    : widget.wrongReason,
                              )
                            : SizedBox(height: _profileQuiz ? 56 : 72),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kPrimaryButtonShadow,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: revealed
                          ? CheckPartScreen.teal
                          : const Color(0xFF8DBAB9),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: revealed ? _next : null,
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
                              Flexible(
                                child: Text(
                                  tr(_nextLabel()),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: appType(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
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

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.option,
    required this.letter,
    required this.isRight,
    required this.revealed,
    required this.selected,
    required this.onTap,
  });

  final CheckOption option;
  final String letter;
  final bool isRight;
  final bool revealed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showRight = revealed && isRight;
    final showWrong = selected && !isRight;
    final borderColor = showRight
        ? CheckPartScreen.green
        : showWrong
        ? CheckPartScreen.red
        : Colors.transparent;
    final labelColor = isRight ? CheckPartScreen.green : CheckPartScreen.muted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: option.profileVariant != null
                        ? ColoredBox(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    physics: const ClampingScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                      ),
                                      child: IgProfilePreview(
                                        variant: option.profileVariant!,
                                        quizCard: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : option.chat != null
                        ? _ChatPreview(
                            chat: option.chat!,
                            revealed: revealed,
                            isRight: isRight,
                          )
                        : option.tile != null
                        ? _TilePreview(tile: option.tile!, revealed: revealed)
                        : option.image != null && option.stats.isNotEmpty
                        ? _PostPreview(
                            image: option.image!,
                            stats: option.stats,
                            highlight: showRight,
                          )
                        : option.image != null && option.caption != null
                        ? option.roundImage
                              ? _ProfilePreview(
                                  image: option.image!,
                                  caption: option.caption!,
                                )
                              : _CaptionedPicture(
                                  image: option.image!,
                                  caption: option.caption!,
                                  highlight: showRight,
                                )
                        : option.image != null && option.contain
                        ? ColoredBox(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                              child: SharpImage(
                                option.image!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : option.image != null
                        ? SharpImage(option.image!, fit: BoxFit.cover)
                        : ColoredBox(
                            color: const Color(0xFFEBF1EF),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    tr(option.text!),
                                    textAlign: TextAlign.center,
                                    style: appType(
                                      color: showRight
                                          ? CheckPartScreen.teal
                                          : CheckPartScreen.ink,
                                      fontSize: 22,
                                      fontWeight: showRight
                                          ? FontWeight.w800
                                          : FontWeight.w700,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                      letter: letter,
                      state: showRight
                          ? _BadgeState.right
                          : showWrong
                          ? _BadgeState.wrong
                          : _BadgeState.letter,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: revealed ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isRight
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            color: labelColor,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tr(option.label),
                            style: appType(
                              color: labelColor,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview({required this.image, required this.caption});

  final String image;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEBF1EF),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = (constraints.maxWidth * 0.82).clamp(
            0.0,
            constraints.maxHeight - 44,
          );
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: SharpImage(
                  image,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    tr(caption),
                    style: appType(
                      color: CheckPartScreen.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TilePreview extends StatelessWidget {
  const _TilePreview({required this.tile, required this.revealed});

  final CheckTile tile;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: tile.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 36, 8, 12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tile.icon, color: tile.iconColor, size: 44),
              const SizedBox(height: 10),
              Text(
                tr(tile.title),
                style: appType(
                  color: tile.titleColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: revealed ? 1 : 0,
                child: Text(
                  tr(tile.subtitle),
                  style: appType(
                    color: tile.subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

class _CaptionedPicture extends StatelessWidget {
  const _CaptionedPicture({
    required this.image,
    required this.caption,
    required this.highlight,
  });

  final String image;
  final String caption;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 44, 4, 6),
        child: Column(
          children: [
            Expanded(child: SharpImage(image, fit: BoxFit.contain)),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tr(caption),
                style: appType(
                  color: highlight ? CheckPartScreen.teal : CheckPartScreen.ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostPreview extends StatelessWidget {
  const _PostPreview({
    required this.image,
    required this.stats,
    required this.highlight,
  });

  final String image;
  final List<CheckStat> stats;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  child: SharpImage(image, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              Builder(
                builder: (context) {
                  final color = highlight && i == stats.length - 1
                      ? CheckPartScreen.green
                      : CheckPartScreen.ink;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(stats[i].icon, color: color, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            tr(stats[i].text),
                            style: appType(
                              color: color,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatPreview extends StatelessWidget {
  const _ChatPreview({
    required this.chat,
    required this.revealed,
    required this.isRight,
  });

  final CheckChat chat;
  final bool revealed;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    final timeColor = !revealed
        ? CheckPartScreen.muted
        : isRight
        ? CheckPartScreen.green
        : CheckPartScreen.red;
    final image = chat.image;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 30, 8, 6),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 150,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF1EF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (image != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: SharpImage(
                              image,
                              width: 104,
                              height: 78,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            tr(chat.question),
                            style: appType(
                              color: CheckPartScreen.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, color: timeColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        tr(chat.time),
                        style: appType(
                          color: timeColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: CheckPartScreen.teal,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      tr(chat.reply),
                      style: appType(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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

enum _BadgeState { letter, right, wrong }

class _Badge extends StatelessWidget {
  const _Badge({required this.letter, required this.state});

  final String letter;
  final _BadgeState state;

  @override
  Widget build(BuildContext context) {
    if (state != _BadgeState.letter) {
      final right = state == _BadgeState.right;
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: right ? CheckPartScreen.green : CheckPartScreen.red,
          shape: BoxShape.circle,
        ),
        child: Icon(
          right ? Icons.check_rounded : Icons.close_rounded,
          color: Colors.white,
          size: 20,
        ),
      );
    }
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        letter,
        style: appType(
          color: CheckPartScreen.ink,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({super.key, required this.correct, required this.reason});

  final bool correct;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final color = correct ? CheckPartScreen.green : CheckPartScreen.red;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: correct ? CheckPartScreen.greenFill : CheckPartScreen.redFill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              correct ? Icons.check_rounded : Icons.close_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? 'Yes! B is better' : 'Not quite. B is better',
                  style: appType(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tr(reason),
                  style: appType(
                    color: CheckPartScreen.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
