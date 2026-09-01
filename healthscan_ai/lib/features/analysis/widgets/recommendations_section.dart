import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RecommendationsSection extends StatelessWidget {
  const RecommendationsSection({super.key});

  static const _items = [
    (
      Iconsax.heart,
      AppColors.heart,
      AppColors.heartSoft,
      'Your heart health is performing excellently.',
    ),
    (
      Iconsax.activity,
      AppColors.success,
      AppColors.successSoft,
      'Increase your daily activity by 15 minutes.',
    ),
    (
      Iconsax.moon,
      AppColors.sleep,
      AppColors.sleepSoft,
      'Try sleeping 30 minutes earlier for better recovery.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.magic_star, size: 18.sp, color: AppColors.blue),
            SizedBox(width: 8.w),
            Text('AI Recommendations', style: AppTextStyles.sectionTitle),
          ],
        ),
        SizedBox(height: 12.h),
        for (final item in _items)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: AppCard(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: item.$3,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.$1, size: 16.sp, color: item.$2),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      item.$4,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
