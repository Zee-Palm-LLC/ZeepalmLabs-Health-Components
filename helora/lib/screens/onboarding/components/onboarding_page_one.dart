import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helora/theme/app_colors.dart';

abstract final class _CardMotion {
  static double clamp01(double t) => t.clamp(0.0, 1.0);

  static double tanh(double x) {
    final e = math.exp(2 * x.clamp(-20.0, 20.0));
    return (e - 1) / (e + 1);
  }

  /// Magnetic ease — soft attraction to rest.
  static double magnetic(double t, {double sharpness = 2.9}) {
    t = clamp01(t);
    return 0.5 * (1 + tanh(sharpness * (2 * t - 1)) / tanh(sharpness));
  }

  /// Underdamped settle with soft overshoot (may briefly exceed 1).
  static double settle(double t, {double alpha = 7.4, double omega = 8.6}) {
    t = clamp01(t);
    return 1 - math.exp(-alpha * t) * math.cos(omega * t);
  }

  static double fan(double t) {
    t = clamp01(t);
    final body = magnetic(t, sharpness: 2.7);
    final crest = settle(t, alpha: 9.5, omega: 7.2);
    return (body * 0.78 + crest * 0.22).clamp(0.0, 1.15);
  }

  static double fade(double t) => clamp01(magnetic(t, sharpness: 2.6));

  static double channel(double t, {required double start, required double end}) {
    return clamp01((t - start) / (end - start));
  }
}

class _CardTarget {
  const _CardTarget({
    required this.left,
    required this.top,
    required this.angle,
    required this.size,
    required this.url,
    required this.tint,
    this.shadowStrong = false,
  });

  final double left;
  final double top;
  final double angle;
  final double size;
  final String url;
  final Color tint;
  final bool shadowStrong;
}

/// Onboarding page 1 — stacked cards fan out to final collage.
class OnboardingPageOne extends StatefulWidget {
  const OnboardingPageOne({super.key});

  @override
  State<OnboardingPageOne> createState() => _OnboardingPageOneState();
}

class _OnboardingPageOneState extends State<OnboardingPageOne>
    with SingleTickerProviderStateMixin {
  static const double _card = 168;
  static const double _radius = 34;
  static const double _canvas = 330;

  static const _images = [
    // Doctor / specialist
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=640&q=80',
    // Medical care team
    'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&w=640&q=80',
    // Clinic / patient care
    'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?auto=format&fit=crop&w=640&q=80',
  ];

  late final AnimationController _fan;

  // Shared stack origin (center pile) before fanning out.
  static const _stackLeft = 78.0;
  static const _stackTop = 72.0;

  late final List<_CardTarget> _targets = [
    // Back-left — higher, more left, stronger tilt
    _CardTarget(
      left: -18,
      top: 8,
      angle: -0.32,
      size: _card - 2,
      url: _images[0],
      tint: const Color(0xFFFFB7C5).withValues(alpha: 0.28),
    ),
    // Back-right — higher right, opposite lean
    _CardTarget(
      left: 168,
      top: -14,
      angle: 0.28,
      size: _card + 4,
      url: _images[1],
      tint: const Color(0xFFA8C8FF).withValues(alpha: 0.26),
    ),
    // Front — slightly off-center, soft twist
    _CardTarget(
      left: 72,
      top: 122,
      angle: -0.06,
      size: _card + 10,
      url: _images[2],
      tint: const Color(0xFFFF6A3D).withValues(alpha: 0.22),
      shadowStrong: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fan.forward();
    });
  }

  @override
  void dispose() {
    _fan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: SizedBox(
                width: _canvas,
                height: _canvas,
                child: AnimatedBuilder(
                  animation: _fan,
                  builder: (context, _) {
                    final t = _fan.value;
                    // Staggered channels — back cards first, front last.
                    final u0 = _CardMotion.channel(t, start: 0.00, end: 0.72);
                    final u1 = _CardMotion.channel(t, start: 0.08, end: 0.80);
                    final u2 = _CardMotion.channel(t, start: 0.16, end: 0.92);
                    final us = [u0, u1, u2];

                    final sparkle = _CardMotion.fade(
                      _CardMotion.channel(t, start: 0.55, end: 1.0),
                    );

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: -36,
                          top: 48,
                          child: IgnorePointer(
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.glowTeal.withValues(alpha: 0.55),
                                    AppColors.glowTeal.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Draw back → front; slight start offsets so pile feels stacked.
                        for (var i = 0; i < _targets.length; i++)
                          _FanCard(
                            progress: _CardMotion.fan(us[i]),
                            startLeft: _stackLeft + (i - 1) * 4,
                            startTop: _stackTop + (i - 1) * 5,
                            startAngle: (i - 1) * 0.04,
                            target: _targets[i],
                            radius: _radius,
                          ),

                        Positioned(
                          left: 148,
                          bottom: 0,
                          child: Opacity(
                            opacity: sparkle.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.4 + 0.6 * sparkle,
                              child: const _Sparkle(size: 13),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 172,
                          bottom: 18,
                          child: Opacity(
                            opacity: sparkle.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.4 + 0.6 * sparkle,
                              child: const _Sparkle(size: 10),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Care That Meets\nYou Where You Are',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28,
              height: 1.18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Helora brings doctors, labs, and pharmacies\ntogether — book trusted care in minutes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FanCard extends StatelessWidget {
  const _FanCard({
    required this.progress,
    required this.startLeft,
    required this.startTop,
    required this.startAngle,
    required this.target,
    required this.radius,
  });

  final double progress;
  final double startLeft;
  final double startTop;
  final double startAngle;
  final _CardTarget target;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    // Ease position with fan; add tiny settle overshoot on travel.
    final left = startLeft + (target.left - startLeft) * p;
    final top = startTop + (target.top - startTop) * p;
    final angle = startAngle + (target.angle - startAngle) * p;

    // Scale: pile starts slightly smaller, blooms into place.
    final scale = 0.88 + 0.12 * p;

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          child: _PortraitCard(
            url: target.url,
            size: target.size,
            radius: radius,
            tint: target.tint,
            shadowStrong: target.shadowStrong,
          ),
        ),
      ),
    );
  }
}

class _PortraitCard extends StatelessWidget {
  const _PortraitCard({
    required this.url,
    required this.size,
    required this.radius,
    required this.tint,
    this.shadowStrong = false,
  });

  final String url;
  final double size;
  final double radius;
  final Color tint;
  final bool shadowStrong;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowStrong ? 0.5 : 0.38),
            blurRadius: shadowStrong ? 28 : 22,
            offset: Offset(0, shadowStrong ? 16 : 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(color: tint),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return ColoredBox(
                  color: const Color(0xFF1A1A1C),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                );
              },
            ),
            ColoredBox(color: tint),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.22),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Icon(
        LucideIcons.sparkles,
        size: size,
        color: AppColors.text.withValues(alpha: 0.92),
      ),
    );
  }
}
