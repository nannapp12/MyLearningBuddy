import 'package:flutter/material.dart';

import '../state/app_state.dart';

/// Shows the number of stars earned this session.
class StarBadge extends StatelessWidget {
  const StarBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final stars = AppStateScope.of(context).stars;
    return Semantics(
      label: '$stars stars',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(24)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 4),
            Text(
              '$stars',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
