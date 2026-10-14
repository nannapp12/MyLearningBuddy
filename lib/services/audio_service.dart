import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'speech.dart';

/// Plays the bundled voice clips and sound effects.
abstract class AudioService {
  /// Says [texts] one after another, stopping anything already being said.
  void speak(List<String> texts);

  /// Plays the short "you earned a star" chime.
  void chime();

  void dispose() {}
}

/// Plays clips from `assets/audio/` with the audioplayers package.
class ClipAudioService implements AudioService {
  final _voice = AudioPlayer();
  final _effects = AudioPlayer();
  final List<String> _queue = [];
  StreamSubscription<void>? _onComplete;

  ClipAudioService() {
    _onComplete = _voice.onPlayerComplete.listen((_) => _playNext());
  }

  @override
  void speak(List<String> texts) {
    _queue
      ..clear()
      ..addAll(texts);
    _playNext();
  }

  void _playNext() {
    if (_queue.isEmpty) return;
    final clip = clipName(_queue.removeAt(0));
    _voice.stop().then((_) => _voice.play(AssetSource('audio/$clip.mp3'))).catchError((Object e) {
      debugPrint('Could not play $clip: $e');
    });
  }

  @override
  void chime() => _effects.play(AssetSource('audio/effects/chime.mp3')).catchError((Object e) {
    debugPrint('Could not play chime: $e');
  });

  @override
  void dispose() {
    _onComplete?.cancel();
    _voice.dispose();
    _effects.dispose();
  }
}

/// Plays nothing; used in tests.
class SilentAudioService implements AudioService {
  final List<String> spoken = [];

  @override
  void speak(List<String> texts) => spoken.addAll(texts);

  @override
  void chime() {}

  @override
  void dispose() {}
}
