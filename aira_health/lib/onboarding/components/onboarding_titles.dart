import 'package:aira_health/onboarding/components/fade_reveal.dart';
import 'package:aira_health/onboarding/components/onboarding_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingTitles extends StatelessWidget {
  const OnboardingTitles({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeReveal(
          delay: const Duration(milliseconds: 140),
          child: Text(
            'Meet Aira Health',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: OnboardingColors.ink,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        FadeReveal(
          delay: const Duration(milliseconds: 190),
          child: Text(
            'AI-Powered Health Support',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: OnboardingColors.muted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
