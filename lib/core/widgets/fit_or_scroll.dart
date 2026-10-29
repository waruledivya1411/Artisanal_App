import 'package:flutter/widgets.dart';

/// Lays a fixed page out to fill [height] exactly as it would without this,
/// spacers and all, and only scrolls when the content does not fit - a small
/// phone, long translated text or large text size.
///
/// The child must be able to report its own height, so it cannot hold a
/// LayoutBuilder or a list that scrolls by itself.
class FitOrScroll extends StatelessWidget {
  const FitOrScroll({super.key, required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: IntrinsicHeight(child: child),
      ),
    );
  }
}
