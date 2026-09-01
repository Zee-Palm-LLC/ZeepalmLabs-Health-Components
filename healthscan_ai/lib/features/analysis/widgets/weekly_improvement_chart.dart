import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyImprovementChart extends StatelessWidget {
  const WeeklyImprovementChart({super.key});

  static const _values = [0.55, 0.58, 0.62, 0.65, 0.7, 0.75, 0.82];
  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Improvement', style: AppTextStyles.sectionTitle),
          SizedBox(height: 4.h),
          Text(
            '+8% improvement this week',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.successText,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 120.h,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(values: _values),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in _labels)
                Text(label, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - values[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.success.withValues(alpha: 0.2),
            AppColors.success.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.success
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final lastX = size.width;
    final lastY = size.height - values.last * size.height;
    canvas.drawCircle(
      Offset(lastX, lastY),
      5,
      Paint()..color = AppColors.success,
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      8,
      Paint()
        ..color = AppColors.success.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => false;
}
