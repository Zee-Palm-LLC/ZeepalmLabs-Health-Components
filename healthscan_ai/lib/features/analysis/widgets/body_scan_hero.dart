import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BodyScanHero extends StatelessWidget {
  const BodyScanHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 280.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.bpSoft.withValues(alpha: 0.5), AppColors.bg],
              ),
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
          Positioned(
            bottom: 20.h,
            child: Container(
              width: 160.w,
              height: 24.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.blue.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(
              'https://thumbs.dreamstime.com/b/realistic-d-avatar-man-classic-suit-tie-white-shirt-background-representing-office-worker-lawyer-ideal-341136098.jpg',
            ),
            radius: 100.r,
          ),
          const _FloatingTag(
            top: 24,
            left: 0,
            icon: Iconsax.heart,
            iconColor: AppColors.heart,
            label: '72 BPM',
          ),
          const _FloatingTag(
            top: 24,
            right: 0,
            icon: Iconsax.health,
            iconColor: AppColors.oxygen,
            label: '98% O₂ Level',
          ),
          const _FloatingTag(
            bottom: 100,
            left: 0,
            icon: Iconsax.shield_tick,
            iconColor: AppColors.bp,
            label: '120/80 mmHg',
          ),
          const _FloatingTag(
            bottom: 100,
            right: 0,
            icon: Iconsax.flash_1,
            iconColor: AppColors.calories,
            label: '1,240 Kcal',
          ),
          Positioned(bottom: 0, child: _ScoreBadge()),
        ],
      ),
    );
  }
}

class _FloatingTag extends StatelessWidget {
  const _FloatingTag({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top?.h,
      bottom: bottom?.h,
      left: left?.w,
      right: right?.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: iconColor),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.blue, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '92',
            style: AppTextStyles.heroScore.copyWith(
              color: AppColors.textPrimary,
              fontSize: 32.sp,
            ),
          ),
          Text('AI Health Score', style: AppTextStyles.caption),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Excellent',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.successText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
