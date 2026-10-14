import 'package:flutter/material.dart';

import '../state/app_state.dart';

/// Shows the stickers collected so far, under the app title.
class StickerBar extends StatelessWidget implements PreferredSizeWidget {
  const StickerBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final stickers = AppStateScope.of(context).stickers;
    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.amber.shade200, width: 2),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          Expanded(
            child: stickers.isEmpty
                ? const Text(
                    'Finish a section or game to win a sticker!',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Fredoka', fontSize: 18, color: Colors.brown),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Newest first, so a new sticker is always visible.
                      for (final s in stickers.reversed)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Center(child: Text(s, style: const TextStyle(fontSize: 32))),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
