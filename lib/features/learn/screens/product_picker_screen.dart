import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artisnal_app/core/speech/speech_player.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/speak_circle_button.dart';
import 'package:artisnal_app/features/learn/data/products.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

/// Product photos are a mix of upright and wide shots, so their frame is
/// square: that costs each one the same quarter rather than taking half the
/// width off the wide ones.
const double kProductCardRatio = 0.805;

class ProductPickerScreen extends StatefulWidget {
  const ProductPickerScreen({
    super.key,
    required this.locale,
    required this.taskLabel,
    required this.onPicked,
  });

  final String locale;
  final String taskLabel;
  final WidgetBuilder onPicked;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color selectedFill = Color(0xFFEAF1EE);
  static const Color cardBorder = Color(0xFFE4EEEC);
  static const Color waiting = Color(0xFF8DBAB9);

  @override
  State<ProductPickerScreen> createState() => _ProductPickerScreenState();
}

class _ProductPickerScreenState extends State<ProductPickerScreen> {
  late final SpeechPlayer _speech = SpeechPlayer((_) {
    if (mounted) setState(() {});
  });

  late String? _selected = SelectedProduct.instance.name;

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  String get _spokenText =>
      '${tr('What are you photographing?')} '
      '${photographyProducts.map((p) => tr(p.name)).join('. ')}.';

  void _select(String product) {
    HapticFeedback.selectionClick();
    setState(() => _selected = product);
  }

  void _continue() {
    final product = _selected;
    if (product == null) return;
    _speech.stop();
    SelectedProduct.instance.select(product);
    // Pushed, not replaced, so Back steps to the previous question. The next
    // route inherits this one's name so finishing can unwind the whole setup.
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
        systemNavigationBarColor: ProductPickerScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ProductPickerScreen.background,
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
                          color: ProductPickerScreen.ink,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
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
                const SizedBox(height: 18),
                Text(
                  tr('What are you photographing?'),
                  style: appType(
                    color: ProductPickerScreen.ink,
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
                    color: ProductPickerScreen.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: photographyProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: kProductCardRatio,
                        ),
                    itemBuilder: (context, index) {
                      final product = photographyProducts[index];
                      return _ProductCard(
                        product: product,
                        selected: product.name == _selected,
                        onTap: () => _select(product.name),
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
                          ? ProductPickerScreen.teal
                          : ProductPickerScreen.waiting,
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final ProductOption product;
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
        color: selected ? ProductPickerScreen.selectedFill : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected
                ? ProductPickerScreen.teal
                : ProductPickerScreen.cardBorder,
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
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const ColoredBox(
                                color: Color(0xFFEDF2EF),
                                child: Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Color(0xFF9AABA8),
                                    size: 24,
                                  ),
                                ),
                              ),
                        ),
                      ),
                      if (selected)
                        const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: ProductPickerScreen.teal,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  height: 34,
                  child: Center(
                    child: Text(
                      tr(product.name),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: appType(
                        color: ProductPickerScreen.ink,
                        fontSize: 15,
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
