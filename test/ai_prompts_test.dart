import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/learn/data/ai_prompts.dart';
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
      check(AiGoal.makeClothes, aiClothesFor(product.name));
    }
  });

  test('each product offers exactly the props chosen for it', () {
    const expected = {
      'Saree': [
        'Mannequin',
        'Real model',
        'Wooden hanger',
        'Chair',
        'Festive setting',
      ],
      'Mekhala sador': [
        'Mannequin',
        'Real model',
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

  test('only the real model prompt shows a person wearing the saree', () {
    for (final product in photographyProducts) {
      for (final goal in [AiGoal.newDisplay, AiGoal.addProps]) {
        final choices = goal == AiGoal.newDisplay
            ? aiDisplaysFor(product.name)
            : aiPropsFor(product.name);
        for (final choice in choices) {
          final prompt = buildAiPrompt(
            product: product.name,
            goal: goal,
            scene: choice.label,
          );
          final isModel =
              const {'Saree', 'Mekhala sador'}.contains(product.name) &&
              choice.label == 'Real model';
          expect(choice.withModel, isModel, reason: choice.label);
          expect(prompt.contains('no people'), !isModel, reason: prompt);
        }
      }
    }
    final prompt = buildAiPrompt(
      product: 'Saree',
      goal: AiGoal.addProps,
      scene: 'Real model',
    );
    expect(prompt, contains('real woman wearing this saree'));
    expect(prompt, contains('pallu over her shoulder'));
    expect(prompt, contains('It must be this exact saree, not a similar one.'));
    expect(prompt, contains('exactly from my photos'));
    expect(prompt, endsWith('no text.'));

    final mekhala = buildAiPrompt(
      product: 'Mekhala sador',
      goal: AiGoal.addProps,
      scene: 'Real model',
    );
    expect(mekhala, contains('real woman wearing it in Assamese style'));
    expect(mekhala, contains('mekhela pleated at the waist'));
    expect(mekhala, contains('sador over the shoulder'));
    expect(
      mekhala,
      contains('It must be this exact mekhela sador set, not a similar one.'),
    );
    expect(mekhala, isNot(contains('no people')));
  });

  test('only yardages can be made into a kurti, kurta or shirt', () {
    for (final product in photographyProducts) {
      expect(
        [for (final item in aiClothesFor(product.name)) item.label],
        product.name == 'Yardages' ? ['Kurti', 'Kurta', 'Shirt'] : isEmpty,
        reason: product.name,
      );
    }
    const wearer = {
      'Kurti': 'real woman',
      'Kurta': 'real man',
      'Shirt': 'real man',
    };
    wearer.forEach((label, person) {
      final prompt = buildAiPrompt(
        product: 'Yardages',
        goal: AiGoal.makeClothes,
        scene: label,
      );
      expect(prompt, startsWith('Photo 1 shows my handwoven fabric in full.'));
      expect(prompt, contains('Sew this fabric into a'));
      expect(prompt, contains(label.toLowerCase()));
      expect(prompt, contains('worn by a $person'));
      expect(prompt, contains('keeping the pattern at its true size'));
      expect(
        prompt,
        contains('It must be this exact fabric, not a similar one.'),
      );
      expect(prompt, isNot(contains('no people')));
      expect(wordsIn(prompt), lessThanOrEqualTo(70), reason: prompt);
    });
    expect(aiNeedsBothPhotos(AiGoal.makeClothes), isTrue);
  });

  testWidgets('yardages offer Make clothes and copy a kurti prompt', (t) async {
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

    // A saree is not sewn into clothes, so it is not offered.
    await t.tap(find.text('Saree'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();
    expect(find.text('Make clothes'), findsNothing);
    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pump();

    await t.tap(find.text('Yardages'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();
    expect(find.text('Make clothes'), findsOneWidget);
    expect(find.text('Kurti, Kurta, Shirt'), findsOneWidget);
    await t.tap(find.text('Make clothes'));
    await t.pump();
    expect(find.text('Which one?'), findsOneWidget);
    await t.tap(find.text('Kurti'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();

    expect(find.text('You need these 2 photos'), findsOneWidget);
    await t.tap(find.text('Copy prompt'));
    await t.pump();
    expect(copied, contains('knee-length kurti worn by a real woman'));

    // Going back and picking a saree drops the clothes choice.
    await t.pump(const Duration(seconds: 5));
    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pump();
    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pump();
    await t.tap(find.text('Saree'));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pump();
    expect(find.text('Which one?'), findsNothing);
    expect(t.takeException(), isNull);
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
        ...aiClothesFor(product.name),
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
}
