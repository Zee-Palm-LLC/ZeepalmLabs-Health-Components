import 'package:aira_health/dashboard/dashboard_constants.dart';
import 'package:aira_health/dashboard/widgets/section_header.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: DashboardCopy.activityTitle,
          action: 'Today',
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 88.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: DashboardData.recentActivity.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              return _ActivityChip(item: DashboardData.recentActivity[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: 14.r,
      blur: 12,
      opacity: 0.56,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      child: SizedBox(
        width: 168.w,
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: item.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(9.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                size: 16.sp,
                color: item.accent,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: PrimaryBgColors.title,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.time,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w400,
                      color: PrimaryBgColors.subtitle,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: item.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      item.status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w600,
                        color: item.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 14.sp,
              color: PrimaryBgColors.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}
