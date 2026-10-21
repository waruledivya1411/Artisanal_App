import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/data/materials.dart';

/// Every picker card is this shape, so all the photo frames match. It leaves
/// the photo area at roughly 3:4 on a phone, the shape most of the photos
/// already are, so they fill their frame with the least cropped away.
const double kPickerCardRatio = 0.648;

/// Fixed room for the caption, so a name that wraps to two lines does not
/// shrink its photo and leave that card's frame a different size.
const double kPickerCaptionHeight = 34;

class MaterialPickerScreen extends StatefulWidget {
  const MaterialPickerScreen({
    super.key,
    required this.locale,
    required this.taskLabel,
    required this.product,
    required this.onPicked,
  });

  final String locale;
  final String taskLabel;
  final String? product;
  final WidgetBuilder onPicked;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color selectedFill = Color(0xFFEAF1EE);
  static const Color cardBorder = Color(0xFFE4EEEC);
  static const Color waiting = Color(0xFF8DBAB9);

  @override
  State<MaterialPickerScreen> createState() => _MaterialPickerScreenState();
}

class _MaterialPickerScreenState extends State<MaterialPickerScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  late final List<MaterialOption> _materials = materialsFor(widget.product);

  /// A yarn chosen for another product may not be offered for this one.
  late String? _selected = _materials.any(
    (m) => m.name == SelectedMaterial.instance.name,
  )
      ? SelectedMaterial.instance.name
      : null;

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  String get _spokenText =>
      'What is it made of? '
      '${_materials.map((m) => m.name).join('. ')}.';

  void _select(String material) {
    HapticFeedback.selectionClick();
    setState(() => _selected = material);
  }

  void _continue() {
    final material = _selected;
    if (material == null) return;
    _speech.stop();
    SelectedMaterial.instance.select(material);
    // Pushed, not replaced, so Back steps to the previous question.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: ModalRoute.of(context)?.settings.name),
        builder: widget.onPicked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final picked = _selected != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: MaterialPickerScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: MaterialPickerScreen.background,
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
                          color: MaterialPickerScreen.ink,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                      Text(
                        widget.taskLabel,
                        style: GoogleFonts.plusJakartaSans(
                          color: MaterialPickerScreen.teal,
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
                  'What is it made of?',
                  style: GoogleFonts.plusJakartaSans(
                    color: MaterialPickerScreen.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap one',
                  style: GoogleFonts.plusJakartaSans(
                    color: MaterialPickerScreen.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _materials.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: kPickerCardRatio,
                        ),
                    itemBuilder: (context, index) {
                      final material = _materials[index];
                      return _MaterialCard(
                        material: material,
                        selected: material.name == _selected,
                        onTap: () => _select(material.name),
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
                          ? MaterialPickerScreen.teal
                          : MaterialPickerScreen.waiting,
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
                              'Continue',
                              style: GoogleFonts.plusJakartaSans(
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

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({
    required this.material,
    required this.selected,
    required this.onTap,
  });

  final MaterialOption material;
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
        color: selected ? MaterialPickerScreen.selectedFill : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected
                ? MaterialPickerScreen.teal
                : MaterialPickerScreen.cardBorder,
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
                        child: Image.asset(
                          material.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              _WeaveSwatch(color: material.swatch),
                        ),
                      ),
                      if (selected)
                        const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: MaterialPickerScreen.teal,
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
                      material.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: MaterialPickerScreen.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
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

/// Stand-in for a material photo: the yarn's colour under a woven crosshatch.
/// Shown only until a real photo is dropped in at [MaterialOption.image].
class _WeaveSwatch extends StatelessWidget {
  const _WeaveSwatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: CustomPaint(painter: _WeavePainter(color), size: Size.infinite),
    );
  }
}

class _WeavePainter extends CustomPainter {
  const _WeavePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final dark = HSLColor.fromColor(color);
    final warp = Paint()
      ..color = dark
          .withLightness((dark.lightness - 0.07).clamp(0.0, 1.0))
          .toColor()
      ..strokeWidth = 2;
    final weft = Paint()
      ..color = dark
          .withLightness((dark.lightness + 0.05).clamp(0.0, 1.0))
          .toColor()
      ..strokeWidth = 2;

    const step = 7.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), warp);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), weft);
    }
  }

  @override
  bool shouldRepaint(covariant _WeavePainter oldDelegate) =>
      oldDelegate.color != color;
}
