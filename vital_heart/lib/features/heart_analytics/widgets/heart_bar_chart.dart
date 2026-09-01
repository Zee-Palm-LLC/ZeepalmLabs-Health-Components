import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HeartBarChart extends StatefulWidget {
  const HeartBarChart({
    super.key,
    required this.values,
  });

  final List<double> values;

  @override
  State<HeartBarChart> createState() => _HeartBarChartState();
}

class _HeartBarChartState extends State<HeartBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = widget.values.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 196.h,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: _GridPainter(),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < widget.values.length; i++)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                child: _Bar(
                                  value: widget.values[i],
                                  maxValue: maxValue,
                                  highlight: i == 3,
                                  anim: _controller,
                                  delay: i * 0.08,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    for (final label in ['12AM', '6', '12PM', '6'])
                      Expanded(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in ['250', '200', '150', '100', '50', '0'])
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.chartGrid.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    for (var i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.maxValue,
    required this.highlight,
    required this.anim,
    required this.delay,
  });

  final double value;
  final double maxValue;
  final bool highlight;
  final Animation<double> anim;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final ratio = value / maxValue;

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(
          ((anim.value - delay) / (1 - delay)).clamp(0.0, 1.0),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight * ratio * t;

            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: highlight
                        ? [AppColors.heartGlow, AppColors.accent]
                        : [
                            AppColors.accent.withValues(alpha: 0.9),
                            AppColors.accentDeep,
                          ],
                  ),
                  boxShadow: highlight
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
