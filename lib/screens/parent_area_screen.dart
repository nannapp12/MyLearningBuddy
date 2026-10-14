import 'dart:math';

import 'package:flutter/material.dart';

import '../models/content.dart';
import '../state/app_state.dart';

/// Parent-only settings, behind a simple sum that young children can't solve.
class ParentAreaScreen extends StatefulWidget {
  const ParentAreaScreen({super.key, required this.content, this.random});

  final LearningContent content;
  final Random? random;

  @override
  State<ParentAreaScreen> createState() => _ParentAreaScreenState();
}

class _ParentAreaScreenState extends State<ParentAreaScreen> {
  late final Random _random = widget.random ?? Random();
  late int _a, _b;
  late List<int> _choices;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    _a = 3 + _random.nextInt(7);
    _b = 3 + _random.nextInt(7);
    final answer = _a + _b;
    _choices = {answer, answer + 1 + _random.nextInt(3), answer - 1 - _random.nextInt(3)}.toList()..shuffle(_random);
  }

  void _answer(int value) => setState(() => value == _a + _b ? _unlocked = true : _newQuestion());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('For Parents')),
      body: _unlocked ? _Settings(content: widget.content) : _lock(context),
    );
  }

  Widget _lock(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ask a grown-up', style: textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('What is $_a + $_b?', style: textTheme.displaySmall),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              children: [
                for (final c in _choices)
                  OutlinedButton(
                    onPressed: () => _answer(c),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(88, 64)),
                    child: Text('$c', style: textTheme.headlineSmall),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings({required this.content});

  final LearningContent content;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return ListView(
      children: [
        const _Header('Show or hide sections'),
        for (final c in content.categories)
          SwitchListTile(
            secondary: Text(c.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(c.title),
            value: !state.isHidden(c.id),
            onChanged: (show) => state.setHidden(c.id, !show),
          ),
        const _Header('Sound'),
        SwitchListTile(title: const Text('Speech'), value: state.speechOn, onChanged: (v) => state.speechOn = v),
        SwitchListTile(
          title: const Text('Music and sound effects'),
          value: state.effectsOn,
          onChanged: (v) => state.effectsOn = v,
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'These settings, and any stars earned, reset when the app or web page is closed. '
            'My Learning Buddy does not collect or store any personal information.',
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
