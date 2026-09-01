import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
import 'package:healthscan_ai/features/shared/widgets/sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
          children: [
            Expanded(
              child: _VitalCard(
                icon: Iconsax.heart,
                iconColor: AppColors.heart,
                iconBg: AppColors.heartSoft,
                label: 'Heart Rate',
                value: '72 BPM',
                trend: '↑ 5%',
                trendColor: AppColors.successText,
                sparkColor: AppColors.heart,
                sparkValues: const [0.4, 0.5, 0.45, 0.6, 0.55, 0.7, 0.65],
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
                trend: '↓ 3%',
                trendColor: AppColors.bp,
                sparkColor: AppColors.bp,
                sparkValues: const [0.7, 0.65, 0.6, 0.55, 0.5, 0.48, 0.45],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _VitalCard(
                icon: Iconsax.health,
                iconColor: AppColors.oxygen,
                iconBg: AppColors.oxygenSoft,
                label: 'Oxygen Level',
                value: '98 %',
                trend: '↑ 2%',
                trendColor: AppColors.successText,
                sparkColor: AppColors.oxygen,
                sparkValues: const [0.5, 0.52, 0.55, 0.58, 0.6, 0.62, 0.65],
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
                trend: '↑ 8%',
                trendColor: AppColors.successText,
                sparkColor: AppColors.calories,
                sparkValues: const [0.3, 0.35, 0.4, 0.5, 0.55, 0.6, 0.7],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VitalCard extends StatelessWidget {
  const _VitalCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendColor,
    required this.sparkColor,
    required this.sparkValues,
    this.unit,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String? unit;
  final String trend;
  final Color trendColor;
  final Color sparkColor;
  final List<double> sparkValues;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16.sp, color: iconColor),
              ),
              const Spacer(),
              Text(
                trend,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(label, style: AppTextStyles.cardLabel),
          SizedBox(height: 2.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.cardValue.copyWith(fontSize: 16.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null)
                Padding(
                  padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
                  child: Text(
                    unit!,
                    style: AppTextStyles.caption,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Sparkline(values: sparkValues, color: sparkColor, height: 24.h),
        ],
      ),
    );
  }
}
