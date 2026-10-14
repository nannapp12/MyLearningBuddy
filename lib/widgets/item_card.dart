import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/content.dart';
import 'shape_painter.dart';

/// The large card showing a single item: picture, name and optional subtitle.
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.category, required this.item, this.isToday = false});

  final Category category;
  final LearningItem item;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: isToday ? BorderSide(color: category.color, width: 8) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ItemPicture(category: category, item: item),
              ),
            ),
            const SizedBox(height: 16),
            ItemLabel(item: item, color: category.color),
            if (item.subtitle != null)
              Text(item.subtitle!, style: textTheme.headlineSmall?.copyWith(color: Colors.black54)),
            if (isToday)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  label: Text('Today', style: textTheme.titleLarge?.copyWith(color: Colors.white)),
                  backgroundColor: category.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The item's picture: a shape, colour swatch, objects to count, emoji or letter.
class ItemPicture extends StatelessWidget {
  const ItemPicture({super.key, required this.category, required this.item});

  final Category category;
  final LearningItem item;

  @override
  Widget build(BuildContext context) {
    if (item.shape != null) {
      return AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(painter: ShapePainter(item.shape!, item.color ?? category.color)),
      );
    }
    if (item.swatch != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: item.swatch,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26, width: 3),
                ),
              ),
            ),
          ),
          if (item.emoji != null) Flexible(child: _Emoji(item.emoji!)),
        ],
      );
    }
    if (item.count != null) {
      // Rows of five, so children can count in fives.
      final rows = (item.count! / 5).ceil();
      return FittedBox(
        child: Column(
          children: [
            for (var r = 0; r < rows; r++)
              Text(
                List.filled(r == rows - 1 ? item.count! - r * 5 : 5, item.countEmoji ?? '●').join(' '),
                style: const TextStyle(fontSize: 64),
              ),
          ],
        ),
      );
    }
    if (item.image != null) {
      return FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.9,
        child: SvgPicture.asset(item.image!, fit: BoxFit.contain, semanticsLabel: item.label),
      );
    }
    if (item.emoji != null) return _Emoji(item.emoji!);
    // No picture yet: show the item's first letter (or the item itself, e.g. "Aa").
    final text = item.label.length <= 2 ? item.label : item.label[0];
    return FittedBox(
      child: Text(
        text,
        style: TextStyle(fontSize: 200, fontWeight: FontWeight.bold, color: category.color),
      ),
    );
  }
}

class _Emoji extends StatelessWidget {
  const _Emoji(this.emoji);

  final String emoji;

  @override
  Widget build(BuildContext context) => FittedBox(child: Text(emoji, style: const TextStyle(fontSize: 200)));
}

/// The item's name, with the [LearningItem.highlight] letter coloured.
class ItemLabel extends StatelessWidget {
  const ItemLabel({super.key, required this.item, required this.color});

  final LearningItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displayMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: item.count != null ? color : null, // Numbers show the numeral in colour.
    );
    final highlight = item.highlight;
    if (highlight == null) return FittedBox(child: Text(item.label, style: style));
    final i = item.label.toUpperCase().indexOf(highlight.toUpperCase());
    if (i < 0) return FittedBox(child: Text(item.label, style: style));
    return FittedBox(
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(text: item.label.substring(0, i)),
            TextSpan(
              text: item.label[i],
              style: TextStyle(color: color),
            ),
            TextSpan(text: item.label.substring(i + 1)),
          ],
        ),
      ),
    );
  }
}
