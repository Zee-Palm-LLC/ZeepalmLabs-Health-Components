import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard({super.key});

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color heartRed = Color(0xFFFF5A63);
  static const Color mutedText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
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
            color: heartRed.withValues(alpha: 0.06),
            blurRadius: 34.r,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      heartRed.withValues(alpha: 0.12),
                      heartRed.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                children: [
                  const Expanded(child: _HeartRateSection()),
                  SizedBox(width: 16.w),
                  const Expanded(child: _PulseSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartRateSection extends StatelessWidget {
  const _HeartRateSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _GlowingHeartIcon(),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heart Rate',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF0F172A),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Resting',
                    style: GoogleFonts.poppins(
                      color: OverviewCard.mutedText,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '78',
              style: GoogleFonts.poppins(
                color: Color(0xFF0F172A),
                fontSize: 40.sp,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            SizedBox(width: 7.w),
            Padding(
              padding: EdgeInsets.only(bottom: 5.h),
              child: Text(
                'bpm',
                style: GoogleFonts.poppins(
                  color: OverviewCard.heartRed,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlowingHeartIcon extends StatelessWidget {
  const _GlowingHeartIcon();

  @override
  Widget build(BuildContext context) {
    const red = OverviewCard.heartRed;
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [red.withValues(alpha: 0.35), red.withValues(alpha: 0.06)],
        ),
        border: Border.all(color: red.withValues(alpha: 0.3)),
      ),
      child: const Icon(Iconsax.heart5, color: red, size: 20)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(0.88, 0.88),
            end: const Offset(1.08, 1.08),
            duration: 550.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}

class _PulseSection extends StatefulWidget {
  const _PulseSection();

  @override
  State<_PulseSection> createState() => _PulseSectionState();
}

class _PulseSectionState extends State<_PulseSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pulse Waveform',
              style: GoogleFonts.poppins(
                color: OverviewCard.mutedText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: OverviewCard.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: OverviewCard.primaryBlue.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _PulsePainter(t: _controller.value),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PulsePainter extends CustomPainter {
  const _PulsePainter({required this.t});

  final double t;

  static const Color red = OverviewCard.heartRed;
  static const Color blue = OverviewCard.primaryBlue;

  static const _beat = <(double x, double y)>[
    (0.00, 0.0),
    (0.06, 0.0),
    (0.11, 0.05),
    (0.16, -0.05),
    (0.20, 0.0),
    (0.26, 0.0),
    (0.30, 0.10),
    (0.35, 0.34),
    (0.41, -0.16),
    (0.46, 0.0),
    (0.52, 0.0),
    (0.58, 0.08),
    (0.68, 0.0),
    (1.00, 0.0),
  ];

  List<Offset> _points(Size size) {
    const beats = 2;
    final w = size.width;
    final h = size.height;
    final mid = h * 0.52;
    final pts = <Offset>[];
    for (var b = 0; b < beats; b++) {
      for (final (x, y) in _beat) {
        pts.add(Offset((b + x) / beats * w, mid - y * h));
      }
    }
    return pts;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pts = _points(size);
    final maxIdx = (pts.length - 1) * t;
    final idx = maxIdx.floor().clamp(0, pts.length - 1).toInt();
    final frac = maxIdx - idx;
    final head = idx >= pts.length - 1
        ? pts.last
        : Offset.lerp(pts[idx], pts[idx + 1], frac)!;

    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var i = 1; i < 5; i++) {
      final gy = h * i / 5;
      canvas.drawLine(Offset(0, gy), Offset(w, gy), gridPaint);
    }

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i <= idx; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.lineTo(head.dx, head.dy);

    final area = Path.from(path)
      ..lineTo(head.dx, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [red.withValues(alpha: 0.22), red.withValues(alpha: 0.0)],
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
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5),
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [red, blue],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    canvas.drawCircle(
      head,
      4.5 + pulse * 2.5,
      Paint()..color = blue.withValues(alpha: 0.35),
    );
    canvas.drawCircle(head, 2.2, Paint()..color = const Color(0xFF0F172A));
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) => oldDelegate.t != t;
}
