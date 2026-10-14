import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_learning_buddy/models/content.dart';

void main() {
  final content = LearningContent.fromJsonString(File('assets/content/content.json').readAsStringSync());
  Category byId(String id) => content.categories.firstWhere((c) => c.id == id);

  test('has the 24 sections in order', () {
    expect(content.categories.map((c) => c.title), [
      'Letters',
      'Numbers',
      'Words',
      'Tracing',
      'Shapes',
      'Days of the Week',
      'Farm Animals',
      'Wild Animals',
      'Vehicles',
      'Fruits',
      'Vegetables',
      'Colors',
      'Body Parts',
      'Family',
      'Emotions',
      'Opposites',
      'Weather and Seasons',
      'Months',
      'Birds',
      'Sea Creatures',
      'Insects',
      'Community Helpers',
      'Things Around the House',
      'Places We Visit',
    ]);
  });

  test('sections have at most 10 items, except where the subject needs more', () {
    const longer = {'letters', 'numbers', 'words', 'tracing', 'months'};
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
    for (final id in ['shapes', 'farm_animals', 'wild_animals', 'vehicles', 'fruits', 'vegetables', 'colors']) {
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

  test('tracing covers A-Z, a-z and 1-20', () {
    final groups = byId('tracing').groups;
    expect(groups.map((g) => g.items.length), [26, 26, 20]);
  });
}
