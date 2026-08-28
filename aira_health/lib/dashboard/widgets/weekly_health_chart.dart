import 'dart:math' as math;

import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:aira_health/shared/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyHealthChart extends StatelessWidget {
  const WeeklyHealthChart({super.key});

  static const _values = [0.45, 0.62, 0.55, 0.78, 0.71, 0.87, 0.82];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: 16.r,
      blur: 14,
      opacity: 0.58,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Weekly Activity',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: PrimaryBgColors.title,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B5FD4).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Best: Saturday',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7B5FD4),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 72.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < _values.length; i++) ...[
                  if (i > 0) SizedBox(width: 8.w),
                  Expanded(
                    child: _Bar(
                      value: _values[i],
                      label: _days[i],
                      highlight: i == 5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.label,
    required this.highlight,
  });

  final double value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: const Cubic(0.16, 1, 0.3, 1),
          height: math.max(12.h, 56.h * value),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: highlight
                  ? const [Color(0xFF9B6BFF), Color(0xFF7B5FD4)]
                  : [
                      const Color(0xFFB89BFF).withValues(alpha: 0.55),
                      const Color(0xFF7B5FD4).withValues(alpha: 0.35),
                    ],
            ),
            boxShadow: highlight
                ? [
                    BoxShadow(
                      color: const Color(0xFF7B5FD4).withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: Offset(0, 3.h),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.sp,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            color: highlight
                ? const Color(0xFF7B5FD4)
                : PrimaryBgColors.subtitle,
          ),
        ),
      ],
    );
  }
}
