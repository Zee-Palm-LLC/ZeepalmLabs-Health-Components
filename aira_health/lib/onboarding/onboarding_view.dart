import 'package:aira_health/dashboard/dashboard_view.dart';
import 'package:aira_health/onboarding/components/avatar_carousel.dart';
import 'package:aira_health/onboarding/components/fade_reveal.dart';
import 'package:aira_health/onboarding/components/get_started_button.dart';
import 'package:aira_health/onboarding/components/hero_portrait.dart';
import 'package:aira_health/onboarding/components/onboarding_constants.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = OnboardingAssets.defaultIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheAvatars());
  }

  Future<void> _precacheAvatars() async {
    if (!mounted) return;
    await Future.wait(
      OnboardingAssets.avatars.map(
        (asset) => precacheImage(AssetImage(asset), context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PrimaryBg(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.h),
            child: Column(
              children: [
                FadeReveal(
                  delay: Duration.zero,
                  duration: const Duration(milliseconds: 480),
                  offsetY: 8,
                  child: Text(
                    'Choose Your AI Health Assistant',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Expanded(
                  child: HeroPortrait(
                    asset: OnboardingAssets.avatars[_selectedIndex],
                  ),
                ),
                SizedBox(height: 20.h),
                FadeReveal(
                  delay: const Duration(milliseconds: 140),
                  child: Text(
                    'Meet Aira Health',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FadeReveal(
                  delay: const Duration(milliseconds: 190),
                  child: Text(
                    'AI-Powered Health Support',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                AvatarCarousel(
                  selectedIndex: _selectedIndex,
                  onChanged: (index) => setState(() => _selectedIndex = index),
                ),
                SizedBox(height: 60.h),
                FadeReveal(
                  delay: const Duration(milliseconds: 300),
                  offsetY: 12,
                  child: GetStartedButton(
                    onPressed: () {
                      Get.to(
                        () => DashboardView(
                          avatarAsset:
                              OnboardingAssets.avatars[_selectedIndex],
                        ),
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 380),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
