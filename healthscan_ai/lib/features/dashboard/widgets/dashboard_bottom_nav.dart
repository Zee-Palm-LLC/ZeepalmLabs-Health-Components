import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    this.onScanTap,
  });

  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 68.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: Offset(0, -4.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: Center(child: _NavItem(icon: Iconsax.home_2, label: 'Home', active: true)),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: Center(child: _NavItem(icon: Iconsax.activity, label: 'Activity')),
                  ),
                ),
                SizedBox(width: 56.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: Center(child: _NavItem(icon: Iconsax.chart_2, label: 'Reports')),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: Center(child: _NavItem(icon: Iconsax.user, label: 'Profile')),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: _NavScanButton(onTap: onScanTap),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.blue : AppColors.navInactive;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.navLabel.copyWith(
              color: color,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NavScanButton extends StatelessWidget {
  const _NavScanButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Iconsax.scan,
          size: 24.sp,
          color: AppColors.white,
        ),
      ),
    );
  }
}
