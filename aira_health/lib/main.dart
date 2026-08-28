import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/onboarding/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const AiraApp());
}

class AiraApp extends StatelessWidget {
  const AiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) {
        return GetMaterialApp(
          title: 'Aira Health',
          scrollBehavior: ScrollBehavior().copyWith(
            overscroll: false,
            physics: BouncingScrollPhysics(),
          ),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: PrimaryBgColors.base,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7B61FF),
              surface: Colors.white,
            ),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: const OnboardingView(),
        );
      },
    );
  }
}
