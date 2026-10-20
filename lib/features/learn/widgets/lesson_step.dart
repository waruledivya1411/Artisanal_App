import 'package:flutter/material.dart';

class LessonStep extends InheritedWidget {
  const LessonStep({
    super.key,
    required this.nextTitle,
    this.nextLearnTaskTitle,
    this.learnTaskId,
    this.locale,
    this.nextPartHidden = false,
    required this.onFinished,
    required super.child,
  });

  final String? nextTitle;
  final String? nextLearnTaskTitle;
  final String? learnTaskId;
  final String? locale;

  /// Next part exists but is not shown on the task list (e.g. Try it).
  final bool nextPartHidden;
  final VoidCallback onFinished;

  static LessonStep? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LessonStep>();

  Route<void> routeFor(WidgetBuilder builder) {
    return MaterialPageRoute<void>(
      builder: (_) => LessonStep(
        nextTitle: nextTitle,
        nextLearnTaskTitle: nextLearnTaskTitle,
        learnTaskId: learnTaskId,
        locale: locale,
        nextPartHidden: nextPartHidden,
        onFinished: onFinished,
        child: Builder(builder: builder),
      ),
    );
  }

  @override
  bool updateShouldNotify(LessonStep oldWidget) => false;
}
