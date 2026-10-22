import 'package:flutter/widgets.dart';

/// Read-aloud has been removed; the button is kept so callers still build,
/// but it takes no space and does nothing.
class ListenPlayingButton extends StatelessWidget {
  const ListenPlayingButton({
    super.key,
    required this.playing,
    required this.onTap,
  });

  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
