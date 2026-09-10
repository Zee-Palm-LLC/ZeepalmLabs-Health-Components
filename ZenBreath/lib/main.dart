import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'data/app_data.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_motion.dart';
import 'theme/app_text.dart';
import 'widgets/image_warmup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const ZenBreathApp());
}

class ZenBreathApp extends StatelessWidget {
  const ZenBreathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MaterialApp(
        title: 'ZenBreath',
        scrollBehavior: const ScrollBehavior().copyWith(
          overscroll: false,
          physics: const BouncingScrollPhysics(),
        ),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.aquaDeep,
            surface: AppColors.surface,
          ),
          textTheme: TextTheme(bodyMedium: AppText.body(15.5)),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: AppPageTransitionsBuilder(),
              TargetPlatform.iOS: AppPageTransitionsBuilder(),
              TargetPlatform.windows: AppPageTransitionsBuilder(),
              TargetPlatform.macOS: AppPageTransitionsBuilder(),
            },
          ),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        home: child,
      ),
      child: ImageWarmup(sources: AppImages.all, child: const WelcomeScreen()),
    );
  }
}
