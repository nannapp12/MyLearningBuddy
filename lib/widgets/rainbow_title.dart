import 'package:flutter/material.dart';

/// The app name with each letter in its own bright colour.
class RainbowTitle extends StatelessWidget {
  const RainbowTitle(this.text, {super.key, this.fontSize = 34});

  final String text;
  final double fontSize;

  static const _colors = [
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFFFBC02D),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFD81B60),
    Color(0xFF00ACC1),
  ];

  @override
  Widget build(BuildContext context) {
    var i = 0;
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                for (final ch in text.characters)
                  TextSpan(
                    text: ch,
                    // Spaces don't use up a colour.
                    style: ch == ' ' ? null : TextStyle(color: _colors[i++ % _colors.length]),
                  ),
              ],
            ),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              shadows: const [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}
