import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/landing_page/landing_page_view.dart';
import 'theme/kinora_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: KinoraColors.bg,
    ),
  );
  runApp(const KinoraApp());
}

class KinoraApp extends StatelessWidget {
  const KinoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KinoraColors.bg,
      colorScheme: const ColorScheme.dark(
        surface: KinoraColors.bg,
        primary: KinoraColors.lime,
        onPrimary: KinoraColors.ink,
      ),
    );

    return MaterialApp(
      title: 'Kinora',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      ),
      home: const LandingPageView(),
    );
  }
}
