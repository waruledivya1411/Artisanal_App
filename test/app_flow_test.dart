import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisnal_app/app/app.dart';
import 'package:artisnal_app/features/learn/data/display_guides.dart';
import 'package:artisnal_app/features/learn/widgets/guide_diagram.dart';
import 'package:artisnal_app/features/learn/widgets/shot_outline.dart';
import 'package:artisnal_app/features/learn/data/displays.dart';
import 'package:artisnal_app/features/learn/data/learn_progress.dart';

void main() {
  testWidgets('Onboarding and Learn lessons flow', (WidgetTester tester) async {
    LearnProgress.instance.reset();
    await tester.pumpWidget(const ArtisnalApp());
    expect(find.text('Click & Social'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Forgot password?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('আপোনাৰ ভাষা বাছনি কৰক'), findsOneWidget);
    expect(find.text('অসমীয়া'), findsWidgets);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('ଓଡ଼ିଆ'), findsOneWidget);
    expect(find.text('తెలుగు'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pump();

    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    final selectedCard = find.byWidgetPredicate((widget) {
      if (widget is! Container) return false;
      final decoration = widget.decoration;
      if (decoration is! BoxDecoration) return false;
      final border = decoration.border;
      return border is Border &&
          border.top.color == const Color(0xFF1B7574) &&
          border.top.width > 1;
    });
    expect(selectedCard, findsOneWidget);
    expect(
      find.descendant(of: selectedCard, matching: find.text('English')),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // The language choice goes straight to the photo welcome page.
    expect(find.text('Take beautiful photos'), findsOneWidget);
    expect(find.text('Listen'), findsNothing);
    expect(
      find.text('The camera helps you keep the photo\nstraight and bright.'),
      findsOneWidget,
    );
    expect(find.text('Next'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Share and sell'), findsOneWidget);
    expect(find.text('Listen'), findsNothing);
    expect(
      find.text('Send your photos to Instagram and\nWhatsApp in a few taps.'),
      findsOneWidget,
    );
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Divya Warule'), findsOneWidget);
    expect(find.text('Photography'), findsOneWidget);
    expect(find.text('0 OF 5 TASKS DONE'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);

    expect(find.text('Create a post'), findsOneWidget);
    await tester.ensureVisible(find.text('Create a post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create a post'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 3 OF 5'), findsOneWidget);
    expect(find.text('Allow photo access'), findsOneWidget);
    expect(find.text('Photos and videos'), findsOneWidget);
    expect(find.text('Allow all'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What do you want to make?'), findsOneWidget);
    await tester.tap(find.text('Photo on your page'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Post in Instagram'), findsWidgets);
    expect(find.text('Tap +'), findsOneWidget);
    await tester.ensureVisible(find.text('Tap +'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tap +'));
    await tester.pumpAndSettle();
    expect(find.text('New post'), findsOneWidget);
    expect(find.text('STEP 2 OF 4'), findsOneWidget);
    expect(find.text('Pick your photo'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('gallery-photo-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next').last);
    await tester.pumpAndSettle();
    expect(find.text('Did you post it?'), findsOneWidget);
    expect(find.text('Look at your Instagram page'), findsOneWidget);
    expect(find.text('Yes, I posted'), findsOneWidget);
    await tester.tap(find.text('Yes, I posted'));
    await tester.pumpAndSettle();
    expect(find.text('Share a story'), findsWidgets);
    expect(find.text('Scroll down'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
    }
    expect(find.text('Read the numbers'), findsOneWidget);

    await tester.ensureVisible(find.text('Photography'));
    await tester.pumpAndSettle();
    // The Photography card holds the photo lessons.
    await tester.tap(find.text('Photography'));
    await tester.pumpAndSettle();
    expect(find.text('Hold steady'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Hold steady'), findsNothing);

    await tester.ensureVisible(find.text('Set up your page'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set up your page'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 2 OF 5'), findsOneWidget);
    expect(find.text('Good name'), findsOneWidget);
    expect(find.text('Clear photo'), findsOneWidget);
    expect(find.text('Professional'), findsOneWidget);
    expect(find.text('Try it'), findsNothing);
    await tester.tap(find.text('Good name'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 2 · PART 1 · GOOD NAME'), findsOneWidget);
    expect(find.text('Short name with your craft'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('@divya\n.weaves'), findsOneWidget);
    expect(find.text('Easy to say and find'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Easy to say and find'), findsOneWidget);
    expect(find.text('Short'), findsOneWidget);
    expect(find.text('Long'), findsOneWidget);
    await tester.tap(find.text('Next part · Clear photo'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 2 · PART 2 · CLEAR PHOTO'), findsOneWidget);
    expect(find.text('Use your face or your loom'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('divya.weaves'), findsNWidgets(2));
    expect(find.text('Buyers trust a clear face'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Buyers trust a clear face'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Blurry'), findsOneWidget);
    await tester.tap(find.text('Next part · Professional'));
    await tester.pumpAndSettle();
    expect(find.text('Use a professional page'), findsOneWidget);
    await tester.tap(find.text('Professional dashboard').first);
    await tester.pumpAndSettle();
    expect(find.text('Which is better?'), findsOneWidget);
    expect(find.text('Buyers can message you'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Buyers can message you'), findsOneWidget);
    expect(find.text('Professional'), findsWidgets);
    expect(find.text('Personal'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Pick your name'), findsOneWidget);
    expect(find.text('Short. Easy to say.'), findsOneWidget);
    expect(find.text('@ divya.weaves'), findsOneWidget);
    expect(find.text('Best'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('TASK 2 OF 5'), findsOneWidget);
    expect(find.text('Done'), findsNWidgets(3));
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Posting plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Posting plan'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 4 OF 5'), findsOneWidget);
    expect(find.text('Post often'), findsOneWidget);
    expect(find.text('Good time'), findsOneWidget);
    expect(find.text('Mix posts'), findsOneWidget);
    expect(find.text('Try it'), findsNothing);
    await tester.tap(find.text('Post often'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 4 · PART 1 · POST OFTEN'), findsOneWidget);
    expect(find.text('Post 3 times a week'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('1 a month'), findsOneWidget);
    expect(find.text('3 a week'), findsOneWidget);
    expect(find.text('People remember you'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('People remember you'), findsOneWidget);
    expect(find.text('Often'), findsOneWidget);
    expect(find.text('Rarely'), findsOneWidget);
    await tester.tap(find.text('Next part · Good time'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 4 · PART 2 · GOOD TIME'), findsOneWidget);
    expect(find.text('Post in the evening'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('More people see it'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('More people see it'), findsOneWidget);
    expect(find.text('Buyers online'), findsOneWidget);
    expect(find.text('All asleep'), findsOneWidget);
    await tester.tap(find.text('Next part · Mix posts'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 4 · PART 3 · MIX POSTS'), findsOneWidget);
    expect(find.text('Cloth, work, then price'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Every post shows something new'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Every post shows something new'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
    expect(find.text('Same photo'), findsOneWidget);
    // The last part of a task now leads straight into the next task.
    await tester.tap(find.text('Next task: Read the numbers'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 5 OF 5'), findsOneWidget);
    expect(find.text('Saves matter'), findsOneWidget);
    expect(find.text('Reply fast'), findsOneWidget);
    expect(find.text('What they mean'), findsOneWidget);
    expect(find.text('Best posts'), findsNothing);
    expect(find.text('Try it'), findsNothing);
    await tester.tap(find.text('Saves matter'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 5 · PART 1 · SAVES MATTER'), findsOneWidget);
    expect(find.text('Saves mean buyers'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('120 likes'), findsOneWidget);
    expect(find.text('0 saves'), findsOneWidget);
    expect(find.text('60 likes'), findsOneWidget);
    expect(find.text('18 saves'), findsOneWidget);
    expect(find.text('Saves show they want to buy'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Saves show they want to buy'), findsOneWidget);
    expect(find.text('Many saves'), findsOneWidget);
    expect(find.text('Only likes'), findsOneWidget);
    await tester.tap(find.text('Next part · Reply fast'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 5 · PART 2 · REPLY FAST'), findsOneWidget);
    expect(find.text('Reply the same day'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Price please?'), findsNWidgets(2));
    expect(find.text('After 3 days'), findsOneWidget);
    expect(find.text('In 1 hour'), findsOneWidget);
    expect(find.text('₹4,500'), findsNWidgets(2));
    expect(find.text('Fast replies make sales'), findsNothing);
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Fast replies make sales'), findsOneWidget);
    expect(find.text('Fast'), findsOneWidget);
    expect(find.text('Late'), findsOneWidget);
    await tester.tap(find.text('Next part · What they mean'));
    await tester.pumpAndSettle();
    expect(find.text('4 numbers to watch'), findsOneWidget);
    expect(find.text('People who saw it'), findsOneWidget);
    expect(find.text('Want to buy later'), findsOneWidget);
    expect(find.text('Buyers asking'), findsOneWidget);
    expect(find.text('BEST'), findsNWidgets(2));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Find your numbers'), findsOneWidget);
    expect(find.text('TASK 5 · 2 OF 2'), findsOneWidget);
    expect(find.text('divya.weaves'), findsOneWidget);
    expect(find.text('Professional dashboard'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Share profile'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Tap Professional dashboard'), findsOneWidget);
    expect(find.text('Open Instagram'), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);
    await tester.tap(find.text('Complete'));
    await tester.pump();
    expect(find.text('Badge earned'), findsOneWidget);
    expect(find.text('Read the numbers'), findsWidgets);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('TASK 5 OF 5'), findsOneWidget);
    expect(find.text('Done'), findsNWidgets(3));
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // The Photo button goes straight into the shoot.
    await tester.tap(find.text('Photo'));
    await tester.pumpAndSettle();

    expect(find.text('What are you photographing?'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Photography'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Photography'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hold steady'));
    await tester.pumpAndSettle();
    expect(find.text('PART 1 · HOLD STEADY'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    final photography = find.text('Photography');
    await tester.ensureVisible(photography);
    await tester.pumpAndSettle();
    await tester.tap(photography);
    await tester.pumpAndSettle();
    expect(find.text('What are you photographing?'), findsOneWidget);
    // Photo cards build a row at a time, so walk down the grid.
    final productGrid = find.descendant(
      of: find.byType(GridView),
      matching: find.byType(Scrollable),
    );
    expect(find.text('Saree'), findsOneWidget);
    expect(find.text('Mekhala sador'), findsOneWidget);

    for (final row in [
      ['Stole', 'Gamusa'],
      ['Shawl', 'Jod kappur'],
      ['Yardages', 'Cushion covers'],
    ]) {
      await tester.scrollUntilVisible(
        find.text(row.first),
        200,
        scrollable: productGrid,
      );
      expect(find.text(row.first), findsOneWidget);
      expect(find.text(row.last), findsOneWidget);
    }

    await tester.scrollUntilVisible(
      find.text('Saree'),
      -200,
      scrollable: productGrid,
    );
    await tester.ensureVisible(find.text('Saree'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saree'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('What are you photographing?'), findsNothing);
    expect(find.text('What is it made of?'), findsOneWidget);

    // Back steps to the previous question, it does not leave the setup.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('What are you photographing?'), findsOneWidget);
    expect(find.text('Hello, Divya Warule'), findsNothing);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What is it made of?'), findsOneWidget);
    // The grid builds a row at a time, so walk down it.
    final materialGrid = find.descendant(
      of: find.byType(GridView),
      matching: find.byType(Scrollable),
    );
    expect(find.text('Cotton'), findsOneWidget);
    expect(find.text('Mulberry'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tussar'),
      200,
      scrollable: materialGrid,
    );
    expect(find.text('Tussar'), findsOneWidget);
    expect(find.text('Muga'), findsOneWidget);

    await tester.ensureVisible(find.text('Muga'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Muga'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Eri'),
      200,
      scrollable: materialGrid,
    );
    expect(find.text('Eri'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('What is it made of?'), findsNothing);
    expect(find.text('How will you show it?'), findsOneWidget);

    // A saree is shown every way, a row at a time.
    final displayGrid = find.descendant(
      of: find.byType(GridView),
      matching: find.byType(Scrollable),
    );
    expect(find.text('Full display'), findsOneWidget);
    expect(find.text('Close-up texture'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Draped'),
      200,
      scrollable: displayGrid,
    );
    expect(find.text('Draped'), findsOneWidget);
    expect(find.text('Embroidery and border'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Folded'),
      200,
      scrollable: displayGrid,
    );
    expect(find.text('Folded'), findsOneWidget);
    expect(find.text('Hanging'), findsOneWidget);

    await tester.ensureVisible(find.text('Folded'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Folded'));
    await tester.pumpAndSettle();

    // Tapping a display opens its shooting guide.
    expect(find.text('One folded sari in the box'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Good example'), findsOneWidget);
    expect(find.text('Take the shot'), findsOneWidget);
    await tester.tap(find.text('Take the shot'));
    await tester.pumpAndSettle();

    // The camera opens with the dotted box to fit the product into. There is
    // no camera under test, so it says so and keeps the outline. Like a phone
    // camera, the black bands hold only Back and the shutter - no captions.
    expect(find.byType(ShotOutlineOverlay), findsOneWidget);
    expect(find.text('Move the saree into the frame'), findsNothing);

    // Backing out of the camera leaves the guide open on its last step.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Good example'), findsOneWidget);

    // Back steps through the guide, then out of it.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('One folded sari in the box'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('How will you show it?'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Setup is the whole of Photography now, so Done lands back on the home
    // screen with the three choices on the card.
    expect(find.text('How will you show it?'), findsNothing);
    await tester.ensureVisible(find.text('Photography'));
    await tester.pumpAndSettle();
    expect(find.text('Saree · Muga · Folded'), findsOneWidget);
  });

  test('each product offers the displays that suit it', () {
    const everyName = [
      'Full display',
      'Close-up texture',
      'Draped',
      'Embroidery and border',
      'Folded',
      'Hanging',
    ];
    for (final product in ['Saree', 'Mekhala sador']) {
      expect(
        displaysFor(product).map((d) => d.name),
        everyName,
        reason: product,
      );
    }
    for (final product in [
      'Stole',
      'Shawl',
      'Gamusa',
    ]) {
      expect(
        displaysFor(product).map((d) => d.name),
        ['Full display', 'Folded'],
        reason: product,
      );
    }
    expect(
      displaysFor('Cushion covers').map((d) => d.name),
      ['Sofa-Seated', 'Flat-Lay'],
    );
    expect(
      displaysFor('Jod kappur').map((d) => d.name),
      ['Folded', 'Hanging'],
    );
    expect(
      displaysFor('Yardages').map((d) => d.name),
      ['Hanging', 'Close-up texture'],
    );
  });

  test('full display is a flat lay and hanging is a hang', () {
    final full = guideFor('full_display');
    expect(full.first.title, 'Lay the whole piece flat');
    expect(full.first.art, GuideArt.spread);
    expect(full.any((step) => step.art == GuideArt.hang), isFalse);

    expect(
      guideFor('hanging_display').first.art,
      GuideArt.hangingDisplayCentre,
    );
  });

  test('every display has a guide that ends on a worked example', () {
    for (final display in everyDisplay) {
      final steps = guideFor(display.key);
      expect(steps, isNotEmpty, reason: display.name);
      expect(steps.last.showExample, isTrue, reason: display.name);
      // Every setup step draws something; only the example step has no art.
      for (final step in steps.where((s) => !s.showExample)) {
        expect(step.art, isNotNull, reason: '${display.name}: ${step.title}');
      }
    }
  });
}
