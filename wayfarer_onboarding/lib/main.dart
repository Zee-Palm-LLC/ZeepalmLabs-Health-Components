import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/brand.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  runApp(const MediWiseApp());
}

class MediWiseApp extends StatelessWidget {
  const MediWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBrand.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const OnboardingScreen(),
    );
  }
}
