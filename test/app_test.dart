import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_learning_buddy/main.dart';
import 'package:my_learning_buddy/models/content.dart';
import 'package:my_learning_buddy/screens/parent_area_screen.dart';
import 'package:my_learning_buddy/state/app_state.dart';

void main() {
  final content = LearningContent.fromJsonString(File('assets/content/content.json').readAsStringSync());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MyLearningBuddyApp(content: content));
  }

  testWidgets('home screen shows all sections', (tester) async {
    await pumpApp(tester);
    for (final c in content.categories) {
      expect(find.text(c.title), findsOneWidget);
    }
  });

  testWidgets('finishing a section awards a star', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Shapes'));
    await tester.pumpAndSettle();
    expect(find.text('Circle'), findsOneWidget);

    for (var i = 0; i < 9; i++) {
      await tester.tap(find.bySemanticsLabel('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Hexagon'), findsOneWidget);
    expect(find.text('Great job!'), findsOneWidget);
  });

  test('stars are awarded once per section', () {
    final state = AppState();
    expect(state.finish('shapes'), isTrue);
    expect(state.finish('shapes'), isFalse);
    expect(state.stars, 1);
  });

  testWidgets('parent area is locked and can hide a section', (tester) async {
    final state = AppState();
    // With a fixed seed the sum is predictable: read it from the screen.
    await tester.pumpWidget(
      AppStateScope(
        state: state,
        child: MaterialApp(
          home: ParentAreaScreen(content: content, random: Random(1)),
        ),
      ),
    );
    expect(find.text('Show or hide sections'), findsNothing);

    final question = tester.widget<Text>(find.textContaining('What is')).data!;
    final nums = RegExp(r'\d+').allMatches(question).map((m) => int.parse(m[0]!)).toList();
    await tester.tap(find.widgetWithText(OutlinedButton, '${nums[0] + nums[1]}'));
    await tester.pumpAndSettle();
    expect(find.text('Show or hide sections'), findsOneWidget);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Shapes'));
    await tester.pump();
    expect(state.isHidden('shapes'), isTrue);
  });
}
