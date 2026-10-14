import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/speech.dart';
import '../state/app_state.dart';

/// The friendly puppy hops across the screen, says "Woof woof! You did it!"
/// and wags its tail. Completes when it has finished (or is tapped).
Future<void> showPuppy(BuildContext context) {
  final done = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => PuppyShow(
      onDone: () {
        if (done.isCompleted) return;
        entry.remove();
        done.complete();
      },
    ),
  );
  Overlay.of(context).insert(entry);
  AppStateScope.of(context).speak([Speech.puppy]);
  return done.future;
}

/// A puppy drawn from two pictures, so its tail can wag.
class Puppy extends StatelessWidget {
  const Puppy({super.key, required this.size, this.tailAngle = 0});

  final double size;
  final double tailAngle;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size * 1.25,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: size * 0.68,
          top: size * 0.48,
          width: size * 0.28,
          height: size * 0.28,
          child: Transform.rotate(
            angle: tailAngle,
            alignment: Alignment.bottomLeft,
            child: SvgPicture.asset('assets/images/puppy_tail.svg'),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          width: size,
          height: size,
          child: SvgPicture.asset('assets/images/puppy.svg', semanticsLabel: 'Puppy'),
        ),
      ],
    ),
  );
}

class PuppyShow extends StatefulWidget {
  const PuppyShow({super.key, required this.onDone});

  final VoidCallback onDone;

  static const duration = Duration(milliseconds: 5200);

  @override
  State<PuppyShow> createState() => _PuppyShowState();
}

class _PuppyShowState extends State<PuppyShow> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: PuppyShow.duration)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Hops as (start x, end x, start time, end time, height), x as a fraction of the width.
  static const _hops = [
    (-0.3, 0.15, 0.00, 0.14, 0.45),
    (0.15, 0.45, 0.14, 0.27, 0.55),
    (0.45, 0.75, 0.27, 0.40, 0.45),
    (0.75, 0.50, 0.40, 0.55, 0.60),
    (0.50, 0.50, 0.62, 0.70, 0.20),
    (0.50, 0.50, 0.70, 0.78, 0.20),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onDone,
      child: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final size = math.min(box.maxWidth, box.maxHeight) * 0.34;
            final ground = box.maxHeight - size - 24;
            var x = 0.5, lift = 0.0, facingLeft = false, squash = 1.0;
            for (final (x0, x1, t0, t1, h) in _hops) {
              if (t >= t0 && t <= t1) {
                final p = (t - t0) / (t1 - t0);
                x = x0 + (x1 - x0) * p;
                lift = h * box.maxHeight * 4 * p * (1 - p);
                facingLeft = x1 < x0;
                squash = p < 0.12 || p > 0.88 ? 0.9 : 1.0;
                break;
              }
              if (t > t1) x = x1;
            }
            final sitting = t > 0.55;
            final wag = math.sin(t * 60) * 0.45;
            final left = x * box.maxWidth - size * 0.6;
            return Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: Colors.black.withValues(alpha: 0.12))),
                Positioned(
                  left: left,
                  top: ground - lift,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.diagonal3Values(facingLeft ? -1 : 1, squash, 1),
                    child: Puppy(size: size, tailAngle: wag),
                  ),
                ),
                if (sitting)
                  Positioned(
                    left: (left + size * 0.1).clamp(8, box.maxWidth - 280),
                    top: math.max(8, ground - lift - 84),
                    child: const _Bubble('Woof woof! You did it!'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 4,
    borderRadius: BorderRadius.circular(24),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6D4C41),
        ),
      ),
    ),
  );
}
