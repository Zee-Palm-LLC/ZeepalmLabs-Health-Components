import 'package:fit_profile/core/motion/animated_value_text.dart';
import 'package:fit_profile/core/motion/setup_step_header.dart';
import 'package:fit_profile/core/motion/stagger_column.dart';
import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:fit_profile/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HeightStep extends StatefulWidget {
  const HeightStep({
    super.key,
    required this.heightCm,
    required this.onChanged,
  });

  final double heightCm;
  final ValueChanged<double> onChanged;

  @override
  State<HeightStep> createState() => _HeightStepState();
}

class _HeightStepState extends State<HeightStep> {
  static const _min = 120.0;
  static const _max = 220.0;
  static const _step = 1.0;
  static const _pixelsPerUnit = 10.0;

  late final ScrollController _controller;
  late double _value;
  DateTime _lastHaptic = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _value = widget.heightCm.clamp(_min, _max);
    final initialOffset = (_value - _min) / _step * _pixelsPerUnit.h;
    _controller = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final units = _controller.offset / _pixelsPerUnit.h;
    final next = (_min + units * _step).clamp(_min, _max);
    final rounded = next.roundToDouble();
    if (rounded != _value) {
      final now = DateTime.now();
      if (now.difference(_lastHaptic).inMilliseconds > 90) {
        HapticFeedback.selectionClick();
        _lastHaptic = now;
      }
      setState(() => _value = rounded);
      widget.onChanged(rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tickCount = ((_max - _min) / _step).round() + 1;
    final feet = (_value / 30.48).floor();
    final inches = ((_value / 2.54) - feet * 12).round();

    return StaggerColumn(
      children: [
        const SetupStepHeader(
          title: 'Whats your Height?',
          subtitle:
              'Height helps us calculate BMI and\nrecommend the right workouts',
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedValueText(
                      value: _value,
                      style: AppTextStyles.valueLarge,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
                      child: Text(
                        'cm',
                        style: AppTextStyles.valueUnit.copyWith(
                          color: AppColors.subtitle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    '$feet\' $inches"',
                    key: ValueKey('$feet-$inches'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subtitle,
                    ),
                  ),
                ),
                SizedBox(height: 36.h),
                SizedBox(
                  width: 120.w,
                  height: 280.h,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification ||
                          notification is ScrollEndNotification) {
                        _onScroll();
                      }
                      return false;
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ListView.builder(
                          controller: _controller,
                          physics: const BouncingScrollPhysics(),
                          itemCount: tickCount,
                          padding: EdgeInsets.symmetric(vertical: 140.h),
                          itemBuilder: (context, index) {
                            final isMajor = index % 10 == 0;
                            final isMid = index % 5 == 0;
                            final width = isMajor
                                ? 42.w
                                : isMid
                                    ? 28.w
                                    : 16.w;

                            return SizedBox(
                              height: _pixelsPerUnit.h,
                              child: Align(
                                alignment: Alignment.center,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  width: width,
                                  height: isMajor ? 2.h : 1.2.h,
                                  decoration: BoxDecoration(
                                    color: isMajor
                                        ? AppColors.title
                                        : AppColors.rulerTick,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const _CenterIndicator(vertical: false),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Slide to adjust',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CenterIndicator extends StatelessWidget {
  const _CenterIndicator({required this.vertical});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: vertical ? 2.5.w : double.infinity,
        height: vertical ? double.infinity : 2.5.h,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.4),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}
