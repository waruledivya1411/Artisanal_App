import 'package:artisnal_app/features/learn/data/create_content_kind.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';

/// Task 3 — Post, then Story, then Reel (one part each).
class CreatePostProgress {
  CreatePostProgress._();

  static const taskId = 'create_post';
  static const partCount = 3;

  static int get completedCount =>
      LearnProgress.instance.completedParts(taskId);

  static bool isDone(CreateContentKind kind) =>
      completedCount > kind.index;

  static bool get allDone => completedCount >= partCount;

  static CreateContentKind? get nextKind {
    final n = completedCount;
    if (n >= partCount) return null;
    return CreateContentKind.values[n];
  }

  static void completeKind(CreateContentKind kind) {
    LearnProgress.instance.completePart(taskId, kind.index);
    if (allDone) {
      LearnProgress.instance.finishTask(taskId, partCount);
    }
  }
}
