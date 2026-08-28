import 'package:aira_health/voice/symptom_voice_view.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class QuickActionPills extends StatelessWidget {
  const QuickActionPills({super.key});

  static const _items = [
    _PillData('Voice', Iconsax.microphone_2, Color(0xFFFF8FAB)),
    _PillData('Scan', Iconsax.scan, Color(0xFF7B9BFF)),
    _PillData('Meds', Iconsax.health, Color(0xFF9B7BFF)),
    _PillData('Sleep', Iconsax.moon, Color(0xFFB07CFF)),
    _PillData('Water', Iconsax.drop, Color(0xFF6EB8FF)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final item = _items[index];
          return PressableScale(
            onTap: () {
              if (item.label == 'Voice') {
                Get.to(
                  () => const SymptomVoiceView(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 360),
                );
              }
            },
            scale: 0.95,
            child: Container(
              width: 64.w,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.72),
                    Colors.white.withValues(alpha: 0.45),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.accent.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      color: item.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      item.icon,
                      size: 15.sp,
                      color: item.accent,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: PrimaryBgColors.title,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PillData {
  const _PillData(this.label, this.icon, this.accent);

  final String label;
  final IconData icon;
  final Color accent;
}
