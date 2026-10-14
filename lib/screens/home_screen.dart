import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/speech.dart';
import '../state/app_state.dart';
import '../widgets/app_title.dart';
import '../widgets/category_icon.dart';
import '../widgets/difficulty_bar.dart';
import '../widgets/puppy.dart';
import '../widgets/star_badge.dart';
import '../widgets/sticker_bar.dart';
import 'find_it_screen.dart';
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Align(
          alignment: Alignment.centerLeft,
          child: AppTitle(onTapOnHome: _thisIsFun),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(64 + DifficultyBar.height),
          child: Column(children: [StickerBar(), DifficultyBar()]),
        ),
        actions: [
          const StarBadge(),
          IconButton(
            tooltip: 'Parents',
            icon: const Icon(Icons.lock_outline),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ParentAreaScreen(content: content))),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: (constraints.maxWidth / 220).floor().clamp(2, 6),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [for (final c in visible) _CategoryTile(category: c, content: content)],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.content});

  final Category category;
  final LearningContent content;

  void _open(BuildContext context) {
    final state = AppStateScope.of(context)..pop();
    final Widget screen = switch (category.layout) {
      CategoryLayout.groups => SectionScreen.groups(category, groups: state.limited(category.groups)),
      CategoryLayout.tracing => TracingPickerScreen(category: category),
      CategoryLayout.findit => FindItScreen(game: category, content: content),
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
