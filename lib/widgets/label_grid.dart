import 'package:flutter/material.dart';

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
