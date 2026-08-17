import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.activeIndex,
    this.scrollPage,
  });

  final int count;
  final int activeIndex;
  final double? scrollPage;

  @override
  Widget build(BuildContext context) {
    final page = scrollPage ?? activeIndex.toDouble();

    return SizedBox(
      height: 10.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final distance = (page - index).abs().clamp(0.0, 1.0);
          final focus = 1 - distance;
          final width = 6.w + (16.w * focus);
          final opacity = 0.35 + (0.65 * focus);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            width: width,
            height: 6.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.r),
              color: Color.lerp(
                AppColors.dotInactive,
                AppColors.dotActive,
                focus,
              )!.withValues(alpha: opacity.clamp(0.35, 1.0)),
              boxShadow: focus > 0.4
                  ? [
                      BoxShadow(
                        color: AppColors.dotActive
                            .withValues(alpha: 0.35 * focus),
                        blurRadius: 12 * focus,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
