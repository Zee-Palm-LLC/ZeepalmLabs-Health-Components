import 'package:healthscan_ai/core/motion/luxury_tap.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AnalysisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnalysisAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: LuxuryTap(
          onTap: Get.back,
          scale: 0.94,
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Icon(
              Iconsax.arrow_left_2,
              size: 18.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      title: Text('AI Health Analysis', style: AppTextStyles.screenTitle),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Icon(
              Iconsax.more,
              size: 18.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
