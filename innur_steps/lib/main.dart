import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/palette.dart';
import 'features/home/home_screen.dart';
import 'features/splash/splash_screen.dart';

void main() => runApp(const InnurApp());

class InnurApp extends StatelessWidget {
  const InnurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'innur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Ground.top,
      ),
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Ground.top,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 620),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _ready
              ? const HomeScreen(key: ValueKey<String>('home'))
              : SplashScreen(
                  key: const ValueKey<String>('splash'),
                  onDone: () => setState(() => _ready = true),
                ),
        ),
      ),
    );
  }
}
