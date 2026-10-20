import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/data/display_guides.dart';
import 'package:artisnal_app/features/learn/data/displays.dart';
import 'package:artisnal_app/features/learn/widgets/guide_diagram.dart';

/// Walks the artisan through setting up one shot, ending on a worked example.
class DisplayGuideScreen extends StatefulWidget {
  const DisplayGuideScreen({
    super.key,
    required this.locale,
    required this.display,
    required this.material,
    required this.onTakeShot,
  });

  final String locale;
  final DisplayOption display;
  final String? material;

  /// Called from the last step, to record the shot and leave the guide.
  final VoidCallback onTakeShot;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color track = Color(0xFFEDF2EF);
  static const Color cardBorder = Color(0xFFE4EEEC);

  @override
  State<DisplayGuideScreen> createState() => _DisplayGuideScreenState();
}

class _DisplayGuideScreenState extends State<DisplayGuideScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  late final List<GuideStep> _steps = guideFor(widget.display.key);

  int _index = 0;

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  GuideStep get _step => _steps[_index];
  bool get _isLast => _index == _steps.length - 1;

  String get _spokenText {
    final caption = _step.caption;
    return '${_step.title}. ${_step.subtitle}.'
        '${caption == null ? '' : ' $caption'}';
  }

  void _back() {
    if (_index == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    _speech.stop();
    setState(() => _index--);
  }

  void _next() {
    _speech.stop();
    if (_isLast) {
      widget.onTakeShot();
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: DisplayGuideScreen.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: DisplayGuideScreen.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 14),
                  _progress(),
                  const SizedBox(height: 16),
                  Text(
                    _step.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: DisplayGuideScreen.ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _step.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: DisplayGuideScreen.muted,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _body()),
                  const SizedBox(height: 16),
                  _nextButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_rounded),
              color: DisplayGuideScreen.ink,
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 54),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.display.name.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: DisplayGuideScreen.teal,
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
              onTap: () =>
                  _speech.toggle(locale: widget.locale, text: _spokenText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          Expanded(
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                color: i <= _index
                    ? DisplayGuideScreen.teal
                    : DisplayGuideScreen.track,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (i != _steps.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _body() {
    final caption = _step.caption;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: DisplayGuideScreen.cardBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _step.showExample
                  ? _example()
                  : GuideDiagram(art: _step.art ?? GuideArt.grid),
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 12),
          Text(
            caption,
            style: GoogleFonts.plusJakartaSans(
              color: DisplayGuideScreen.muted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  /// The chosen material's photo of this display, in a 3:4 frame so it fills
  /// the box the way the picker cards do.
  Widget _example() {
    final material = widget.material;
    return Center(
      child: AspectRatio(
        aspectRatio: 0.75,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: material == null
              ? const ColoredBox(
                  color: DisplayGuideScreen.track,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Color(0xFF9AABA8),
                      size: 28,
                    ),
                  ),
                )
              : Image.asset(
                  widget.display.imageFor(material),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const ColoredBox(
                    color: DisplayGuideScreen.track,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Color(0xFF9AABA8),
                        size: 28,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _nextButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: kPrimaryButtonShadow,
      ),
      child: Material(
        color: DisplayGuideScreen.teal,
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
                Text(
                  _isLast ? 'Take the shot' : 'Next',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
