import 'package:flutter/material.dart';

import 'features/mood/mood_screen.dart';

void main() => runApp(const AdhdMoodTrackerApp());

class AdhdMoodTrackerApp extends StatelessWidget {
  const AdhdMoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADHD Mood Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEBAA08)),
        splashFactory: InkSparkle.splashFactory,
      ),
      home: MoodScreen(
        // Lets you preview the filled note state without typing:
        //   flutter run --dart-define=NOTE="Three deadlines, skipped lunch"
        initialNote: const String.fromEnvironment('NOTE').isEmpty
            ? null
            : const String.fromEnvironment('NOTE'),
        onSubmit: (mood, note) {
          // Hook your storage layer up here.
          debugPrint('Logged ${mood.word}${note == null ? '' : ' — "$note"'}');
        },
      ),
    );
  }
}

