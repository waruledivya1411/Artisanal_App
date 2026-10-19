import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class SharpImage extends StatelessWidget {
  const SharpImage(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w =
            width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);
        final h =
            height ??
            (constraints.hasBoundedHeight ? constraints.maxHeight : null);
        final ratio = MediaQuery.devicePixelRatioOf(context);

        ImageProvider provider = AssetImage(asset);
        if (w != null && h != null && w > 0 && h > 0) {
          // Cover crops one side, so decode against the longer side to keep both
          // dimensions at or above the painted size.
          final boxW = fit == BoxFit.cover ? math.max(w, h) : w;
          final boxH = fit == BoxFit.cover ? math.max(w, h) : h;
          provider = ResizeImage(
            provider,
            width: (boxW * ratio).round(),
            height: (boxH * ratio).round(),
            policy: ResizeImagePolicy.fit,
          );
        }

        return Image(
          image: provider,
          width: width,
          height: height,
          fit: fit,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        );
      },
    );
  }
}
