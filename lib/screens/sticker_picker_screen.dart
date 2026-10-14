import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../services/speech.dart';
import '../state/app_state.dart';
import '../widgets/app_title.dart';
import '../widgets/confetti.dart';
import '../widgets/puppy.dart';
import '../widgets/rainbow_title.dart';
import '../widgets/sticker_bar.dart';

/// Stickers a child can win.
const stickerChoices = [
  '🐶', '🐱', '🦄', '🌈', '⭐', '🦋', '🍦', '🎈', '🌸', '🚀', //
  '🐼', '🦊', '🍓', '🐬', '🌻', '🎀', '🐞', '🍭', '🐥', '🧸',
];

/// Shows the puppy, then the sticker picker. Used at the end of every section,
/// the last tracing letter and every game.
Future<void> finishWithReward(BuildContext context) async {
  await showPuppy(context);
  if (!context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StickerPickerScreen()));
}

/// "Great Job! Now pick your sticker" with five stickers to choose from.
/// Picking one adds it to the sticker bar and goes back to the main menu.
class StickerPickerScreen extends StatefulWidget {
  const StickerPickerScreen({super.key, this.random});

  final Random? random;

  @override
  State<StickerPickerScreen> createState() => _StickerPickerScreenState();
}

class _StickerPickerScreenState extends State<StickerPickerScreen> {
  late final List<String> _options;
  Timer? _speakTimer;

  @override
  void dispose() {
    _speakTimer?.cancel();
    super.dispose();
  }

  bool _ready = false;
  String? _picked;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    final random = widget.random ?? Random();
    final have = AppStateScope.of(context).stickers.toSet();
    // Prefer stickers the child doesn't have yet.
    final fresh = [
      for (final s in stickerChoices)
        if (!have.contains(s)) s,
    ]..shuffle(random);
    final old = [
      for (final s in stickerChoices)
        if (have.contains(s)) s,
    ]..shuffle(random);
    _options = [...fresh, ...old].take(5).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Clapping first, then "Great job! Now pick your sticker."
      AppStateScope.of(context).clap();
      _speakTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) AppStateScope.of(context).speak([Speech.pickSticker]);
      });
    });
  }

  Future<void> _pick(String sticker) async {
    if (_picked != null) return;
    final state = AppStateScope.of(context);
    setState(() => _picked = sticker);
    state.addSticker(sticker);
    state.celebrate(Speech.greatJob);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFF8E1),
        toolbarHeight: 72,
        title: const Align(alignment: Alignment.centerLeft, child: AppTitle()),
        bottom: const StickerBar(),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Puppy(size: 120),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClappingHands(),
                        SizedBox(width: 12),
                        Flexible(child: RainbowTitle('Great Job!', fontSize: 56)),
                        SizedBox(width: 12),
                        ClappingHands(),
                      ],
                    ),
                    const Text(
                      'Now pick your sticker',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6D4C41),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final s in _options)
                          AnimatedScale(
                            scale: _picked == null ? 1 : (_picked == s ? 1.4 : 0.6),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                            child: AnimatedOpacity(
                              opacity: _picked == null || _picked == s ? 1 : 0.3,
                              duration: const Duration(milliseconds: 300),
                              child: Semantics(
                                button: true,
                                label: 'Sticker',
                                excludeSemantics: true,
                                child: InkWell(
                                  onTap: () => _pick(s),
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.amber, width: 4),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                                      ],
                                    ),
                                    child: Text(s, style: const TextStyle(fontSize: 64)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: Confetti()),
        ],
      ),
    );
  }
}
