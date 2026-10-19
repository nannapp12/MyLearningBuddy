import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_learning_buddy/models/content.dart';

void main() {
  final content = LearningContent.fromJsonString(File('assets/content/content.json').readAsStringSync());
  Category byId(String id) => content.categories.firstWhere((c) => c.id == id);

  test('Words (Level 1 and 2), Phrases, Tracing, Nursery Rhymes, Short Stories and Games, in order', () {
    String names(MenuSection section) => [
      for (final c in content.categories)
        if (c.section == section) c.title,
    ].join(', ');
    expect(
      names(MenuSection.level1),
      'Letters, Numbers, Words, Farm Animals, Wild Animals, Birds, Sea Creatures, Insects, Vehicles, Fruits, '
      'Vegetables, Food, Colors, Shapes',
    );
    expect(
      names(MenuSection.level2),
      'Days of the Week, Months, Weather and Seasons, Time, Body Parts, Family, Emotions, Community Helpers, '
      'Places We Visit, Things Around the House, Appliances, At the Park, In the School, Clothing, Sports, Opposites',
    );
    expect(names(MenuSection.phrases), 'Greetings, Activities');
    expect(names(MenuSection.tracing), 'Shapes, Letters, Numbers');
    expect(names(MenuSection.games), 'Find It, Matching, Memory');
    expect(MenuTab.values.map((t) => t.label), [
      'Words',
      'Phrases',
      'Tracing',
      'Nursery Rhymes',
      'Short Stories',
      'Games',
    ]);
    expect(
      names(MenuSection.nurseryRhymes),
      'Twinkle Twinkle Little Star, Hickory Dickory Dock, Mary Had a Little Lamb, Teddy Bear, Teddy Bear, '
      'One, Two, Buckle My Shoe, Baa Baa Black Sheep, Itsy Bitsy Spider, Rain, Rain, Go Away, '
      'Row, Row, Row Your Boat, Hey Diddle Diddle',
    );
    expect(
      names(MenuSection.shortStories),
      'Hansel & Gretel, Little Red Riding Hood, Cinderella, Sleeping Beauty, Beauty & the Beast, The Three Little Pigs, '
      'Goldilocks and the Three Bears, The Tortoise and the Hare, The Ugly Duckling, The Lion and the Mouse, '
      'The Little Red Hen, Jack and the Beanstalk',
    );
    // In content.json the sections are listed in the order of the headings.
    final order = [for (final c in content.categories) c.section.index];
    expect(order, [...order]..sort());
  });

  test('greetings and activities have at least 10 phrases each', () {
    expect(byId('greetings').items.length, greaterThanOrEqualTo(10));
    expect(byId('activities').items.length, greaterThanOrEqualTo(10));
  });

  test('sections have at most 10 items, except where the subject needs more', () {
    const longer = {'letters', 'numbers', 'words', 'months', 'shapes', 'time', 'greetings', 'activities'};
    for (final c in content.categories) {
      if (!longer.contains(c.id)) expect(c.items.length, lessThanOrEqualTo(10), reason: c.title);
    }
    expect(byId('months').items, hasLength(12));
    expect(byId('time').items.map((i) => i.label).last, "12 o'clock");
  });

  test('every opposite has a pair', () {
    for (final i in byId('opposites').items) {
      expect(i.opposite, isNotNull, reason: i.label);
    }
  });

  test('section sizes match the requirements', () {
    expect(byId('letters').items, hasLength(26));
    expect(byId('numbers').items.map((i) => i.count), List.generate(20, (i) => i + 1));
    expect(byId('days').items, hasLength(7));
    for (final id in [
      'food',
      'appliances',
      'clothing',
      'sports',
      'park',
      'school',
      'farm_animals',
      'wild_animals',
      'vehicles',
      'fruits',
      'vegetables',
      'colors',
    ]) {
      expect(byId(id).items, hasLength(10), reason: id);
    }
  });

  test('words has 5 words for every letter', () {
    final groups = byId('words').groups;
    expect(groups.map((g) => g.label).join(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    for (final g in groups) {
      expect(g.items, hasLength(5), reason: g.label);
      for (final w in g.items) {
        expect(w.label.toUpperCase(), contains(g.label), reason: w.label);
      }
    }
  });

  test('shapes: 10 shapes, then lines and signs', () {
    expect(byId('shapes').items.map((i) => i.label).skip(10), [
      'Vertical Line',
      'Horizontal Line',
      'Plus',
      'Minus',
      'Cross',
      'Check',
      'Equal',
    ]);
  });

  test('nursery rhymes are shown a verse at a time, each with a picture', () {
    for (final c in content.categories.where((c) => c.section == MenuSection.nurseryRhymes)) {
      expect(c.layout, CategoryLayout.story);
      expect(c.readOnlyInAutoRead, isTrue);
      for (final verse in c.items) {
        expect(verse.emoji, isNotNull, reason: verse.label);
      }
    }
  });

  test('short stories are under 100 words, as the note under the heading says', () {
    for (final c in content.categories.where((c) => c.section == MenuSection.shortStories)) {
      final words = c.items.expand((i) => i.label.split(RegExp(r'\s+'))).length;
      expect(words, lessThan(100), reason: c.title);
    }
  });

  test('short stories have 6 to 8 lines, each with a picture', () {
    for (final c in content.categories.where((c) => c.section == MenuSection.shortStories)) {
      expect(c.layout, CategoryLayout.story);
      expect(c.items.length, inInclusiveRange(6, 8), reason: c.title);
      for (final line in c.items) {
        expect(line.emoji, isNotNull, reason: line.label);
      }
    }
  });

  test('tracing covers every shape, A-Z, a-z and 1-20', () {
    // Tracing starts with the simple lines and signs, then the other shapes.
    final shapes = byId('shapes').items.map((i) => i.shape).toList();
    expect(byId('trace_shapes').groups.single.items.map((i) => i.shape), [...shapes.skip(10), ...shapes.take(10)]);
    expect(byId('trace_letters').groups.map((g) => g.items.length), [26, 26]);
    expect(byId('trace_numbers').groups.single.items, hasLength(20));
  });
}
