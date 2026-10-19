import 'dart:math';

import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/speech.dart';
import '../state/app_state.dart';
import '../widgets/game_widgets.dart';
import '../widgets/home_button.dart';
import '../widgets/item_card.dart';
import '../widgets/section_picker.dart';
import 'sticker_picker_screen.dart';

/// Matching: pick a section, then draw a line from each picture to its name.
/// Three rounds of four pictures. Tapping a picture and then a name works too.
class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key, required this.game, required this.content, this.random});

  final Category game;
  final LearningContent content;
  final Random? random;

  static const rounds = 3;
  static const perRound = 4;

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  late final Random _random = widget.random ?? Random();
  final _stackKey = GlobalKey();
  final _pictureKeys = List.generate(MatchingScreen.perRound, (_) => GlobalKey());
  final _nameKeys = List.generate(MatchingScreen.perRound, (_) => GlobalKey());

  Category? _section;
  List<LearningItem> _pool = [];
  int _round = 0;
  List<LearningItem> _pictures = [];
  List<LearningItem> _names = [];
  final Set<int> _matched = {}; // indexes into _pictures
  int? _selected; // a picture tapped, waiting for its name
  int? _dragFrom;
  Offset? _dragTo;
  int _shakes = 0;
  int? _wrongName;

  AppState get _state => AppStateScope.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _state.speak([Speech.category(widget.game)]);
    });
  }

  void _start(Category section) {
    // Easy / Medium / Hard: pictures from the section's first 5, 8 or all items.
    _pool = [..._state.limited(section.items)];
    setState(() {
      _section = section;
      _round = 0;
    });
    _newRound();
  }

  void _newRound() {
    final pictures = ([..._pool]..shuffle(_random)).take(MatchingScreen.perRound).toList();
    setState(() {
      _pictures = pictures;
      _names = [...pictures]..shuffle(_random);
      _matched.clear();
      _selected = null;
      _wrongName = null;
    });
  }

  Future<void> _try(int picture, int name) async {
    if (_matched.contains(picture)) return;
    final item = _pictures[picture];
    if (_names[name] != item) {
      setState(() {
        _selected = null;
        _wrongName = name;
        _shakes++;
      });
      _state.speak([Speech.tryAgain]);
      return;
    }
    setState(() {
      _matched.add(picture);
      _selected = null;
    });
    if (_matched.length < _pictures.length) {
      _state.speak([Speech.item(item)]);
      return;
    }
    // All four matched: on to the next round, or the puppy and stickers.
    await _state.celebrate(Speech.item(item)).timeout(const Duration(seconds: 4), onTimeout: () => true);
    if (!mounted) return;
    setState(() => _round++);
    if (_round < MatchingScreen.rounds) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) _newRound();
      return;
    }
    _state.finish('matching/${_section!.id}');
    await finishWithReward(context);
  }

  void _tapPicture(int i) {
    if (_matched.contains(i)) return;
    setState(() => _selected = i);
    _state.speak([Speech.item(_pictures[i])]);
  }

  void _tapName(int i) {
    final selected = _selected;
    if (selected != null) {
      _try(selected, i);
    } else {
      _state.speak([Speech.item(_names[i])]);
    }
  }

  /// Where [key]'s card is, in the coordinates of the play area.
  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final area = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || area == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero, ancestor: area) & box.size;
  }

  int? _hit(List<GlobalKey> keys, Offset point) {
    for (var i = 0; i < keys.length; i++) {
      if (_rectOf(keys[i])?.inflate(8).contains(point) ?? false) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.game.color;
    return Scaffold(
      appBar: gameAppBar(widget.game.title, color),
      body: SafeArea(
        child: _section == null
            ? SectionPicker(content: widget.content, question: 'What shall we match?', onPick: _start)
            : _play(color),
      ),
    );
  }

  Widget _play(Color color) => Column(
    children: [
      const SizedBox(height: 12),
      GameProgress(done: _round, total: MatchingScreen.rounds),
      const Padding(
        padding: EdgeInsets.all(8),
        child: FittedBox(
          child: Text(
            'Draw a line to the matching name!',
            style: TextStyle(fontFamily: 'Fredoka', fontSize: 30, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      Expanded(
        child: GestureDetector(
          onPanStart: (d) {
            final from = _hit(_pictureKeys, d.localPosition);
            if (from == null || _matched.contains(from)) return;
            setState(() {
              _dragFrom = from;
              _dragTo = d.localPosition;
            });
          },
          onPanUpdate: (d) {
            if (_dragFrom != null) setState(() => _dragTo = d.localPosition);
          },
          onPanEnd: (_) {
            final from = _dragFrom, to = _dragTo;
            setState(() {
              _dragFrom = null;
              _dragTo = null;
            });
            if (from == null || to == null) return;
            final name = _hit(_nameKeys, to);
            if (name != null) _try(from, name);
          },
          child: Stack(
            key: _stackKey,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for (var i = 0; i < _pictures.length; i++)
                            Expanded(
                              child: Padding(padding: const EdgeInsets.all(6), child: _pictureCard(i, color)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 96), // room to draw the lines
                    Expanded(
                      child: Column(
                        children: [
                          for (var i = 0; i < _names.length; i++)
                            Expanded(
                              child: Padding(padding: const EdgeInsets.all(6), child: _nameCard(i, color)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(child: CustomPaint(painter: _LinesPainter(this, color))),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 4),
        child: HomeButton(color: color),
      ),
    ],
  );

  Widget _pictureCard(int i, Color color) {
    final matched = _matched.contains(i);
    final selected = _selected == i;
    return Material(
      key: _pictureKeys[i],
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: matched ? Colors.green : (selected ? color : Colors.transparent), width: 5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _tapPicture(i),
        child: Semantics(
          label: 'Picture ${_pictures[i].label}',
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: ItemPicture(category: _section!, item: _pictures[i]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameCard(int i, Color color) {
    final item = _names[i];
    final matched = _matched.contains(_pictures.indexOf(item));
    return Shake(
      shakes: _wrongName == i ? _shakes : 0,
      child: Material(
        key: _nameKeys[i],
        color: matched ? Colors.green.shade50 : Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: matched ? Colors.green : Colors.transparent, width: 5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _tapName(i),
          child: Semantics(
            label: 'Name ${item.label}',
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: FittedBox(
                  child: Text(
                    item.label,
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: matched ? Colors.green : color),
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

/// The lines between matched pictures and names, and the one being drawn.
class _LinesPainter extends CustomPainter {
  _LinesPainter(this.state, this.color);

  final _MatchingScreenState state;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Offset? rightEdge(int picture) {
      final r = state._rectOf(state._pictureKeys[picture]);
      return r == null ? null : Offset(r.right, r.center.dy);
    }

    final line = Paint()
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    for (final p in state._matched) {
      final name = state._names.indexOf(state._pictures[p]);
      final from = rightEdge(p), to = state._rectOf(state._nameKeys[name]);
      if (from == null || to == null) continue;
      canvas.drawLine(from, Offset(to.left, to.center.dy), line..color = Colors.green);
    }
    final dragFrom = state._dragFrom, dragTo = state._dragTo;
    if (dragFrom != null && dragTo != null) {
      final from = rightEdge(dragFrom);
      if (from != null) canvas.drawLine(from, dragTo, line..color = color);
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) => true;
}
