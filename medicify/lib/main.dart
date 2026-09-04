import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicify/screens/onboarding/onboarding_flow.dart';
import 'package:medicify/theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MedicifyApp());
}

class MedicifyApp extends StatelessWidget {
  const MedicifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.light(
          surface: AppColors.bg,
          primary: AppColors.purple,
          onPrimary: AppColors.white,
          secondary: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      scrollBehavior: const ScrollBehavior().copyWith(
        overscroll: false,
        physics: const BouncingScrollPhysics(),
      ),
      home: const OnboardingFlow(),
    );
  }
}
