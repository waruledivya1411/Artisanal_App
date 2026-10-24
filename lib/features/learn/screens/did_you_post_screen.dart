import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/core/theme/button_shadow.dart';
import 'package:artisnal_app/core/widgets/sharp_image.dart';
import 'package:artisnal_app/features/learn/create_post_flow.dart';
import 'package:artisnal_app/features/learn/data/create_content_kind.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class DidYouPostScreen extends StatelessWidget {
  const DidYouPostScreen({
    super.key,
    required this.photoAsset,
    required this.locale,
    required this.kind,
    this.isVideo = false,
  });

  final String photoAsset;
  final String locale;
  final CreateContentKind kind;
  final bool isVideo;

  static const Color sheetGrey = Color(0xFF8E9895);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: sheetGrey,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: sheetGrey,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Spacer(),
              Expanded(
                flex: 11,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              width: 168,
                              height: 200,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  SharpImage(photoAsset, fit: BoxFit.cover),
                                  if (isVideo)
                                    const ColoredBox(
                                      color: Color(0x33000000),
                                      child: Center(
                                        child: Icon(
                                          Icons.play_circle_fill_rounded,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          tr('Did you post it?'),
                          textAlign: TextAlign.center,
                          style: appType(
                            color: ink,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr('Look at your Instagram page'),
                          textAlign: TextAlign.center,
                          style: appType(
                            color: muted,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: kPrimaryButtonShadow,
                          ),
                          child: Material(
                            color: teal,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () => onCreatePostKindFinished(
                                context,
                                locale: locale,
                                kind: kind,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      tr('Yes, I posted'),
                                      style: appType(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: const Color(0xFFD5DEDB)),
                          ),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    color: teal,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tr('Show me again'),
                                    style: appType(
                                      color: teal,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
