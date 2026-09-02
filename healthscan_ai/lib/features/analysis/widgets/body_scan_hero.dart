import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';

class BodyScanHero extends StatelessWidget {
  const BodyScanHero({super.key});

  static const _bodyAsset = 'assets/human_body.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 260.w,
              height: 280.h,
              child: const CustomPaint(
                painter: _BlueMeshGradientPainter(),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              _bodyAsset,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const Center(child: _ScoreCard()),
          ),
        ],
      ),
    );
  }
}

class _BlueMeshGradientPainter extends CustomPainter {
  const _BlueMeshGradientPainter();

  static const _deepBlue = Color(0xFF2E5BFF);
  static const _skyBlue = Color(0xFF60A5FA);
  static const _cyan = Color(0xFF38BDF8);
  static const _indigo = Color(0xFF6366F1);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.48);

    _drawBlob(canvas, center: center, radius: size.width * 0.52, color: _deepBlue, alpha: 0.32);
    _drawBlob(
      canvas,
      center: center + Offset(-size.width * 0.18, -size.height * 0.08),
      radius: size.width * 0.38,
      color: _skyBlue,
      alpha: 0.26,
    );
    _drawBlob(
      canvas,
      center: center + Offset(size.width * 0.2, -size.height * 0.06),
      radius: size.width * 0.36,
      color: _indigo,
      alpha: 0.22,
    );
    _drawBlob(
      canvas,
      center: center + Offset(0, size.height * 0.12),
      radius: size.width * 0.4,
      color: _cyan,
      alpha: 0.2,
    );
  }

  void _drawBlob(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: alpha * 0.45),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  @override
  bool shouldRepaint(covariant _BlueMeshGradientPainter oldDelegate) => false;
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124.w,
      height: 124.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          center: Alignment.center,
          startAngle: 0,
          endAngle: 6.28,
          colors: [
            Color(0xFF93C5FD),
            Color(0xFF2E5BFF),
            Color(0xFF1DA1F2),
            Color(0xFFE0F2FE),
            Color(0xFF6366F1),
            Color(0xFF93C5FD),
          ],
          stops: [0.0, 0.2, 0.4, 0.55, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: const Color(0xFF60A5FA).withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.5.w),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '92',
                style: AppTextStyles.heroScore.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 34.sp,
                  height: 1,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'AI Health Score',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Excellent',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.successText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
