import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/motion/dashboard_motion.dart';
import 'package:healthscan_ai/core/motion/luxury_tap.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, this.onScanTap});

  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: AppTextStyles.sectionTitle),
            SizedBox(height: 12.h),
            SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  MotionProgress(
                    start: 0.52,
                    end: 0.68,
                    builder: (context, t) => Opacity(
                      opacity: t,
                      child: Transform.scale(
                        scale: 0.92 + 0.08 * t,
                        child: LuxuryTap(
                          onTap: onScanTap,
                          scale: 0.97,
                          enableHaptic: true,
                          child: _ScanActionPill(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  MotionProgress(
                    start: 0.56,
                    end: 0.72,
                    builder: (context, t) => Opacity(
                      opacity: t,
                      child: Transform.scale(
                        scale: 0.92 + 0.08 * t,
                        child: const _ActivityActionPill(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  MotionProgress(
                    start: 0.60,
                    end: 0.76,
                    builder: (context, t) => Opacity(
                      opacity: t,
                      child: Transform.scale(
                        scale: 0.92 + 0.08 * t,
                        child: const _ReportActionPill(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScanActionPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF2E5BFF),
            Color(0xFF4F8CFF),
            Color(0xFF6BB3FF),
          ],
        ),
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.32),
            blurRadius: 16,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.scan, size: 18.sp, color: AppColors.white),
          SizedBox(width: 10.w),
          Text(
            'AI Health Scan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityActionPill extends StatelessWidget {
  const _ActivityActionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Iconsax.add,
              size: 16.sp,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Add Activity',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportActionPill extends StatelessWidget {
  const _ReportActionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Iconsax.document_text,
              size: 15.sp,
              color: AppColors.purple,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Health Report',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
