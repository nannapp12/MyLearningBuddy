import 'package:flutter/material.dart';

import '../models/content.dart';
import '../widgets/star_badge.dart';
import 'section_screen.dart';

/// Lets the child pick a group, e.g. a letter in the Words section.
class GroupPickerScreen extends StatelessWidget {
  const GroupPickerScreen({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        backgroundColor: category.color,
        foregroundColor: Colors.white,
        actions: const [StarBadge()],
      ),
      body: LabelGrid(
        color: category.color,
        labels: [for (final g in category.groups) g.label],
        onTap: (i) {
          final group = category.groups[i];
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SectionScreen(
                category: category,
                items: group.items,
                finishKey: '${category.id}/${group.label}',
                title: '${category.title}: ${group.label}',
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A grid of big tappable labels (letters, numbers).
class LabelGrid extends StatelessWidget {
  const LabelGrid({super.key, required this.labels, required this.color, required this.onTap});

  final List<String> labels;
  final Color color;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: labels.length,
      itemBuilder: (context, i) => Material(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onTap(i),
          child: Center(
            child: Text(
              labels[i],
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
