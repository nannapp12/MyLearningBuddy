import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/audio_service.dart';
import '../state/app_state.dart';
import '../widgets/celebration.dart';
import '../widgets/item_card.dart';
import '../widgets/star_badge.dart';

/// Shows a list of items one at a time, with swipe and big next/previous buttons.
class SectionScreen extends StatefulWidget {
  const SectionScreen({
    super.key,
    required this.category,
    required this.items,
    required this.finishKey,
    this.title,
    this.audio = const AudioService(),
  });

  final Category category;
  final List<LearningItem> items;

  /// Identifies this section for awarding a star once all items are seen.
  final String finishKey;
  final String? title;
  final AudioService audio;

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  late final PageController _controller;
  late int _page;
  late final int _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now().weekday;
    final todayIndex = widget.items.indexWhere((i) => i.weekday == _today);
    _page = todayIndex < 0 ? 0 : todayIndex;
    _controller = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _speak(LearningItem item) {
    final text = item.subtitle != null && item.count == null ? '${item.label}. ${item.subtitle}' : item.spokenText;
    widget.audio.speak(text, enabled: AppStateScope.of(context).speechOn);
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    _speak(widget.items[page]);
    if (page == widget.items.length - 1 && AppStateScope.of(context).finish(widget.finishKey)) {
      showCelebration(context);
    }
  }

  void _go(int delta) =>
      _controller.animateToPage(_page + delta, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final color = widget.category.color;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? widget.category.title),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: const [StarBadge()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.items.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, i) {
                  final item = widget.items[i];
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => _speak(item),
                      child: ItemCard(category: widget.category, item: item, isToday: item.weekday == _today),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'Previous',
                    color: color,
                    onPressed: _page > 0 ? () => _go(-1) : null,
                  ),
                  Text('${_page + 1} / ${widget.items.length}', style: Theme.of(context).textTheme.titleLarge),
                  _NavButton(
                    icon: Icons.arrow_forward_rounded,
                    label: 'Next',
                    color: color,
                    onPressed: _page < widget.items.length - 1 ? () => _go(1) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.label, required this.color, required this.onPressed});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(backgroundColor: color, minimumSize: const Size(96, 72)),
    child: Icon(icon, size: 44, semanticLabel: label),
  );
}
