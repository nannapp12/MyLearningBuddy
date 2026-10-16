import 'dart:convert';
import 'dart:ui';

/// How a category's items are presented.
enum CategoryLayout { cards, groups, tracing, shapes, days, colors, pairs, findit, story }

/// One thing a child can look at, e.g. a letter, a word or an animal.
class LearningItem {
  const LearningItem({
    required this.label,
    this.emoji,
    this.image,
    this.color,
    this.subtitle,
    this.speak,
    this.highlight,
    this.count,
    this.countEmoji,
    this.shape,
    this.swatch,
    this.opposite,
    this.scale,
  });

  factory LearningItem.fromJson(Map<String, dynamic> json) => LearningItem(
    label: json['label'] as String,
    emoji: json['emoji'] as String?,
    image: json['image'] as String?,
    color: json['color'] == null ? null : parseHexColor(json['color'] as String),
    subtitle: json['subtitle'] as String?,
    speak: json['speak'] as String?,
    highlight: json['highlight'] as String?,
    count: json['count'] as int?,
    countEmoji: json['countEmoji'] as String?,
    shape: json['shape'] as String?,
    swatch: json['swatch'] == null ? null : parseHexColor(json['swatch'] as String),
    opposite: json['opposite'] == null ? null : LearningItem.fromJson(json['opposite'] as Map<String, dynamic>),
    scale: (json['scale'] as num?)?.toDouble(),
  );

  final String label;

  /// Emoji picture, used when there is no [image].
  final String? emoji;

  /// Asset path of an SVG picture.
  final String? image;

  /// Colour for a drawn shape.
  final Color? color;
  final String? subtitle;

  /// Text to say aloud instead of the default (see `Speech.item`).
  final String? speak;

  /// Letter to highlight within [label] (Words section).
  final String? highlight;

  /// Number of objects to show (Numbers section).
  final int? count;
  final String? countEmoji;
  final String? shape;
  final Color? swatch;

  /// The other half of an opposite pair, e.g. "Small" for "Big".
  final LearningItem? opposite;

  /// Picture size relative to normal, e.g. 0.45 for the small mouse.
  final double? scale;
}

/// A named set of items within a category, e.g. the words for "A".
class ItemGroup {
  const ItemGroup({required this.label, required this.items});

  factory ItemGroup.fromJson(Map<String, dynamic> json) =>
      ItemGroup(label: json['label'] as String, items: _items(json['items']));

  final String label;
  final List<LearningItem> items;
}

/// The headings the home screen's tiles are grouped under.
enum MenuSection {
  learning('Learning'),
  tracing('Tracing'),
  games('Games'),
  shortStories('Short Stories');

  const MenuSection(this.heading);

  final String heading;
}

/// One of the learning sections shown on the home screen.
class Category {
  const Category({
    required this.id,
    required this.title,
    this.section = MenuSection.learning,
    required this.emoji,
    this.image,
    required this.color,
    required this.layout,
    this.items = const [],
    this.groups = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    title: json['title'] as String,
    section: MenuSection.values.byName(json['section'] as String? ?? 'learning'),
    emoji: json['emoji'] as String,
    image: json['image'] as String?,
    color: parseHexColor(json['color'] as String),
    layout: CategoryLayout.values.byName(json['layout'] as String),
    items: _items(json['items']),
    groups: [for (final g in (json['groups'] as List? ?? const [])) ItemGroup.fromJson(g as Map<String, dynamic>)],
  );

  final String id;
  final String title;

  /// The heading the section's tile is under on the home screen.
  final MenuSection section;
  final String emoji;

  /// Asset path of an SVG picture shown instead of [emoji].
  final String? image;
  final Color color;
  final CategoryLayout layout;
  final List<LearningItem> items;
  final List<ItemGroup> groups;

  /// Tracing and stories have no voice (the owner's choice).
  bool get silent => layout == CategoryLayout.tracing || layout == CategoryLayout.story;
}

/// All learning content, loaded from `assets/content/content.json`.
class LearningContent {
  const LearningContent(this.categories);

  factory LearningContent.fromJsonString(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return LearningContent([for (final c in json['categories'] as List) Category.fromJson(c as Map<String, dynamic>)]);
  }

  final List<Category> categories;
}

List<LearningItem> _items(Object? json) => [
  for (final i in (json as List? ?? const [])) LearningItem.fromJson(i as Map<String, dynamic>),
];

Color parseHexColor(String hex) => Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
