import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/audio/sfx.dart';

import 'core/palette.dart';
import 'core/settings.dart';
import 'core/shaders.dart';
import 'core/type.dart';
import 'features/onboarding/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Shaders.warmUp();
  await GameSettings.instance.load();
  unawaited(GameAudio.init());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const HealthQuestApp());
}

class HealthQuestApp extends StatelessWidget {
  const HealthQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: T.body,
        scaffoldBackgroundColor: Night.voidBlack,
        colorScheme: const ColorScheme.dark(
          primary: Spectrum.violet,
          secondary: Spectrum.blue,
          surface: Night.deep,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      builder: (BuildContext context, Widget? child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.15),
          ),
          child: child!,
        );
      },
      home: const OnboardingScreen(),
    );
  }
}
