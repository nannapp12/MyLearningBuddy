import '../models/content.dart';

/// What the app says aloud, in one place.
///
/// Every sentence here has a pre-recorded clip in `assets/audio/`, named by
/// [clipName]. `tool/generate_audio.py` follows the same rules to make the
/// clips, and `test/speech_test.dart` checks that none are missing.
class Speech {
  static const greatJob = 'Great job!';
  static const wellDone = 'Well done!';
  static const pickSticker = 'Great job! Now pick your sticker.';
  static const puppy = 'Woof woof! You did it!';
  static const canYouFind = 'Can you find';
  static const foundIt = 'Yay! You found it!';
  static const tryAgain = 'Try again!';
  static const hello = 'Hi! How are you?';
  static const thisIsFun = 'This is fun!';

  /// Phrases used by the games.
  static const extras = [canYouFind];

  /// What the puppy says (greetings and rewards). These use the puppy's own
  /// livelier, child-like voice and live in `assets/audio/puppy/`.
  static const mascot = {greatJob, wellDone, pickSticker, puppy, foundIt, tryAgain, hello, thisIsFun};

  static String category(Category category) => category.title;

  /// E.g. "Apple", "Seven strawberries.", "Big. Small.".
  static String item(LearningItem item) {
    if (item.speak != null) return item.speak!;
    if (item.opposite != null) return '${item.label}. ${item.opposite!.label}.';
    if (item.subtitle != null) return '${item.label}. ${item.subtitle}';
    return item.label;
  }

  /// The letter for a page of words, e.g. "A".
  static String group(ItemGroup group) => group.label;

  /// Everything the app can say for [content].
  static Set<String> all(LearningContent content) => {
    ...mascot,
    ...extras,
    for (final c in content.categories)
      if (!c.silent) ...[
        category(c),
        for (final i in c.items) item(i),
        for (final g in c.groups) ...[group(g), for (final i in g.items) item(i)],
      ],
  };
}

/// The asset path of [text]'s clip: the puppy's lines are in their own folder.
String clipPath(String text) =>
    Speech.mascot.contains(text) ? 'audio/puppy/${clipName(text)}.mp3' : 'audio/${clipName(text)}.mp3';

/// The audio file name for [text], e.g. "Cow. Moo!" -> "cow_moo".
String clipName(String text) =>
    text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
