import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class WaterIntakeCard extends StatelessWidget {
  const WaterIntakeCard({super.key});

  @override
  Widget build(BuildContext context) {
    const filled = 6;
    const total = 8;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Text('Water Intake', style: AppTextStyles.sectionTitle),
              const Spacer(),
              Text(
                '$filled / $total Glasses',
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
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < total; i++)
                      Icon(
                        Iconsax.glass,
                        size: 22.sp,
                        color: i < filled ? AppColors.water : AppColors.waterEmpty,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '+ Add Water',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
