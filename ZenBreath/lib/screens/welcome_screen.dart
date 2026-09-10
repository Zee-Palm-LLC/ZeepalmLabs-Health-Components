import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/app_shell.dart';
import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/app_image.dart';
import '../widgets/gold_button.dart';
import '../widgets/lotus_mark.dart';
import '../widgets/motion.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _enterApp(BuildContext context) {
    Navigator.of(context).pushReplacement(AppPageRoute(builder: (_) => const AppShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 46.h),
          const Entrance(child: _Wordmark()),
          SizedBox(height: 46.h),
          Entrance(
            delay: AppMotion.stagger * 2,
            child: Column(
              children: [
                Text('Welcome to', style: AppText.display(34, weight: FontWeight.w400)),
                Text('ZenBreath', style: AppText.display(45, weight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Entrance(
            delay: AppMotion.stagger * 4,
            child: Text(
              'Find calm in every breath.',
              style: AppText.body(15, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 22.h),
          const Expanded(child: _WelcomeHero()),
          SizedBox(height: 18.h),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0),
            child: GoldButton(
              label: 'Get Started',
              trailingIcon: LucideIcons.arrowRight,
              fontSize: 17,
              onPressed: () => _enterApp(context),
            ),
          ),
          SizedBox(height: 16.h),
          const _SignInPrompt(),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 18.h),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LotusMark(size: 34.r),
        SizedBox(height: 6.h),
        Text('ZenBreath', style: AppText.display(20, weight: FontWeight.w500)),
      ],
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage(
            source: AppImages.welcomeBackground,
            fallback: [Color(0xFFDCEAF2), Color(0xFFB9D2E0), Color(0xFFE8D7C2)],
            alignment: Alignment.center,
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface,
                  AppColors.surface.withValues(alpha: 0.0),
                  AppColors.surface.withValues(alpha: 0.0),
                  AppColors.surface.withValues(alpha: 0.85),
                  AppColors.surface,
                ],
                stops: const [0.0, 0.12, 0.55, 0.86, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppText.body(13.5, color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Sign In',
            style: AppText.body(13.5, weight: FontWeight.w600, color: AppColors.blueDeep),
          ),
        ),
      ],
    );
  }
}
