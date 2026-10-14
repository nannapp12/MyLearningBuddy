import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_learning_buddy/models/content.dart';
import 'package:my_learning_buddy/services/speech.dart';

void main() {
  final content = LearningContent.fromJsonString(File('assets/content/content.json').readAsStringSync());

  test('every sentence the app can say has a voice clip', () {
    final missing = [
      for (final text in Speech.all(content))
        if (!File('assets/audio/${clipName(text)}.mp3').existsSync()) text,
    ];
    expect(missing, isEmpty, reason: 'Run tool/generate_audio.py to make the missing clips');
    expect(File('assets/audio/effects/chime.mp3').existsSync(), isTrue);
  });

  test('speech rules', () {
    expect(clipName('Cow. Moo!'), 'cow_moo');
    expect(Speech.trace('a'), 'Trace the small letter A.');
    expect(Speech.trace('B'), 'Trace the big letter B.');
    expect(Speech.trace('12'), 'Trace the number 12.');
  });

  test('every picture file exists', () {
    for (final c in content.categories) {
      if (c.image != null) expect(File(c.image!).existsSync(), isTrue, reason: c.image);
      for (final i in [...c.items, for (final g in c.groups) ...g.items]) {
        if (i.image != null) expect(File(i.image!).existsSync(), isTrue, reason: i.image);
      }
    }
  });
}
