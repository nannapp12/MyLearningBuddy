import 'package:flutter/material.dart';

import '../state/app_state.dart';

/// Easy / Medium / Hard: only one can be picked.
class DifficultyBar extends StatelessWidget {
  const DifficultyBar({super.key});

  static const height = 64.0;

  static const _colors = {
    Difficulty.easy: Color(0xFF43A047),
    Difficulty.medium: Color(0xFFFB8C00),
    Difficulty.hard: Color(0xFFE53935),
  };

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          for (final d in Difficulty.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _ModeButton(
                  difficulty: d,
                  color: _colors[d]!,
                  selected: state.difficulty == d,
                  onTap: () => state.difficulty = d,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.difficulty, required this.color, required this.selected, required this.onTap});

  final Difficulty difficulty;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: difficulty.label,
    excludeSemantics: true,
    child: Material(
      color: selected ? color : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: color, width: 3),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Center(
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${difficulty.icon} ${difficulty.label}',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
