import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';
import '../widgets/floating_motion.dart';

/// Page 2 — centered mood-orbit visual. Animation: orbit + breath + stagger.
class OnboardingPatternsPage extends StatefulWidget {
  const OnboardingPatternsPage({super.key, required this.visible});

  final bool visible;

  @override
  State<OnboardingPatternsPage> createState() => _OnboardingPatternsPageState();
}

class _OnboardingPatternsPageState extends State<OnboardingPatternsPage>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _orbit;
  late final AnimationController _breath;

  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _copyOpacity;
  late final Animation<Offset> _copySlide;
  late final Animation<double> _pillsOpacity;
  late final Animation<Offset> _pillsSlide;
  late final Animation<double> _chartOpacity;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _ringScale = Tween<double>(begin: 0.78, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _ringOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0, 0.35, curve: Curves.easeOut),
    );
    _copyOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.28, 0.72, curve: Curves.easeOut),
    );
    _copySlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.28, 0.78, curve: Curves.easeOutCubic),
      ),
    );
    _pillsOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.48, 0.9, curve: Curves.easeOut),
    );
    _pillsSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.48, 0.95, curve: Curves.easeOutCubic),
      ),
    );
    _chartOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.58, 1, curve: Curves.easeOut),
    );

    if (widget.visible) _play();
  }

  @override
  void didUpdateWidget(covariant OnboardingPatternsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _play();
    } else if (!widget.visible && oldWidget.visible) {
      _entrance.reset();
      _orbit.stop();
      _breath.stop();
    }
  }

  void _play() {
    _entrance.forward(from: 0);
    _orbit.repeat();
    _breath.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _orbit.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            flex: 11,
            child: FadeTransition(
              opacity: _ringOpacity,
              child: ScaleTransition(
                scale: _ringScale,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_orbit, _breath]),
                  builder: (context, _) {
                    final breath = Curves.easeInOut.transform(_breath.value);
                    return CustomPaint(
                      painter: _OrbitPainter(
                        progress: _orbit.value,
                        breath: breath,
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: 0.96 + breath * 0.06,
                          child: FloatingMotion(
                            amplitude: 5,
                            duration: const Duration(milliseconds: 3600),
                            child: Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  center: const Alignment(-0.25, -0.35),
                                  radius: 1.05,
                                  colors: [
                                    AppColors.white,
                                    AppColors.softLavender,
                                    AppColors.lavender.withValues(alpha: 0.55),
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.lavender
                                        .withValues(alpha: 0.35 + breath * 0.2),
                                    blurRadius: 30 + breath * 10,
                                    offset: const Offset(0, 14),
                                  ),
                                  BoxShadow(
                                    color: AppColors.peach
                                        .withValues(alpha: 0.18),
                                    blurRadius: 40,
                                    offset: const Offset(-8, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.spa_rounded,
                                  size: 40,
                                  color: Color.lerp(
                                    const Color(0xFF8B7FB8),
                                    AppColors.lavender,
                                    breath,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Column(
              children: [
                FadeTransition(
                  opacity: _copyOpacity,
                  child: SlideTransition(
                    position: _copySlide,
                    child: Column(
                      children: [
                        Text(
                          'Notice the patterns\nin your feelings',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.libreBaskerville(
                            fontSize: height < 700 ? 25 : 27,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: -0.4,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Gentle check-ins help you spot what lifts you up, what drains you, and when you need rest.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            height: 1.5,
                            color: AppColors.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _pillsOpacity,
                  child: SlideTransition(
                    position: _pillsSlide,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MoodPill(
                          label: 'Calm',
                          color: AppColors.lavender,
                          icon: Icons.water_drop_outlined,
                        ),
                        SizedBox(width: 8),
                        _MoodPill(
                          label: 'Heavy',
                          color: AppColors.peach,
                          icon: Icons.cloud_outlined,
                        ),
                        SizedBox(width: 8),
                        _MoodPill(
                          label: 'Hopeful',
                          color: Color(0xFFF0E6C8),
                          icon: Icons.wb_sunny_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: _chartOpacity,
                  child: const _WeekPatternCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodPill extends StatelessWidget {
  const _MoodPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.ink.withValues(alpha: 0.7)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekPatternCard extends StatelessWidget {
  const _WeekPatternCard();

  static const _heights = [0.35, 0.55, 0.42, 0.78, 0.5, 0.62, 0.4];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'This week',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                'Soft trend',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < _heights.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 28 * _heights[i] + 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: i == 3
                                  ? [
                                      AppColors.lavender,
                                      AppColors.peach,
                                    ]
                                  : [
                                      AppColors.lavender.withValues(alpha: 0.45),
                                      AppColors.softLavender,
                                    ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _days[i],
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.progress, required this.breath});

  final double progress;
  final double breath;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;

    // Soft glow disc
    canvas.drawCircle(
      center,
      radius * (0.92 + breath * 0.04),
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.lavender.withValues(alpha: 0.18 + breath * 0.08),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.15)),
    );

    // Rings
    for (final factor in [0.55, 0.78, 1.0]) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = factor == 1.0 ? 1.6 : 1.1
        ..color = AppColors.lavender.withValues(alpha: 0.28 + factor * 0.18);
      canvas.drawCircle(center, radius * factor, paint);
    }

    // Dashed arc accent
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.peach.withValues(alpha: 0.65);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.78),
      progress * math.pi * 2,
      math.pi * 0.55,
      false,
      arcPaint,
    );

    final dots = [
      (0.0, AppColors.peach, 11.0, Icons.wb_sunny_rounded),
      (0.28, AppColors.lavender, 9.0, Icons.favorite_rounded),
      (0.55, const Color(0xFFEBC84A), 8.5, Icons.nightlight_round),
      (0.8, AppColors.softLavender, 7.5, Icons.spa_rounded),
    ];

    for (final (offset, color, r, _) in dots) {
      final speed = 1.0 + offset * 0.15;
      final angle = (progress * speed + offset) * math.pi * 2;
      final orbitR = radius * (0.55 + (offset % 0.5) * 0.7);
      final pos = Offset(
        center.dx + math.cos(angle) * orbitR,
        center.dy + math.sin(angle) * orbitR,
      );

      canvas.drawCircle(
        pos,
        r + 10,
        Paint()..color = color.withValues(alpha: 0.18),
      );
      canvas.drawCircle(pos, r, Paint()..color = color);
      canvas.drawCircle(
        pos.translate(-r * 0.25, -r * 0.25),
        r * 0.28,
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.breath != breath;
}
