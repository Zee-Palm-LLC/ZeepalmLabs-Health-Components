import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_text.dart';
import 'motion.dart';
import 'shimmer_sweep.dart';

/// The primary call to action: a gold gradient pill with optional leading or
/// trailing glyph.
class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.height,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPressed,
      child: ShimmerSweep(
        child: Container(
          height: height ?? 52.h,
          decoration: BoxDecoration(
            gradient: AppDecoration.goldGradient,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldDark.withValues(alpha: 0.30),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: (fontSize + 3).r, color: AppColors.textOnGold),
                SizedBox(width: 8.w),
              ],
              Text(
                label,
                style: AppText.body(
                  fontSize,
                  weight: FontWeight.w500,
                  color: AppColors.textOnGold,
                ),
              ),
              if (trailingIcon != null) ...[
                SizedBox(width: 8.w),
                Icon(trailingIcon, size: (fontSize + 3).r, color: AppColors.textOnGold),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
