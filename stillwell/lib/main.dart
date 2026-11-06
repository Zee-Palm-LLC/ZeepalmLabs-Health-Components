import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/today_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  runApp(const StillwellApp());
}

class StillwellApp extends StatelessWidget {
  const StillwellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stillwell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Tone.canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: Mood.orange.base, surface: Tone.canvas),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      // Mouse and trackpad can drag-scroll too, so the bounce works in a browser.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus},
      ),
      home: const TodayScreen(),
    );
  }
}
