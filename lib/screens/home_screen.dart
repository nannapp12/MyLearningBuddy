import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/speech.dart';
import '../state/app_state.dart';
import '../widgets/app_title.dart';
import '../widgets/auto_read_bar.dart';
import '../widgets/category_icon.dart';
import '../widgets/difficulty_bar.dart';
import '../widgets/puppy.dart';
import '../widgets/star_badge.dart';
import '../widgets/sticker_bar.dart';
import 'find_it_screen.dart';
import 'matching_screen.dart';
import 'memory_screen.dart';
import 'parent_area_screen.dart';
import 'section_screen.dart';
import 'tracing_screen.dart';

/// Lets the home screen know when the child comes back to it.
final homeRouteObserver = RouteObserver<ModalRoute<void>>();

/// The child's home screen: one big tile per visible learning section.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.content, this.puppyGreetings = true});

  final LearningContent content;

  /// The puppy says "Hi! How are you?" on start and "This is fun!" on coming back.
  final bool puppyGreetings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  LearningContent get content => widget.content;

  @override
  void initState() {
    super.initState();
    if (widget.puppyGreetings) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // On the web, sound only plays after a tap, so the puppy waits for one.
        if (mounted) showPuppy(context, message: Speech.hello, short: true, waitForTap: kIsWeb);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) homeRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    homeRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => _thisIsFun(); // back on the main menu

  void _thisIsFun() {
    if (widget.puppyGreetings) showPuppy(context, message: Speech.thisIsFun, short: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final visible = [
      for (final c in content.categories)
        if (!state.isHidden(c.id)) c,
    ];
    final tabs = [
      for (final tab in MenuTab.values)
        if (visible.any((c) => tab.sections.contains(c.section))) tab,
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: Align(
            alignment: Alignment.centerLeft,
            child: AppTitle(onTapOnHome: _thisIsFun),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(64 + DifficultyBar.height + AutoReadBar.height),
            child: Column(children: [StickerBar(), DifficultyBar(), AutoReadBar()]),
          ),
          actions: [
            const StarBadge(),
            IconButton(
              tooltip: 'Parents',
              icon: const Icon(Icons.lock_outline),
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => ParentAreaScreen(content: content))),
            ),
          ],
        ),
        body: Column(
          children: [
            // Words, Phrases, Tracing, Nursery Rhymes, Short Stories, Games.
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF4A3A8C),
              unselectedLabelColor: Colors.black45,
              indicatorColor: const Color(0xFF4A3A8C),
              indicatorWeight: 4,
              labelStyle: const TextStyle(fontFamily: 'Fredoka', fontSize: 24, fontWeight: FontWeight.w700),
              onTap: (_) => state.pop(),
              tabs: [for (final tab in tabs) Tab(text: tab.label, height: 56)],
            ),
            Expanded(
              child: TabBarView(
                children: [for (final tab in tabs) _TabPage(tab: tab, visible: visible, content: content)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One tab of the home screen: its tiles, under headings when the tab has more than one group.
class _TabPage extends StatelessWidget {
  const _TabPage({required this.tab, required this.visible, required this.content});

  final MenuTab tab;
  final List<Category> visible;
  final LearningContent content;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => CustomScrollView(
      key: ValueKey('menu-${tab.name}'),
      slivers: [
        for (final section in tab.sections)
          if (visible.any((c) => c.section == section)) ...[
            if (tab.sections.length > 1 || section.note != null)
              SliverToBoxAdapter(child: _Heading(tab.sections.length > 1 ? section.heading : null, note: section.note))
            else
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.count(
                crossAxisCount: (constraints.maxWidth / 220).floor().clamp(2, 6),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  for (final c in visible)
                    if (c.section == section)
                      _CategoryTile(key: ValueKey('tile-${c.id}'), category: c, content: content),
                ],
              ),
            ),
          ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    ),
  );
}

/// A heading above a group of tiles, e.g. "Learning".
class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.note});

  final String? text;
  final String? note;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text != null)
          Semantics(
            header: true,
            child: Text(
              text!,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A3A8C),
              ),
            ),
          ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              note!,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
            ),
          ),
      ],
    ),
  );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({super.key, required this.category, required this.content});

  final Category category;
  final LearningContent content;

  void _open(BuildContext context) {
    final state = AppStateScope.of(context)..pop();
    final Widget screen = switch (category.layout) {
      CategoryLayout.groups => SectionScreen.groups(category, groups: state.limited(category.groups)),
      CategoryLayout.tracing => TracingPickerScreen(category: category),
      CategoryLayout.findit => FindItScreen(game: category, content: content),
      CategoryLayout.matching => MatchingScreen(game: category, content: content),
      CategoryLayout.memory => MemoryScreen(game: category, content: content),
      // A week is always all seven days, and a story is always told to the end, whatever the mode.
      CategoryLayout.days || CategoryLayout.story => SectionScreen.items(category, items: category.items),
      _ => SectionScreen.items(category, items: state.limited(category.items)),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: category.color,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                // Padding so pictures that reach the edge (like the apple's leaf) are not cut off.
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: FittedBox(child: CategoryIcon(category: category, size: 100)),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    // Keeps the white name readable on light tiles such as yellow.
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
