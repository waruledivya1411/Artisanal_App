import 'package:flutter/material.dart';

import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/features/learn/data/create_content_kind.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

/// Consistent wireframe Instagram art for Post / Story / Reel lessons.
class IgCreateIllustration extends StatelessWidget {
  const IgCreateIllustration({
    super.key,
    required this.kind,
    this.locale = 'en-US',
    this.onTapPrimary,
    this.onTapMenu,
    this.compact = false,
  });

  final CreateContentKind kind;
  final String locale;
  final VoidCallback? onTapPrimary;
  final VoidCallback? onTapMenu;
  final bool compact;

  static const _cream = Color(0xFFF4F0E8);
  static const _ink = Color(0xFF3D4A47);
  static const _gold = Color(0xFFC5922E);
  static const _line = Color(0xFFD5DEDB);
  static const _fabric =
      'assets/images/lessons/read_numbers/post_many_saves.jpg';

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: _cream,
          child: LayoutBuilder(
            builder: (context, c) => _PhoneFrame(
              locale: locale,
              width: c.maxWidth,
              height: c.maxHeight,
              kind: kind,
              onTapPrimary: null,
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: _cream,
                  child: _PhoneFrame(
                    locale: locale,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    kind: kind,
                    onTapPrimary: onTapPrimary,
                    onTapMenu: onTapMenu,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({
    required this.locale,
    required this.width,
    required this.height,
    required this.kind,
    this.onTapPrimary,
    this.onTapMenu,
  });

  final String locale;
  final double width;
  final double height;
  final CreateContentKind kind;
  final VoidCallback? onTapPrimary;
  final VoidCallback? onTapMenu;

  @override
  Widget build(BuildContext context) {
    final phoneW = width * 0.72;
    final phoneH = height * 0.88;
    final left = (width - phoneW) / 2;
    final top = (height - phoneH) / 2;

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: phoneW,
          height: phoneH,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(phoneW * 0.08),
              border: Border.all(color: IgCreateIllustration._ink, width: 2.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(phoneW * 0.07),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (kind == CreateContentKind.post)
                    _PostScreenBody(phoneW: phoneW)
                  else
                    _CreateMenuBody(
                      phoneW: phoneW,
                      highlight: kind == CreateContentKind.story
                          ? _CreateMenuItem.story
                          : _CreateMenuItem.reel,
                    ),
                  if (onTapPrimary != null)
                    _PlusTapOverlay(phoneW: phoneW, onTap: onTapPrimary!),
                  if (onTapMenu != null)
                    _MenuTapOverlay(kind: kind, phoneW: phoneW, onTap: onTapMenu!),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PostScreenBody extends StatelessWidget {
  const _PostScreenBody({required this.phoneW});

  final double phoneW;

  @override
  Widget build(BuildContext context) {
    final pad = phoneW * 0.06;
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, pad * 0.9, pad, pad * 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _goldPlusBadge(size: phoneW * 0.11),
              const Spacer(),
              _bar(w: phoneW * 0.22),
              const Spacer(),
              Icon(
                Icons.favorite_border,
                size: phoneW * 0.07,
                color: IgCreateIllustration._ink,
              ),
              SizedBox(width: phoneW * 0.03),
              Icon(
                Icons.chat_bubble_outline,
                size: phoneW * 0.065,
                color: IgCreateIllustration._ink,
              ),
            ],
          ),
          SizedBox(height: phoneW * 0.05),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) SizedBox(width: phoneW * 0.03),
                Container(
                  width: phoneW * 0.13,
                  height: phoneW * 0.13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i == 0
                          ? IgCreateIllustration._gold
                          : IgCreateIllustration._line,
                      width: i == 0 ? 2 : 1.2,
                    ),
                    color: const Color(0xFFF3F5F4),
                  ),
                  child: i == 0
                      ? Icon(
                          Icons.add,
                          size: phoneW * 0.06,
                          color: IgCreateIllustration._ink,
                        )
                      : null,
                ),
              ],
            ],
          ),
          SizedBox(height: phoneW * 0.04),
          Row(
            children: [
              Container(
                width: phoneW * 0.07,
                height: phoneW * 0.07,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8ECEB),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: phoneW * 0.02),
              _bar(w: phoneW * 0.2, h: phoneW * 0.025),
            ],
          ),
          SizedBox(height: phoneW * 0.03),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const SharpImage(
                IgCreateIllustration._fabric,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: phoneW * 0.04),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              5,
              (_) => Container(
                width: phoneW * 0.1,
                height: phoneW * 0.08,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECEB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CreateMenuItem { post, story, reel }

class _CreateMenuBody extends StatelessWidget {
  const _CreateMenuBody({required this.phoneW, required this.highlight});

  final double phoneW;
  final _CreateMenuItem highlight;

  @override
  Widget build(BuildContext context) {
    final pad = phoneW * 0.06;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _goldPlusBadge(size: phoneW * 0.11),
                  const Spacer(),
                  _bar(w: phoneW * 0.18),
                  const Spacer(),
                  Icon(
                    Icons.favorite_border,
                    size: phoneW * 0.07,
                    color: IgCreateIllustration._ink,
                  ),
                ],
              ),
              SizedBox(height: phoneW * 0.05),
              Row(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (i > 0) SizedBox(width: phoneW * 0.03),
                    Container(
                      width: phoneW * 0.12,
                      height: phoneW * 0.12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i == 0
                              ? IgCreateIllustration._gold
                              : IgCreateIllustration._line,
                          width: i == 0 ? 2 : 1.2,
                        ),
                        color: const Color(0xFFF3F5F4),
                      ),
                      child: i == 0
                          ? Icon(
                              Icons.add,
                              size: phoneW * 0.055,
                              color: IgCreateIllustration._ink,
                            )
                          : null,
                    ),
                  ],
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: phoneW * 0.95,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(pad, pad * 1.2, pad, pad),
            child: Column(
              children: [
                _menuRow(
                  phoneW: phoneW,
                  label: 'Post',
                  icon: Icons.grid_on_rounded,
                  highlighted: highlight == _CreateMenuItem.post,
                ),
                SizedBox(height: phoneW * 0.04),
                _menuRow(
                  phoneW: phoneW,
                  label: 'Story',
                  icon: Icons.history_rounded,
                  highlighted: highlight == _CreateMenuItem.story,
                ),
                SizedBox(height: phoneW * 0.04),
                _menuRow(
                  phoneW: phoneW,
                  label: 'Reel',
                  icon: Icons.movie_creation_outlined,
                  highlighted: highlight == _CreateMenuItem.reel,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuRow({
    required double phoneW,
    required String label,
    required IconData icon,
    required bool highlighted,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: phoneW * 0.04,
        vertical: phoneW * 0.035,
      ),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFF8EE) : const Color(0xFFF6F7F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? IgCreateIllustration._gold
              : IgCreateIllustration._line,
          width: highlighted ? 2.2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: phoneW * 0.08, color: IgCreateIllustration._ink),
          SizedBox(width: phoneW * 0.04),
          Text(
            tr(label),
            style: appType(
              color: IgCreateIllustration._ink,
              fontSize: phoneW * 0.065,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (highlighted) ...[
            const Spacer(),
            Container(
              width: phoneW * 0.09,
              height: phoneW * 0.09,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: IgCreateIllustration._gold,
                shape: BoxShape.circle,
              ),
              child: Text(
                '1',
                style: appType(
                  color: Colors.white,
                  fontSize: phoneW * 0.045,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlusTapOverlay extends StatelessWidget {
  const _PlusTapOverlay({required this.phoneW, required this.onTap});

  final double phoneW;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: phoneW * 0.04,
      top: phoneW * 0.05,
      width: phoneW * 0.14,
      height: phoneW * 0.14,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, customBorder: const CircleBorder()),
      ),
    );
  }
}

class _MenuTapOverlay extends StatelessWidget {
  const _MenuTapOverlay({
    required this.kind,
    required this.phoneW,
    required this.onTap,
  });

  final CreateContentKind kind;
  final double phoneW;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final top = kind == CreateContentKind.story ? 0.52 : 0.68;
    return Positioned(
      left: phoneW * 0.06,
      right: phoneW * 0.06,
      top: phoneW * top,
      height: phoneW * 0.14,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

Widget _goldPlusBadge({required double size}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: IgCreateIllustration._gold, width: 2),
        ),
        child: Icon(
          Icons.add,
          size: size * 0.55,
          color: IgCreateIllustration._ink,
        ),
      ),
      Positioned(
        right: -2,
        top: -2,
        child: Container(
          width: size * 0.42,
          height: size * 0.42,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: IgCreateIllustration._gold,
            shape: BoxShape.circle,
          ),
          child: Text(
            '1',
            style: appType(
              color: Colors.white,
              fontSize: size * 0.22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _bar({required double w, double? h}) {
  return Container(
    width: w,
    height: h ?? w * 0.12,
    decoration: BoxDecoration(
      color: const Color(0xFFE8ECEB),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
