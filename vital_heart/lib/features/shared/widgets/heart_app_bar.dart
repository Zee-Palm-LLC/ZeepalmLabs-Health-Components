import 'package:vital_heart/core/motion/luxury_tap.dart';
import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:vital_heart/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HeartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HeartAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: true,
      toolbarHeight: 56.h,
      titleSpacing: 0,
      leadingWidth: 56.w,
      leading: showBack
          ? Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: _CircleNavButton(
                icon: Iconsax.arrow_left_2,
                onTap: onBack,
              ),
            )
          : SizedBox(width: 56.w),
      title: Text(title, style: AppTextStyles.screenTitle),
      actions: [
        if (trailing != null)
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: trailing!,
          )
        else
          SizedBox(width: 16.w),
      ],
    );
  }
}

class _CircleNavButton extends StatelessWidget {
  const _CircleNavButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LuxuryTap(
      onTap: onTap,
      scale: 0.94,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18.sp,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class AnalyticsNavButton extends StatelessWidget {
  const AnalyticsNavButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LuxuryTap(
      onTap: onTap,
      scale: 0.94,
      enableHaptic: true,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 9.w,
              bottom: 8.h,
              child: Icon(
                Iconsax.chart_2,
                size: 14.sp,
                color: AppColors.accent,
              ),
            ),
            Positioned(
              right: 8.w,
              top: 7.h,
              child: Icon(
                Iconsax.heart,
                size: 13.sp,
                color: AppColors.heartGlow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
