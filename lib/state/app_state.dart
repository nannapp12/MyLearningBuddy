import 'package:flutter/widgets.dart';

/// Everything that changes while the app is open.
///
/// Held in memory only: per the requirements nothing is saved, so closing the
/// app or web page resets stars, finished sections and parent settings.
class AppState extends ChangeNotifier {
  final Set<String> _hiddenCategoryIds = {};
  final Set<String> _finished = {};
  int _stars = 0;
  bool _speechOn = true;
  bool _effectsOn = true;

  int get stars => _stars;
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
