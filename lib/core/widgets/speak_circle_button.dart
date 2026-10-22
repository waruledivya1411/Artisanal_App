import 'package:flutter/widgets.dart';

// Read-aloud has been removed; these are kept so callers still build, but
// they take no space and do nothing.

class SpeakCircleButton extends StatelessWidget {
  const SpeakCircleButton({
    super.key,
    required this.playing,
    required this.onTap,
  });

  final bool playing;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class SpeakIconButton extends StatelessWidget {
  const SpeakIconButton({
    super.key,
    required this.playing,
    required this.onTap,
    this.iconSize = 22,
  });

  final bool playing;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
