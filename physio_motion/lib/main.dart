import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/welcome_screen/welcome_screen.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.bg,
    ),
  );
  runApp(const PhysioMotionApp());
}

class PhysioMotionApp extends StatelessWidget {
  const PhysioMotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhysioMotion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.light(
          surface: AppColors.bg,
          primary: AppColors.lime,
          secondary: AppColors.cobalt,
          onPrimary: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      scrollBehavior: ScrollBehavior().copyWith(overscroll: false,physics: BouncingScrollPhysics()),
      home: const WelcomeScreen(),
    );
  }
}

