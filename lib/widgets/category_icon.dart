import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/content.dart';

/// A section's picture: its SVG image if it has one, otherwise its emoji.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, required this.size});

  final Category category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = category.image;
    if (image != null) return SvgPicture.asset(image, width: size, height: size, excludeFromSemantics: true);
    return Text(category.emoji, style: TextStyle(fontSize: size * 0.8));
  }
}
