import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

class CustomShade extends StatelessWidget {
  const CustomShade({super.key, this.height = 100});

  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: height.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primaryLight.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            _ShadeOrb(
              left: -24.w,
              top: -18.h,
              size: 120.w,
              color: AppColors.primary,
              opacity: 0.16,
            ),
            _ShadeOrb(
              left: 0.42.sw,
              top: -8.h,
              size: 96.w,
              color: const Color(0xFF5B9DFF),
              opacity: 0.14,
            ),
            _ShadeOrb(
              right: -20.w,
              top: 12.h,
              size: 88.w,
              color: AppColors.primaryDark,
              opacity: 0.12,
            ),
            _ShadeOrb(
              left: 0.18.sw,
              top: 28.h,
              size: 72.w,
              color: AppColors.neuroIcon,
              opacity: 0.10,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShadeOrb extends StatelessWidget {
  const _ShadeOrb({
    required this.size,
    required this.color,
    required this.opacity,
    this.left,
    this.right,
    this.top = 0,
  });

  final double? left;
  final double? right;
  final double top;
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: opacity * 0.35),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
