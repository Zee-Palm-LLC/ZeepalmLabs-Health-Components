import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/palette.dart';
import 'core/shaders.dart';
import 'core/type.dart';
import 'features/assess/assess_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Shaders.warmUp();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const SymptomApp());
}

class SymptomApp extends StatelessWidget {
  const SymptomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Symptom Assessment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: T.family,
        scaffoldBackgroundColor: Paper.washMid,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Leaf.base,
          surface: Paper.white,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Leaf.base,
          selectionColor: Leaf.soft,
          selectionHandleColor: Leaf.base,
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        // Large accessibility sizes are honoured up to a point; past that
        // the measured layout would break, so the scale is clamped.
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.2),
          ),
          child: child!,
        );
      },
      home: const AssessScreen(),
    );
  }
}
