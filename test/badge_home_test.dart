import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_task_navigation.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/screens/check_part_screen.dart';
import 'package:artisnal_app/features/learn/screens/create_post_badge_screen.dart';
import 'package:artisnal_app/features/learn/screens/find_numbers_screen.dart';
import 'package:artisnal_app/features/learn/screens/lesson_badge_screen.dart';
import 'package:artisnal_app/features/learn/widgets/lesson_step.dart';

/// A home page, then a list page, then [page] on top of them.
Future<void> open(WidgetTester t, WidgetBuilder page) async {
  t.view.physicalSize = const Size(800, 1400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  await t.pumpWidget(
    MaterialApp(
      initialRoute: LearnTaskNavigation.learnHomeRoute,
      routes: {
        LearnTaskNavigation.learnHomeRoute: (_) => Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      body: Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).push(MaterialPageRoute<void>(builder: page)),
                          child: const Text('LIST PAGE'),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('HOME PAGE'),
              ),
            ),
          ),
        ),
      },
    ),
  );
  await t.tap(find.text('HOME PAGE'));
  await t.pumpAndSettle();
  await t.tap(find.text('LIST PAGE'));
  await t.pump();
  await t.pump(const Duration(milliseconds: 400));
}

Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  setUp(() {
    AppLang.current = 'en-US';
    LearnProgress.instance.reset();
  });
  tearDown(LearnProgress.instance.reset);

  LessonStep lastStep(BuildContext context, Widget child, String taskId) {
    return LessonStep(
      nextTitle: null,
      nextLearnTaskTitle: LearnTaskChain.nextTaskTitle(taskId),
      learnTaskId: taskId,
      locale: 'en-US',
      onFinished: () => Navigator.of(context).pop(),
      child: Builder(builder: (_) => child),
    );
  }

  testWidgets('the numbers badge offers the next task and home', (t) async {
    await open(
      t,
      (context) => lastStep(
        context,
        const FindNumbersScreen(
          locale: 'en-US',
          taskId: readNumbersTaskId,
          partCount: 3,
        ),
        readNumbersTaskId,
      ),
    );
    await t.tap(find.text('Complete'));
    await t.pump();
    expect(find.text('Badge earned'), findsOneWidget);
    expect(find.text('Next task: AI photos'), findsOneWidget);
    await t.tap(find.text('Go to home'));
    await settle(t);
    expect(find.text('HOME PAGE'), findsOneWidget);
    expect(find.text('LIST PAGE'), findsNothing);
    expect(
      LearnProgress.instance.isLearnTaskComplete(readNumbersTaskId),
      isTrue,
    );
  });

  testWidgets('the numbers badge really opens AI photos next', (t) async {
    await open(
      t,
      (context) => lastStep(
        context,
        const FindNumbersScreen(
          locale: 'en-US',
          taskId: readNumbersTaskId,
          partCount: 3,
        ),
        readNumbersTaskId,
      ),
    );
    await t.tap(find.text('Complete'));
    await t.pump();
    await t.tap(find.text('Next task: AI photos'));
    await settle(t);
    expect(find.text('Which product is it?'), findsOneWidget);
  });

  testWidgets('the last page of a lesson task offers home', (t) async {
    await open(
      t,
      (context) => lastStep(
        context,
        CheckPartScreen(
          locale: 'en-US',
          partLabel: 'PART',
          wrong: const CheckOption(
            image: 'assets/images/lessons/photography/cotton_side_light.jpg',
            label: 'Wrong one',
          ),
          right: const CheckOption(
            image: 'assets/images/lessons/photography/cotton_soft_front.jpg',
            label: 'Right one',
          ),
          rightReason: 'Yes',
          wrongReason: 'No',
        ),
        photographyTaskId,
      ),
    );
    await t.tap(find.text('Right one'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Next task'), findsNothing);
    await t.tap(find.text('Finish'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Badge earned'), findsOneWidget);
    expect(find.text('Next task: Set up your page'), findsOneWidget);
    await t.tap(find.text('Go to home'));
    await settle(t);
    expect(find.text('HOME PAGE'), findsOneWidget);
  });

  // The real tasks, played to their real endings.
  Future<void> reachBadge(WidgetTester t, Future<void> Function() play) async {
    await play();
    await t.tap(find.text('Finish'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Badge earned'), findsOneWidget);
    expect(find.text('Go to home'), findsOneWidget);
  }

  Future<void> quizToFinish(WidgetTester t, String part) async {
    await t.tap(find.text(part));
    await t.pumpAndSettle();
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    await t.tap(find.text('B'));
    await t.pumpAndSettle();
  }

  // Step lines were small bars; only the Learn home keeps one.
  Finder stepLines() => find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    final height = widget.constraints?.maxHeight;
    return height == 6 || height == 7;
  });

  testWidgets('task pages and lessons have no step lines', (t) async {
    LearnProgress.instance.completePart(postingPlanTaskId, 0);
    LearnProgress.instance.completePart(postingPlanTaskId, 1);
    await open(t, (_) => postingPlanTask('en-US'));
    expect(find.text('Mix posts'), findsOneWidget);
    expect(stepLines(), findsNothing);

    await t.tap(find.text('Mix posts'));
    await t.pumpAndSettle();
    expect(stepLines(), findsNothing);

    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    expect(find.text('Which is better?'), findsOneWidget);
    expect(stepLines(), findsNothing);
  });

  testWidgets('the numbers pages have no step lines', (t) async {
    await open(
      t,
      (_) => const FindNumbersScreen(
        locale: 'en-US',
        taskId: readNumbersTaskId,
        partCount: 3,
      ),
    );
    expect(find.text('Find your numbers'), findsOneWidget);
    expect(stepLines(), findsNothing);
  });

  testWidgets('Posting plan ends on a badge that can go home', (t) async {
    LearnProgress.instance.completePart(postingPlanTaskId, 0);
    LearnProgress.instance.completePart(postingPlanTaskId, 1);
    await open(t, (_) => postingPlanTask('en-US'));
    await reachBadge(t, () => quizToFinish(t, 'Mix posts'));
    expect(
      LearnProgress.instance.isLearnTaskComplete(postingPlanTaskId),
      isTrue,
    );
    await t.tap(find.text('Go to home'));
    await settle(t);
    expect(find.text('HOME PAGE'), findsOneWidget);
    expect(find.text('Saves matter'), findsNothing);
  });

  testWidgets('Posting plan badge can still go on to the next task', (t) async {
    LearnProgress.instance.completePart(postingPlanTaskId, 0);
    LearnProgress.instance.completePart(postingPlanTaskId, 1);
    await open(t, (_) => postingPlanTask('en-US'));
    await reachBadge(t, () => quizToFinish(t, 'Mix posts'));
    await t.tap(find.text('Next task: Read the numbers'));
    await settle(t);
    expect(find.text('Saves matter'), findsOneWidget);
  });

  testWidgets('Photography ends on a badge that can go home', (t) async {
    for (var i = 0; i < 5; i++) {
      LearnProgress.instance.completePart(photographyTaskId, i);
    }
    await open(t, (_) => photographyTask('en-US'));
    expect(find.text('Light for silk'), findsOneWidget);
    await reachBadge(t, () => quizToFinish(t, 'Light for silk'));
    expect(find.text('Sharp photos sell better'), findsOneWidget);
    await t.tap(find.text('Go to home'));
    await settle(t);
    expect(find.text('HOME PAGE'), findsOneWidget);
  });

  testWidgets('Set up your page ends on a badge that can go home', (t) async {
    await open(t, (_) => setUpPageTask('en-US'));
    await reachBadge(t, () async {
      await t.tap(find.text('Professional'));
      await t.pumpAndSettle();
      await t.tap(find.text('Professional dashboard').first);
      await t.pumpAndSettle();
      await t.tap(find.text('B'));
      await t.pumpAndSettle();
      await t.tap(find.text('Next'));
      await t.pumpAndSettle();
      expect(find.text('Pick your name'), findsNothing);
      for (var i = 0; i < 6 && find.text('Finish').evaluate().isEmpty; i++) {
        await t.tap(find.byIcon(Icons.chevron_right_rounded).last);
        await t.pumpAndSettle();
      }
    });
    await t.tap(find.text('Go to home'));
    await settle(t);
    expect(find.text('HOME PAGE'), findsOneWidget);
    expect(LearnProgress.instance.isLearnTaskComplete(setUpPageTaskId), isTrue);
  });

  testWidgets('the shared badge shows home only beside a next task', (t) async {
    var home = 0;
    await open(
      t,
      (_) => LessonBadgeScreen(
        title: 'Set up your page',
        subtitle: 'Done',
        nextLearnTaskTitle: 'Create a post',
        onContinue: () {},
        onHome: () => home++,
      ),
    );
    await t.tap(find.text('Go to home'));
    expect(home, 1);

    await t.pumpWidget(
      MaterialApp(
        key: const ValueKey('no next task'),
        home: LessonBadgeScreen(
          title: 'AI photos',
          subtitle: 'Done',
          onContinue: () {},
          onHome: () => home++,
        ),
      ),
    );
    await t.pump();
    expect(find.text('Go to home'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('the create a post badge offers home', (t) async {
    await open(t, (_) => const CreatePostBadgeScreen(locale: 'en-US'));
    expect(find.text('Next task: Posting plan'), findsOneWidget);
    await t.tap(find.text('Go to home'));
    await settle(t);
    expect(find.text('HOME PAGE'), findsOneWidget);
  });
}
