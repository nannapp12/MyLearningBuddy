import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'speech.dart';

/// Plays the bundled voice clips and sound effects.
abstract class AudioService {
  /// Says [texts] one after another, with [gap] of silence between them,
  /// stopping anything already being said.
  ///
  /// Completes with true once everything has been said, or false if it was
  /// interrupted by another call.
  Future<bool> speak(List<String> texts, {Duration gap = Duration.zero});

  /// Plays the short "you earned a star" chime.
  void chime();

  /// Plays a soft pop, for taps on the main menu.
  void pop();

  /// Plays happy clapping.
  void clap();

  void dispose() {}
}

/// Plays clips from `assets/audio/` with the audioplayers package.
class ClipAudioService implements AudioService {
  final _voice = AudioPlayer();
  final _effects = AudioPlayer();
  final List<String> _queue = [];
  StreamSubscription<void>? _onComplete;
  Completer<bool>? _done;
  Duration _gap = Duration.zero;
  Timer? _gapTimer;

  ClipAudioService() {
    _onComplete = _voice.onPlayerComplete.listen((_) {
      if (_queue.isNotEmpty && _gap > Duration.zero) {
        _gapTimer = Timer(_gap, _playNext);
      } else {
        _playNext();
      }
    });
  }

  @override
  Future<bool> speak(List<String> texts, {Duration gap = Duration.zero}) {
    _gapTimer?.cancel();
    _gap = gap;
    _done?.complete(false);
    final done = _done = Completer<bool>();
    _queue
      ..clear()
      ..addAll(texts);
    _playNext();
    return done.future;
  }

  void _playNext() {
    if (_queue.isEmpty) {
      _done?.complete(true);
      _done = null;
      return;
    }
    final clip = clipName(_queue.removeAt(0));
    _voice.stop().then((_) => _voice.play(AssetSource('audio/$clip.mp3'))).catchError((Object e) {
      debugPrint('Could not play $clip: $e');
      _playNext();
    });
  }

  @override
  void pop() => _effect('pop');

  @override
  void clap() => _effect('clap');

  void _effect(String name) => _effects
      .play(AssetSource('audio/effects/$name.mp3'))
      .catchError((Object e) => debugPrint('Could not play $name: $e'));

  @override
  void chime() => _effects.play(AssetSource('audio/effects/chime.mp3')).catchError((Object e) {
    debugPrint('Could not play chime: $e');
  });

  @override
  void dispose() {
    _gapTimer?.cancel();
    _done?.complete(false);
    _onComplete?.cancel();
    _voice.dispose();
    _effects.dispose();
  }
}

/// Plays nothing; used in tests.
class SilentAudioService implements AudioService {
  final List<String> spoken = [];
  final List<String> effects = [];

  @override
  Future<bool> speak(List<String> texts, {Duration gap = Duration.zero}) {
    spoken.addAll(texts);
    return Future.value(true);
  }

  @override
  void chime() {}

  @override
  void pop() => effects.add('pop');

  @override
  void clap() => effects.add('clap');

  @override
  void dispose() {}
}
