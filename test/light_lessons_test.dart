import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/screens/learn_part_screen.dart';

void main() {
  testWidgets('photography teaches cotton, silk, and eri light', (tester) async {
    final parts = photographyTask('en-US').parts;
    expect(parts.map((part) => part.title), [
      'Hold steady',
      'Plain sheet',
      'Window light',
      'Straight angle',
      'Light for cotton',
      'Light for silk',
      'Shade the silk',
      'Turn the silk',
    ]);
    expect(LearnTaskChain.partCounts[photographyTaskId], parts.length);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    LearnPartScreen screen(int index) =>
        parts[index].open!(context) as LearnPartScreen;

    expect(
      screen(4).line,
      'Cotton and eri soak up light. Side light shows the weave.',
    );
    expect(
      screen(5).line,
      'Mulberry and muga throw light back. Soft light lets them glow.',
    );

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(home: screen(6)),
    );
    await tester.pump();
    expect(find.text('Hang a white sheet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
