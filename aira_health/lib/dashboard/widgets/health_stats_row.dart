import 'package:aira_health/dashboard/dashboard_constants.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthStatsRow extends StatelessWidget {
  const HealthStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < DashboardData.healthStats.length; i++) ...[
          if (i > 0) SizedBox(width: 10.w),
          Expanded(child: _HealthStatCard(item: DashboardData.healthStats[i])),
        ],
      ],
    );
  }
}

class _HealthStatCard extends StatelessWidget {
  const _HealthStatCard({required this.item});

  final HealthStatItem item;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: 14.r,
      blur: 12,
      opacity: 0.56,
      child: Stack(
        children: [
          Positioned(
            right: -8.w,
            top: -8.h,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.accent.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(11.w, 11.h, 11.w, 10.h),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: item.accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(item.icon, size: 13.sp, color: item.accent),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6ED6A0).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        item.trend,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3FAF74),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: PrimaryBgColors.title,
                      height: 1,
                    ),
                    children: [
                      TextSpan(text: item.value),
                      TextSpan(
                        text: ' ${item.unit}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w500,
                          color: PrimaryBgColors.subtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: PrimaryBgColors.subtitle,
                  ),
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 4.h,
                    backgroundColor: item.accent.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(item.accent),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.goalLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w500,
                    color: PrimaryBgColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
