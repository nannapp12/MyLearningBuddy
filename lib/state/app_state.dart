import 'package:flutter/widgets.dart';

import '../services/audio_service.dart';

/// Everything that changes while the app is open.
///
/// Held in memory only: per the requirements nothing is saved, so closing the
/// app or web page resets stars, finished sections and parent settings.
class AppState extends ChangeNotifier {
  AppState({AudioService? audio}) : audio = audio ?? ClipAudioService();

  final AudioService audio;
  final Set<String> _hiddenCategoryIds = {};
  final Set<String> _finished = {};
  int _stars = 0;
  final List<String> _stickers = [];
  bool _speechOn = true;
  bool _effectsOn = true;

  int get stars => _stars;

  /// Stickers picked this session, oldest first.
  List<String> get stickers => List.unmodifiable(_stickers);

  void addSticker(String sticker) {
    _stickers.add(sticker);
    notifyListeners();
  }

  bool get speechOn => _speechOn;
  bool get effectsOn => _effectsOn;

  bool isHidden(String categoryId) => _hiddenCategoryIds.contains(categoryId);

  void setHidden(String categoryId, bool hidden) {
    final changed = hidden ? _hiddenCategoryIds.add(categoryId) : _hiddenCategoryIds.remove(categoryId);
    if (changed) notifyListeners();
  }

  set speechOn(bool value) {
    _speechOn = value;
    notifyListeners();
  }

  set effectsOn(bool value) {
    _effectsOn = value;
    notifyListeners();
  }

  /// Says [texts] in order, if speech is switched on. Completes with true once
  /// it has all been said (straight away when speech is off), or false if it
  /// was interrupted.
  Future<bool> speak(List<String> texts, {Duration gap = Duration.zero}) =>
      _speechOn ? audio.speak(texts, gap: gap) : Future.value(true);

  /// Celebrates a finished section: chime (if effects are on) and "Great job!".
  /// The balloon pop sound, if effects are on.
  void pop() {
    if (_effectsOn) audio.pop();
  }

  /// Completes once [message] has been said (see [speak]).
  Future<bool> celebrate(String message) {
    if (_effectsOn) audio.chime();
    return speak([message]);
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  /// Awards a star the first time [key] (e.g. a section or a traced letter) is
  /// finished this session. Returns whether a star was awarded.
  bool finish(String key) {
    if (!_finished.add(key)) return false;
    _stars++;
    notifyListeners();
    return true;
  }
}

/// Makes [AppState] available to the widget tree and rebuilds dependents when it changes.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}
