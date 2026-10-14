import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Stars across the top of a game: one per round, filled when done.
class GameProgress extends StatelessWidget {
  const GameProgress({super.key, required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < total; i++)
        AnimatedScale(
          scale: i < done ? 1.15 : 1,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            i < done ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < done ? Colors.amber : Colors.black26,
            size: 44,
          ),
        ),
    ],
  );
}

/// A big speaker button that says the question again.
class ReplayButton extends StatelessWidget {
  const ReplayButton({super.key, required this.color, required this.onPressed});

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    iconSize: 44,
    tooltip: 'Say it again',
    style: IconButton.styleFrom(backgroundColor: color),
    onPressed: onPressed,
    icon: const Icon(Icons.volume_up_rounded),
  );
}

/// Shakes its child sideways each time [shakes] changes.
class Shake extends StatelessWidget {
  const Shake({super.key, required this.shakes, required this.child});

  final int shakes;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    key: ValueKey(shakes),
    tween: Tween(begin: shakes == 0 ? 1 : 0, end: 1),
    duration: const Duration(milliseconds: 500),
    builder: (context, t, child) {
      final dx = math.sin(t * math.pi * 6) * 16 * (1 - t);
      return Transform.translate(offset: Offset(dx, 0), child: child);
    },
    child: child,
  );
}

/// The coloured top bar shared by the games, with a big back button.
PreferredSizeWidget gameAppBar(String title, Color color) => AppBar(
  title: Text(title),
  backgroundColor: color,
  foregroundColor: Colors.white,
  toolbarHeight: 80,
  leadingWidth: 80,
  iconTheme: const IconThemeData(color: Colors.white, size: 48),
  titleTextStyle: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
);
