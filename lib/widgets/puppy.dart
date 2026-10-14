import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/speech.dart';
import '../state/app_state.dart';

/// The friendly puppy hops around the screen, says [message] (by default
/// "Woof woof! You did it!") and wags its tail. Completes when it has
/// finished, or when tapped.
///
/// [short] is a quicker hop, used when coming back to the main menu.
/// With [waitForTap] the puppy sits with its message until the first tap and
/// only then speaks and hops: browsers only allow sound after a tap.
Future<void> showPuppy(
  BuildContext context, {
  String message = Speech.puppy,
  bool short = false,
  bool waitForTap = false,
}) {
  final done = Completer<void>();
  final state = AppStateScope.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => PuppyShow(
      message: message,
      short: short,
      waitForTap: waitForTap,
      onStart: () => state.speak([message]),
      onDone: () {
        if (done.isCompleted) return;
        entry.remove();
        done.complete();
      },
    ),
  );
  Overlay.of(context).insert(entry);
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
  const PuppyShow({
    super.key,
    required this.onDone,
    required this.onStart,
    this.message = Speech.puppy,
    this.short = false,
    this.waitForTap = false,
  });

  final VoidCallback onDone;

  /// Called when the puppy starts hopping (to say [message]).
  final VoidCallback onStart;
  final String message;
  final bool short;
  final bool waitForTap;

  static const duration = Duration(milliseconds: 5200);
  static const shortDuration = Duration(milliseconds: 3200);

  @override
  State<PuppyShow> createState() => _PuppyShowState();
}

class _PuppyShowState extends State<PuppyShow> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.short ? PuppyShow.shortDuration : PuppyShow.duration)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.onDone();
        });
  late bool _waiting = widget.waitForTap;

  @override
  void initState() {
    super.initState();
    if (!_waiting) _start();
  }

  void _start() {
    _waiting = false;
    widget.onStart();
    _c.forward();
  }

  void _tap() {
    if (_waiting) {
      setState(_start);
    } else {
      widget.onDone();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// A quick hop in and a little bounce, for coming back to the main menu.
  static const _shortHops = [
    (-0.3, 0.25, 0.00, 0.25, 0.40),
    (0.25, 0.50, 0.25, 0.45, 0.45),
    (0.50, 0.50, 0.55, 0.68, 0.18),
  ];

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
      onTap: _tap,
      child: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final size = math.min(box.maxWidth, box.maxHeight) * 0.34;
            final ground = box.maxHeight - size - 24;
            var x = 0.5, lift = 0.0, facingLeft = false, squash = 1.0;
            // While waiting for the first tap the puppy just sits in the middle.
            final hops = _waiting
                ? const <(double, double, double, double, double)>[]
                : (widget.short ? _shortHops : _hops);
            for (final (x0, x1, t0, t1, h) in hops) {
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
            final sitting = _waiting || t > (widget.short ? 0.45 : 0.55);
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
                    child: _Bubble(widget.message),
                  ),
                if (_waiting) const Positioned(left: 0, right: 0, top: 32, child: Center(child: _TapHint())),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A gently pulsing "Tap to play" hint.
class _TapHint extends StatelessWidget {
  const _TapHint();

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.9, end: 1.1),
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeInOut,
    builder: (context, s, child) => Transform.scale(scale: s, child: child),
    child: Material(
      color: const Color(0xFFFFCA28),
      borderRadius: BorderRadius.circular(32),
      elevation: 4,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        child: Text(
          '👆 Tap to play',
          style: TextStyle(fontFamily: 'Fredoka', fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xFF5D4037)),
        ),
      ),
    ),
  );
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
