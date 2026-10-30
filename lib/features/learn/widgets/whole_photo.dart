import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Products whose example photos are wider than the cards they sit in.
const wholePhotoProducts = {'Jod kappur', 'Cushion covers'};

/// Shows the whole of [asset] in its box, nothing cut off, with a soft
/// blurred copy of the same photo filling any space around it - so a wide
/// photo in a tall card has no blank bands.
class WholePhoto extends StatelessWidget {
  const WholePhoto(this.asset, {super.key, this.errorBuilder});

  final String asset;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
          ),
        ),
        Image.asset(asset, fit: BoxFit.contain, errorBuilder: errorBuilder),
      ],
    );
  }
}
