import 'package:flutter/foundation.dart';

/// Plays the spoken name of an item.
///
/// Placeholder: the requirements call for pre-generated clips from a free
/// text-to-speech tool (female, US English) bundled with the app. Until those
/// clips exist this only logs what would be said.
class AudioService {
  const AudioService();

  void speak(String text, {required bool enabled}) {
    if (!enabled) return;
    debugPrint('speak: $text');
  }
}
