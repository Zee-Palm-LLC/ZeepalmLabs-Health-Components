import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RecommendationsSection extends StatelessWidget {
  const RecommendationsSection({super.key});

  static const _items = [
    (Iconsax.heart, AppColors.heart, 'Your heart health is performing excellently.'),
    (Iconsax.activity, AppColors.success, 'Increase your daily activity by 15 minutes.'),
    (Iconsax.moon, AppColors.sleep, 'Try sleeping 30 minutes earlier for better recovery.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            children: [
              Icon(Iconsax.magic_star, size: 16.sp, color: AppColors.blue),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'AI Recommendations',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _RecommendationRow(
              icon: _items[i].$1,
              iconColor: _items[i].$2,
              text: _items[i].$3,
            ),
          ],
        ],
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Icon(icon, size: 14.sp, color: iconColor),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
