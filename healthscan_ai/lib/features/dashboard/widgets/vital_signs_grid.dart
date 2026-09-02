import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/motion/dashboard_motion.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
import 'package:healthscan_ai/features/shared/widgets/sparkline.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class VitalSignsGrid extends StatelessWidget {
  const VitalSignsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('Vital Signs', style: AppTextStyles.sectionTitle),
            const Spacer(),
            Text('View All', style: AppTextStyles.link),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _VitalCard(
                icon: Iconsax.heart,
                iconColor: AppColors.heart,
                iconBg: AppColors.heartSoft,
                label: 'Heart Rate',
                value: '72',
                unit: 'BPM',
                trendUp: true,
                trendPercent: '5%',
                trendColor: AppColors.heart,
                sparkColor: AppColors.heart,
                sparkStart: 0.28,
                sparkEnd: 0.52,
                sparkValues: const [
                  0.38, 0.62, 0.45, 0.71, 0.52, 0.68, 0.48, 0.75, 0.58, 0.82,
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _VitalCard(
                icon: Iconsax.drop,
                iconColor: AppColors.bp,
                iconBg: AppColors.bpSoft,
                label: 'Blood Pressure',
                value: '120 / 80',
                unit: 'mmHg',
                trendUp: false,
                trendPercent: '3%',
                trendColor: AppColors.successText,
                sparkColor: AppColors.bp,
                sparkStart: 0.32,
                sparkEnd: 0.56,
                sparkValues: const [
                  0.78, 0.55, 0.68, 0.42, 0.58, 0.35, 0.5, 0.28, 0.4, 0.22,
                ],
                showRangeIcon: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _VitalCard(
                customIcon: _OxygenIcon(),
                label: 'Oxygen Level',
                value: '98',
                unit: '%',
                trendUp: true,
                trendPercent: '2%',
                trendColor: AppColors.successText,
                sparkColor: AppColors.oxygen,
                sparkStart: 0.36,
                sparkEnd: 0.60,
                sparkValues: const [
                  0.48, 0.65, 0.52, 0.7, 0.58, 0.74, 0.62, 0.68, 0.55, 0.76,
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _VitalCard(
                icon: Iconsax.flash_circle,
                iconColor: AppColors.calories,
                iconBg: AppColors.caloriesSoft,
                label: 'Calories',
                value: '1,240',
                unit: 'kcal',
                trendUp: true,
                trendPercent: '8%',
                trendColor: AppColors.calories,
                sparkColor: AppColors.calories,
                sparkStart: 0.40,
                sparkEnd: 0.64,
                sparkValues: const [
                  0.22, 0.48, 0.3, 0.55, 0.38, 0.62, 0.45, 0.7, 0.52, 0.85,
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OxygenIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: const BoxDecoration(
        color: AppColors.oxygenSoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'O₂',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.oxygen,
          height: 1,
        ),
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  const _VitalCard({
    this.icon,
    this.customIcon,
    this.iconColor,
    this.iconBg,
    required this.label,
    required this.value,
    required this.unit,
    required this.trendUp,
    required this.trendPercent,
    required this.trendColor,
    required this.sparkColor,
    required this.sparkValues,
    this.sparkStart = 0.28,
    this.sparkEnd = 0.52,
    this.showRangeIcon = false,
  });

  final IconData? icon;
  final Widget? customIcon;
  final Color? iconColor;
  final Color? iconBg;
  final String label;
  final String value;
  final String unit;
  final bool trendUp;
  final String trendPercent;
  final Color trendColor;
  final Color sparkColor;
  final List<double> sparkValues;
  final double sparkStart;
  final double sparkEnd;
  final bool showRangeIcon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(14.w),
      radius: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (customIcon != null)
                customIcon!
              else
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18.sp, color: iconColor),
                ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                              height: 1.1,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          unit,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TrendChip(
                isUp: trendUp,
                percent: trendPercent,
                color: trendColor,
              ),
              if (showRangeIcon) ...[
                SizedBox(width: 6.w),
                Icon(
                  Iconsax.arrow_swap_horizontal,
                  size: 14.sp,
                  color: AppColors.bp.withValues(alpha: 0.7),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: 78.w,
                child: MotionProgress(
                  start: sparkStart,
                  end: sparkEnd,
                  builder: (context, t) => Sparkline(
                    values: sparkValues,
                    color: sparkColor,
                    height: 34.h,
                    progress: t,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({
    required this.isUp,
    required this.percent,
    required this.color,
  });

  final bool isUp;
  final String percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
          size: 11.sp,
          color: color,
        ),
        SizedBox(width: 2.w),
        Text(
          percent,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1,
          ),
        ),
      ],
    );
  }
}
