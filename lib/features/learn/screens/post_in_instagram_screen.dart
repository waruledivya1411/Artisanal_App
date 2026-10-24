import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/widgets/ig_create_illustration.dart';
import 'package:artisnal_app/features/learn/data/create_content_kind.dart';
import 'package:artisnal_app/features/learn/screens/pick_photo_guide_screen.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class PostInInstagramScreen extends StatefulWidget {
  const PostInInstagramScreen({
    super.key,
    required this.locale,
    this.kind = CreateContentKind.post,
  });

  final String locale;
  final CreateContentKind kind;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color gold = Color(0xFFC5922E);

  @override
  State<PostInInstagramScreen> createState() => _PostInInstagramScreenState();
}

class _PostInInstagramScreenState extends State<PostInInstagramScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });
  late final SpeechPlayer _stepSpeech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });
  late final ScrollController _scroll = ScrollController();

  int _activeGuideStep = 0;
  bool _showScrollHint = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  @override
  void dispose() {
    _speech.stop();
    _stepSpeech.stop();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() => _updateScrollHint();

  void _updateScrollHint() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final canScroll = position.maxScrollExtent > 12;
    final nearBottom = position.pixels >= position.maxScrollExtent - 28;
    final show = canScroll && !nearBottom;
    if (show != _showScrollHint && mounted) {
      setState(() => _showScrollHint = show);
    }
  }

  CreateContentGuide get _guide => CreateContentGuide.forKind(widget.kind);

  bool get _needsMenuPick =>
      widget.kind == CreateContentKind.story ||
      widget.kind == CreateContentKind.reel;

  void _onPlusAction() {
    if (!_needsMenuPick) {
      _openMediaPicker();
      return;
    }
    if (_activeGuideStep == 0) {
      setState(() => _activeGuideStep = 1);
    }
  }

  void _onMenuPickAction() {
    if (_needsMenuPick && _activeGuideStep >= 1) {
      _openMediaPicker();
    }
  }

  void _onGuideStepTap(int index) {
    if (index == 0) {
      _onPlusAction();
      return;
    }
    if (index == 1 && _needsMenuPick) {
      _onMenuPickAction();
    }
  }

  void _playStepAudio() {
    _speech.stop();
    _stepSpeech.toggle(
      locale: widget.locale,
      text: tr(_guide.firstStepSpoken),
    );
  }

  void _openMediaPicker() {
    _speech.stop();
    _stepSpeech.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PickPhotoGuideScreen(
          locale: widget.locale,
          kind: widget.kind,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: PostInInstagramScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: PostInInstagramScreen.background,
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
                          color: PostInInstagramScreen.ink,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                      Text(
                        tr(_guide.headerTitle),
                        style: appType(
                          color: PostInInstagramScreen.teal,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SpeakCircleButton(
                          playing: _speech.playing,
                          onTap: () {
                            _stepSpeech.stop();
                            _speech.toggle(
                              locale: widget.locale,
                              text: tr(_guide.spoken),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IgCreateIllustration(
                          kind: widget.kind,
                          onTapPrimary: _onPlusAction,
                          onTapMenu: _needsMenuPick && _activeGuideStep >= 1
                              ? _onMenuPickAction
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          tr(_guide.instructionTitle),
                          style: appType(
                            color: PostInInstagramScreen.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tr(_guide.instructionBody),
                          style: appType(
                            color: PostInInstagramScreen.muted,
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                        if (_showScrollHint) ...[
                          const SizedBox(height: 10),
                          const _ScrollDownCue(),
                        ],
                        const SizedBox(height: 14),
                        _StepListWithDoodle(
                          steps: _guide.steps,
                          activeStep: _activeGuideStep,
                          onStepTap: _onGuideStepTap,
                          stepAudioPlaying: _stepSpeech.playing,
                          onStepSpeak: _playStepAudio,
                        ),
                        const SizedBox(height: 24),
                      ],
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

/// Plain label — not tappable, not button-shaped.
class _ScrollDownCue extends StatelessWidget {
  const _ScrollDownCue();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.south_rounded,
            size: 14,
            color: PostInInstagramScreen.muted.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 4),
          Text(
            tr('Scroll down'),
            style: appType(
              color: PostInInstagramScreen.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepListWithDoodle extends StatelessWidget {
  const _StepListWithDoodle({
    required this.steps,
    required this.activeStep,
    required this.onStepTap,
    required this.stepAudioPlaying,
    required this.onStepSpeak,
  });

  final List<String> steps;
  final int activeStep;
  final void Function(int index) onStepTap;
  final bool stepAudioPlaying;
  final VoidCallback onStepSpeak;

  static const _doodleAsset =
      'assets/images/lessons/create_post/click_here_doodle.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeStep == 0)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 0),
            child: IgnorePointer(
              child: Image.asset(
                _doodleAsset,
                width: 152,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        _StepList(
          steps: steps,
          activeStep: activeStep,
          onStepTap: onStepTap,
          stepAudioPlaying: stepAudioPlaying,
          onStepSpeak: onStepSpeak,
        ),
      ],
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({
    required this.steps,
    required this.activeStep,
    required this.onStepTap,
    required this.stepAudioPlaying,
    required this.onStepSpeak,
  });

  final List<String> steps;
  final int activeStep;
  final void Function(int index) onStepTap;
  final bool stepAudioPlaying;
  final VoidCallback onStepSpeak;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          children: [
            for (var i = 0; i < steps.length; i++)
              _StepRow(
                number: i + 1,
                label: steps[i],
                current: i == activeStep,
                onTap: i == activeStep ? () => onStepTap(i) : null,
                speakPlaying: i == activeStep && i == 0 && stepAudioPlaying,
                onSpeak: i == activeStep && i == 0 ? onStepSpeak : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.label,
    required this.current,
    this.onTap,
    this.onSpeak,
    this.speakPlaying = false,
  });

  final int number;
  final String label;
  final bool current;
  final VoidCallback? onTap;
  final VoidCallback? onSpeak;
  final bool speakPlaying;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: current
                              ? PostInInstagramScreen.gold
                              : const Color(0xFFD5DEDB),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          tr('$number'),
                          style: appType(
                            color: current
                                ? Colors.white
                                : PostInInstagramScreen.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr(label),
                          style: appType(
                            color: current
                                ? PostInInstagramScreen.ink
                                : PostInInstagramScreen.muted,
                            fontSize: 15,
                            fontWeight: current
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (current && onSpeak != null)
            SpeakIconButton(playing: speakPlaying, onTap: onSpeak!),
        ],
      ),
    );
  }
}
