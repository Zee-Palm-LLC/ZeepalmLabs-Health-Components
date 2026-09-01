import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vital_heart/core/controllers/heart_controller.dart';
import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:vital_heart/core/theme/app_text_styles.dart';
import 'package:vital_heart/features/heart_rate/widgets/animated_bpm_text.dart';
import 'package:vital_heart/features/heart_rate/widgets/heart_pulse_visual.dart';

class HeartHeroCard extends StatelessWidget {
  const HeartHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HeartController>();

    return Column(
      children: [
        Text(
          'Live Reading',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: 4.h),
        const HeartPulseVisual(),
        Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedBpmText(bpm: c.liveBpm.value),
              Padding(
                padding: EdgeInsets.only(left: 6.w, bottom: 10.h),
                child: Text(
                  'BPM',
                  style: AppTextStyles.statUnit.copyWith(
                    color: AppColors.subtitle,
                  ),
                ),
              ),
            ],
          );
        }),
        SizedBox(height: 8.h),
        const _MeasuringPill(),
      ],
    );
  }
}

class _MeasuringPill extends StatelessWidget {
  const _MeasuringPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.2),
            AppColors.accentSoft,
          ],
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PulsingDot(),
          SizedBox(width: 8.w),
          Text(
            'Measuring pulse...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.heartGlow,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final glow = 0.4 + (_controller.value * 0.6);

        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: glow),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
