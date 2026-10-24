import 'package:flutter/material.dart';

import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

enum IgProfileVariant {
  business,
  personalActionsOnly,
}

class IgProfilePreview extends StatelessWidget {
  const IgProfilePreview({
    super.key,
    required this.variant,
    this.locale = 'en-US',
    this.compact = false,
    this.quizCard = false,
    this.onDashboardTap,
    this.highlightDashboard = false,
  });

  final IgProfileVariant variant;
  final String locale;
  final bool compact;
  final bool quizCard;
  final VoidCallback? onDashboardTap;
  final bool highlightDashboard;

  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color gold = Color(0xFFC5922E);

  static const _posts = [
    'assets/images/lessons/read_numbers/post_many_saves.jpg',
    'assets/images/lessons/read_numbers/reply_cloth_post.jpg',
    'assets/images/lessons/photography/fabric_straight.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final pad = quizCard ? 10.0 : (compact ? 8.0 : 14.0);
    final avatar = quizCard ? 46.0 : (compact ? 40.0 : 52.0);
    final nameSize = quizCard ? 14.0 : (compact ? 12.0 : 15.0);
    final bioSize = quizCard ? 11.5 : (compact ? 10.0 : 13.0);
    final tight = compact || quizCard;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(quizCard ? 12 : (compact ? 14 : 22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SharpImage(
                    'assets/images/lessons/set_up_page/profile_clear.jpg',
                    width: avatar,
                    height: avatar,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: tight ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'divya.weaves',
                        style: appType(
                          color: ink,
                          fontSize: nameSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: tight ? 4 : 6),
                      if (quizCard)
                        const _QuizStatsRow()
                      else
                        Row(
                          children: [
                            _Stat('12', 'posts', compact: tight),
                            _Stat('86', 'followers', compact: tight),
                            _Stat('4', 'following', compact: tight),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: tight ? 6 : 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${tr('Divya Warule')}\n${tr('Handwoven cloth · Sualkuchi, Assam')}',
                style: appType(
                  color: ink,
                  fontSize: bioSize,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
            if (variant == IgProfileVariant.business) ...[
              SizedBox(height: tight ? 6 : 10),
              _DashboardButton(
                compact: tight,
                quizCard: quizCard,
                highlight: highlightDashboard,
                onTap: onDashboardTap,
              ),
            ],
            SizedBox(height: tight ? 6 : 8),
            Row(
              children: [
                _ProfileButton(
                  quizCard ? 'Edit' : 'Edit profile',
                  compact: tight,
                  quizCard: quizCard,
                ),
                SizedBox(width: tight ? 4 : 6),
                _ProfileButton(
                  quizCard ? 'Share' : 'Share profile',
                  compact: tight,
                  quizCard: quizCard,
                ),
                if (variant == IgProfileVariant.business) ...[
                  SizedBox(width: tight ? 4 : 6),
                  _ProfileButton(
                    'Contact',
                    compact: tight,
                    quizCard: quizCard,
                  ),
                ],
              ],
            ),
            if (!quizCard) ...[
              SizedBox(height: tight ? 6 : 10),
              Row(
                children: [
                  for (var i = 0; i < _posts.length; i++) ...[
                    if (i > 0) SizedBox(width: tight ? 4 : 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(tight ? 5 : 8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SharpImage(_posts[i], fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  const _DashboardButton({
    required this.compact,
    this.quizCard = false,
    required this.highlight,
    this.onTap,
  });

  final bool compact;
  final bool quizCard;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: quizCard ? 8 : (compact ? 8 : 12),
        vertical: quizCard ? 8 : (compact ? 6 : 8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(quizCard ? 8 : (compact ? 8 : 12)),
        border: Border.all(
          color: IgProfilePreview.gold,
          width: highlight ? 2.2 : 1.6,
        ),
        boxShadow: highlight
            ? const [
                BoxShadow(
                  color: Color(0x33C5922E),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            tr('Professional dashboard'),
            style: appType(
              color: IgProfilePreview.ink,
              fontSize: quizCard ? 12 : (compact ? 11 : 14),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: compact ? 1 : 2),
          Text(
            quizCard
                ? tr('Tools for businesses.')
                : tr('Tools and resources just for businesses.'),
            textAlign: TextAlign.center,
            style: appType(
              color: IgProfilePreview.muted,
              fontSize: quizCard ? 9.5 : (compact ? 8 : 11),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton(
    this.label, {
    required this.compact,
    this.quizCard = false,
  });

  final String label;
  final bool compact;
  final bool quizCard;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: quizCard ? 28 : (compact ? 24 : 30),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(compact ? 6 : 8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            tr(label),
            style: appType(
              color: IgProfilePreview.ink,
              fontSize: quizCard ? 10 : (compact ? 9 : 12),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizStatsRow extends StatelessWidget {
  const _QuizStatsRow();

  static const _stats = [
    ('12', 'posts'),
    ('86', 'followers'),
    ('4', 'following'),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _stats.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              _StatColumn(
                value: _stats[i].$1,
                label: _stats[i].$2,
                valueSize: 12,
                labelSize: 9,
                align: CrossAxisAlignment.start,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.valueSize,
    required this.labelSize,
    this.align = CrossAxisAlignment.center,
  });

  final String value;
  final String label;
  final double valueSize;
  final double labelSize;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        Text(
          value,
          maxLines: 1,
          style: appType(
            color: IgProfilePreview.ink,
            fontSize: valueSize,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        Text(
          tr(label),
          maxLines: 1,
          softWrap: false,
          style: appType(
            color: IgProfilePreview.muted,
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
    this.value,
    this.label, {
    required this.compact,
  });

  final String value;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _StatColumn(
        value: value,
        label: label,
        valueSize: compact ? 10 : 13,
        labelSize: compact ? 8 : 10,
        align: CrossAxisAlignment.start,
      ),
    );
  }
}
