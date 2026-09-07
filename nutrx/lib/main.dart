import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/landing_page/landing_page_view.dart';
import 'theme/nutrx_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: NutrxColors.bg,
    ),
  );
  runApp(const NutrxApp());
}

class NutrxApp extends StatelessWidget {
  const NutrxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NutrxColors.bg,
      colorScheme: const ColorScheme.dark(
        surface: NutrxColors.bg,
        primary: NutrxColors.yellow,
        onPrimary: NutrxColors.onYellow,
      ),
    );

    return MaterialApp(
      title: 'Nutrx',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      ),
      home: const LandingPageView(),
    );
  }
}
