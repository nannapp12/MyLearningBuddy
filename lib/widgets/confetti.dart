import 'dart:math';

import 'package:flutter/material.dart';

/// Colourful confetti falling from the top of the screen for a few seconds.
/// Taps pass through it.
class Confetti extends StatefulWidget {
  const Confetti({super.key, this.pieces = 90, this.seed});

  final int pieces;
  final int? seed;

  static const duration = Duration(seconds: 6);

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _Piece {
  _Piece(Random r)
    : x = r.nextDouble(),
      delay = r.nextDouble() * 0.4,
      fall = 0.4 + r.nextDouble() * 0.25,
      sway = 0.02 + r.nextDouble() * 0.05,
      spin = (r.nextDouble() - 0.5) * 20,
      size = 8 + r.nextDouble() * 10,
      round = r.nextBool(),
      color = _colors[r.nextInt(_colors.length)];

  static const _colors = [
    Color(0xFFE53935), Color(0xFFFB8C00), Color(0xFFFDD835), Color(0xFF43A047), //
    Color(0xFF1E88E5), Color(0xFF8E24AA), Color(0xFFD81B60), Color(0xFF00ACC1),
  ];

  final double x, delay, fall, sway, spin, size;
  final bool round;
  final Color color;
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Confetti.duration)..forward();
  late final List<_Piece> _pieces = [
    for (var i = 0; i < widget.pieces; i++) _Piece(Random(widget.seed ?? DateTime.now().microsecond + i * 7919)),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_pieces, _c.value), size: Size.infinite),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      // Progress of this piece's fall, from above the top to below the bottom.
      final q = (t - p.delay) / p.fall;
      if (q <= 0 || q >= 1) continue;
      final y = -20 + q * (size.height + 40);
      final x = (p.x + sin(q * 12 + p.x * 10) * p.sway) * size.width;
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(q * p.spin);
      final paint = Paint()..color = p.color;
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2.5, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

/// A clapping-hands emoji that claps (squeezes and bounces) for a few seconds.
class ClappingHands extends StatefulWidget {
  const ClappingHands({super.key, this.size = 56});

  final double size;

  @override
  State<ClappingHands> createState() => _ClappingHandsState();
}

class _ClappingHandsState extends State<ClappingHands> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, child) {
      // About 8 claps, then rest.
      final beat = _c.value < 1 ? sin(_c.value * pi * 16).abs() : 0.0;
      return Transform.scale(scaleX: 1 - beat * 0.25, scaleY: 1 + beat * 0.1, child: child);
    },
    child: Text('👏', style: TextStyle(fontSize: widget.size)),
  );
}
