import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/motion/dashboard_motion.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DailyActivityCard extends StatelessWidget {
  const DailyActivityCard({super.key});

  static const _steps = 8420;
  static const _goal = 10000;

  @override
  Widget build(BuildContext context) {
    final progress = _steps / _goal;

    return AppCard(
      padding: EdgeInsets.all(16.w),
      radius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Iconsax.activity,
                  size: 18.sp,
                  color: AppColors.successText,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Daily Activity',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
                      children: [
                        TextSpan(
                          text: '8,420',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: ' / 10,000',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Steps',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MotionProgress(
                      start: 0.32,
                      end: 0.58,
                      builder: (context, t) => _GradientProgressBar(
                        progress: progress * t,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _ActivityMetric(
                            icon: Iconsax.flash_1,
                            iconColor: AppColors.calories,
                            value: '368',
                            label: 'Kcal Burned',
                          ),
                        ),
                        Expanded(
                          child: _ActivityMetric(
                            icon: Iconsax.location,
                            iconColor: const Color(0xFF14B8A6),
                            value: '6.2',
                            label: 'km Distance',
                          ),
                        ),
                        Expanded(
                          child: _ActivityMetric(
                            icon: Iconsax.user_octagon,
                            iconColor: AppColors.successText,
                            value: '45',
                            label: 'Min Active',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              MotionProgress(
                start: 0.38,
                end: 0.72,
                builder: (context, t) => _ActivityBarChart(progress: t),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  const _GradientProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F6),
        borderRadius: BorderRadius.circular(99),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * progress.clamp(0.0, 1.0),
              height: 9.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4ADE80),
                    Color(0xFF2DD4BF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ADE80).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActivityMetric extends StatelessWidget {
  const _ActivityMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13.sp, color: iconColor),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _ActivityBarChart extends StatelessWidget {
  const _ActivityBarChart({required this.progress});

  final double progress;

  static const _bars = <_BarData>[
    _BarData(0.18, false),
    _BarData(0.32, false),
    _BarData(0.12, true),
    _BarData(0.45, false),
    _BarData(0.62, false),
    _BarData(0.78, false),
    _BarData(0.55, false),
    _BarData(0.92, false),
    _BarData(0.7, false),
    _BarData(0.38, true),
    _BarData(0.22, true),
    _BarData(0.1, true),
  ];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 108.w,
        child: Column(
          children: [
            SizedBox(
              height: 58.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_bars.length, (i) {
                  final barStart = i / _bars.length;
                  final barT = ((progress - barStart) / 0.12).clamp(0.0, 1.0);
                  return _BarItem(
                    data: _bars[i],
                    heightFactor: Curves.easeOutCubic.transform(barT),
                  );
                }),
              ),
            ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['00', '06', '12', '18', '24'].map((label) {
              return Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.data, required this.heightFactor});

  final _BarData data;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final height = 58.h * data.height * heightFactor;

    if (data.faded) {
      return Container(
        width: 6.w,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB).withValues(alpha: 0.55),
          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
        ),
      );
    }

    return Container(
      width: 6.w,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF22C55E),
            const Color(0xFF4ADE80).withValues(alpha: 0.85),
            const Color(0xFF86EFAC).withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _BarData {
  const _BarData(this.height, this.faded);

  final double height;
  final bool faded;
}
