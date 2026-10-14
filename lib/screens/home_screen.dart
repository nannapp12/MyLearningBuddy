import 'package:flutter/material.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import '../widgets/star_badge.dart';
import 'parent_area_screen.dart';
import 'section_screen.dart';
import 'tracing_screen.dart';

/// The child's home screen: one big tile per visible learning section.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.content});

  final LearningContent content;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final visible = [
      for (final c in content.categories)
        if (!state.isHidden(c.id)) c,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning Buddy'),
        actions: [
          const StarBadge(),
          IconButton(
            tooltip: 'Parents',
            icon: const Icon(Icons.lock_outline),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ParentAreaScreen(content: content))),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: (constraints.maxWidth / 220).floor().clamp(2, 6),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [for (final c in visible) _CategoryTile(category: c)],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  void _open(BuildContext context) {
    final Widget screen = switch (category.layout) {
      CategoryLayout.groups => SectionScreen.groups(category),
      CategoryLayout.tracing => TracingPickerScreen(category: category),
      _ => SectionScreen.items(category),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: category.color,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(child: Text(category.emoji, style: const TextStyle(fontSize: 80))),
              ),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(
                  category.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
