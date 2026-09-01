import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthscan_ai/core/theme/app_colors.dart';
import 'package:healthscan_ai/core/theme/app_text_styles.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HealthScoreHero extends StatelessWidget {
  const HealthScoreHero({
    super.key,
    this.score = 92,
    this.maxScore = 100,
    this.statusLabel = 'Excellent Health',
    this.trendLabel = '+8% this week',
    this.trendPercent = 0.08,
  });

  final int score;
  final int maxScore;
  final String statusLabel;
  final String trendLabel;
  final double trendPercent;

  @override
  Widget build(BuildContext context) {
    final circleSize = 168.w;
    final overflowRight = 42.w;
    final cardHeight = 162.h;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.9, -0.5),
          end: Alignment(0.9, 0.5),
          colors: [
            Color(0xFF2F5BD2),
            Color(0xFF214BD2),
            Color(0xFF147FDB),
            Color(0xFF3ACBC5),
          ],
          stops: [0.0, 0.42, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163FA4).withValues(alpha: 0.28),
            blurRadius: 30,
            offset: Offset(0, 15.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AI Health Score',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white.withValues(alpha: 0.82),
                    letterSpacing: 0.1,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: AppTextStyles.heroScore.copyWith(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 3.w),
                      child: Text(
                        '/$maxScore',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      Iconsax.magic_star,
                      size: 14.sp,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                _TrendBadge(label: trendLabel),
              ],
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Transform.translate(
                offset: Offset(overflowRight, 0),
                child: SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: const _AiHealthCircle(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A6E).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.45),
                  blurRadius: 6,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Iconsax.arrow_up_3,
              size: 10.sp,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 7.w),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB8E4FF),
            ),
          ),
        ],
      ),
    );
  }
}

/// Flutter port of `enhanced-ai-health-circle.html`
class _AiHealthCircle extends StatefulWidget {
  const _AiHealthCircle();

  @override
  State<_AiHealthCircle> createState() => _AiHealthCircleState();
}

class _AiHealthCircleState extends State<_AiHealthCircle>
    with TickerProviderStateMixin {
  late final AnimationController _driftCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _sparkleCtrl;
  late final AnimationController _twinkleCtrl;

  static const _stars = <_StarSpec>[
    _StarSpec(left: 0.17, top: 0.16, size: 4),
    _StarSpec(left: 0.29, top: 0.09, size: 3, delay: -1.0),
    _StarSpec(left: 0.48, top: 0.13, size: 3, delay: -1.8),
    _StarSpec(left: 0.76, top: 0.18, size: 3),
    _StarSpec(left: 0.91, top: 0.46, size: 5, delay: -1.0),
    _StarSpec(left: 0.16, top: 0.72, size: 3, delay: -1.8),
    _StarSpec(left: 0.75, top: 0.78, size: 3),
    _StarSpec(left: 0.11, top: 0.50, size: 3, delay: -1.0),
  ];

  @override
  void initState() {
    super.initState();
    _driftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _twinkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _driftCtrl.dispose();
    _orbitCtrl.dispose();
    _floatCtrl.dispose();
    _sparkleCtrl.dispose();
    _twinkleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;

        return AnimatedBuilder(
          animation: Listenable.merge([
            _driftCtrl,
            _orbitCtrl,
            _floatCtrl,
            _sparkleCtrl,
            _twinkleCtrl,
          ]),
          builder: (context, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                _ambient(size),
                _orbitRing(size),
                _ringGlow(size),
                _progressRing(size),
                ..._stars.map((star) => _twinkleStar(size, star)),
                _innerCore(size),
              ],
            );
          },
        );
      },
    );
  }

  Widget _ambient(double size) {
    final drift = _driftCtrl.value;
    final ambientSize = size * 0.45;
    return Positioned(
      right: -size * 0.12 - drift * size * 0.05,
      top: -size * 0.18 + drift * size * 0.05,
      width: ambientSize * (1 + drift * 0.15),
      height: ambientSize * (1 + drift * 0.15),
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF52EBE6).withValues(alpha: 0.28),
          ),
        ),
      ),
    );
  }

  Widget _orbitRing(double size) {
    final orbitSize = size * 0.76;
    final pulse = _orbitCtrl.value;
    final opacity = 0.72 + (1 - pulse) * 0.28;
    final scale = 1 + pulse * 0.01;
    final rotation = (-33 + pulse * 2) * math.pi / 180;

    return Positioned(
      left: size * 0.12,
      top: size * 0.09,
      width: orbitSize,
      height: orbitSize,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(
              size: Size(orbitSize, orbitSize),
              painter: _OrbitRingPainter(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ringGlow(double size) {
    final glowSize = size * 0.64;
    return Positioned(
      left: size * 0.18,
      top: size * 0.18,
      width: glowSize,
      height: glowSize,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF27DEE1).withValues(alpha: 0.2),
                Colors.transparent,
              ],
              stops: const [0.0, 0.62],
            ),
          ),
        ),
      ),
    );
  }

  Widget _progressRing(double size) {
    final ringSize = size * 0.60;
    final float = _floatCtrl.value;
    final yShift = -5 * float;
    final rotation = float * 1 * math.pi / 180;

    return Positioned(
      left: size * 0.20,
      top: size * 0.20 + yShift,
      width: ringSize,
      height: ringSize,
      child: Transform.rotate(
        angle: rotation,
        child: CustomPaint(
          size: Size(ringSize, ringSize),
          painter: const _ProgressRingPainter(),
        ),
      ),
    );
  }

  Widget _twinkleStar(double size, _StarSpec star) {
    final t = (_twinkleCtrl.value + star.delay / 2.5) % 1.0;
    final opacity = 0.3 + math.sin(t * math.pi) * 0.7;
    final scale = 0.7 + math.sin(t * math.pi) * 0.65;
    final dot = star.size * (size / 124);

    return Positioned(
      left: size * star.left - dot / 2,
      top: size * star.top - dot / 2,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: dot,
            height: dot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF9AFFEF),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF79F4E7).withValues(alpha: 0.9),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _innerCore(double size) {
    final innerSize = size * 0.30;
    final sparkle = _sparkleCtrl.value;
    final sparkleScale = 1 + sparkle * 0.08;
    final sparkleRotate = sparkle * 2 * math.pi / 180;

    return Positioned(
      left: size * 0.35,
      top: size * 0.35,
      width: innerSize,
      height: innerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.1, -0.3),
            radius: 0.95,
            colors: [
              Color(0xFF2868DF),
              Color(0xFF1649BA),
              Color(0xFF113B9D),
            ],
            stops: [0.0, 0.58, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFF75DCFF).withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ADAE1).withValues(alpha: 0.22),
              blurRadius: 45,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(innerSize * 0.10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF74ECFF).withValues(alpha: 0.16),
                    ),
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: sparkleRotate,
              child: Transform.scale(
                scale: sparkleScale,
                child: CustomPaint(
                  size: Size(innerSize * 0.54, innerSize * 0.54),
                  painter: const _SparkleIconPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    final outerGlow = Paint()
      ..color = const Color(0xFF58F2E1).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, radius, outerGlow);

    final outer = Paint()
      ..color = const Color(0xFF81FFEF).withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.25,
      math.pi * 1.5,
      false,
      outer,
    );

    final innerRadius = radius * 0.92;
    final inner = Paint()
      ..color = const Color(0xFF66ECE9).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      math.pi * 0.15,
      math.pi * 1.35,
      false,
      inner,
    );

    final innerBright = Paint()
      ..color = const Color(0xFFA8FFF3).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -math.pi * 0.55,
      math.pi * 0.45,
      false,
      innerBright,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final stroke = size.width * 0.125;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    final glow = Paint()
      ..color = const Color(0xFFC2FFF7).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius - stroke / 2, glow);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..shader = SweepGradient(
        startAngle: 138 * math.pi / 180,
        endAngle: 138 * math.pi / 180 + 2 * math.pi,
        colors: const [
          Color(0x1FFFFFFF),
          Color(0xB8FFFFFF),
          Color(0xFFFFFFFF),
          Color(0xE6DAFFF8),
          Color(0xB865E6DE),
          Color(0x1FFFFFFF),
        ],
        stops: [0.0, 20 / 360, 38 / 360, 190 / 360, 267 / 360, 1.0],
        transform: GradientRotation(138 * math.pi / 180),
      ).createShader(rect);

    canvas.drawArc(rect, 0, 2 * math.pi, false, ringPaint);

    final dotAngle = 138 * math.pi / 180 + 2 * math.pi * 0.72;
    final dotR = radius - stroke / 2;
    final dot = Offset(
      center.dx + math.cos(dotAngle) * dotR,
      center.dy + math.sin(dotAngle) * dotR,
    );

    final dotGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawCircle(dot, 9, dotGlow);
    canvas.drawCircle(dot, 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparkleIconPainter extends CustomPainter {
  const _SparkleIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;

    canvas.save();
    canvas.scale(scale);

    final mainStar = Path()
      ..moveTo(50, 10)
      ..cubicTo(53, 30, 59, 39, 79, 44)
      ..cubicTo(59, 49, 53, 58, 50, 80)
      ..cubicTo(47, 58, 41, 49, 21, 44)
      ..cubicTo(41, 39, 47, 30, 50, 10)
      ..close();

    final mainGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(mainStar, mainGlow);

    final mainPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(mainStar, mainPaint);

    final smallStar1 = Path()
      ..moveTo(25, 53)
      ..cubicTo(27, 62, 30, 66, 39, 68)
      ..cubicTo(30, 70, 27, 74, 25, 83)
      ..cubicTo(23, 74, 20, 70, 11, 68)
      ..cubicTo(20, 66, 23, 62, 25, 53)
      ..close();

    final smallStar2 = Path()
      ..moveTo(79, 17)
      ..cubicTo(80, 23, 82, 26, 88, 27)
      ..cubicTo(82, 28, 80, 31, 79, 37)
      ..cubicTo(78, 31, 76, 28, 70, 27)
      ..cubicTo(76, 26, 78, 23, 79, 17)
      ..close();

    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(smallStar1, fill);
    canvas.drawPath(smallStar2, fill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarSpec {
  const _StarSpec({
    required this.left,
    required this.top,
    required this.size,
    this.delay = 0,
  });

  final double left;
  final double top;
  final double size;
  final double delay;
}
