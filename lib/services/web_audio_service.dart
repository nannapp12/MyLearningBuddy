import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'audio_service.dart';
import 'speech.dart';

/// Plays the clips in the browser through two long-lived audio elements, one
/// for the voice and one for sound effects.
///
/// Browsers, Safari above all, only let an audio element start playing right
/// after a tap. Once an element has played after a tap it may keep playing, so
/// reusing the same element is what lets auto-read go on to the next card by
/// itself (a new element for each clip would be silenced).
class WebAudioService implements AudioService {
  WebAudioService() {
    _voice.preload = 'auto';
    _ended = web.EventStreamProviders.endedEvent.forTarget(_voice).listen((_) {
      if (_queue.isNotEmpty && _gap > Duration.zero) {
        _gapTimer = Timer(_gap, _playNext);
      } else {
        _playNext();
      }
    });
  }

  final _voice = web.HTMLAudioElement();
  final _effects = web.HTMLAudioElement();
  final List<String> _queue = [];
  StreamSubscription<web.Event>? _ended;
  Completer<bool>? _done;
  Duration _gap = Duration.zero;
  Timer? _gapTimer;

  /// Counts the clips started, so a failure of a clip that has since been
  /// replaced is ignored.
  int _clip = 0;

  static String _url(String asset) => ui_web.assetManager.getAssetUrl('assets/$asset');

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
    final clip = clipPath(_queue.removeAt(0));
    final id = ++_clip;
    _voice.src = _url(clip);
    _voice.play().toDart.catchError((Object e) {
      // Skip a clip that cannot be played, unless another one has replaced it.
      if (id != _clip) return null;
      debugPrint('Could not play $clip: $e');
      _playNext();
      return null;
    });
  }

  void _effect(String name) {
    _effects.src = _url('audio/effects/$name.mp3');
    _effects.play().toDart.catchError((Object e) {
      debugPrint('Could not play $name: $e');
      return null;
    });
  }

  @override
  void chime() => _effect('chime');

  @override
  void pop() => _effect('pop');

  @override
  void cheer() => _effect('cheer');

  @override
  void dispose() {
    _gapTimer?.cancel();
    _done?.complete(false);
    _ended?.cancel();
    _voice.pause();
    _effects.pause();
  }
}
