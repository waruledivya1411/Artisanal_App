import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/learn/data/ai_words.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';

void main() {
  test('a bio prompt carries only what the artisan said', () {
    final prompt = buildAiWordsPrompt(
      goal: AiWordsGoal.bio,
      answers: {
        'name': 'Rina Das',
        'from': ' Sualkuchi,   Assam ',
        'make': 'Muga silk sarees',
        'story': '',
        'buy': 'DM to order',
      },
      language: 'Assamese',
    );
    expect(prompt, startsWith('Write 3 Instagram bio options'));
    expect(prompt, contains('- Name: Rina Das'));
    expect(prompt, contains('- From: Sualkuchi, Assam'));
    expect(prompt, contains('- I make: Muga silk sarees'));
    expect(prompt, contains('- How to buy: DM to order'));
    expect(prompt, isNot(contains('My story')));
    expect(prompt, contains('under 150 characters'));
    expect(prompt, contains('Write in Assamese.'));
    expect(prompt, endsWith('Use only these facts. Do not make anything up.'));
  });

  test('a caption prompt asks for a hook, how to buy and hashtags', () {
    final withBuy = buildAiWordsPrompt(
      goal: AiWordsGoal.caption,
      answers: {
        'product': 'Red Muga saree',
        'special': 'Woven in 20 days',
        'price': '₹4,500',
        'buy': 'DM to order',
      },
      language: 'English',
    );
    expect(withBuy, startsWith('Write 3 Instagram caption options'));
    expect(withBuy, contains('- Product: Red Muga saree'));
    expect(withBuy, contains('- What is special: Woven in 20 days'));
    expect(withBuy, contains('- Price: ₹4,500'));
    expect(withBuy, contains('End with how to buy, then add 5 hashtags.'));
    expect(withBuy, contains('Do not make anything up.'));

    final noBuy = buildAiWordsPrompt(
      goal: AiWordsGoal.caption,
      answers: {'product': 'Red Muga saree', 'special': 'Woven in 20 days'},
      language: 'Odia',
    );
    expect(noBuy, contains('End by asking people to message me to order'));
    expect(noBuy, isNot(contains('Price')));
    expect(noBuy, contains('Write in Odia.'));
  });

  test('the prompt waits for the answers it needs', () {
    expect(aiWordsReady(AiWordsGoal.bio, {'from': 'Assam'}), isFalse);
    expect(
      aiWordsReady(AiWordsGoal.bio, {'from': 'Assam', 'make': '  '}),
      isFalse,
    );
    expect(
      aiWordsReady(AiWordsGoal.bio, {'from': 'Assam', 'make': 'Sarees'}),
      isTrue,
    );
    expect(
      aiWordsReady(AiWordsGoal.caption, {'product': 'Saree', 'special': 'x'}),
      isTrue,
    );
    expect(aiWordsLanguageFor('as'), 'Assamese');
    expect(aiWordsLanguageFor('en'), 'English');
  });

  test('Use AI is the sixth task, with two parts', () {
    expect(LearnTaskChain.taskOrder.last, aiPhotosTaskId);
    expect(LearnTaskChain.nextTaskTitle(readNumbersTaskId), 'Use AI');
    expect(LearnTaskChain.partCounts[aiPhotosTaskId], 2);
  });

  testWidgets('photo prompts lead to bio and caption, which earns the badge', (
    t,
  ) async {
    AppLang.current = 'en-US';
    LearnProgress.instance.reset();
    addTearDown(LearnProgress.instance.reset);
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
    final progress = LearnProgress.instance;

    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => aiTask('en-US')),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('Open'));
    await t.pumpAndSettle();
    expect(find.text('Use AI'), findsOneWidget);
    expect(find.text('Photo prompts'), findsOneWidget);
    expect(find.text('Bio and caption'), findsOneWidget);

    // Part 1, to its prompt.
    await t.tap(find.text('Photo prompts'));
    await t.pumpAndSettle();
    await t.tap(find.text('Saree'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();
    await t.tap(find.text('Clean background'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();
    expect(progress.completedParts(aiPhotosTaskId), 0);
    await t.tap(find.text('Next part · Bio and caption'));
    await t.pumpAndSettle();
    expect(progress.completedParts(aiPhotosTaskId), 1);
    expect(progress.isLearnTaskComplete(aiPhotosTaskId), isFalse);

    // Part 2: pick, answer, copy.
    expect(find.text('BIO AND CAPTION'), findsOneWidget);
    await t.tap(find.text('Bio'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();
    expect(find.text('Tell us about you'), findsOneWidget);
    expect(find.text('Write it in'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    Future<void> tapContinue() async {
      await t.tap(find.text('Continue'));
      await t.pump();
    }

    // Not ready until where and what are filled in.
    await tapContinue();
    expect(find.text('Tell us about you'), findsOneWidget);
    await t.enterText(find.byKey(const ValueKey('ai-words-from')), 'Sualkuchi');
    await t.pump();
    await tapContinue();
    expect(find.text('Tell us about you'), findsOneWidget);
    await t.enterText(
      find.byKey(const ValueKey('ai-words-make')),
      'Muga silk sarees',
    );
    await t.tap(find.text('Hindi'));
    await t.pump();
    await tapContinue();

    expect(find.text('Your prompt'), findsOneWidget);
    expect(find.textContaining('- From: Sualkuchi'), findsOneWidget);
    expect(find.textContaining('Write in Hindi.'), findsOneWidget);
    await t.tap(find.text('Copy prompt'));
    await t.pump();
    expect(copied, contains('- I make: Muga silk sarees'));
    expect(find.text('Prompt copied'), findsOneWidget);

    // The end of the last part earns the badge.
    await t.tap(find.text('Done'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(progress.isLearnTaskComplete(aiPhotosTaskId), isTrue);
    expect(find.text('Badge earned'), findsOneWidget);
    expect(
      find.text('You can use AI for photos, bios and captions.'),
      findsOneWidget,
    );
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);

    // After that, Done simply closes a part.
    await t.tap(find.text('Open'));
    await t.pumpAndSettle();
    await t.tap(find.text('Bio and caption'));
    await t.pumpAndSettle();
    await t.tap(find.text('Caption'));
    await t.pump();
    await tapContinue();
    // Where they are from is remembered from the bio.
    expect(find.text('Sualkuchi'), findsOneWidget);
    await t.enterText(find.byKey(const ValueKey('ai-words-product')), 'Saree');
    await t.enterText(
      find.byKey(const ValueKey('ai-words-special')),
      'Woven in 20 days',
    );
    await t.pump();
    await tapContinue();
    await t.pump(const Duration(seconds: 3));
    await t.tap(find.text('Done'));
    await t.pumpAndSettle();
    expect(find.text('Badge earned'), findsNothing);
    expect(find.text('Photo prompts'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
