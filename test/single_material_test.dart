import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/data/materials.dart';

void main() {
  Future<void> pickProduct(WidgetTester t, String product) async {
    t.view.physicalSize = const Size(390, 1600);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    await t.pumpWidget(MaterialApp(home: photographyEntry('en-US')));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text(product), 200);
    await t.tap(find.text(product));
    await t.pumpAndSettle();
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
  }

  testWidgets('a cotton-only product skips the material page', (t) async {
    await pickProduct(t, 'Saree');
    expect(find.text('What is it made of?'), findsNothing);
    expect(find.text('How will you show it?'), findsOneWidget);
    expect(SelectedMaterial.instance.name, 'Cotton');
  });
}
