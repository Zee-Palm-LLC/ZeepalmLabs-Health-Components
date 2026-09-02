import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/motion/dashboard_motion.dart';
import 'package:healthscan_ai/core/motion/luxury_tap.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/features/shared/widgets/app_card.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class WaterIntakeCard extends StatelessWidget {
  const WaterIntakeCard({super.key, this.onAddWater});

  final VoidCallback? onAddWater;

  static const filled = 6;
  static const total = 8;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(16.w),
      radius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Iconsax.drop,
                size: 20.sp,
                color: AppColors.water,
              ),
              SizedBox(width: 8.w),
              Text(
                'Water Intake',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
                  children: [
                    TextSpan(
                      text: '$filled',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(
                      text: ' / $total Glasses',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          MotionProgress(
            start: 0.42,
            end: 0.68,
            builder: (context, t) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < total; i++)
                  _WaterGlass(
                    filled: i < filled,
                    fillProgress: ((t - i * 0.08) / 0.14).clamp(0.0, 1.0),
                  ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Align(
            alignment: Alignment.centerRight,
            child: LuxuryTap(
              onTap: onAddWater,
              scale: 0.97,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FF),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.add,
                      size: 14.sp,
                      color: AppColors.blue,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Add Water',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterGlass extends StatelessWidget {
  const _WaterGlass({
    required this.filled,
    this.fillProgress = 1,
  });

  final bool filled;
  final double fillProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28.w,
      height: 34.h,
      child: CustomPaint(
        painter: _WaterGlassPainter(
          filled: filled,
          fillProgress: fillProgress,
        ),
      ),
    );
  }
}

class _WaterGlassPainter extends CustomPainter {
  const _WaterGlassPainter({
    required this.filled,
    required this.fillProgress,
  });

  final bool filled;
  final double fillProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final glassPath = Path()
      ..moveTo(w * 0.18, h * 0.08)
      ..lineTo(w * 0.82, h * 0.08)
      ..lineTo(w * 0.72, h * 0.92)
      ..lineTo(w * 0.28, h * 0.92)
      ..close();

    if (filled && fillProgress > 0) {
      final waterTop = h * (0.86 - (0.48 * fillProgress));
      final liquidPath = Path()
        ..moveTo(w * 0.24, waterTop)
        ..lineTo(w * 0.76, waterTop)
        ..lineTo(w * 0.7, h * 0.86)
        ..lineTo(w * 0.3, h * 0.86)
        ..close();

      canvas.drawPath(
        liquidPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF60CFFF),
              Color(0xFF38BDF8),
              Color(0xFF0EA5E9),
            ],
          ).createShader(Rect.fromLTWH(0, h * 0.35, w, h * 0.55)),
      );

      canvas.drawLine(
        Offset(w * 0.28, waterTop),
        Offset(w * 0.72, waterTop),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawPath(
        glassPath,
        Paint()..color = const Color(0xFFF3F4F6),
      );
    }

    canvas.drawPath(
      glassPath,
      Paint()
        ..color = filled
            ? const Color(0xFF7DD3FC)
            : const Color(0xFFD1D5DB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WaterGlassPainter oldDelegate) =>
      oldDelegate.filled != filled || oldDelegate.fillProgress != fillProgress;
}
