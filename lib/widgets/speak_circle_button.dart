import 'package:flutter/material.dart';

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
                  : const Image(
                      image: AssetImage('assets/images/speaker.png'),
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
  const _WaveBars();

  @override
  Widget build(BuildContext context) {
    const heights = <double>[10, 18, 13, 20];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < heights.length; i++) ...[
          Container(
            width: 3,
            height: heights[i],
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (i != heights.length - 1) const SizedBox(width: 3),
        ],
      ],
    );
  }
}
