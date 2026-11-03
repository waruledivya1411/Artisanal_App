import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/learn/data/ai_prompts.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/data/products.dart';
import 'package:artisnal_app/features/learn/screens/ai_photos_screen.dart';

int wordsIn(String text) => text.trim().split(RegExp(r'\s+')).length;

void main() {
  test('every prompt for every product is short and protects the product', () {
    for (final product in photographyProducts) {
      final displays = aiDisplaysFor(product.name);
      final props = aiPropsFor(product.name);
      expect(displays, isNotEmpty, reason: product.name);
      expect(props, isNotEmpty, reason: product.name);

      for (final goal in [AiGoal.cleanBackground, AiGoal.betterLight]) {
        final prompt = buildAiPrompt(product: product.name, goal: goal);
        expect(prompt, startsWith('Edit my photo.'));
        expect(
          prompt,
          contains('keep the same motifs, border, colours and weave'),
        );
        expect(wordsIn(prompt), lessThanOrEqualTo(35), reason: prompt);
      }

      void check(AiGoal goal, List<AiChoice> choices) {
        for (final choice in choices) {
          expect(choice.label.toLowerCase(), isNot(contains('close')));
          final prompt = buildAiPrompt(
            product: product.name,
            goal: goal,
            scene: choice.label,
          );
          expect(prompt, startsWith('Photo 1 shows my handwoven'));
          expect(prompt, contains('Photo 2 shows its motif up close.'));
          expect(prompt, contains(choice.line));
          expect(prompt, contains('exactly from my photos'));
          expect(wordsIn(prompt), lessThanOrEqualTo(70), reason: prompt);
        }
      }

      check(AiGoal.newDisplay, displays);
      check(AiGoal.addProps, props);
    }
  });

  test('each product offers exactly the props chosen for it', () {
    const expected = {
      'Saree': ['Mannequin', 'Wooden hanger', 'Chair', 'Festive setting'],
      'Mekhala sador': [
        'Mannequin',
        'Wooden hanger',
        'Chair',
        'Festive setting',
      ],
      'Gamusa': ['Wooden hanger'],
      'Stole': ['Wooden hanger'],
      'Shawl': ['Wooden hanger'],
      'Cushion covers': ['Sofa'],
    };
    expected.forEach((product, labels) {
      expect(
        [for (final item in aiPropsFor(product)) item.label],
        labels,
        reason: product,
      );
    });
  });

  test('a scene never names another product', () {
    const names = {
      'Saree': 'saree',
      'Stole': 'stole',
      'Gamusa': 'gamusa',
      'Shawl': 'shawl',
      'Jod kappur': 'jod kappur',
      'Cushion covers': 'cushion',
      'Yardages': 'fabric',
    };
    for (final product in photographyProducts) {
      for (final choice in [
        ...aiDisplaysFor(product.name),
        ...aiPropsFor(product.name),
      ]) {
        for (final entry in names.entries) {
          if (entry.key == product.name) continue;
          expect(
            choice.line.toLowerCase(),
            isNot(contains(entry.value)),
            reason: '${product.name}: ${choice.line}',
          );
        }
      }
    }
  });

  testWidgets('a new display says which 2 photos it needs', (t) async {
    AppLang.current = 'en-US';
    t.view.physicalSize = const Size(390, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
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
    await t.pumpWidget(
      const MaterialApp(home: AiPhotosScreen(locale: 'en-US')),
    );

    await t.tap(find.text('Continue'));
    await t.pump();
    expect(find.text('Which product is it?'), findsOneWidget);
    await t.tap(find.text('Cushion covers'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();

    // Only what a cushion can have is offered.
    expect(find.text('Sofa-Seated, Flat-Lay'), findsOneWidget);
    await t.tap(find.text('New display'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();
    expect(find.text('What do you want?'), findsOneWidget);
    await t.tap(find.text('Sofa-Seated'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();

    expect(find.text('Your prompt'), findsOneWidget);
    expect(find.text('You need these 2 photos'), findsOneWidget);
    expect(find.text('Full photo'), findsOneWidget);
    expect(find.text('Close-up of the motif'), findsOneWidget);
    expect(
      find.text('Attach the full photo, then the close-up'),
      findsOneWidget,
    );
    await t.tap(find.text('Copy prompt'));
    await t.pump();
    expect(copied, contains('neutral sofa'));
    expect(copied, contains('Photo 2 shows its motif up close.'));
    expect(find.text('Prompt copied'), findsOneWidget);

    // Back steps one page at a time and keeps the answers.
    await t.pump(const Duration(seconds: 5));
    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pump();
    expect(find.text('What do you want?'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('each page opens at the top on a small screen', (t) async {
    AppLang.current = 'en-US';
    t.view.physicalSize = const Size(320, 568);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    await t.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.6)),
          child: child!,
        ),
        home: const AiPhotosScreen(locale: 'en-US'),
      ),
    );
    await t.pump();
    final list = find.byType(Scrollable).first;

    Future<void> scrollToAndTap(String text) async {
      await t.scrollUntilVisible(find.text(text), 120, scrollable: list);
      await t.pump();
      await t.ensureVisible(find.text(text));
      await t.pump();
      await t.tap(find.text(text));
      await t.pump();
    }

    await scrollToAndTap('Saree');
    await t.tap(find.text('Continue'));
    await t.pump();

    await scrollToAndTap('Add props');
    await scrollToAndTap('Festive setting');
    expect(t.state<ScrollableState>(list).position.pixels, greaterThan(0));

    await t.tap(find.text('Continue'));
    await t.pump();
    expect(find.text('Your prompt'), findsOneWidget);
    expect(t.state<ScrollableState>(list).position.pixels, 0);
  });

  testWidgets('fixing one photo does not ask for two', (t) async {
    AppLang.current = 'en-US';
    t.view.physicalSize = const Size(390, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    await t.pumpWidget(
      const MaterialApp(home: AiPhotosScreen(locale: 'en-US')),
    );
    await t.tap(find.text('Gamusa'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();
    await t.tap(find.text('Better light'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();
    expect(find.text('Your prompt'), findsOneWidget);
    expect(find.text('Attach your photo'), findsOneWidget);
    expect(find.text('You need these 2 photos'), findsNothing);

    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pump();
    expect(find.text('What do you want?'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  test('AI photos is the sixth task and follows Read the numbers', () {
    expect(LearnTaskChain.totalTasks, 6);
    expect(LearnTaskChain.taskOrder.last, aiPhotosTaskId);
    expect(LearnTaskChain.nextTaskTitle(readNumbersTaskId), 'AI photos');
    expect(LearnTaskChain.nextTaskId(aiPhotosTaskId), isNull);
  });

  testWidgets('Done earns the badge once, then simply closes', (t) async {
    AppLang.current = 'en-US';
    LearnProgress.instance.reset();
    addTearDown(LearnProgress.instance.reset);
    t.view.physicalSize = const Size(390, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);

    Future<void> reachPrompt() async {
      await t.tap(find.text('Open'));
      await t.pumpAndSettle();
      await t.tap(find.text('Saree'));
      await t.pump();
      await t.tap(find.text('Continue'));
      await t.pump();
      await t.tap(find.text('Clean background'));
      await t.pump();
      await t.tap(find.text('Continue'));
      await t.pump();
    }

    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AiPhotosScreen(locale: 'en-US'),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    // Reaching the prompt alone does not finish the task.
    await reachPrompt();
    expect(LearnProgress.instance.isLearnTaskComplete(aiPhotosTaskId), isFalse);

    await t.tap(find.text('Done'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(LearnProgress.instance.isLearnTaskComplete(aiPhotosTaskId), isTrue);
    expect(find.text('Badge earned'), findsOneWidget);
    expect(
      find.text('You can use AI and keep your product the same.'),
      findsOneWidget,
    );

    // Leave the badge, then a second run earns no second badge.
    await t.pump(const Duration(milliseconds: 400));
    t.state<NavigatorState>(find.byType(Navigator)).pop();
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump();
    await reachPrompt();
    await t.tap(find.text('Done'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Badge earned'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });
}
