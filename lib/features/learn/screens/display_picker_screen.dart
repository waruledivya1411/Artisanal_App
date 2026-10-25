import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/data/displays.dart';
import 'package:artisnal_app/features/learn/screens/display_guide_screen.dart';
import 'package:artisnal_app/features/learn/screens/shoot_screen.dart';
import 'package:artisnal_app/features/learn/screens/material_picker_screen.dart'
    show kPickerCardRatio, kPickerCaptionHeight;
import 'package:artisnal_app/core/l10n/app_text.dart';

class DisplayPickerScreen extends StatefulWidget {
  const DisplayPickerScreen({
    super.key,
    required this.locale,
    required this.taskLabel,
    required this.product,
    required this.material,
  });

  final String locale;
  final String taskLabel;
  final String? product;
  final String? material;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color selectedFill = Color(0xFFEAF1EE);
  static const Color cardBorder = Color(0xFFE4EEEC);
  static const Color waiting = Color(0xFF8DBAB9);

  @override
  State<DisplayPickerScreen> createState() => _DisplayPickerScreenState();
}

class _DisplayPickerScreenState extends State<DisplayPickerScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  late final List<DisplayOption> _displays = displaysFor(widget.product);

  late String? _selected = _displays.any(
        (d) => d.name == SelectedDisplay.instance.name,
      )
      ? SelectedDisplay.instance.name
      : null;

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  String get _spokenText =>
      '${tr('How will you show it?')} ${_displays.map((d) => tr(d.name)).join('. ')}.';

  /// Tapping a display only selects it; nothing moves on until Continue.
  void _select(DisplayOption display) {
    HapticFeedback.selectionClick();
    SelectedDisplay.instance.select(display.name);
    setState(() => _selected = display.name);
  }

  /// Continue goes on to the chosen display's guide, which ends at the
  /// camera - it does not leave the setup.
  void _continue() {
    final name = _selected;
    if (name == null) return;
    for (final d in _displays) {
      if (d.name == name) return _openGuide(d);
    }
  }

  void _openGuide(DisplayOption display) {
    _speech.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: ModalRoute.of(context)?.settings.name),
        builder: (routeContext) => DisplayGuideScreen(
          locale: widget.locale,
          display: display,
          material: widget.material,
          product: widget.product,
          onTakeShot: () => _shoot(routeContext, display),
        ),
      ),
    );
  }

  /// Last step of the setup. Every step is its own route so Back steps once,
  /// which means finishing has to unwind all of them: they share a route name,
  /// so pop until the first route that is not part of the setup.
  Future<void> _shoot(BuildContext guideContext, DisplayOption display) async {
    SelectedDisplay.instance.select(display.name);
    if (mounted) setState(() => _selected = display.name);

    final navigator = Navigator.of(guideContext);
    final kept = await navigator.push<bool>(
      MaterialPageRoute<bool>(
        settings: RouteSettings(name: ModalRoute.of(context)?.settings.name),
        builder: (_) => ShootScreen(
          locale: widget.locale,
          display: display,
          product: widget.product,
        ),
      ),
    );
    if (kept == true && navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final picked = _selected != null;
    final material = widget.material;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: DisplayPickerScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: DisplayPickerScreen.background,
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
                          color: DisplayPickerScreen.ink,
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
                          color: DisplayPickerScreen.teal,
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
                            text: _spokenText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  tr('How will you show it?'),
                  style: appType(
                    color: DisplayPickerScreen.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr('Tap one'),
                  style: appType(
                    color: DisplayPickerScreen.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _displays.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: kPickerCardRatio,
                        ),
                    itemBuilder: (context, index) {
                      final display = _displays[index];
                      return _DisplayCard(
                        display: display,
                        material: material,
                        product: widget.product,
                        selected: display.name == _selected,
                        onTap: () => _select(display),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: picked
                          ? DisplayPickerScreen.teal
                          : DisplayPickerScreen.waiting,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: picked ? _continue : null,
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 56,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              tr('Continue'),
                              style: appType(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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

class _DisplayCard extends StatelessWidget {
  const _DisplayCard({
    required this.display,
    required this.material,
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final DisplayOption display;
  final String? material;
  final String? product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(18));

    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: selected ? DisplayPickerScreen.selectedFill : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected
                ? DisplayPickerScreen.teal
                : DisplayPickerScreen.cardBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _Example(
                          display: display,
                          material: material,
                          product: product,
                        ),
                      ),
                      if (selected)
                        const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: DisplayPickerScreen.teal,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  height: kPickerCaptionHeight,
                  child: Center(
                    child: Text(
                      tr(display.name),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: appType(
                        color: DisplayPickerScreen.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
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

/// The example photo for this display in the chosen material, falling back to
/// a plain tile when no material is set or its photo is missing.
class _Example extends StatelessWidget {
  const _Example({
    required this.display,
    required this.material,
    required this.product,
  });

  final DisplayOption display;
  final String? material;
  final String? product;

  @override
  Widget build(BuildContext context) {
    final name = material;
    if (name == null) return const _NoExample();
    return Image.asset(
      display.imageFor(name, product: product),
      fit: product == 'Cushion covers' ||
              product == 'Jod kappur' ||
              product == 'Yardages'
          ? BoxFit.contain
          : BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stack) => const _NoExample(),
    );
  }
}

class _NoExample extends StatelessWidget {
  const _NoExample();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFEDF2EF),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFF9AABA8),
          size: 26,
        ),
      ),
    );
  }
}
