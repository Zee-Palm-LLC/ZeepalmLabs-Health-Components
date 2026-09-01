import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CategoryStatsRow extends StatelessWidget {
  const CategoryStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _CategoryCard(
            icon: Iconsax.heart,
            iconColor: AppColors.heart,
            iconBg: AppColors.heartSoft,
            barColor: AppColors.heart,
            label: 'Heart Health',
            value: '92%',
            status: 'Excellent',
          ),
          _CategoryCard(
            icon: Iconsax.activity,
            iconColor: AppColors.success,
            iconBg: AppColors.successSoft,
            barColor: AppColors.success,
            label: 'Activity Level',
            value: '85%',
            status: 'Very Good',
          ),
          _CategoryCard(
            icon: Iconsax.moon,
            iconColor: AppColors.sleep,
            iconBg: AppColors.sleepSoft,
            barColor: AppColors.sleep,
            label: 'Sleep Quality',
            value: '78%',
            status: 'Good',
          ),
          _CategoryCard(
            icon: Iconsax.cpu,
            iconColor: AppColors.stress,
            iconBg: AppColors.stressSoft,
            barColor: AppColors.stress,
            label: 'Stress Level',
            value: '20%',
            status: 'Low',
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.barColor,
    required this.label,
    required this.value,
    required this.status,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color barColor;
  final String label;
  final String value;
  final String status;

  @override
  Widget build(BuildContext context) {
    final progress = double.parse(value.replaceAll('%', '')) / 100;

    return Container(
      width: 130.w,
      margin: EdgeInsets.only(right: 10.w),
      child: AppCard(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 15.sp, color: iconColor),
            ),
            SizedBox(height: 10.h),
            Text(label, style: AppTextStyles.cardLabel),
            SizedBox(height: 2.h),
            Text(value, style: AppTextStyles.cardValue.copyWith(fontSize: 16.sp)),
            SizedBox(height: 2.h),
            Text(
              status,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4.h,
                backgroundColor: AppColors.border,
                color: barColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
