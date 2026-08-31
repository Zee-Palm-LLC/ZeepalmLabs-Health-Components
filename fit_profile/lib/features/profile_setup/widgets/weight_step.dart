import 'package:fit_profile/core/motion/animated_value_text.dart';
import 'package:fit_profile/core/motion/setup_step_header.dart';
import 'package:fit_profile/core/motion/stagger_column.dart';
import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:fit_profile/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightStep extends StatefulWidget {
  const WeightStep({
    super.key,
    required this.weightKg,
    required this.onChanged,
  });

  final double weightKg;
  final ValueChanged<double> onChanged;

  @override
  State<WeightStep> createState() => _WeightStepState();
}

class _WeightStepState extends State<WeightStep> {
  static const _min = 30.0;
  static const _max = 150.0;
  static const _step = 0.5;
  static const _pixelsPerUnit = 12.0;

  late final ScrollController _controller;
  late double _value;
  DateTime _lastHaptic = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _value = widget.weightKg.clamp(_min, _max);
    final initialOffset = (_value - _min) / _step * _pixelsPerUnit.w;
    _controller = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final units = _controller.offset / _pixelsPerUnit.w;
    final next = (_min + units * _step).clamp(_min, _max);
    final rounded = (next * 2).round() / 2;
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

    return StaggerColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SetupStepHeader(
          title: 'Whats your Weight?',
          subtitle:
              'You can always change this later.\nWe use it to track your progress',
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
                      'kg',
                      style: AppTextStyles.valueUnit.copyWith(
                        color: AppColors.subtitle,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 36.h),
              SizedBox(
                height: 90.h,
                width: double.infinity,
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
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: tickCount,
                        padding: EdgeInsets.symmetric(
                          horizontal: (1.sw - 48.w) / 2,
                        ),
                        itemBuilder: (context, index) {
                          final isMajor = index % 10 == 0;
                          final isMid = index % 5 == 0;
                          final height = isMajor
                              ? 48.h
                              : isMid
                                  ? 34.h
                                  : 22.h;

                          return SizedBox(
                            width: _pixelsPerUnit.w,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                width: isMajor ? 2.w : 1.2.w,
                                height: height,
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
                      _CenterIndicator(vertical: true),
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
    return AnimatedContainer(
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
    );
  }
}
