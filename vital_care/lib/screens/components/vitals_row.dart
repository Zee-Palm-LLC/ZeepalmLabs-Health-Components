import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class HealthVitalsCards extends StatelessWidget {
  const HealthVitalsCards({super.key});

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color heartRed = Color(0xFFFF5A63);
  static const Color mutedText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: _BloodPressureBarChartCard()),
        SizedBox(width: 16.w),
        const Expanded(child: _HeartRateCard()),
      ],
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  final Color accent;

  const _PremiumCard({required this.child, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEAF1FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24.r,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.07),
            blurRadius: 34.r,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(12.r),
        child: Stack(
          children: [
            Positioned(
              top: -34,
              right: -28,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.14),
                      accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -34,
              bottom: -42,
              child: Container(
                width: 110.w,
                height: 110.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.03),
                      Colors.black.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(12.r), child: child),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;

  const _CardHeader({
    required this.icon,
    required this.title,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEAF1FF),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 14.sp, color: accent),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF0F172A),
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BloodPressureBarChartCard extends StatelessWidget {
  const _BloodPressureBarChartCard();

  static const List<double> _bars = [0.42, 0.55, 0.48, 0.68, 0.6, 0.8, 0.72];
  static const List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      accent: HealthVitalsCards.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Iconsax.activity,
            title: 'Blood Pressure',
            accent: HealthVitalsCards.primaryBlue,
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '125/85',
                style: GoogleFonts.poppins(
                  color: HealthVitalsCards.primaryBlue,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Text(
                  'mmHg',
                  style: GoogleFonts.poppins(
                    color: HealthVitalsCards.mutedText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: _BarChart(bars: _bars, days: _days),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> bars;
  final List<String> days;

  const _BarChart({required this.bars, required this.days});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  height: 1,
                  child: const CustomPaint(
                    painter: _DashedLinePainter(color: Color(0x141E293B)),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(bars.length, (i) {
                    final isToday = i == bars.length - 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.2.w),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: bars[i]),
                          duration: 900.ms,
                          curve: Curves.easeOutCubic,
                          builder: (context, v, child) => Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: v,
                              child: _Bar(isToday: isToday),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: days
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: GoogleFonts.poppins(
                        fontSize: 8.sp,
                        color: HealthVitalsCards.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final bool isToday;

  const _Bar({required this.isToday});

  @override
  Widget build(BuildContext context) {
    const blue = HealthVitalsCards.primaryBlue;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: isToday
              ? const [Color(0xFF60A5FA), blue]
              : [blue.withValues(alpha: 0.14), blue.withValues(alpha: 0.5)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: blue.withValues(alpha: 0.4),
                  blurRadius: 10.r,
                  offset: const Offset(0, 0),
                ),
              ]
            : null,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dash).clamp(0, size.width), 0),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _HeartRateCard extends StatelessWidget {
  const _HeartRateCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      accent: HealthVitalsCards.heartRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PulsingHeartIcon(),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Heart Rate',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0F172A),
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '78',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0F172A),
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              SizedBox(width: 5.w),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  'bpm',
                  style: GoogleFonts.poppins(
                    color: HealthVitalsCards.heartRed,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Expanded(
            child: CustomPaint(
              painter: _EcgPainter(),
              child: SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingHeartIcon extends StatelessWidget {
  const _PulsingHeartIcon();

  @override
  Widget build(BuildContext context) {
    const red = HealthVitalsCards.heartRed;
    return SizedBox(
      width: 30.w,
      height: 30.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: red.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.5, 1.5),
                duration: 1500.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(duration: 1500.ms, curve: Curves.easeOut),
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  red.withValues(alpha: 0.4),
                  red.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          const Icon(Iconsax.heart5, size: 15, color: red)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.82, 0.82),
                end: const Offset(1.12, 1.12),
                duration: 520.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  const _EcgPainter();

  static const Color red = HealthVitalsCards.heartRed;
  static const Color blue = HealthVitalsCards.primaryBlue;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final mid = h * 0.5;

    final pts = <Offset>[
      Offset(0, mid),
      Offset(w * .06, mid),
      Offset(w * .10, mid - h * .06),
      Offset(w * .14, mid + h * .06),
      Offset(w * .20, mid),
      Offset(w * .26, mid),
      Offset(w * .30, mid + h * .10),
      Offset(w * .34, mid - h * .30),
      Offset(w * .39, mid + h * .12),
      Offset(w * .45, mid),
      Offset(w * .52, mid),
      Offset(w * .58, mid - h * .05),
      Offset(w * .64, mid + h * .05),
      Offset(w * .70, mid),
      Offset(w * 1.0, mid),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    final area = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [red.withValues(alpha: 0.26), red.withValues(alpha: 0.02)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = red.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3),
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [red, blue],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
