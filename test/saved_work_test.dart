import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/data/saved_work.dart';
import 'package:artisnal_app/features/learn/screens/write_caption_screen.dart';
import 'package:artisnal_app/features/me/screens/badge_work_screen.dart';
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
    t.view.physicalSize = const Size(390, 1600);
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
    LearnProgress.instance.finishTask(aiPhotosTaskId, 1);

    // As if closed: memory is gone, what was stored stays.
    final stored = await SharedPreferences.getInstance();
    final kept = {for (final key in stored.getKeys()) key: stored.get(key)!};
    SavedWork.instance.reset();
    LearnProgress.instance.reset();
    expect(SavedWork.instance.bio, isNull);
    SharedPreferences.setMockInitialValues(kept);

    await loadSavedData();
    expect(SavedWork.instance.caption, 'My own caption');
    expect(SavedWork.instance.bio, 'My own bio');
    expect(SavedWork.instance.category, 'Artist');
    expect(LearnProgress.instance.isLearnTaskComplete(aiPhotosTaskId), isTrue);
  });

  testWidgets('only an earned badge opens', (t) async {
    SavedWork.instance.saveCaption('My own caption');
    LearnProgress.instance.finishTask(LearnTaskChain.createPostTaskId, 3);
    await pumpTall(t, const Scaffold(body: MeScreen(locale: 'en-US')));

    await t.tap(find.text('Photography'));
    await t.pumpAndSettle();
    expect(find.text('Your caption'), findsNothing);

    await t.tap(find.text('Create a post'));
    await t.pumpAndSettle();
    expect(find.text('Your caption'), findsOneWidget);
    expect(find.text('My own caption'), findsOneWidget);
    expect(find.text('Caption ideas'), findsOneWidget);
    expect(find.text(captionIdeas.first), findsOneWidget);
  });

  testWidgets('the page badge shows their bio and copies it', (t) async {
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
    SavedWork.instance.savePage(
      name: 'Divya',
      username: 'divya.weaves',
      category: 'Artist',
      bio: 'My own bio',
    );
    await pumpTall(t, const BadgeWorkScreen(taskId: setUpPageTaskId));

    expect(find.text('Your work'), findsOneWidget);
    expect(find.text('divya.weaves'), findsOneWidget);
    expect(find.text('Artist'), findsOneWidget);
    expect(find.text('My own bio'), findsOneWidget);
    expect(find.text('Bio ideas'), findsOneWidget);
    expect(find.text(bioIdeas.last), findsOneWidget);

    await t.tap(find.text('Copy').first);
    await t.pump();
    expect(copied, 'My own bio');
    expect(find.text('Copied'), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    expect(find.text('Copied'), findsNothing);
  });

  testWidgets('a badge with no saved work says so and still helps', (t) async {
    await pumpTall(
      t,
      const BadgeWorkScreen(taskId: LearnTaskChain.createPostTaskId),
    );
    expect(find.text('Nothing saved yet.'), findsOneWidget);
    expect(find.text(captionIdeas.first), findsOneWidget);
  });

  testWidgets('badges with nothing to write open without lists', (t) async {
    await pumpTall(t, const BadgeWorkScreen(taskId: photographyTaskId));
    expect(find.text('Photography'), findsOneWidget);
    expect(find.text('Sharp photos sell better'), findsOneWidget);
    expect(find.text('Copy'), findsNothing);
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
