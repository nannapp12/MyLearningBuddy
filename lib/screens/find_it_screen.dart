import 'dart:math';

import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/speech.dart';
import '../state/app_state.dart';
import '../widgets/category_icon.dart';
import '../widgets/game_widgets.dart';
import '../widgets/home_button.dart';
import '../widgets/item_card.dart';
import 'sticker_picker_screen.dart';

/// Sections that work for Find It: every item has a clear picture and a plain name.
List<Category> findItSections(LearningContent content) => [
  for (final c in content.categories)
    if (const {CategoryLayout.cards, CategoryLayout.shapes, CategoryLayout.colors}.contains(c.layout) &&
        !const {'letters', 'numbers', 'months'}.contains(c.id) &&
        c.items.length >= 3 &&
        c.items.every((i) => (i.emoji ?? i.image ?? i.shape ?? i.swatch) != null && i.count == null))
      c,
];

/// "Can you find the cow?": pick a section, then five rounds of three pictures.
class FindItScreen extends StatefulWidget {
  const FindItScreen({super.key, required this.game, required this.content, this.random});

  final Category game;
  final LearningContent content;
  final Random? random;

  static const rounds = 5;

  @override
  State<FindItScreen> createState() => _FindItScreenState();
}

class _FindItScreenState extends State<FindItScreen> {
  late final Random _random = widget.random ?? Random();
  Category? _section;
  List<LearningItem> _targets = [];
  int _round = 0;
  List<LearningItem> _choices = [];
  int? _found;
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

  void _start(Category section) {
    final items = [...section.items]..shuffle(_random);
    setState(() {
      _section = section;
      _targets = items.take(FindItScreen.rounds).toList();
      _round = 0;
    });
    _newRound();
  }

  void _newRound() {
    final target = _targets[_round];
    final others = [...?_section?.items.where((i) => i != target)]..shuffle(_random);
    setState(() {
      _choices = [target, ...others.take(2)]..shuffle(_random);
      _found = null;
      _wrong = null;
    });
    _ask();
  }

  void _ask() => _state.speak([Speech.canYouFind, Speech.item(_targets[_round])]);

  Future<void> _tap(int index) async {
    if (_found != null) return;
    if (_choices[index] != _targets[_round]) {
      setState(() {
        _wrong = index;
        _shakes++;
      });
      _state.speak([Speech.tryAgain]);
      return;
    }
    setState(() => _found = index);
    await _state.celebrate(Speech.foundIt).timeout(const Duration(seconds: 6), onTimeout: () => true);
    if (!mounted) return;
    if (_round + 1 < FindItScreen.rounds) {
      setState(() => _round++);
      _newRound();
    } else {
      setState(() => _round++);
      _state.finish('find_it/${_section!.id}');
      await finishWithReward(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.game.color;
    return Scaffold(
      appBar: gameAppBar(widget.game.title, color),
      body: SafeArea(child: _section == null ? _sectionPicker() : _play(color)),
    );
  }

  Widget _sectionPicker() {
    final state = _state;
    final sections = [
      for (final c in findItSections(widget.content))
        if (!state.isHidden(c.id)) c,
    ];
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'What shall we find?',
            style: TextStyle(fontFamily: 'Fredoka', fontSize: 30, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: GridView.extent(
            padding: const EdgeInsets.all(16),
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final c in sections)
                Material(
                  color: c.color,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _start(c),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Expanded(
                            child: FittedBox(child: CategoryIcon(category: c, size: 100)),
                          ),
                          FittedBox(
                            child: Text(
                              c.title,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _play(Color color) {
    final section = _section!;
    final target = _round < _targets.length ? _targets[_round] : _targets.last;
    return Column(
      children: [
        const SizedBox(height: 12),
        GameProgress(done: _round, total: FindItScreen.rounds),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ReplayButton(color: color, onPressed: _ask),
              const SizedBox(width: 16),
              Flexible(
                child: FittedBox(
                  child: Text(
                    'Can you find ${target.label}?',
                    style: const TextStyle(fontFamily: 'Fredoka', fontSize: 34, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, box) {
                final wide = box.maxWidth > box.maxHeight * 0.9;
                final cards = [
                  for (var i = 0; i < _choices.length; i++)
                    Expanded(
                      child: Padding(padding: const EdgeInsets.all(8), child: _choice(section, i)),
                    ),
                ];
                return wide ? Row(children: cards) : Column(children: cards);
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

  Widget _choice(Category section, int i) {
    final item = _choices[i];
    final found = _found == i;
    final faded = _found != null && !found;
    return Shake(
      shakes: _wrong == i ? _shakes : 0,
      child: AnimatedScale(
        scale: found ? 1.08 : (faded ? 0.9 : 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        child: AnimatedOpacity(
          opacity: faded ? 0.35 : 1,
          duration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: found ? Colors.green : Colors.transparent, width: 8),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _tap(i),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: ItemPicture(category: section, item: item),
                      ),
                    ),
                    // The name appears once it has been found.
                    SizedBox(
                      height: 40,
                      child: found
                          ? FittedBox(
                              child: ItemLabel(item: item, color: section.color),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
