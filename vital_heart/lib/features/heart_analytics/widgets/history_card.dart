import 'package:vital_heart/core/controllers/heart_controller.dart';
import 'package:vital_heart/core/motion/app_motion.dart';
import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:vital_heart/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.record,
    this.index = 0,
  });

  final HeartRecord record;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index * 70)),
      curve: AppMotion.curve,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.card,
              AppColors.surfaceElevated.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 12,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.25),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Iconsax.heart,
                size: 16.sp,
                color: AppColors.accent,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              '${record.bpm} bpm',
              style: AppTextStyles.historyValue,
            ),
            const Spacer(),
            Text(
              '${record.timeLabel} / ${record.dateLabel}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
