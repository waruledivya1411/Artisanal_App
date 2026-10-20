import 'package:flutter/material.dart';

import 'package:artisnal_app/features/learn/data/create_content_kind.dart';
import 'package:artisnal_app/features/learn/data/create_post_progress.dart';
import 'package:artisnal_app/features/learn/screens/create_post_badge_screen.dart';
import 'package:artisnal_app/features/learn/screens/post_in_instagram_screen.dart';

void onCreatePostKindFinished(
  BuildContext context, {
  required String locale,
  required CreateContentKind kind,
}) {
  CreatePostProgress.completeKind(kind);

  final navigator = Navigator.of(context);
  navigator.pop();
  navigator.pop();
  navigator.pop();

  if (CreatePostProgress.allDone) {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => CreatePostBadgeScreen(locale: locale),
      ),
    );
    return;
  }

  final next = CreatePostProgress.nextKind;
  if (next == null) return;

  navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => PostInInstagramScreen(locale: locale, kind: next),
    ),
  );
}
