import 'package:flutter/material.dart';

import 'shape_painter.dart';

/// A grid of big tappable labels (letters, numbers) or shapes.
class LabelGrid extends StatelessWidget {
  const LabelGrid({super.key, required this.labels, this.shapes, required this.color, required this.onTap});

  final List<String> labels;

  /// Shapes to draw instead of the labels, e.g. "circle" (null for a label).
  final List<String?>? shapes;
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
          child: switch (shapes?[i]) {
            final String shape => Semantics(
              label: labels[i],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CustomPaint(painter: ShapePainter(shape, color), child: const SizedBox.expand()),
              ),
            ),
            null => Center(
              child: Text(
                labels[i],
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          },
        ),
      ),
    );
  }
}
