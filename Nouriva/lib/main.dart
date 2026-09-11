import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/onboarding/onboarding_screen.dart';
import 'services/onboarding_video_cache.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Kick off video decode ASAP (runs while first frame builds).
  final videos = OnboardingVideoCache.instance.preload();

  runApp(NourivaApp(videosReady: videos));
}

class NourivaApp extends StatelessWidget {
  const NourivaApp({super.key, required this.videosReady});

  final Future<void> videosReady;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MaterialApp(
        title: 'Nouriva',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.cream,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.forest,
            brightness: Brightness.light,
            surface: AppColors.cream,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        home: child,
      ),
      child: _BootGate(videosReady: videosReady),
    );
  }
}

class _BootGate extends StatelessWidget {
  const _BootGate({required this.videosReady});

  final Future<void> videosReady;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: videosReady,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.cream,
            body: SizedBox.expand(),
          );
        }
        return const OnboardingScreen();
      },
    );
  }
}
