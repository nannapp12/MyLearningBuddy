import 'package:flutter/material.dart';

import '../services/speech.dart';
import '../state/app_state.dart';

/// A short "Great job!" popup, with a chime and the message spoken aloud.
///
/// Tapping anywhere on it closes it. With [goHome], closing it also returns to
/// the main menu (used when a whole section is finished).
Future<void> showCelebration(BuildContext context, {String message = Speech.greatJob, bool goHome = false}) async {
  AppStateScope.of(context).celebrate(message);
  final navigator = Navigator.of(context);
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
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
                child: goHome
                    ? const Icon(Icons.home_rounded, size: 40, semanticLabel: 'Home')
                    : const Icon(Icons.check_rounded, size: 40, semanticLabel: 'OK'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (goHome) navigator.popUntil((route) => route.isFirst);
}
