import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/widgets/ig_create_illustration.dart';
import 'package:artisnal_app/features/learn/data/create_content_kind.dart';
import 'package:artisnal_app/features/learn/screens/pick_photo_guide_screen.dart';

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

  int _activeGuideStep = 0;

  @override
  void dispose() {
    _speech.stop();
    _stepSpeech.stop();
    super.dispose();
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
    _stepSpeech.toggle(locale: widget.locale, text: _guide.firstStepSpoken);
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

  void _finishLesson() {
    final navigator = Navigator.of(context);
    navigator.pop();
    if (navigator.canPop()) navigator.pop();
    if (navigator.canPop()) navigator.pop();
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
                        _guide.headerTitle,
                        style: GoogleFonts.plusJakartaSans(
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
                              text: _guide.spoken,
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
                    child: Column(
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
                          _guide.instructionTitle,
                          style: GoogleFonts.plusJakartaSans(
                            color: PostInInstagramScreen.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _guide.instructionBody,
                          style: GoogleFonts.plusJakartaSans(
                            color: PostInInstagramScreen.muted,
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _StepList(
                          steps: _guide.steps,
                          activeStep: _activeGuideStep,
                          onStepTap: _onGuideStepTap,
                          stepAudioPlaying: _stepSpeech.playing,
                          onStepSpeak: _playStepAudio,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: _finishLesson,
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Got it',
                          style: GoogleFonts.plusJakartaSans(
                            color: PostInInstagramScreen.teal,
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
                          '$number',
                          style: GoogleFonts.plusJakartaSans(
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
                          label,
                          style: GoogleFonts.plusJakartaSans(
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
