import 'dart:convert';
import 'dart:ui';

/// How a category's items are presented.
enum CategoryLayout { cards, groups, tracing, shapes, days, colors }

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
    this.weekday,
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
    weekday: json['weekday'] as int?,
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

  /// [DateTime.weekday] value (1 = Monday, 7 = Sunday).
  final int? weekday;
}

/// A named set of items within a category, e.g. the words for "A".
class ItemGroup {
  const ItemGroup({required this.label, required this.items});

  factory ItemGroup.fromJson(Map<String, dynamic> json) =>
      ItemGroup(label: json['label'] as String, items: _items(json['items']));

  final String label;
  final List<LearningItem> items;
}

/// One of the learning sections shown on the home screen.
class Category {
  const Category({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.layout,
    this.items = const [],
    this.groups = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    title: json['title'] as String,
    emoji: json['emoji'] as String,
    color: parseHexColor(json['color'] as String),
    layout: CategoryLayout.values.byName(json['layout'] as String),
    items: _items(json['items']),
    groups: [for (final g in (json['groups'] as List? ?? const [])) ItemGroup.fromJson(g as Map<String, dynamic>)],
  );

  final String id;
  final String title;
  final String emoji;
  final Color color;
  final CategoryLayout layout;
  final List<LearningItem> items;
  final List<ItemGroup> groups;
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
