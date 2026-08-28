import 'package:aira_health/onboarding/components/fade_reveal.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/glass_surface.dart';
import 'package:aira_health/shared/pressable_scale.dart';
import 'package:aira_health/voice/symptom_voice_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../dashboard_constants.dart';
import 'section_header.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: DashboardCopy.quickTitle,
          action: DashboardCopy.quickSeeAll,
          onActionTap: () {},
        ),
        SizedBox(height: 14.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DashboardData.quickAccess.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            return FadeReveal(
              delay: Duration(milliseconds: 200 + (index * 70)),
              duration: const Duration(milliseconds: 460),
              offsetY: 14,
              child: _QuickAccessCard(item: DashboardData.quickAccess[index]),
            );
          },
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({required this.item});

  final QuickAccessItem item;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        if (item.title == 'Symptoms') {
          Get.to(
            () => const SymptomVoiceView(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 360),
          );
        }
      },
      child: GlassSurface(
        borderRadius: 16.r,
        blur: 14,
        opacity: 0.58,
        child: Stack(
          children: [
            Positioned(
              right: -14.w,
              bottom: -14.h,
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.accent.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(13.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GlassInset(
                        size: 36.w,
                        child: Icon(item.icon, size: 17.sp, color: item.accent),
                      ),
                      const Spacer(),
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: item.accent.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.65),
                            width: 0.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Iconsax.arrow_up_3,
                          size: 13.sp,
                          color: item.accent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: PrimaryBgColors.title,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w400,
                      color: PrimaryBgColors.subtitle,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 0.7,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: item.accent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            item.badge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w700,
                              color: item.accent,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            item.meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w500,
                              color: PrimaryBgColors.subtitle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
