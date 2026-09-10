import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.height,
    this.color = AppColors.green,
  });

  final List<double> values;
  final List<String> labels;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final max = values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                children: [
                  for (var i = 0; i < values.length; i++)
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: values[i] / max),
                          duration: AppMotion.enter + AppMotion.stagger * i,
                          curve: AppMotion.enterCurve,
                          builder: (context, t, _) => Container(
                            width: 5.w,
                            height: constraints.maxHeight * t,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.55 + 0.45 * (values[i] / max)),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              for (final label in labels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppText.body(10.5, color: AppColors.textTertiary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
