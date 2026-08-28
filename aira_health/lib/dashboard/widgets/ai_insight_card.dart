import 'package:aira_health/dashboard/dashboard_constants.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: 16.r,
      blur: 14,
      opacity: 0.58,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8DEFF),
                      Color(0xFFFFE3F0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(9.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Iconsax.magic_star,
                  size: 18.sp,
                  color: const Color(0xFF8B6FD6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          DashboardCopy.insightTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: PrimaryBgColors.title,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6ED6A0).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '+12%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3FAF74),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DashboardCopy.insightBody,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: PrimaryBgColors.subtitle,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep quality score',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w500,
                        color: PrimaryBgColors.subtitle,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: const LinearProgressIndicator(
                        value: 0.82,
                        minHeight: 5,
                        backgroundColor: Color(0x1AB07CFF),
                        valueColor: AlwaysStoppedAnimation(Color(0xFFB07CFF)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 0.7,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View tips',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: PrimaryBgColors.title,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(
                      Iconsax.arrow_right_3,
                      size: 11.sp,
                      color: PrimaryBgColors.title,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
