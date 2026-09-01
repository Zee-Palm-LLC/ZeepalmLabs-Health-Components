import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:vital_heart/core/theme/app_text_styles.dart';

class HeartHomeStats extends StatelessWidget {
  const HeartHomeStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Iconsax.clock,
            label: 'Session',
            value: '00:42',
            tint: const Color(0xFF3B82F6),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatTile(
            icon: Iconsax.heart,
            label: 'Resting',
            value: '68',
            unit: 'bpm',
            tint: AppColors.accent,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatTile(
            icon: Iconsax.flash_1,
            label: 'Signal',
            value: 'Strong',
            tint: AppColors.heartGlow,
            valueColor: AppColors.heartGlow,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    this.unit,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final String? unit;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.12),
            AppColors.surface.withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: tint.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16.sp, color: tint),
          ),
          SizedBox(height: 10.h),
          Text(label, style: AppTextStyles.caption),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.title,
                  ),
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: 2.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Text(
                    unit!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
