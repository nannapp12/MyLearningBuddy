import 'dart:async';
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
    // "Great job!" follows a short pause after the last item is said.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Great job!'), findsOneWidget);
    expect(audio.spoken, containsAllInOrder(['Shapes', 'Circle', 'Square', 'Hexagon', 'Great job!']));

    // Tapping "Great job!" goes back to the main menu.
    await tester.tap(find.text('Great job!'));
    await tester.pumpAndSettle();
    expect(find.text('Hexagon'), findsNothing);
    expect(find.text('Letters'), findsOneWidget);
  });

  testWidgets('"Great job!" waits until the last item has been said', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final slow = _ManualAudioService();
    await tester.pumpWidget(MyLearningBuddyApp(content: content, audio: slow));
    await tester.tap(find.text('Shapes'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 9; i++) {
      await tester.tap(find.bySemanticsLabel('Next'));
      await tester.pumpAndSettle();
    }
    expect(slow.lastSaid, ['Hexagon']);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Great job!'), findsNothing);

    slow.finish();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Great job!'), findsOneWidget);
  });

  testWidgets('words shows all five words for a letter on one card', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Words'));
    await tester.pumpAndSettle();
    for (final word in ['Apple', 'Ant', 'Airplane', 'Alligator', 'Arrow']) {
      expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == word), findsOneWidget);
    }
    await tester.tap(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == 'Ant'));
    // Opening the card reads the letter and all five words; tapping a picture says that word.
    expect(audio.spoken, ['Words', 'A', 'Apple', 'Ant', 'Airplane', 'Alligator', 'Arrow', 'Ant']);
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

  testWidgets('tracing next button moves on, and stops at Z', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Tracing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Y'));
    await tester.pumpAndSettle();
    expect(audio.spoken.last, 'Trace the letter Y.');
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Trace Z'), findsOneWidget);
    expect(audio.spoken.last, 'Trace the letter Z.');
    final next = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.arrow_forward_rounded));
    expect(next.onPressed, isNull);
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

    // The last item in the ABC list is Z.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Z'));
    await tester.pumpAndSettle();
    await traceAndFinish(tester);
    expect(find.text('Letters'), findsOneWidget);
  });

  testWidgets('opposites show both words and say them', (tester) async {
    await pumpApp(tester);
    await tester.scrollUntilVisible(find.text('Opposites'), 300);
    await tester.tap(find.text('Opposites'));
    await tester.pumpAndSettle();
    expect(find.text('Big'), findsOneWidget);
    expect(find.text('Small'), findsOneWidget);
    expect(audio.spoken, ['Opposites', 'Big. Small.']);
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

/// Speaks only when told to [finish], to test what waits for the voice.
class _ManualAudioService implements AudioService {
  List<String> lastSaid = [];
  Completer<bool>? _done;

  @override
  Future<bool> speak(List<String> texts, {Duration gap = Duration.zero}) {
    if (_done?.isCompleted == false) _done!.complete(false);
    lastSaid = texts;
    return (_done = Completer<bool>()).future;
  }

  void finish() => _done?.complete(true);

  @override
  void chime() {}

  @override
  void dispose() {}
}
