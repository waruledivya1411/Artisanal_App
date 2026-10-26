import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/features/learn/data/displays.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

/// Every display the artisan ticked, taken one at a time in any order:
/// tap one to choose it, then Next opens its guide and camera. Once its
/// photo is kept it is marked done, and the next one can be chosen.
class ShotListScreen extends StatefulWidget {
  const ShotListScreen({
    super.key,
    required this.displays,
    required this.material,
    required this.product,
    required this.onOpen,
  });

  final List<DisplayOption> displays;
  final String? material;
  final String? product;

  /// Opens a display's guide and camera; completes with true once its photo
  /// is kept.
  final Future<bool?> Function(DisplayOption display) onOpen;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color doneFill = Color(0xFFEAF1EE);
  static const Color cardBorder = Color(0xFFE4EEEC);
  static const Color waiting = Color(0xFF8DBAB9);

  @override
  State<ShotListScreen> createState() => _ShotListScreenState();
}

class _ShotListScreenState extends State<ShotListScreen> {
  final Set<String> _done = {};

  /// The display picked to shoot next; none until the artisan taps one.
  String? _chosen;

  bool get _allDone => _done.length == widget.displays.length;

  List<DisplayOption> get _remaining =>
      widget.displays.where((d) => !_done.contains(d.name)).toList();

  void _choose(DisplayOption display) {
    HapticFeedback.selectionClick();
    setState(() => _chosen = display.name);
  }

  Future<void> _next() async {
    final display = widget.displays.firstWhere((d) => d.name == _chosen);
    final kept = await widget.onOpen(display);
    if (kept == true && mounted) {
      setState(() {
        _done.add(display.name);
        // Back on the list, the next one still to do is ready to go.
        _chosen = _remaining.firstOrNull?.name;
      });
    }
  }

  /// Leaves the shoot altogether, back to where it was started from.
  void _finish() {
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name != photographySetupRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Next opens the chosen display; once every display is done the
    // button finishes instead.
    final VoidCallback? onButton = _allDone
        ? _finish
        : _chosen == null
        ? null
        : _next;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: ShotListScreen.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ShotListScreen.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: tr('Back'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: ShotListScreen.ink,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  tr('Your shots'),
                  style: appType(
                    color: ShotListScreen.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr('Choose one, then tap Next'),
                  style: appType(color: ShotListScreen.muted, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  tr('${_done.length} of ${widget.displays.length} done'),
                  style: appType(
                    color: ShotListScreen.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  // The displays still to do come first; finished ones drop
                  // to the bottom.
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final (title, group) in [
                        ('Remaining', _remaining),
                        (
                          'Done',
                          widget.displays
                              .where((d) => _done.contains(d.name))
                              .toList(),
                        ),
                      ])
                        if (group.isNotEmpty) ...[
                          if (_done.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 4,
                                bottom: 10,
                              ),
                              child: Text(
                                tr(title).toUpperCase(),
                                style: appType(
                                  color: ShotListScreen.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          for (final display in group)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ShotRow(
                                number: widget.displays.indexOf(display) + 1,
                                display: display,
                                material: widget.material,
                                product: widget.product,
                                done: _done.contains(display.name),
                                chosen: _chosen == display.name,
                                onTap: () => _choose(display),
                              ),
                            ),
                        ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kPrimaryButtonShadow,
                  ),
                  child: Material(
                    color: onButton == null
                        ? ShotListScreen.waiting
                        : ShotListScreen.teal,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: onButton,
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            tr(_allDone ? 'Finish' : 'Next'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShotRow extends StatelessWidget {
  const _ShotRow({
    required this.number,
    required this.display,
    required this.material,
    required this.product,
    required this.done,
    required this.chosen,
    required this.onTap,
  });

  final int number;
  final DisplayOption display;
  final String? material;
  final String? product;
  final bool done;
  final bool chosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(18));
    final material = this.material;
    final marked = done || chosen;
    return Material(
      color: marked ? ShotListScreen.doneFill : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: marked ? ShotListScreen.teal : ShotListScreen.cardBorder,
          width: marked ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        // A done shot is finished; only the others can be chosen.
        onTap: done ? null : onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: material == null
                      ? const ColoredBox(color: ShotListScreen.doneFill)
                      : Image.asset(
                          display.imageFor(material, product: product),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const ColoredBox(color: ShotListScreen.doneFill),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$number',
                      style: appType(
                        color: ShotListScreen.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(display.name),
                      style: appType(
                        color: ShotListScreen.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (done)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr('Done'),
                      style: appType(
                        color: ShotListScreen.teal,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: ShotListScreen.teal,
                      size: 22,
                    ),
                  ],
                )
              else
                Icon(
                  chosen
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: chosen
                      ? ShotListScreen.teal
                      : ShotListScreen.cardBorder,
                  size: 24,
                ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
