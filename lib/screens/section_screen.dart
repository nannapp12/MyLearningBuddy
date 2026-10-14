import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/speech.dart';
import '../state/app_state.dart';
import '../widgets/celebration.dart';
import '../widgets/home_button.dart';
import '../widgets/item_card.dart';
import '../widgets/star_badge.dart';
import '../widgets/word_group_card.dart';

/// One page of a section: what to show and what to say.
class SectionPage {
  const SectionPage({required this.child, required this.speech, this.gap = Duration.zero});

  final Widget child;

  /// What to say for this page, in order.
  final List<String> speech;

  /// Silence between the things in [speech].
  final Duration gap;
}

/// Pause between the words on a Words card, so children can repeat each one.
const wordGap = Duration(seconds: 3);

/// Shows a section's pages one at a time, with swipe and big next/previous buttons.
class SectionScreen extends StatefulWidget {
  const SectionScreen({super.key, required this.category, required this.pages});

  /// A page per item, e.g. one animal per page.
  factory SectionScreen.items(Category category) {
    return SectionScreen(
      category: category,
      pages: [
        for (final item in category.items)
          SectionPage(
            speech: [Speech.item(item)],
            child: ItemCard(category: category, item: item),
          ),
      ],
    );
  }

  /// A page per group, e.g. one letter's five words per page.
  factory SectionScreen.groups(Category category) => SectionScreen(
    category: category,
    pages: [
      for (final group in category.groups)
        SectionPage(
          // The letter, then each word with a pause.
          speech: [Speech.group(group), for (final item in group.items) Speech.item(item)],
          gap: wordGap,
          child: WordGroupCard(category: category, group: group),
        ),
    ],
  );

  final Category category;
  final List<SectionPage> pages;

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speakPage(_page, intro: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AppState get _state => AppStateScope.of(context);

  void _onPageChanged(int page) {
    setState(() => _page = page);
    _speakPage(page);
  }

  /// Says the page; on the last page, "Great job!" follows once the voice has
  /// finished, so the child sees and hears the last item first.
  Future<void> _speakPage(int page, {bool intro = false}) async {
    final p = widget.pages[page];
    final texts = [if (intro) Speech.category(widget.category), ...p.speech];
    final finished = await _state
        .speak(texts, gap: p.gap)
        // In case the browser never reports the end of a clip.
        .timeout(Duration(seconds: 8) + (p.gap + const Duration(seconds: 2)) * texts.length, onTimeout: () => true);
    final isLast = page == widget.pages.length - 1;
    if (!finished || !isLast || !mounted || _page != page) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted && _page == page && _state.finish(widget.category.id)) {
      showCelebration(context, goHome: true);
    }
  }

  void _go(int delta) =>
      _controller.animateToPage(_page + delta, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final color = widget.category.color;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
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
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(onTap: () => _speakPage(i), child: widget.pages[i].child),
                ),
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HomeButton(color: color),
                      const SizedBox(height: 4),
                      Text('${_page + 1} / ${widget.pages.length}', style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                  _NavButton(
                    icon: Icons.arrow_forward_rounded,
                    label: 'Next',
                    color: color,
                    onPressed: _page < widget.pages.length - 1 ? () => _go(1) : null,
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
