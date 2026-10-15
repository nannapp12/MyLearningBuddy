import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_learning_buddy/main.dart';
import 'package:my_learning_buddy/models/content.dart';
import 'package:my_learning_buddy/screens/parent_area_screen.dart';
import 'package:my_learning_buddy/screens/sticker_picker_screen.dart';
import 'package:my_learning_buddy/services/audio_service.dart';
import 'package:my_learning_buddy/state/app_state.dart';

void main() {
  final content = LearningContent.fromJsonString(File('assets/content/content.json').readAsStringSync());

  late SilentAudioService audio;

  Future<void> pumpApp(WidgetTester tester, {bool allItems = false}) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    audio = SilentAudioService();
    await tester.pumpWidget(MyLearningBuddyApp(content: content, audio: audio, puppyGreetings: false));
    if (allItems) {
      // Easy is the default; Hard shows every item.
      await tester.tap(find.bySemanticsLabel('Hard'));
      await tester.pump();
    }
  }

  testWidgets('home screen shows all sections', (tester) async {
    await pumpApp(tester);
    for (final c in content.categories) {
      expect(find.text(c.title), findsOneWidget);
    }
  });

  testWidgets('finishing a section: puppy, then pick a sticker for the sticker bar', (tester) async {
    await pumpApp(tester, allItems: true);
    await tester.tap(find.text('Shapes'));
    await tester.pumpAndSettle();
    expect(find.text('Circle'), findsOneWidget);

    for (var i = 0; i < 8; i++) {
      await tester.tap(find.bySemanticsLabel('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.bySemanticsLabel('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 360));
    expect(find.text('Hexagon'), findsOneWidget);
    // The puppy follows a short pause after the last item is said.
    expect(find.text('Woof woof! You did it!'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Woof woof! You did it!'), findsOneWidget);
    await tester.pumpAndSettle();

    // Then "Great Job! Now pick your sticker" with five stickers, clapping and confetti.
    expect(find.text('Now pick your sticker'), findsOneWidget);
    expect(audio.effects, contains('cheer'));
    expect(find.text('👏'), findsNWidgets(2));
    expect(find.bySemanticsLabel('Sticker'), findsNWidgets(5));
    expect(
      audio.spoken,
      containsAllInOrder([
        'Shapes',
        'Circle',
        'Hexagon',
        'Woof woof! You did it!',
        'Great job! Now pick your sticker.',
      ]),
    );

    // Picking one adds it to the sticker bar and goes back to the main menu.
    await tester.tap(find.bySemanticsLabel('Sticker').first);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Letters'), findsOneWidget);
    expect(find.text('Finish a section or game to win a sticker!'), findsNothing);
  });

  testWidgets('Find It: pick a section, find the right picture five times', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Find It'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fruits'));
    await tester.pumpAndSettle();
    final fruits = content.categories.firstWhere((c) => c.id == 'fruits').items;
    for (var round = 0; round < 5; round++) {
      // The voice asks "Can you find" + the fruit's name.
      final asked = audio.spoken.last;
      expect(audio.spoken[audio.spoken.length - 2], 'Can you find');
      final answer = fruits.firstWhere((f) => f.label == asked);
      if (round == 0) {
        // A wrong picture says "Try again!".
        final wrong = fruits.firstWhere((f) => f != answer && find.text(f.emoji!).evaluate().isNotEmpty);
        await tester.tap(find.text(wrong.emoji!));
        await tester.pump();
        expect(audio.spoken.last, 'Try again!');
      }
      await tester.tap(find.text(answer.emoji!));
      await tester.pumpAndSettle();
    }
    // After five rounds: the puppy, then the stickers.
    expect(find.text('Now pick your sticker'), findsOneWidget);
  });

  testWidgets('"Great job!" waits until the last item has been said', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final slow = _ManualAudioService();
    await tester.pumpWidget(MyLearningBuddyApp(content: content, audio: slow, puppyGreetings: false));
    await tester.tap(find.bySemanticsLabel('Hard'));
    await tester.pump();
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
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Woof woof! You did it!'), findsOneWidget);
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
    await pumpApp(tester, allItems: true);
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

  testWidgets('days of the week start on Monday with no "today", all 7 even on Easy', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Days of the Week'));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
    expect(find.text('1 / 7'), findsOneWidget);
  });

  Future<void> traceAndFinish(WidgetTester tester) async {
    await tester.dragFrom(const Offset(600, 600), const Offset(100, 200));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Great job!'));
    await tester.pumpAndSettle();
  }

  testWidgets('tracing: Great job moves to the next letter; after the last, the puppy and stickers', (tester) async {
    await pumpApp(tester, allItems: true);
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
    await tester.dragFrom(const Offset(600, 600), const Offset(100, 200));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Now pick your sticker'), findsOneWidget);
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

  testWidgets('taps on the main menu make a pop sound', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Easy'));
    await tester.pump();
    expect(audio.effects, ['pop']);
    await tester.tap(find.text('Shapes'));
    await tester.pumpAndSettle();
    expect(audio.effects, ['pop', 'pop']);
  });

  testWidgets('Easy shows the first 5 items, Medium 8, Hard all; one mode at a time', (tester) async {
    await pumpApp(tester);
    Future<String> countIn(String section) async {
      await tester.tap(find.text(section));
      await tester.pumpAndSettle();
      final counter = tester.widget<Text>(find.textContaining(' / ')).data!;
      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      return counter;
    }

    expect(await countIn('Shapes'), '1 / 5'); // Easy is the default
    await tester.tap(find.bySemanticsLabel('Hard'));
    await tester.pump();
    expect(await countIn('Shapes'), '1 / 10');
    await tester.tap(find.bySemanticsLabel('Medium'));
    await tester.pump();
    expect(await countIn('Shapes'), '1 / 8');
    expect(await countIn('Words'), '1 / 8'); // letters A-H
    expect(await countIn('Family'), '1 / 8');

    final selected = [
      for (final d in ['Easy', 'Medium', 'Hard'])
        if (find
            .byWidgetPredicate((w) => w is Semantics && w.properties.label == d && w.properties.selected == true)
            .evaluate()
            .isNotEmpty)
          d,
    ];
    expect(selected, ['Medium']);
  });

  testWidgets('Phrases say the phrase and wait for the next button', (tester) async {
    await pumpApp(tester, allItems: true);
    await tester.scrollUntilVisible(find.text('Phrases'), 400);
    await tester.tap(find.text('Phrases'));
    await tester.pumpAndSettle();
    expect(audio.spoken, ['Phrases', 'How are you?']);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('1 / 10'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Next'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 10'), findsOneWidget);
    expect(audio.spoken.last, 'I am doing well, thank you');
  });

  testWidgets('puppy says hello on start and "This is fun!" back on the main menu', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    audio = SilentAudioService();
    await tester.pumpWidget(MyLearningBuddyApp(content: content, audio: audio));
    await tester.pump();
    expect(find.text('Hi! How are you?'), findsNothing); // the bubble shows once it sits down
    expect(audio.spoken, ['Hi! How are you?']);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shapes'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Home'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('This is fun!'), findsOneWidget);
    expect(audio.spoken.last, 'This is fun!');
    await tester.pumpAndSettle();
  });

  testWidgets('tapping the puppy title goes to the main menu, where the puppy says "This is fun!"', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    audio = SilentAudioService();
    await tester.pumpWidget(MyLearningBuddyApp(content: content, audio: audio));
    await tester.pumpAndSettle(); // the "Hi! How are you?" puppy

    // On the main menu: the puppy says "This is fun!".
    await tester.tap(find.bySemanticsLabel('My Learning Buddy'));
    await tester.pump();
    expect(audio.spoken.last, 'This is fun!');
    await tester.pumpAndSettle();

    // From the sticker screen (which shows the title): back to the main menu.
    await tester.tap(find.text('Shapes'));
    await tester.pumpAndSettle();
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute<void>(builder: (_) => const StickerPickerScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('My Learning Buddy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Shapes'), findsOneWidget); // the main menu tile
    expect(find.text('Circle'), findsNothing);
    expect(audio.spoken.last, 'This is fun!');
    await tester.pumpAndSettle();
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
  void pop() {}

  @override
  void cheer() {}

  @override
  void dispose() {}
}
