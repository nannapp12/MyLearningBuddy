import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/speech.dart';
import '../state/app_state.dart';
import 'item_card.dart';

/// One letter's words on a single card: the letter on top, its pictures below.
class WordGroupCard extends StatelessWidget {
  const WordGroupCard({super.key, required this.category, required this.group});

  final Category category;
  final ItemGroup group;

  @override
  Widget build(BuildContext context) {
    final letter = group.label;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Flexible(
              flex: 2,
              child: FittedBox(
                child: Text(
                  '$letter${letter.toLowerCase()}',
                  style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: category.color),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 7,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // One row when wide; otherwise 3 + 2.
                  final wide = constraints.maxWidth > constraints.maxHeight * 1.6;
                  final rows = wide ? [group.items] : [group.items.take(3).toList(), group.items.skip(3).toList()];
                  return Column(
                    children: [
                      for (final row in rows)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (final word in row)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: _WordTile(category: category, item: word),
                                  ),
                                ),
                              // Keep tiles the same width in a shorter row.
                              if (!wide && row.length < 3) const Spacer(),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({required this.category, required this.item});

  final Category category;
  final LearningItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: category.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => AppStateScope.of(context).speak([Speech.item(item)]),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ItemPicture(category: category, item: item),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 36,
                child: ItemLabel(item: item, color: category.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
