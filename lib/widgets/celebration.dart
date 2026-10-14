import 'package:flutter/material.dart';

/// A short "Great job!" popup shown when a star is earned.
Future<void> showCelebration(BuildContext context, {String message = 'Great job!'}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: const Icon(Icons.star_rounded, color: Colors.amber, size: 120),
            ),
            Text(message, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(minimumSize: const Size(160, 64)),
              child: const Icon(Icons.check_rounded, size: 40, semanticLabel: 'OK'),
            ),
          ],
        ),
      ),
    ),
  );
}
