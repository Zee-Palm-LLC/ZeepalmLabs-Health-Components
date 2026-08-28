import 'package:aira_health/dashboard/dashboard_constants.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/glass_surface.dart';
import 'package:aira_health/shared/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.avatarAsset,
  });

  final String avatarAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFC4DD),
                Color(0xFFC4B5FF),
                Color(0xFFB8E8FF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB8A0D8).withValues(alpha: 0.28),
                blurRadius: 14,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 21.r,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(avatarAsset),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dashboardGreeting(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w400,
                  color: PrimaryBgColors.subtitle,
                ),
              ),
              Text(
                DashboardCopy.userName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: PrimaryBgColors.title,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        PressableScale(
          onTap: () {},
          child: GlassSurface(
            borderRadius: 12.r,
            blur: 12,
            opacity: 0.5,
            padding: EdgeInsets.all(10.w),
            child: Icon(
              Iconsax.search_normal_1,
              size: 19.sp,
              color: PrimaryBgColors.title,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        PressableScale(
          onTap: () {},
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GlassSurface(
                borderRadius: 12.r,
                blur: 12,
                opacity: 0.5,
                padding: EdgeInsets.all(10.w),
                child: Icon(
                  Iconsax.notification,
                  size: 19.sp,
                  color: PrimaryBgColors.title,
                ),
              ),
              Positioned(
                top: 7.h,
                right: 9.w,
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B8A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
