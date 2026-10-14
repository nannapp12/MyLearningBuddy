import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/speech.dart';
import '../state/app_state.dart';
import '../widgets/celebration.dart';
import '../widgets/home_button.dart';
import '../widgets/star_badge.dart';
import '../widgets/label_grid.dart';

/// Lets the child pick a letter or number to trace.
class TracingPickerScreen extends StatefulWidget {
  const TracingPickerScreen({super.key, required this.category});

  final Category category;

  @override
  State<TracingPickerScreen> createState() => _TracingPickerScreenState();
}

class _TracingPickerScreenState extends State<TracingPickerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppStateScope.of(context).speak([Speech.category(widget.category)]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    return DefaultTabController(
      length: category.groups.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(category.title),
          backgroundColor: category.color,
          foregroundColor: Colors.white,
          toolbarHeight: 80,
          leadingWidth: 80,
          iconTheme: const IconThemeData(color: Colors.white, size: 48),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          actions: const [StarBadge()],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            labelStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            tabs: [for (final g in category.groups) Tab(text: g.label, height: 64)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final g in category.groups)
              LabelGrid(
                color: category.color,
                labels: [for (final i in g.items) i.label],
                onTap: (i) => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TracingScreen(
                      category: category,
                      characters: [for (final item in g.items) item.label],
                      index: i,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Stroke {
  _Stroke(this.color, this.width);

  final Color color;
  final double width;
  final List<Offset> points = [];
}

/// A drawing canvas over a faint guide of a letter or number, with a button to
/// move on to the next one in [characters].
class TracingScreen extends StatefulWidget {
  const TracingScreen({super.key, required this.category, required this.characters, required this.index});

  final Category category;
  final List<String> characters;
  final int index;

  static const crayons = [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange];

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  final List<_Stroke> _strokes = [];
  Color _color = TracingScreen.crayons.first;
  double _width = 24;
  late int _index = widget.index;

  String get _character => widget.characters[_index];
  bool get _hasNext => _index < widget.characters.length - 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppStateScope.of(context).speak([Speech.trace(_character)]);
    });
  }

  void _next() {
    setState(() {
      _index++;
      _strokes.clear();
    });
    AppStateScope.of(context).speak([Speech.trace(_character)]);
  }

  Future<void> _done() async {
    final state = AppStateScope.of(context);
    final awarded = state.finish('tracing/$_character');
    await showCelebration(context, message: awarded ? Speech.greatJob : Speech.wellDone);
    if (mounted) setState(_strokes.clear);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.category.color;
    return Scaffold(
      appBar: AppBar(
        title: Text('Trace $_character'),
        backgroundColor: color,
        foregroundColor: Colors.white,
        // A big back button that small fingers can hit.
        toolbarHeight: 80,
        leadingWidth: 80,
        iconTheme: const IconThemeData(color: Colors.white, size: 48),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        actions: const [StarBadge()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: ColoredBox(
                    color: Colors.white,
                    child: GestureDetector(
                      onPanStart: (d) =>
                          setState(() => _strokes.add(_Stroke(_color, _width)..points.add(d.localPosition))),
                      onPanUpdate: (d) => setState(() => _strokes.last.points.add(d.localPosition)),
                      child: CustomPaint(
                        painter: _TracingPainter(_character, _strokes),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final c in TracingScreen.crayons)
                    _RoundButton(
                      color: c,
                      selected: c == _color,
                      label: 'Crayon',
                      onTap: () => setState(() => _color = c),
                    ),
                  const SizedBox(width: 8),
                  for (final w in [16.0, 32.0])
                    _RoundButton(
                      color: Colors.grey.shade300,
                      selected: w == _width,
                      label: w < 20 ? 'Thin' : 'Thick',
                      onTap: () => setState(() => _width = w),
                      child: Container(
                        width: w * 0.8,
                        height: w * 0.8,
                        decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    iconSize: 40,
                    tooltip: 'Try again',
                    onPressed: () => setState(_strokes.clear),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  IconButton.filled(
                    iconSize: 40,
                    tooltip: 'Done',
                    style: IconButton.styleFrom(backgroundColor: color),
                    onPressed: _strokes.isEmpty ? null : _done,
                    icon: const Icon(Icons.check_rounded),
                  ),
                  IconButton.filled(
                    iconSize: 40,
                    tooltip: 'Next',
                    style: IconButton.styleFrom(backgroundColor: color),
                    onPressed: _hasNext ? _next : null,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                  HomeButton(color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.color,
    required this.selected,
    required this.label,
    required this.onTap,
    this.child,
  });

  final Color color;
  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? Colors.black : Colors.black12, width: selected ? 4 : 1),
        ),
        child: child,
      ),
    ),
  );
}

class _TracingPainter extends CustomPainter {
  _TracingPainter(this.character, this.strokes);

  final String character;
  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGuide(canvas, size);
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length == 1) {
        canvas.drawCircle(s.points.first, s.width / 2, paint..style = PaintingStyle.fill);
        continue;
      }
      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (final p in s.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  /// Draws the character large and faint, with a grey outline to follow.
  void _paintGuide(Canvas canvas, Size size) {
    TextPainter layout(Paint foreground) => TextPainter(
      text: TextSpan(
        text: character,
        style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold, foreground: foreground),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final fill = layout(Paint()..color = Colors.grey.shade200);
    final scale = (size.height * 0.85 / fill.height).clamp(0.0, size.width * 0.9 / fill.width);
    canvas
      ..save()
      ..translate((size.width - fill.width * scale) / 2, (size.height - fill.height * scale) / 2)
      ..scale(scale);
    fill.paint(canvas, Offset.zero);
    layout(
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.grey.shade500,
    ).paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TracingPainter old) => true;
}
