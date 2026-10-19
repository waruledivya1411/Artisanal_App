import 'package:flutter/material.dart';

class LessonStep extends InheritedWidget {
  const LessonStep({
    super.key,
    required this.nextTitle,
    required this.onFinished,
    required super.child,
  });

  final String? nextTitle;
  final VoidCallback onFinished;

  static LessonStep? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LessonStep>();

  Route<void> routeFor(WidgetBuilder builder) {
    return MaterialPageRoute<void>(
      builder: (_) => LessonStep(
        nextTitle: nextTitle,
        onFinished: onFinished,
        child: Builder(builder: builder),
      ),
    );
  }

  @override
  bool updateShouldNotify(LessonStep oldWidget) => false;
}
