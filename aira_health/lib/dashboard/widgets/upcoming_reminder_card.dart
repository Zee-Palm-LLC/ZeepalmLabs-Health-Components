import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class UpcomingReminderCard extends StatelessWidget {
  const UpcomingReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: 14.r,
      blur: 12,
      opacity: 0.56,
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFE3F0),
                  Color(0xFFE8DEFF),
                ],
              ),
              borderRadius: BorderRadius.circular(11.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Iconsax.calendar_1,
              size: 18.sp,
              color: const Color(0xFF7B5FD4),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evening medication',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: PrimaryBgColors.title,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Today at 8:00 PM · Vitamin D',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: PrimaryBgColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF7B5FD4).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '2h left',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7B5FD4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
