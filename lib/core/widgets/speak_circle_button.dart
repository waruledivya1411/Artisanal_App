import 'package:flutter/material.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';

class SpeakCircleButton extends StatelessWidget {
  const SpeakCircleButton({
    super.key,
    required this.playing,
    required this.onTap,
  });

  final bool playing;
  final VoidCallback onTap;

  static const Color teal = Color(0xFF1B7574);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: playing ? const Color(0x591B7574) : const Color(0x22000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: playing ? teal : Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: playing
                  ? const _WaveBars()
                  : const SharpImage(
                      'assets/images/icons/speaker.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveBars extends StatelessWidget {
  const _WaveBars({this.color = Colors.white, this.barWidth = 3});

  final Color color;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    const heights = <double>[10, 18, 13, 20];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < heights.length; i++) ...[
          Container(
            width: barWidth,
            height: heights[i] * (barWidth / 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (i != heights.length - 1) SizedBox(width: barWidth),
        ],
      ],
    );
  }
}

/// Speaker in lesson steps — tap to hear the step, then shows wave bars.
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            width: iconSize + 4,
            height: iconSize + 4,
            child: Center(
              child: playing
                  ? _WaveBars(color: SpeakCircleButton.teal, barWidth: 2.5)
                  : SharpImage(
                      'assets/images/icons/speaker.png',
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
