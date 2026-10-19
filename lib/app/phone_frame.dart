import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  static const double _width = 390;
  static const double _height = 844;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (!kIsWeb || media.size.width <= 600) return child;

    final height = math.min(_height, media.size.height - 32);
    const radius = BorderRadius.all(Radius.circular(28));

    return ColoredBox(
      color: const Color(0xFFE3E8E6),
      child: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: SizedBox(
              width: _width,
              height: height,
              child: MediaQuery(
                data: media.copyWith(
                  size: Size(_width, height),
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                  viewInsets: EdgeInsets.zero,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
