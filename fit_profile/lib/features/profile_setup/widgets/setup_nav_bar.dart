import 'package:fit_profile/core/motion/app_motion.dart';
import 'package:fit_profile/core/motion/luxury_tap.dart';
import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SetupNavBar extends StatelessWidget {
  const SetupNavBar({
    super.key,
    required this.onNext,
    this.isLast = false,
  });

  final VoidCallback onNext;
  final bool isLast;

  static TextStyle _labelStyle() => GoogleFonts.plusJakartaSans(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
      child: LuxuryTap(
        onTap: onNext,
        scale: 0.98,
        enableHaptic: true,
        child: _ContinueButton(
          label: isLast ? 'Done' : 'Continue',
          labelStyle: _labelStyle(),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.labelStyle,
  });

  final String label;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.curve,
      width: double.infinity,
      height: 48.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.32),
            blurRadius: 16,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.fast,
        child: Text(
          label,
          key: ValueKey(label),
          style: labelStyle,
        ),
      ),
    );
  }
}
