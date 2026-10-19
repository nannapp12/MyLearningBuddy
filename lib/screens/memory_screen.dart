import 'dart:async';
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

/// Memory: pick a section, then find the 4 pairs among 8 cards lying face down.
class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key, required this.game, required this.content, this.random});

  final Category game;
  final LearningContent content;
  final Random? random;

  static const pairs = 4;

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  late final Random _random = widget.random ?? Random();
  Category? _section;
  List<LearningItem> _cards = [];
  final List<int> _open = [];
  final Set<int> _matched = {};
  Timer? _flipBack;

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
    _flipBack?.cancel();
    super.dispose();
  }

  void _start(Category section) {
    // Easy / Medium / Hard: pictures from the section's first 5, 8 or all items.
    final items = ([..._state.limited(section.items)]..shuffle(_random)).take(MemoryScreen.pairs);
    setState(() {
      _section = section;
      _cards = [...items, ...items]..shuffle(_random);
      _open.clear();
      _matched.clear();
    });
  }

  Future<void> _tap(int i) async {
    if (_open.length == 2 || _open.contains(i) || _matched.contains(i)) return;
    setState(() => _open.add(i));
    if (_open.length < 2) {
      _state.speak([Speech.item(_cards[i])]);
      return;
    }
    final a = _open[0], b = _open[1];
    if (_cards[a] != _cards[b]) {
      // Not a pair: both turn back over after a moment.
      _state.speak([Speech.item(_cards[i])]);
      _flipBack = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) setState(_open.clear);
      });
      return;
    }
    setState(() {
      _matched.addAll(_open);
      _open.clear();
    });
    if (_matched.length < _cards.length) {
      _state.celebrate(Speech.item(_cards[i]));
      return;
    }
    await _state.celebrate(Speech.item(_cards[i])).timeout(const Duration(seconds: 4), onTimeout: () => true);
    if (!mounted) return;
    _state.finish('memory/${_section!.id}');
    await finishWithReward(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.game.color;
    return Scaffold(
      appBar: gameAppBar(widget.game.title, color),
      body: SafeArea(
        child: _section == null
            ? SectionPicker(content: widget.content, question: 'Which pictures shall we play with?', onPick: _start)
            : _play(color),
      ),
    );
  }

  Widget _play(Color color) => Column(
    children: [
      const SizedBox(height: 12),
      GameProgress(done: _matched.length ~/ 2, total: MemoryScreen.pairs),
      const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Find the pairs!',
          style: TextStyle(fontFamily: 'Fredoka', fontSize: 30, fontWeight: FontWeight.w700),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, box) {
              // 4 across and 2 down on a wide screen, 2 across and 4 down on a tall one.
              final across = box.maxWidth > box.maxHeight ? 4 : 2;
              final rows = _cards.length ~/ across;
              return Column(
                children: [
                  for (var r = 0; r < rows; r++)
                    Expanded(
                      child: Row(
                        children: [
                          for (var c = 0; c < across; c++)
                            Expanded(
                              child: Padding(padding: const EdgeInsets.all(8), child: _card(r * across + c, color)),
                            ),
                        ],
                      ),
                    ),
                ],
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

  Widget _card(int i, Color color) {
    final item = _cards[i];
    final faceUp = _open.contains(i) || _matched.contains(i);
    final matched = _matched.contains(i);
    return Semantics(
      key: ValueKey('card-$i'),
      button: true,
      label: faceUp ? item.label : 'Card',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _tap(i),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: faceUp
              ? Container(
                  key: const ValueKey('front'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: matched ? Colors.green : color, width: 6),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Center(
                    child: ItemPicture(category: _section!, item: item),
                  ),
                )
              : Container(
                  key: const ValueKey('back'),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: const Center(
                    child: FittedBox(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 80,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
