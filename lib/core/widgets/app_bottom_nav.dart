import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.onLearnTap});

  final VoidCallback? onLearnTap;

  static const Color teal = Color(0xFF1B7574);
  static const Color muted = Color(0xFF4F5F5D);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return SizedBox(
      height: 92 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 12,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 16, bottom: bottomInset),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onLearnTap,
                        child: const _NavItem(
                          image: 'assets/images/icons/book.png',
                          label: 'Learn',
                          selected: true,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    const Expanded(
                      child: _NavItem(
                        image: 'assets/images/icons/user.png',
                        label: 'Me',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x591B7574),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: teal,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Photo',
                  style: GoogleFonts.plusJakartaSans(
                    color: muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.image,
    required this.label,
    this.selected = false,
  });

  final String image;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppBottomNav.teal : AppBottomNav.muted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image(
          image: AssetImage(image),
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
