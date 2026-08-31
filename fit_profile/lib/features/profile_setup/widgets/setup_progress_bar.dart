import 'package:fit_profile/core/motion/app_motion.dart';
import 'package:fit_profile/core/motion/luxury_tap.dart';
import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SetupProgressBar extends StatelessWidget {
  const SetupProgressBar({
    super.key,
    required this.progress,
    this.onBack,
  });

  final double progress;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.dur(context, AppMotion.normal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40.w,
          child: Align(
            alignment: Alignment.centerLeft,
            child: LuxuryTap(
              onTap: onBack,
              scale: 0.94,
              child: const _CircleBackButton(),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _ProgressTrack(
          progress: progress,
          duration: duration,
        ),
      ],
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      alignment: Alignment.center,
      child: Icon(
        Iconsax.arrow_left_2,
        size: 18.sp,
        color: AppColors.white,
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({
    required this.progress,
    required this.duration,
  });

  final double progress;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final fillWidth = (trackWidth * progress.clamp(0.0, 1.0))
            .clamp(18.w, trackWidth);
        final iconSize = 18.w;

        return SizedBox(
          height: 22.h,
          width: trackWidth,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 3.h,
                width: trackWidth,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              AnimatedContainer(
                duration: duration,
                curve: AppMotion.curve,
                height: 3.h,
                width: fillWidth,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: duration,
                curve: AppMotion.curve,
                left: (fillWidth - iconSize / 2).clamp(0, trackWidth - iconSize),
                top: (22.h - iconSize) / 2,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: progress),
                  duration: duration,
                  curve: AppMotion.curve,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.92 + (value * 0.08),
                      child: child,
                    );
                  },
                  child: Icon(
                    Iconsax.activity,
                    size: iconSize,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
