import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DailyActivityCard extends StatelessWidget {
  const DailyActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Daily Activity', style: AppTextStyles.sectionTitle),
              const Spacer(),
              Text(
                '8,420 / 10,000 Steps',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: 0.842,
                        minHeight: 8.h,
                        backgroundColor: AppColors.border,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        _ActivityStat(
                          icon: Iconsax.flash_1,
                          label: '368 Kcal Burned',
                        ),
                        SizedBox(width: 12.w),
                        _ActivityStat(
                          icon: Iconsax.location,
                          label: '6.2 km',
                        ),
                        SizedBox(width: 12.w),
                        _ActivityStat(
                          icon: Iconsax.clock,
                          label: '45 Min',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              SizedBox(
                width: 72.w,
                height: 64.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final h in [0.3, 0.5, 0.7, 0.9, 0.6])
                      Container(
                        width: 10.w,
                        height: 64.h * h,
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.15 + h * 0.5),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  const _ActivityStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: AppColors.textMuted),
        SizedBox(width: 4.w),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
