import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/features/learn/data/ai_prompts.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/data/products.dart';
import 'package:artisnal_app/features/learn/data/saved_work.dart';
import 'package:artisnal_app/features/learn/screens/lesson_badge_screen.dart';

/// Builds a prompt for the artisan's own AI tool, a few taps at a time: the
/// product, what they want, then the prompt to copy.
class AiPhotosScreen extends StatefulWidget {
  const AiPhotosScreen({super.key, required this.locale});

  final String locale;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color selectedFill = Color(0xFFEAF1EE);
  static const Color cardBorder = Color(0xFFE4EEEC);
  static const Color waiting = Color(0xFF8DBAB9);
  static const Color noteFill = Color(0xFFFFF6E5);
  static const Color noteBorder = Color(0xFFC5922E);

  @override
  State<AiPhotosScreen> createState() => _AiPhotosScreenState();
}

class _AiPhotosScreenState extends State<AiPhotosScreen> {
  int _step = 0;
  String? _product;
  AiGoal? _goal;
  String? _scene;
  bool _copied = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step--);
  }

  void _pickProduct(String name) {
    HapticFeedback.selectionClick();
    setState(() {
      // Displays and props differ by product.
      if (name != _product) _scene = null;
      _product = name;
    });
  }

  void _pickGoal(AiGoal goal) {
    HapticFeedback.selectionClick();
    setState(() {
      if (goal != _goal) _scene = null;
      _goal = goal;
    });
  }

  bool get _canContinue {
    if (_step == 0) return _product != null;
    final goal = _goal;
    return goal != null && (!aiNeedsBothPhotos(goal) || _scene != null);
  }

  String get _prompt =>
      buildAiPrompt(product: _product!, goal: _goal!, scene: _scene);

  /// The first finish earns the badge. After that this stays a tool to come
  /// back to, so Done simply closes it.
  void _finish() {
    final progress = LearnProgress.instance;
    final navigator = Navigator.of(context);
    if (progress.isLearnTaskComplete(aiPhotosTaskId)) {
      // Not maybePop: on this page that would step back instead of closing.
      navigator.pop();
      return;
    }
    progress.finishTask(aiPhotosTaskId, 1);
    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (badgeContext) => LessonBadgeScreen(
          title: 'AI photos',
          subtitle: 'You can use AI and keep your product the same.',
          onContinue: () => Navigator.of(badgeContext).pop(),
        ),
      ),
    );
  }

  /// The button itself says when the prompt is copied, so the answer is where
  /// the artisan is already looking. A browser that never answers counts as a
  /// failure rather than leaving the button doing nothing.
  Future<void> _copy() async {
    var worked = true;
    try {
      await Clipboard.setData(
        ClipboardData(text: _prompt),
      ).timeout(const Duration(seconds: 3));
    } on PlatformException {
      worked = false;
    } on TimeoutException {
      worked = false;
    }
    if (!mounted) return;
    if (!worked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              tr('Could not copy. Select the words and copy them.'),
              style: appType(color: Colors.white),
            ),
          ),
        );
      return;
    }
    SavedWork.instance.saveAiPrompt(_prompt);
    setState(() => _copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AiPhotosScreen.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: tr('Back'),
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AiPhotosScreen.ink,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                      Text(
                        tr('AI photos').toUpperCase(),
                        style: appType(
                          color: AiPhotosScreen.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  // Its own key per page, so each page opens at the top rather
                  // than scrolled as far as the page before it.
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: switch (_step) {
                      0 => _productStep(),
                      1 => _goalStep(),
                      _ => _promptStep(),
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (_step < 2)
                  _button(
                    label: 'Continue',
                    onTap: _canContinue ? () => setState(() => _step++) : null,
                  )
                else ...[
                  _button(
                    label: _copied ? 'Prompt copied' : 'Copy prompt',
                    icon: _copied ? Icons.check_rounded : null,
                    onTap: _copy,
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                      foregroundColor: AiPhotosScreen.teal,
                    ),
                    child: Text(
                      tr('Done'),
                      style: appType(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heading(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(title),
            style: appType(
              color: AiPhotosScreen.ink,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr(subtitle),
            style: appType(color: AiPhotosScreen.muted, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _productStep() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _heading('Which product is it?', 'We write the words for your AI tool'),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final product in photographyProducts)
              _ProductCard(
                product: product,
                selected: product.name == _product,
                onTap: () => _pickProduct(product.name),
              ),
          ],
        ),
      ],
    );
  }

  Widget _goalStep() {
    final goal = _goal;
    final displays = aiDisplaysFor(_product);
    final props = aiPropsFor(_product);
    // What this product can really have, so the card promises nothing else.
    String sample(List<AiChoice> items) =>
        items.take(3).map((item) => tr(item.label)).join(', ');
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _heading('What do you want?', 'Tap one'),
        _ChoiceRow(
          title: 'Clean background',
          detail: 'A plain wall behind your product',
          icon: Icons.wallpaper_rounded,
          selected: goal == AiGoal.cleanBackground,
          onTap: () => _pickGoal(AiGoal.cleanBackground),
        ),
        _ChoiceRow(
          title: 'Better light',
          detail: 'Soft, even light and true colours',
          icon: Icons.wb_sunny_outlined,
          selected: goal == AiGoal.betterLight,
          onTap: () => _pickGoal(AiGoal.betterLight),
        ),
        _ChoiceRow(
          title: 'New display',
          detail: sample(displays),
          icon: Icons.checkroom_rounded,
          selected: goal == AiGoal.newDisplay,
          onTap: () => _pickGoal(AiGoal.newDisplay),
        ),
        _ChoiceRow(
          title: 'Add props',
          detail: sample(props),
          icon: Icons.chair_outlined,
          selected: goal == AiGoal.addProps,
          onTap: () => _pickGoal(AiGoal.addProps),
        ),
        if (goal != null && aiNeedsBothPhotos(goal)) ...[
          _label(goal == AiGoal.newDisplay ? 'Which display?' : 'Which prop?'),
          _chips(
            [
              for (final item in goal == AiGoal.newDisplay ? displays : props)
                item.label,
            ],
            isOn: (label) => label == _scene,
            onTap: (label) {
              HapticFeedback.selectionClick();
              setState(() => _scene = label);
            },
          ),
        ],
      ],
    );
  }

  /// New displays and props are made from these two photos, so this stands out
  /// from everything else on the prompt page.
  Widget _photosNeeded() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AiPhotosScreen.noteFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AiPhotosScreen.noteBorder, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('You need these 2 photos'),
            style: appType(
              color: AiPhotosScreen.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          for (final photo in aiNeededPhotos)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.photo_outlined,
                    color: AiPhotosScreen.noteBorder,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(photo.label),
                          style: appType(
                            color: AiPhotosScreen.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          tr(photo.line),
                          style: appType(
                            color: AiPhotosScreen.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text(
            tr('Without these, the AI has to guess your product.'),
            style: appType(
              color: AiPhotosScreen.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _promptStep() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _heading('Your prompt', 'Copy it and paste it into your AI tool'),
        if (aiNeedsBothPhotos(_goal!)) _photosNeeded(),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AiPhotosScreen.cardBorder),
          ),
          child: SelectableText(
            _prompt,
            style: appType(
              color: AiPhotosScreen.ink,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
        _label('How to use it'),
        _numbered(1, 'Open your AI tool'),
        _numbered(
          2,
          aiNeedsBothPhotos(_goal!)
              ? 'Attach the full photo, then the close-up'
              : 'Attach your photo',
        ),
        _numbered(3, 'Paste the prompt and send'),
        _label('Check before you post'),
        _ticked('Are the motifs the same?'),
        _ticked('Is the colour the same?'),
        _ticked('Is the border the same?'),
        const SizedBox(height: 8),
        Text(
          tr('If not, do not post it. Try again.'),
          style: appType(
            color: AiPhotosScreen.ink,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr('Use your real photo for close-ups. They show your handwork.'),
          style: appType(
            color: AiPhotosScreen.muted,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        tr(text),
        style: appType(
          color: AiPhotosScreen.ink,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _chips(
    List<String> labels, {
    required bool Function(String) isOn,
    required void Function(String) onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in labels)
          ChoiceChip(
            label: Text(
              tr(label),
              style: appType(
                color: isOn(label) ? Colors.white : AiPhotosScreen.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: isOn(label),
            showCheckmark: false,
            selectedColor: AiPhotosScreen.teal,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isOn(label)
                  ? AiPhotosScreen.teal
                  : AiPhotosScreen.cardBorder,
            ),
            onSelected: (_) => onTap(label),
          ),
      ],
    );
  }

  Widget _numbered(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AiPhotosScreen.selectedFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$number',
              style: appType(
                color: AiPhotosScreen.teal,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr(text),
              style: appType(color: AiPhotosScreen.ink, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticked(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AiPhotosScreen.teal,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr(text),
              style: appType(color: AiPhotosScreen.ink, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _button({required String label, IconData? icon, VoidCallback? onTap}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: kPrimaryButtonShadow,
      ),
      child: Material(
        color: onTap == null ? AiPhotosScreen.waiting : AiPhotosScreen.teal,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 56,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      tr(label),
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
    return Material(
      color: selected ? AiPhotosScreen.selectedFill : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? AiPhotosScreen.teal : AiPhotosScreen.cardBorder,
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
                      child: Image.asset(product.image, fit: BoxFit.cover),
                    ),
                    if (selected)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AiPhotosScreen.teal,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                tr(product.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appType(
                  color: AiPhotosScreen.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.detail,
  });

  final String title;
  final String? detail;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));
    final detail = this.detail;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AiPhotosScreen.selectedFill : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AiPhotosScreen.teal : AiPhotosScreen.cardBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: AiPhotosScreen.teal, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(title),
                        style: appType(
                          color: AiPhotosScreen.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (detail != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          tr(detail),
                          style: appType(
                            color: AiPhotosScreen.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? AiPhotosScreen.teal
                      : AiPhotosScreen.cardBorder,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
