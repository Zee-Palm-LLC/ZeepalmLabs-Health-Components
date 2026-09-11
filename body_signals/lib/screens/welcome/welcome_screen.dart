import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/app_text.dart';
import '../../core/page_transitions.dart';
import '../../widgets/animations.dart';
import '../../widgets/gradient_button.dart';
import '../home/home_screen.dart';
import 'welcome_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const KenBurns(
            duration: Duration(seconds: 48),
            maxScale: 1.06,
            child: SizedBox.expand(
              child: Image(
                image: AssetImage('assets/images/welcome_bg.jpeg'),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xF2050914),
                  Color(0xC0060B18),
                  Color(0x59070C1C),
                  Color(0xE6050914),
                ],
                stops: [0.0, 0.30, 0.62, 1.0],
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 14.h),
                  const FadeSlideIn(child: Wordmark()),
                  SizedBox(height: 30.h),
                  const Headline(),
                  SizedBox(height: 16.h),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 520),
                    child: Text(
                      'BodySignals turns your daily data into meaningful '
                      'insights — so you can feel better, live healthier, '
                      'and stay ahead.',
                      style: AppText.body().copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(child: FeatureConstellation()),
                  ),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 1180),
                    child: GradientButton(
                      label: 'Get Started',
                      onPressed: () => Navigator.of(context).push(
                        AppPageRoute(builder: (_) => const HomeScreen()),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 1280),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: AppText.caption().copyWith(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        PressableScale(
                          onTap: () {},
                          scale: 0.9,
                          child: Text(
                            'Log In',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
