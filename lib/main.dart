import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/content.dart';
import 'screens/home_screen.dart';
import 'services/audio_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final content = LearningContent.fromJsonString(await rootBundle.loadString('assets/content/content.json'));
  runApp(MyLearningBuddyApp(content: content));
}

class MyLearningBuddyApp extends StatefulWidget {
  const MyLearningBuddyApp({super.key, required this.content, this.audio, this.puppyGreetings = true});

  final LearningContent content;

  /// Defaults to playing the bundled clips; tests pass a silent one.
  final AudioService? audio;

  /// Turned off in tests that don't want the puppy covering the screen.
  final bool puppyGreetings;

  @override
  State<MyLearningBuddyApp> createState() => _MyLearningBuddyAppState();
}

class _MyLearningBuddyAppState extends State<MyLearningBuddyApp> {
  // In memory only: a fresh state every time the app starts.
  late final _state = AppState(audio: widget.audio);

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _state,
      child: MaterialApp(
        title: 'My Learning Buddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        navigatorObservers: [homeRouteObserver],
        home: HomeScreen(content: widget.content, puppyGreetings: widget.puppyGreetings),
      ),
    );
  }
}
