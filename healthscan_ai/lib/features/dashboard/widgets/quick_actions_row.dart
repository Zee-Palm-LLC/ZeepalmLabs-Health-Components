import 'package:healthscan_ai/core/motion/luxury_tap.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, this.onScanTap});

  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.sectionTitle),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              LuxuryTap(
                onTap: onScanTap,
                scale: 0.97,
                enableHaptic: true,
                child: _ActionPill(
                  label: 'AI Health Scan',
                  icon: Iconsax.scan,
                  gradient: AppColors.buttonGradient,
                  textColor: AppColors.white,
                  iconColor: AppColors.white,
                ),
              ),
              SizedBox(width: 10.w),
              const _ActionPill(
                label: 'Add Activity',
                icon: Iconsax.add,
                border: true,
                textColor: AppColors.textPrimary,
                iconColor: AppColors.success,
              ),
              SizedBox(width: 10.w),
              const _ActionPill(
                label: 'Health Report',
                icon: Iconsax.document_text,
                border: true,
                textColor: AppColors.textPrimary,
                iconColor: AppColors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.iconColor,
    this.gradient,
    this.border = false,
  });

  final String label;
  final IconData icon;
  final Color textColor;
  final Color iconColor;
  final Gradient? gradient;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppColors.card : null,
        borderRadius: BorderRadius.circular(99),
        border: border ? Border.all(color: AppColors.border) : null,
        boxShadow: gradient != null
            ? [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: Offset(0, 4.h),
                ),
              ]
            : const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: iconColor),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
