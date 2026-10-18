import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/button_shadow.dart';
import '../widgets/listen_playing_button.dart';
import '../widgets/speak_circle_button.dart';

class CheckOption {
  const CheckOption({this.image, this.text, this.caption, required this.label})
    : assert(image != null || text != null);

  final String? image;
  final String? text;
  final String? caption;
  final String label;
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
    this.nextBuilder,
  });

  final String locale;
  final String partLabel;
  final CheckOption wrong;
  final CheckOption right;
  final String rightReason;
  final String wrongReason;
  final WidgetBuilder? nextBuilder;

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
  late final WelcomeSpeech _speech = WelcomeSpeech((_) {
    if (mounted) setState(() {});
  });

  _Choice? _choice;

  bool get _correct => _choice == _Choice.b;

  String get _spokenText {
    if (_choice == null) return 'Which is better? Tap one.';
    return _correct
        ? 'Yes! B is better. ${widget.rightReason}.'
        : 'Not quite. B is better. ${widget.wrongReason}.';
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
    final builder = widget.nextBuilder;
    if (builder == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
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
                          icon: const Icon(Icons.close_rounded),
                          color: CheckPartScreen.ink,
                          iconSize: 26,
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
                            widget.partLabel,
                            style: GoogleFonts.plusJakartaSans(
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
                  'Which is better?',
                  style: GoogleFonts.plusJakartaSans(
                    color: CheckPartScreen.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap one',
                  style: GoogleFonts.plusJakartaSans(
                    color: CheckPartScreen.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    children: [
                      Flexible(
                        child: AspectRatio(
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
                      const SizedBox(height: 16),
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
                            : const SizedBox(height: 72),
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
                    child: option.image != null && option.caption != null
                        ? _ProfilePreview(
                            image: option.image!,
                            caption: option.caption!,
                          )
                        : option.image != null
                        ? Image(
                            image: AssetImage(option.image!),
                            fit: BoxFit.cover,
                          )
                        : ColoredBox(
                            color: const Color(0xFFEBF1EF),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    option.text!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isRight
                                          ? CheckPartScreen.teal
                                          : CheckPartScreen.ink,
                                      fontSize: isRight ? 27 : 18,
                                      fontWeight: isRight
                                          ? FontWeight.w800
                                          : FontWeight.w600,
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
                            option.label,
                            style: GoogleFonts.plusJakartaSans(
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
                child: Image(
                  image: AssetImage(image),
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
                    caption,
                    style: GoogleFonts.plusJakartaSans(
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
        style: GoogleFonts.plusJakartaSans(
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
                  style: GoogleFonts.plusJakartaSans(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: GoogleFonts.plusJakartaSans(
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
