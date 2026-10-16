import 'package:flutter/material.dart';

import '../state/app_state.dart';

/// The auto-read on/off button, under Easy / Medium / Hard.
class AutoReadBar extends StatelessWidget {
  const AutoReadBar({super.key});

  static const height = 64.0;
  static const _color = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final on = state.autoRead;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Semantics(
        button: true,
        toggled: on,
        label: 'Auto-read',
        excludeSemantics: true,
        child: Material(
          color: on ? _color : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(color: _color, width: 3),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: () {
              state.pop();
              state.autoRead = !on;
            },
            child: SizedBox(
              height: 52,
              child: Center(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      on ? '🔊 Auto-read: ON' : '🔈 Auto-read: OFF',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: on ? Colors.white : _color,
                      ),
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
}
