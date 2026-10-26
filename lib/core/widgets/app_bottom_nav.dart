import 'package:flutter/material.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

enum AppNavTab { learn, me }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.locale,
    this.selectedTab = AppNavTab.learn,
    this.onLearnTap,
    this.onPhotoTap,
    this.onMeTap,
  });

  final String locale;
  final AppNavTab selectedTab;
  final VoidCallback? onLearnTap;
  final VoidCallback? onPhotoTap;
  final VoidCallback? onMeTap;

  static const Color teal = Color(0xFF1B7574);
  static const Color muted = Color(0xFF4F5F5D);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    // Photo sits level with Learn and Me, styled like them, so the bar
    // shows where the artisan is rather than drawing the eye to the camera.
    return SizedBox(
      height: 80 + bottomInset,
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
                  child: _NavItem(
                    locale: locale,
                    image: 'assets/images/icons/book.png',
                    label: 'Learn',
                    selected: selectedTab == AppNavTab.learn,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onPhotoTap,
                  child: _NavItem(
                    locale: locale,
                    icon: Icons.photo_camera_outlined,
                    label: 'Photo',
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onMeTap,
                  child: _NavItem(
                    locale: locale,
                    image: 'assets/images/icons/user.png',
                    label: 'Me',
                    selected: selectedTab == AppNavTab.me,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.locale,
    required this.label,
    this.image,
    this.icon,
    this.selected = false,
  });

  final String locale;

  /// The tab's picture: an image file, or a plain icon for Photo.
  final String? image;
  final IconData? icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppBottomNav.teal : AppBottomNav.muted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (image case final file?)
          SharpImage(file, width: 24, height: 24, fit: BoxFit.contain)
        else
          Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          tr(label),
          style: appType(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
