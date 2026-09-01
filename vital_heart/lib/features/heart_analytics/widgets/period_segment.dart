import 'package:vital_heart/core/controllers/heart_controller.dart';
import 'package:vital_heart/core/motion/app_motion.dart';
import 'package:vital_heart/core/motion/luxury_tap.dart';
import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:vital_heart/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PeriodSegment extends StatelessWidget {
  const PeriodSegment({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HeartPeriod selected;
  final ValueChanged<HeartPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _SegmentTab(
            label: 'Day',
            selected: selected == HeartPeriod.day,
            onTap: () => onChanged(HeartPeriod.day),
          ),
          _SegmentTab(
            label: 'Week',
            selected: selected == HeartPeriod.week,
            onTap: () => onChanged(HeartPeriod.week),
          ),
          _SegmentTab(
            label: 'Month',
            selected: selected == HeartPeriod.month,
            onTap: () => onChanged(HeartPeriod.month),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LuxuryTap(
        onTap: onTap,
        scale: 0.97,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        SizedBox(height: 6.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: AppTextStyles.statValue),
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
              child: Text(unit, style: AppTextStyles.statUnit),
            ),
          ],
        ),
      ],
    );
  }
}
