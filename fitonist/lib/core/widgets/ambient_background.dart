import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

enum AmbientVariant { onboardingOne, onboardingTwo, aboutYou }

class AmbientBackground extends StatefulWidget {
  const AmbientBackground({
    super.key,
    required this.variant,
    this.animate = true,
  });

  final AmbientVariant variant;
  final bool animate;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _MeshGradientPainter(
            progress: _controller.value,
            variant: widget.variant,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  _MeshGradientPainter({
    required this.progress,
    required this.variant,
  });

  final double progress;
  final AmbientVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.background,
    );

    final drift = math.sin(progress * math.pi * 2) * 0.035;
    final driftY = math.cos(progress * math.pi * 2) * 0.028;

    for (final orb in _orbsFor(variant)) {
      _drawOrb(
        canvas,
        size,
        x: orb.x + drift * orb.driftScale,
        y: orb.y + driftY * orb.driftScale,
        radius: size.width * orb.radiusScale,
        color: orb.color,
        opacity: orb.opacity,
      );
    }

    _drawVignette(canvas, size);
  }

  List<_GlowOrb> _orbsFor(AmbientVariant variant) {
    return switch (variant) {
      AmbientVariant.onboardingOne => const [
        _GlowOrb(0.82, 0.08, 0.72, Color(0xFF5B45FF), 0.22, 1.2),
        _GlowOrb(0.12, 0.14, 0.55, Color(0xFF2B6FFF), 0.14, 0.9),
        _GlowOrb(0.48, 0.38, 0.48, Color(0xFF8B5CF6), 0.10, 1.0),
        _GlowOrb(0.92, 0.62, 0.38, Color(0xFF4F46E5), 0.08, 0.7),
        _GlowOrb(0.05, 0.78, 0.42, Color(0xFF1E3A8A), 0.07, 0.8),
      ],
      AmbientVariant.onboardingTwo => const [
        _GlowOrb(0.78, 0.10, 0.68, Color(0xFF6366F1), 0.20, 1.1),
        _GlowOrb(0.18, 0.22, 0.52, Color(0xFF2B6FFF), 0.16, 1.0),
        _GlowOrb(0.55, 0.42, 0.50, Color(0xFF7C3AED), 0.11, 0.9),
        _GlowOrb(0.88, 0.55, 0.36, Color(0xFF2563EB), 0.09, 0.8),
        _GlowOrb(0.30, 0.85, 0.40, Color(0xFF4338CA), 0.06, 0.7),
      ],
      AmbientVariant.aboutYou => const [
        _GlowOrb(0.50, 0.18, 0.58, Color(0xFF6D28D9), 0.16, 1.0),
        _GlowOrb(0.85, 0.12, 0.45, Color(0xFF2B6FFF), 0.12, 0.9),
        _GlowOrb(0.15, 0.35, 0.42, Color(0xFF4C1D95), 0.10, 0.8),
        _GlowOrb(0.70, 0.72, 0.38, Color(0xFF1D4ED8), 0.07, 0.7),
      ],
    };
  }

  void _drawOrb(
    Canvas canvas,
    Size size, {
    required double x,
    required double y,
    required double radius,
    required Color color,
    required double opacity,
  }) {
    final center = Offset(size.width * x, size.height * y);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, paint);
  }

  void _drawVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.05,
        colors: [
          Colors.transparent,
          AppColors.background.withValues(alpha: 0.35),
          AppColors.background.withValues(alpha: 0.85),
        ],
        stops: const [0.45, 0.82, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.variant != variant;
  }
}

class _GlowOrb {
  const _GlowOrb(
    this.x,
    this.y,
    this.radiusScale,
    this.color,
    this.opacity,
    this.driftScale,
  );

  final double x;
  final double y;
  final double radiusScale;
  final Color color;
  final double opacity;
  final double driftScale;
}

/// Soft colored glow placed behind hero visuals.
class HeroGlow extends StatelessWidget {
  const HeroGlow({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: 220.w,
        height: 220.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.35),
              color.withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
