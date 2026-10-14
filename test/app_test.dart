import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_learning_buddy/main.dart';
import 'package:my_learning_buddy/models/content.dart';
import 'package:my_learning_buddy/screens/parent_area_screen.dart';
import 'package:my_learning_buddy/services/audio_service.dart';
import 'package:my_learning_buddy/state/app_state.dart';

void main() {
  final content = LearningContent.fromJsonString(File('assets/content/content.json').readAsStringSync());

  late SilentAudioService audio;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    audio = SilentAudioService();
    await tester.pumpWidget(MyLearningBuddyApp(content: content, audio: audio));
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
    expect(audio.spoken, containsAllInOrder(['Shapes', 'Circle', 'Square', 'Hexagon', 'Great job!']));

    // Tapping "Great job!" goes back to the main menu.
    await tester.tap(find.text('Great job!'));
    await tester.pumpAndSettle();
    expect(find.text('Hexagon'), findsNothing);
    expect(find.text('Letters'), findsOneWidget);
  });

  testWidgets('words shows all five words for a letter on one card', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Words'));
    await tester.pumpAndSettle();
    for (final word in ['Apple', 'Ant', 'Airplane', 'Alligator', 'Arrow']) {
      expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == word), findsOneWidget);
    }
    await tester.tap(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == 'Ant'));
    expect(audio.spoken, ['Words', 'A', 'Ant']);
  });

  testWidgets('home button goes back to the main menu', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Farm Animals'));
    await tester.pumpAndSettle();
    expect(find.text('Cow'), findsOneWidget);
    expect(audio.spoken, ['Farm Animals', 'Cow']);
    await tester.tap(find.bySemanticsLabel('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Letters'), findsOneWidget);
  });

  testWidgets('tracing moves on from Z to the number 1', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Tracing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Z'));
    await tester.pumpAndSettle();
    expect(find.text('Trace Z'), findsOneWidget);
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Trace 1'), findsOneWidget);
    expect(audio.spoken.last, 'Trace the number 1.');
  });

  testWidgets('days of the week start on Monday with no "today"', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Days of the Week'));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });

  Future<void> traceAndFinish(WidgetTester tester) async {
    await tester.dragFrom(const Offset(600, 600), const Offset(100, 200));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Great job!'));
    await tester.pumpAndSettle();
  }

  testWidgets('tracing: Great job moves to the next letter, and home after the last', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Tracing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await traceAndFinish(tester);
    expect(find.text('Trace B'), findsOneWidget);

    // The last item in the ABC list is 10.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();
    await traceAndFinish(tester);
    expect(find.text('Letters'), findsOneWidget);
  });

  test('stars are awarded once per section', () {
    final state = AppState(audio: SilentAudioService());
    expect(state.finish('shapes'), isTrue);
    expect(state.finish('shapes'), isFalse);
    expect(state.stars, 1);
  });

  testWidgets('parent area is locked and can hide a section', (tester) async {
    final state = AppState(audio: SilentAudioService());
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
