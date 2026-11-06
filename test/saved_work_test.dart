import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/data/saved_work.dart';
import 'package:artisnal_app/features/learn/screens/setup_try_it_flow_screen.dart';
import 'package:artisnal_app/features/learn/screens/write_caption_screen.dart';
import 'package:artisnal_app/features/learn/widgets/lesson_step.dart';
import 'package:artisnal_app/features/me/screens/me_screen.dart';

void main() {
  setUp(() {
    AppLang.current = 'en-US';
    SavedWork.instance.reset();
    LearnProgress.instance.reset();
  });
  tearDown(() {
    SavedWork.instance.reset();
    LearnProgress.instance.reset();
  });

  Future<void> pumpTall(WidgetTester t, Widget home) async {
    t.view.physicalSize = const Size(800, 1600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    await t.pumpWidget(MaterialApp(home: home));
    await t.pump();
  }

  test('ideas fit Instagram and are translated in every language', () {
    for (final idea in bioIdeas) {
      expect(idea.length, lessThanOrEqualTo(150), reason: idea);
    }
    for (final lang in ['as-IN', 'or-IN', 'te-IN']) {
      AppLang.current = lang;
      for (final idea in [...bioIdeas, ...captionIdeas]) {
        expect(tr(idea), isNot(idea), reason: '$lang: $idea');
      }
      for (final idea in bioIdeas) {
        expect(tr(idea).length, lessThanOrEqualTo(150), reason: idea);
      }
    }
  });

  test('work and badges come back when the app opens again', () async {
    SharedPreferences.setMockInitialValues({});
    await loadSavedData();
    SavedWork.instance.saveCaption('My own caption');
    SavedWork.instance.savePage(
      name: 'Divya',
      username: 'divya.weaves',
      category: 'Artist',
      bio: 'My own bio',
    );
    LearnProgress.instance.finishTask(aiPhotosTaskId, 2);

    // As if closed: memory is gone, what was stored stays.
    final stored = await SharedPreferences.getInstance();
    final kept = {for (final key in stored.getKeys()) key: stored.get(key)!};
    SavedWork.instance.reset();
    LearnProgress.instance.reset();
    expect(SavedWork.instance.bio, isNull);
    SharedPreferences.setMockInitialValues(kept);

    await loadSavedData();
    expect(SavedWork.instance.caption, 'My own caption');
    expect(SavedWork.instance.captions, ['My own caption']);
    expect(SavedWork.instance.bio, 'My own bio');
    expect(SavedWork.instance.category, 'Artist');
    expect(LearnProgress.instance.isLearnTaskComplete(aiPhotosTaskId), isTrue);
  });

  testWidgets('Me shows the badges in one row, then captions and bio', (
    t,
  ) async {
    String? copied;
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    SavedWork.instance.saveCaption('First caption');
    SavedWork.instance.saveCaption('Second caption');
    SavedWork.instance.savePage(name: 'Divya', bio: 'My own bio');
    LearnProgress.instance.finishTask(LearnTaskChain.createPostTaskId, 3);
    await pumpTall(t, const Scaffold(body: MeScreen(locale: 'en-US')));

    // Every badge sits on one line.
    final row = find.byKey(const ValueKey('badge-row'));
    expect(row, findsOneWidget);
    final tops = {
      for (final id in LearnTaskChain.taskOrder.take(4))
        t.getTopLeft(find.text(LearnTaskChain.titleFor(id))).dy.round(),
    };
    expect(tops.length, 1);

    // Only the two kinds of saved work, newest caption first.
    expect(find.text('Saved captions'), findsOneWidget);
    expect(find.text('Saved bio'), findsOneWidget);
    expect(find.text('Your last prompt'), findsNothing);
    expect(
      t.getTopLeft(find.text('Second caption')).dy,
      lessThan(t.getTopLeft(find.text('First caption')).dy),
    );
    expect(find.text('Caption ideas'), findsOneWidget);
    expect(find.text(captionIdeas.first), findsOneWidget);
    expect(find.text('My own bio'), findsOneWidget);
    expect(find.text('Divya'), findsOneWidget);
    expect(find.text('Bio ideas'), findsOneWidget);
    expect(
      t.getTopLeft(find.text('Saved captions')).dy,
      lessThan(t.getTopLeft(find.text('Saved bio')).dy),
    );

    await t.tap(find.text('Copy').first);
    await t.pump();
    expect(copied, 'Second caption');
    expect(find.text('Copied'), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    expect(find.text('Copied'), findsNothing);

    // The bio ideas run on below.
    await t.scrollUntilVisible(
      find.text(bioIdeas.last),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(bioIdeas.last), findsOneWidget);
  });

  testWidgets('with nothing saved, Me still offers ideas', (t) async {
    await pumpTall(t, const Scaffold(body: MeScreen(locale: 'en-US')));
    expect(find.text('Nothing saved yet.'), findsNWidgets(2));
    expect(find.text(captionIdeas.first), findsOneWidget);
    expect(find.text(bioIdeas.first), findsOneWidget);
  });

  test('captions keep the newest few, without repeats', () {
    for (var i = 0; i < 7; i++) {
      SavedWork.instance.saveCaption('Caption $i');
    }
    SavedWork.instance.saveCaption('Caption 4');
    expect(SavedWork.instance.captions, [
      'Caption 4',
      'Caption 6',
      'Caption 5',
      'Caption 3',
      'Caption 2',
    ]);
    expect(SavedWork.instance.caption, 'Caption 4');
  });

  testWidgets('name and bio are practised together and saved', (t) async {
    var finished = false;
    await pumpTall(
      t,
      LessonStep(
        nextTitle: 'Clear photo',
        learnTaskId: setUpPageTaskId,
        locale: 'en-US',
        onFinished: () => finished = true,
        child: const SetupTryItFlowScreen(
          locale: 'en-US',
          practice: SetupPractice.nameAndBio,
        ),
      ),
    );
    expect(find.text('Pick your name'), findsOneWidget);
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    expect(find.text('PRACTICE · LIKE INSTAGRAM'), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
    expect(find.textContaining('professional'), findsNothing);

    await t.enterText(find.byType(TextField).last, 'My own bio');
    await t.pump();
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    expect(finished, isTrue);
    expect(SavedWork.instance.bio, 'My own bio');
    expect(SavedWork.instance.username, 'divya.weaves');
  });

  testWidgets('the professional practice has no name or bio to fill', (
    t,
  ) async {
    SavedWork.instance.savePage(
      name: 'Divya',
      username: 'divya.real',
      bio: 'My own bio',
    );
    await pumpTall(
      t,
      LessonStep(
        nextTitle: null,
        nextLearnTaskTitle: 'Create a post',
        learnTaskId: setUpPageTaskId,
        locale: 'en-US',
        onFinished: () {},
        child: const SetupTryItFlowScreen(
          locale: 'en-US',
          practice: SetupPractice.professional,
        ),
      ),
    );
    expect(find.text('PRACTICE · LIKE INSTAGRAM'), findsNothing);
    expect(find.text('Pick your name'), findsNothing);
    expect(find.byType(TextField), findsNothing);

    // The finished page shows what was written in the first practice.
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    expect(find.text('My own bio'), findsOneWidget);
    expect(find.text('Finish'), findsOneWidget);
  });

  testWidgets('writing a caption saves it and moves on', (t) async {
    await pumpTall(
      t,
      WriteCaptionScreen(
        nextBuilder: (_) => const Scaffold(body: Text('NEXT PAGE')),
      ),
    );
    await t.tap(find.text('Continue'));
    await t.pump();
    expect(find.text('NEXT PAGE'), findsNothing);

    await t.tap(find.text(captionIdeas[1]));
    await t.pump();
    expect(
      t
          .widget<TextField>(find.byKey(const ValueKey('caption-text')))
          .controller!
          .text,
      captionIdeas[1],
    );

    await t.enterText(find.byKey(const ValueKey('caption-text')), ' Mine ');
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.text('NEXT PAGE'), findsOneWidget);
    expect(SavedWork.instance.caption, 'Mine');
  });
}
