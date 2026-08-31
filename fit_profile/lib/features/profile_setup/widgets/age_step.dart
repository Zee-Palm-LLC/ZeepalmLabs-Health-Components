import 'package:fit_profile/core/motion/app_motion.dart';
import 'package:fit_profile/core/motion/setup_step_header.dart';
import 'package:fit_profile/core/motion/stagger_column.dart';
import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:fit_profile/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgeStep extends StatefulWidget {
  const AgeStep({
    super.key,
    required this.age,
    required this.onChanged,
  });

  final int age;
  final ValueChanged<int> onChanged;

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  static const _min = 12;
  static const _max = 80;

  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: (widget.age - _min).clamp(0, _max - _min),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StaggerColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SetupStepHeader(
          title: 'How old are you?',
          subtitle:
              'This helps us personalize your fitness\nplan and calorie targets',
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              width: double.infinity,
              height: 280.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ListWheelScrollView.useDelegate(
                    controller: _controller,
                    itemExtent: 56.h,
                    perspective: 0.003,
                    diameterRatio: 1.6,
                    physics: const FixedExtentScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    onSelectedItemChanged: (index) {
                      widget.onChanged(_min + index);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: _max - _min + 1,
                      builder: (context, index) {
                        final value = _min + index;
                        final distance = (value - widget.age).abs();
                        final style = distance == 0
                            ? AppTextStyles.pickerSelected
                            : distance == 1
                                ? AppTextStyles.pickerNear
                                : AppTextStyles.pickerFar;

                        return AnimatedDefaultTextStyle(
                          duration: AppMotion.fast,
                          curve: AppMotion.curve,
                          style: style,
                          child: Center(child: Text('$value')),
                        );
                      },
                    ),
                  ),
                  IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AccentLine(width: 72.w),
                        SizedBox(height: 56.h),
                        _AccentLine(width: 72.w),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccentLine extends StatelessWidget {
  const _AccentLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.2,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
