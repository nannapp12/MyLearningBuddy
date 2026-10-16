import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_learning_buddy/models/content.dart';

void main() {
  final content = LearningContent.fromJsonString(File('assets/content/content.json').readAsStringSync());
  Category byId(String id) => content.categories.firstWhere((c) => c.id == id);

  test('has the 25 learning sections, the 3 tracing sections and the Find It game in order', () {
    String names(MenuSection section) => [
      for (final c in content.categories)
        if (c.section == section) c.title,
    ].join(', ');
    expect(
      names(MenuSection.learning),
      'Letters, Numbers, Words, Farm Animals, Wild Animals, Birds, Sea Creatures, Insects, Vehicles, Fruits, '
      'Vegetables, Food, Colors, Shapes, Days of the Week, Months, Body Parts, Family, Emotions, '
      'Community Helpers, Places We Visit, Things Around the House, Opposites, Weather and Seasons, Phrases',
    );
    expect(names(MenuSection.tracing), 'Shapes, Letters, Numbers');
    expect(names(MenuSection.games), 'Find It');
    expect(names(MenuSection.shortStories), '');
    // In content.json the sections are listed in the order of the headings.
    final order = [for (final c in content.categories) c.section.index];
    expect(order, [...order]..sort());
  });

  test('sections have at most 10 items, except where the subject needs more', () {
    const longer = {'letters', 'numbers', 'words', 'months'};
    for (final c in content.categories) {
      if (!longer.contains(c.id)) expect(c.items.length, lessThanOrEqualTo(10), reason: c.title);
    }
    expect(byId('months').items, hasLength(12));
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
    for (final id in ['shapes', 'food', 'farm_animals', 'wild_animals', 'vehicles', 'fruits', 'vegetables', 'colors']) {
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

  test('tracing covers the 10 shapes, A-Z, a-z and 1-20', () {
    expect(byId('trace_shapes').groups.single.items.map((i) => i.shape), byId('shapes').items.map((i) => i.shape));
    expect(byId('trace_letters').groups.map((g) => g.items.length), [26, 26]);
    expect(byId('trace_numbers').groups.single.items, hasLength(20));
  });
}
