import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws one of the basic shapes from the Shapes section.
class ShapePainter extends CustomPainter {
  const ShapePainter(this.shape, this.color);

  final String shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final s = math.min(size.width, size.height);
    final c = size.center(Offset.zero);
    final box = Rect.fromCenter(center: c, width: s, height: s);
    switch (shape) {
      case 'circle':
        canvas.drawCircle(c, s / 2, paint);
      case 'square':
        canvas.drawRect(box.deflate(s * 0.05), paint);
      case 'rectangle':
        canvas.drawRect(Rect.fromCenter(center: c, width: s, height: s * 0.6), paint);
      case 'oval':
        canvas.drawOval(Rect.fromCenter(center: c, width: s, height: s * 0.65), paint);
      case 'triangle':
        canvas.drawPath(_polygon(c, s / 2, 3), paint);
      case 'diamond':
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, box.top)
            ..lineTo(c.dx + s * 0.35, c.dy)
            ..lineTo(c.dx, box.bottom)
            ..lineTo(c.dx - s * 0.35, c.dy)
            ..close(),
          paint,
        );
      case 'pentagon':
        canvas.drawPath(_polygon(c, s / 2, 5), paint);
      case 'hexagon':
        canvas.drawPath(_polygon(c, s / 2, 6), paint);
      case 'star':
        canvas.drawPath(_star(c, s / 2, s / 4.6), paint);
      case 'heart':
        canvas.drawPath(_heart(box), paint);
    }
  }

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
