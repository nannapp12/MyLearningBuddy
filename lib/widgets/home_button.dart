import 'package:flutter/material.dart';

/// A big "home" button that goes straight back to the main menu.
class HomeButton extends StatelessWidget {
  const HomeButton({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => FilledButton.tonal(
    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
    style: FilledButton.styleFrom(
      foregroundColor: color,
      backgroundColor: color.withValues(alpha: 0.15),
      minimumSize: const Size(96, 72),
    ),
    child: const Icon(Icons.home_rounded, size: 44, semanticLabel: 'Home'),
  );
}
