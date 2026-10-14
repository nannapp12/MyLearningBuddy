import 'dart:math';

import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/speech.dart';
import '../state/app_state.dart';
import '../widgets/game_widgets.dart';
import '../widgets/home_button.dart';
import 'sticker_picker_screen.dart';

/// "Pop the B!": balloons with letters or numbers float up; pop the one asked for.
class PopScreen extends StatefulWidget {
  const PopScreen({super.key, required this.game, this.random});

  final Category game;
  final Random? random;

  static const rounds = 5;
  static const balloonsPerRound = 5;
  static const balloonColors = [
    Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047), Color(0xFFFB8C00), //
    Color(0xFF8E24AA), Color(0xFFD81B60), Color(0xFF00ACC1), Color(0xFFFBC02D),
  ];

  @override
  State<PopScreen> createState() => _PopScreenState();
}

class _Balloon {
  _Balloon(this.label, this.color, this.speed, this.phase);

  final String label;
  final Color color;
  final double speed;
  final double phase;
  bool popped = false;
}

class _PopScreenState extends State<PopScreen> with SingleTickerProviderStateMixin {
  late final Random _random = widget.random ?? Random();
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(seconds: 14))
    ..repeat();
  List<String>? _pool;
  List<String> _targets = [];
  int _round = 0;
  List<_Balloon> _balloons = [];
  bool _busy = false;
  int _shakes = 0;
  int? _wrong;

  AppState get _state => AppStateScope.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _state.speak([Speech.category(widget.game)]);
    });
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _start(List<String> pool) {
    setState(() {
      _pool = pool;
      _targets = ([...pool]..shuffle(_random)).take(PopScreen.rounds).toList();
      _round = 0;
    });
    _newRound();
  }

  void _newRound() {
    final target = _targets[_round];
    final others = [..._pool!.where((l) => l != target)]..shuffle(_random);
    final labels = [target, ...others.take(PopScreen.balloonsPerRound - 1)]..shuffle(_random);
    final colors = [...PopScreen.balloonColors]..shuffle(_random);
    setState(() {
      _balloons = [
        for (var i = 0; i < labels.length; i++)
          _Balloon(labels[i], colors[i % colors.length], 0.8 + _random.nextDouble() * 0.5, _random.nextDouble()),
      ];
      _busy = false;
      _wrong = null;
    });
    _ask();
  }

  /// What the voice says for a balloon: the letter, or the number's name.
  String _spoken(String label) => int.tryParse(label) == null ? label : Speech.number(int.parse(label));

  void _ask() => _state.speak([Speech.popThe, _spoken(_targets[_round])]);

  Future<void> _tap(int index) async {
    if (_busy) return;
    final b = _balloons[index];
    if (b.label != _targets[_round]) {
      setState(() {
        _wrong = index;
        _shakes++;
      });
      _state.speak([Speech.tryAgain]);
      return;
    }
    _state.pop();
    setState(() {
      b.popped = true;
      _busy = true;
    });
    await _state.celebrate(Speech.foundIt).timeout(const Duration(seconds: 6), onTimeout: () => true);
    if (!mounted) return;
    setState(() => _round++);
    if (_round < PopScreen.rounds) {
      _newRound();
    } else {
      _state.finish('pop');
      await finishWithReward(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.game.color;
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: gameAppBar(widget.game.title, color),
      body: SafeArea(child: _pool == null ? _modePicker(color) : _play(color)),
    );
  }

  Widget _modePicker(Color color) {
    Widget button(String text, List<String> pool) => Padding(
      padding: const EdgeInsets.all(12),
      child: FilledButton(
        onPressed: () => _start(pool),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(220, 140),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'Fredoka', fontSize: 64, fontWeight: FontWeight.w700),
        ),
      ),
    );
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          button('ABC', [for (var c = 65; c <= 90; c++) String.fromCharCode(c)]),
          button('123', [for (var n = 1; n <= 10; n++) '$n']),
        ],
      ),
    );
  }

  Widget _play(Color color) {
    final target = _targets[min(_round, _targets.length - 1)];
    return Column(
      children: [
        const SizedBox(height: 12),
        GameProgress(done: _round, total: PopScreen.rounds),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ReplayButton(color: color, onPressed: _ask),
              const SizedBox(width: 16),
              Text(
                'Pop the $target!',
                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 34, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => AnimatedBuilder(
              animation: _float,
              builder: (context, _) {
                final w = min(box.maxWidth / (PopScreen.balloonsPerRound + 0.5), 140.0);
                final h = w * 1.6;
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [for (var i = 0; i < _balloons.length; i++) _balloon(i, box, w, h)],
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: HomeButton(color: color),
        ),
      ],
    );
  }

  Widget _balloon(int i, BoxConstraints box, double w, double h) {
    final b = _balloons[i];
    final lane = box.maxWidth / _balloons.length;
    final q = (_float.value * b.speed * 2 + b.phase) % 1.0;
    final top = box.maxHeight - q * (box.maxHeight + h);
    return Positioned(
      left: lane * i + (lane - w) / 2,
      top: top,
      width: w,
      height: h,
      child: b.popped
          ? const _Burst()
          : GestureDetector(
              onTap: () => _tap(i),
              child: Shake(
                shakes: _wrong == i ? _shakes : 0,
                child: Semantics(
                  button: true,
                  label: 'Balloon ${b.label}',
                  excludeSemantics: true,
                  child: CustomPaint(
                    painter: _BalloonPainter(b.color),
                    child: Align(
                      alignment: const Alignment(0, -0.35),
                      child: Text(
                        b.label,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: w * 0.42,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: const [Shadow(color: Colors.black38, blurRadius: 3)],
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

/// A balloon: round body, shine, knot and string.
class _BalloonPainter extends CustomPainter {
  _BalloonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, bodyH = size.width * 1.15;
    final body = Rect.fromLTWH(0, 0, w, bodyH);
    canvas.drawOval(body, Paint()..color = color);
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, bodyH * 0.12, w * 0.22, bodyH * 0.2),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    final knot = Path()
      ..moveTo(w * 0.44, bodyH - 2)
      ..lineTo(w * 0.56, bodyH - 2)
      ..lineTo(w * 0.5, bodyH + w * 0.08)
      ..close();
    canvas.drawPath(knot, Paint()..color = color);
    final string = Path()
      ..moveTo(w * 0.5, bodyH + w * 0.08)
      ..quadraticBezierTo(w * 0.35, size.height * 0.85, w * 0.55, size.height);
    canvas.drawPath(
      string,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_BalloonPainter old) => old.color != color;
}

/// A quick burst of colourful dots where a balloon popped.
class _Burst extends StatelessWidget {
  const _Burst();

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 500),
    builder: (context, t, _) => Opacity(
      opacity: 1 - t,
      child: CustomPaint(painter: _BurstPainter(t), size: Size.infinite),
    ),
  );
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.width * 0.55);
    for (var i = 0; i < 12; i++) {
      final a = i * pi / 6;
      final r = size.width * (0.15 + 0.55 * t);
      canvas.drawCircle(
        c + Offset(cos(a), sin(a)) * r,
        size.width * 0.06 * (1 - t * 0.5),
        Paint()..color = PopScreen.balloonColors[i % PopScreen.balloonColors.length],
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
