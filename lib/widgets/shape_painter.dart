import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws one of the basic shapes from the Shapes section.
class ShapePainter extends CustomPainter {
  const ShapePainter(this.shape, this.color);

  final String shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(pathOf(shape, size), Paint()..color = color);

  /// The outline of [shape], centred in [size].
  static Path pathOf(String shape, Size size) {
    final s = math.min(size.width, size.height);
    final c = size.center(Offset.zero);
    final box = Rect.fromCenter(center: c, width: s, height: s);
    return switch (shape) {
      'circle' => Path()..addOval(box),
      'square' => Path()..addRect(box.deflate(s * 0.05)),
      'rectangle' => Path()..addRect(Rect.fromCenter(center: c, width: s, height: s * 0.6)),
      'oval' => Path()..addOval(Rect.fromCenter(center: c, width: s, height: s * 0.65)),
      'triangle' => _polygon(c, s / 2, 3),
      'diamond' =>
        Path()
          ..moveTo(c.dx, box.top)
          ..lineTo(c.dx + s * 0.35, c.dy)
          ..lineTo(c.dx, box.bottom)
          ..lineTo(c.dx - s * 0.35, c.dy)
          ..close(),
      'pentagon' => _polygon(c, s / 2, 5),
      'hexagon' => _polygon(c, s / 2, 6),
      'star' => _star(c, s / 2, s / 4.6),
      'heart' => _heart(box),
      // Lines and signs, drawn as thick bars so they can be traced over.
      'vertical_line' => _bar(c.translate(0, -s * 0.45), c.translate(0, s * 0.45), s * 0.14),
      'horizontal_line' => _bar(c.translate(-s * 0.45, 0), c.translate(s * 0.45, 0), s * 0.14),
      'plus' => _union([
        _bar(c.translate(0, -s * 0.4), c.translate(0, s * 0.4), s * 0.14),
        _bar(c.translate(-s * 0.4, 0), c.translate(s * 0.4, 0), s * 0.14),
      ]),
      'minus' => _bar(c.translate(-s * 0.4, 0), c.translate(s * 0.4, 0), s * 0.14),
      'cross' => _union([
        _bar(c.translate(-s * 0.32, -s * 0.32), c.translate(s * 0.32, s * 0.32), s * 0.14),
        _bar(c.translate(s * 0.32, -s * 0.32), c.translate(-s * 0.32, s * 0.32), s * 0.14),
      ]),
      'check' => _union([
        _bar(c.translate(-s * 0.36, s * 0.02), c.translate(-s * 0.1, s * 0.28), s * 0.14),
        _bar(c.translate(-s * 0.1, s * 0.28), c.translate(s * 0.38, -s * 0.28), s * 0.14),
      ]),
      'equal' => _union([
        _bar(c.translate(-s * 0.4, -s * 0.15), c.translate(s * 0.4, -s * 0.15), s * 0.14),
        _bar(c.translate(-s * 0.4, s * 0.15), c.translate(s * 0.4, s * 0.15), s * 0.14),
      ]),
      _ => Path(),
    };
  }

  /// A thick bar with round ends from [from] to [to].
  static Path _bar(Offset from, Offset to, double thickness) {
    final d = to - from;
    final along = d / d.distance * (thickness / 2);
    final across = Offset(-along.dy, along.dx);
    return Path()
      ..moveTo((from + across).dx, (from + across).dy)
      ..lineTo((to + across).dx, (to + across).dy)
      ..arcToPoint(to - across, radius: Radius.circular(thickness / 2))
      ..lineTo((from - across).dx, (from - across).dy)
      ..arcToPoint(from + across, radius: Radius.circular(thickness / 2))
      ..close();
  }

  /// One outline around overlapping bars (so the tracing guide has no lines inside).
  static Path _union(List<Path> paths) => paths.reduce((a, b) => Path.combine(PathOperation.union, a, b));

  static Path _polygon(Offset c, double r, int sides) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final a = -math.pi / 2 + 2 * math.pi * i / sides;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  static Path _star(Offset c, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + math.pi * i / 5;
      final p = c + Offset(math.cos(a), math.sin(a)) * (i.isEven ? outer : inner);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  static Path _heart(Rect b) {
    final w = b.width, h = b.height, l = b.left, t = b.top;
    return Path()
      ..moveTo(l + w / 2, t + h * 0.92)
      ..cubicTo(l - w * 0.15, t + h * 0.5, l + w * 0.12, t - h * 0.05, l + w / 2, t + h * 0.25)
      ..cubicTo(l + w * 0.88, t - h * 0.05, l + w * 1.15, t + h * 0.5, l + w / 2, t + h * 0.92)
      ..close();
  }

  @override
  bool shouldRepaint(ShapePainter old) => old.shape != shape || old.color != color;
}
