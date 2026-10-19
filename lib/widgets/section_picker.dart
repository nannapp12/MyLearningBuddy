import 'package:flutter/material.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import 'category_icon.dart';

/// Sections that work for the games: every item has a clear picture and a plain name.
List<Category> gameSections(LearningContent content) => [
  for (final c in content.categories)
    if (const {CategoryLayout.cards, CategoryLayout.shapes, CategoryLayout.colors}.contains(c.layout) &&
        c.section != MenuSection.phrases &&
        !const {'letters', 'numbers', 'months'}.contains(c.id) &&
        c.items.length >= 4 &&
        c.items.every((i) => (i.emoji ?? i.image ?? i.shape ?? i.swatch) != null && i.count == null))
      c,
];

/// "What shall we play with?": a grid of the sections a game can use.
class SectionPicker extends StatelessWidget {
  const SectionPicker({super.key, required this.content, required this.question, required this.onPick});

  final LearningContent content;
  final String question;
  final ValueChanged<Category> onPick;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final sections = [
      for (final c in gameSections(content))
        if (!state.isHidden(c.id)) c,
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            question,
            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 30, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: GridView.extent(
            padding: const EdgeInsets.all(16),
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final c in sections)
                Material(
                  color: c.color,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => onPick(c),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Expanded(
                            child: FittedBox(child: CategoryIcon(category: c, size: 100)),
                          ),
                          FittedBox(
                            child: Text(
                              c.title,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
