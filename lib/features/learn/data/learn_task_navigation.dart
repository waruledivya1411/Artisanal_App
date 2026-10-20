import 'package:flutter/material.dart';

import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/screens/choose_content_type_screen.dart';
import 'package:artisnal_app/features/learn/screens/photo_access_screen.dart';

/// Opens Learn tasks and jumps to the next task after finishing one.
class LearnTaskNavigation {
  LearnTaskNavigation._();

  static const learnHomeRoute = 'learn-home';

  static void open(
    BuildContext context,
    String taskId,
    String locale,
  ) {
    final route = _routeFor(taskId, locale);
    if (route != null) {
      Navigator.of(context).push(route);
    }
  }

  static Route<void>? _routeFor(String taskId, String locale) {
    return switch (taskId) {
      photographyTaskId => MaterialPageRoute<void>(
          settings: const RouteSettings(name: photographySetupRoute),
          builder: (_) => photographyEntry(locale),
        ),
      setUpPageTaskId => MaterialPageRoute<void>(
          builder: (_) => setUpPageTask(locale),
        ),
      LearnTaskChain.createPostTaskId => MaterialPageRoute<void>(
          builder: (_) => PhotoAccessScreen(
            locale: locale,
            nextBuilder: (_) => ChooseContentTypeScreen(locale: locale),
          ),
        ),
      postingPlanTaskId => MaterialPageRoute<void>(
          builder: (_) => postingPlanTask(locale),
        ),
      readNumbersTaskId => MaterialPageRoute<void>(
          builder: (_) => readNumbersTask(locale),
        ),
      _ => null,
    };
  }

  static void popToLearnHome(NavigatorState navigator) {
    navigator.popUntil(
      (route) =>
          route.settings.name == learnHomeRoute || route.isFirst,
    );
  }

  /// Runs [finishLesson] (e.g. `LessonStep.onFinished`), then opens the next task.
  static void finishLessonAndOpenNext({
    required NavigatorState navigator,
    required String finishedTaskId,
    required String locale,
    required VoidCallback finishLesson,
  }) {
    final nextId = LearnTaskChain.nextTaskId(finishedTaskId);
    finishLesson();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popToLearnHome(navigator);
      if (nextId != null) {
        open(navigator.context, nextId, locale);
      }
    });
  }

  /// Pops a badge dialog, finishes the lesson, then opens the next task.
  static void dismissBadgeFinishAndOpenNext({
    required BuildContext badgeContext,
    required NavigatorState lessonNavigator,
    required String finishedTaskId,
    required String locale,
    required VoidCallback finishLesson,
  }) {
    Navigator.of(badgeContext).pop();
    finishLessonAndOpenNext(
      navigator: lessonNavigator,
      finishedTaskId: finishedTaskId,
      locale: locale,
      finishLesson: finishLesson,
    );
  }
}
