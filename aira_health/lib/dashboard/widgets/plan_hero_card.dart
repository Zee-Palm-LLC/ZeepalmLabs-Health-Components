import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/glass_surface.dart';
import 'package:aira_health/shared/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../dashboard_constants.dart';
import 'robot_mascot.dart';

class PlanHeroCard extends StatelessWidget {
  const PlanHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: 24.w,
          top: 12.h,
          child: Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD9C8FF).withValues(alpha: 0.55),
                  const Color(0xFFD9C8FF).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        GlassSurface(
          borderRadius: 18.r,
          blur: 18,
          opacity: 0.58,
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 0, 16.h),
          child: SizedBox(
            height: 178.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 92.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFB89BFF).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              'PRO',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF7B5FD4),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '3 features included',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w500,
                              color: PrimaryBgColors.subtitle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        DashboardCopy.planTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.5.sp,
                          fontWeight: FontWeight.w700,
                          color: PrimaryBgColors.title,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        DashboardCopy.planBody,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: PrimaryBgColors.subtitle,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...DashboardData.planFeatures.map(
                        (feature) => Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.tick_circle,
                                size: 12.sp,
                                color: const Color(0xFF7B5FD4),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: PrimaryBgColors.subtitle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      PressableScale(
                        onTap: () {},
                        scale: 0.96,
                        child: GlassSurface(
                          borderRadius: 99,
                          blur: 10,
                          opacity: 0.72,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DashboardCopy.planCta,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: PrimaryBgColors.title,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Iconsax.arrow_right_3,
                                size: 12.sp,
                                color: PrimaryBgColors.title,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -6.w,
                  bottom: -4.h,
                  child: const RobotMascot(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
