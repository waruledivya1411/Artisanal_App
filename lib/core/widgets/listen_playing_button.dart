import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';

class ListenPlayingButton extends StatelessWidget {
  const ListenPlayingButton({
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: playing ? const Color(0x591B7574) : const Color(0x33000000),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: playing ? teal : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              height: 46,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (playing) ...[
                    const _WaveBars(),
                    const SizedBox(width: 8),
                    Text(
                      'Playing',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else ...[
                    const SharpImage(
                      'assets/images/icons/speaker.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Listen',
                      style: GoogleFonts.plusJakartaSans(
                        color: teal,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
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
    const heights = <double>[8, 14, 10, 16];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < heights.length; i++) ...[
          Container(
            width: 2.5,
            height: heights[i],
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (i != heights.length - 1) const SizedBox(width: 2),
        ],
      ],
    );
  }
}
