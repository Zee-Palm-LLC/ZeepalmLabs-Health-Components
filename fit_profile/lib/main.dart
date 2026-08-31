import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:fit_profile/features/profile_setup/profile_setup_view.dart';
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
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FitProfileApp());
}

class FitProfileApp extends StatelessWidget {
  const FitProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) {
        return GetMaterialApp(
          title: 'Fit Profile',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const ScrollBehavior().copyWith(
            overscroll: false,
            physics: const BouncingScrollPhysics(),
          ),
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.bg,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.accent,
              brightness: Brightness.dark,
              surface: AppColors.surface,
            ),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData.dark().textTheme,
            ),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: const ProfileSetupView(),
        );
      },
    );
  }
}
