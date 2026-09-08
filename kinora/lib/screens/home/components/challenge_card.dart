import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../landing_page/components/math_motion.dart';

class ChallengeCard extends StatefulWidget {
  const ChallengeCard({super.key});

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _pulse;
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _pulse]),
      builder: (context, _) {
        final enter = MathMotion.settle(_enter.value, alpha: 5.2, omega: 9.8);
        final phase = _pulse.value * math.pi * 2;
        final breath = MathMotion.breath(phase, lo: 0.92, hi: 1.08);
        final progress = 0.60 * enter;
        final ring = 0.74 * enter;
        final glow = (0.22 + 0.18 * (0.5 + 0.5 * math.sin(phase))) * breath;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: KinoraColors.lime.withValues(alpha: 0.22 * glow),
                blurRadius: 42 * breath,
                spreadRadius: -2,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: KinoraColors.lime.withValues(alpha: 0.10 * glow),
                blurRadius: 70,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BannerAuraPainter(
                      phase: phase,
                      intensity: glow,
                    ),
                  ),
                ),
                Positioned(
                  top: -40,
                  right: -20,
                  child: Transform.rotate(
                    angle: 0.35,
                    child: Container(
                      width: 160,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.07),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 14, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _TrophyRing(
                        progress: ring,
                        phase: phase,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: KinoraColors.lime,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: KinoraColors.lime
                                            .withValues(alpha: 0.7),
                                        blurRadius: 6 * breath,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'New Challenge',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: KinoraColors.lime,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '2 Weeks of Energy',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: KinoraColors.text,
                                height: 1.15,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _ProgressTrack(
                              progress: progress,
                              shimmer: _pulse.value,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '${(progress * 100).round()}% Completed',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: KinoraColors.lime
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StartButton(
                        press: _press,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: KinoraColors.lime
                              .withValues(alpha: 0.12 + 0.08 * glow),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrophyRing extends StatelessWidget {
  const _TrophyRing({required this.progress, required this.phase});

  final double progress;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final breath = MathMotion.breath(phase, lo: 0.97, hi: 1.03);

    return Transform.scale(
      scale: breath,
      child: SizedBox(
        width: 68,
        height: 68,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
                boxShadow: [
                  BoxShadow(
                    color: KinoraColors.lime.withValues(alpha: 0.18),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: const Size(68, 68),
              painter: _RingPainter(progress: progress, phase: phase),
            ),
            Icon(
              LucideIcons.trophy,
              size: 24,
              color: Color.lerp(
                Colors.white,
                KinoraColors.lime,
                0.15 + 0.1 * math.sin(phase),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress, required this.shimmer});

  final double progress;
  final double shimmer;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    final shine = (shimmer * 1.6) % 1.2 - 0.1;

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFF2A2A2A)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: p,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          KinoraColors.limeDeep,
                          KinoraColors.lime,
                          Color(0xFFE8FF8A),
                        ],
                      ),
                    ),
                  ),
                  if (p > 0.05)
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.35,
                      child: Transform.translate(
                        offset: Offset(shine * 120, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.45),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.press, required this.onTap});

  final AnimationController press;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => press.forward(),
      onTapUp: (_) {
        press.reverse();
        onTap();
      },
      onTapCancel: () => press.reverse(),
      child: AnimatedBuilder(
        animation: press,
        builder: (context, child) {
          final t = MathMotion.smootherstep(press.value);
          return Transform.scale(
            scale: 1 - 0.08 * t,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'START',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerAuraPainter extends CustomPainter {
  _BannerAuraPainter({required this.phase, required this.intensity});

  final double phase;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Deep base
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFF121412),
    );

    // Primary lime bloom (left)
    final bloomA = Paint()
      ..shader = ui.Gradient.radial(
        Offset(
          size.width * 0.18,
          size.height * (0.35 + 0.04 * math.sin(phase)),
        ),
        size.width * 0.62,
        [
          KinoraColors.lime.withValues(alpha: 0.28 * intensity),
          KinoraColors.lime.withValues(alpha: 0.08 * intensity),
          Colors.transparent,
        ],
        const [0, 0.4, 1],
      );
    canvas.drawRect(rect, bloomA);

    // Secondary cooler bloom (right)
    final bloomB = Paint()
      ..shader = ui.Gradient.radial(
        Offset(
          size.width * 0.88,
          size.height * (0.7 + 0.05 * math.cos(phase * 0.8)),
        ),
        size.width * 0.45,
        [
          const Color(0xFF3D5A1A).withValues(alpha: 0.35 * intensity),
          Colors.transparent,
        ],
      );
    canvas.drawRect(rect, bloomB);

    // Diagonal light sweep
    final sweep = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * (0.15 + 0.05 * math.sin(phase)), 0),
        Offset(size.width * 0.7, size.height),
        [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.04 * intensity),
          Colors.white.withValues(alpha: 0),
        ],
        const [0.2, 0.5, 0.8],
      );
    canvas.drawRect(rect, sweep);

    // Soft vignette
    final vig = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.75,
        [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35),
        ],
        const [0.55, 1],
      );
    canvas.drawRect(rect, vig);
  }

  @override
  bool shouldRepaint(covariant _BannerAuraPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.intensity != intensity;
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.phase});

  final double progress;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (sweep <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.sweep(
        center,
        [
          KinoraColors.limeDeep,
          KinoraColors.lime,
          const Color(0xFFE8FF8A),
          KinoraColors.limeDeep,
        ],
        const [0.0, 0.35, 0.7, 1.0],
        TileMode.clamp,
        -math.pi / 2,
        -math.pi / 2 + sweep,
      );

    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);

    // Leading tip glow
    final tipAngle = -math.pi / 2 + sweep;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    final tipGlow = Paint()
      ..color = KinoraColors.lime.withValues(
        alpha: 0.55 + 0.25 * math.sin(phase),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(tip, 3.2, tipGlow);
    canvas.drawCircle(tip, 2.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.phase != phase;
}
