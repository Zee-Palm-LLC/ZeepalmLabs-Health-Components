import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helora/theme/app_colors.dart';

abstract final class _OrbitMotion {
  static double clamp01(double t) => t.clamp(0.0, 1.0);

  static double tanh(double x) {
    final e = math.exp(2 * x.clamp(-20.0, 20.0));
    return (e - 1) / (e + 1);
  }

  static double magnetic(double t, {double sharpness = 2.8}) {
    t = clamp01(t);
    return 0.5 * (1 + tanh(sharpness * (2 * t - 1)) / tanh(sharpness));
  }

  /// Soft pop 0 → 1 for scale-from-zero entrances.
  static double scaleIn(double t) {
    t = clamp01(t);
    final base = magnetic(t, sharpness: 3.1);
    // Tiny overshoot then settle under 1.06
    final crest = math.sin(math.pi * base) * 0.06 * (1 - t);
    return (base + crest).clamp(0.0, 1.08);
  }

  static double channel(double t, {required double start, required double end}) {
    return clamp01((t - start) / (end - start));
  }

  static double breath(double phase, {double lo = 0.97, double hi = 1.03}) {
    return lo + (hi - lo) * (0.5 + 0.5 * math.sin(phase));
  }

  static Offset float(double phase, {double ampY = 3}) =>
      Offset(0, math.sin(phase) * ampY);

  /// Orbit angle: fast spin that eases into a calm cruise.
  /// θ(t) = ω∞·t + (ω0−ω∞)/α · (1 − e^(−αt))
  static double orbitAngle(double seconds, {double direction = 1}) {
    const w0 = 5.8; // rad/s start (fast)
    const wInf = 0.30; // rad/s cruise (slow)
    const alpha = 1.45;
    final t = seconds.clamp(0.0, double.infinity);
    final theta =
        wInf * t + (w0 - wInf) / alpha * (1 - math.exp(-alpha * t));
    return theta * direction;
  }

  /// Perspective depth from orbit angle (−1 back → +1 front).
  static double depth(double angle) => math.sin(angle);

  static double depthScale(double d) =>
      0.72 + 0.36 * ((d + 1) * 0.5);

  static double depthOpacity(double d) =>
      0.48 + 0.52 * ((d + 1) * 0.5);

  /// Perfect circular orbit position.
  static Offset circle(double angle, {required double radius}) {
    return Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }
}

const _avatars = [
  'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1594824476967-48c8b964273f?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1537368910025-700362fe4657?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1651009173162-76d230d2bdc1?auto=format&fit=crop&w=200&q=80',
];

/// Distinct sizes — one focal avatar slightly larger.
const _avatarSizes = [40.0, 34.0, 44.0, 52.0, 36.0, 42.0];

class _OrbitSlot {
  const _OrbitSlot({
    required this.index,
    required this.radius,
    required this.speed,
    required this.lane,
  });

  final int index;
  final double radius;
  final double speed; // relative angular speed (+/− for counter-orbit)
  final int lane; // 0 = inner, 1 = outer
}

/// Dual concentric circular orbits (outer counters the inner).
const _orbitSlots = [
  _OrbitSlot(index: 0, radius: 118, speed: 1.00, lane: 0),
  _OrbitSlot(index: 1, radius: 148, speed: -0.72, lane: 1),
  _OrbitSlot(index: 2, radius: 118, speed: 1.08, lane: 0),
  _OrbitSlot(index: 3, radius: 148, speed: -0.78, lane: 1),
  _OrbitSlot(index: 4, radius: 148, speed: -0.65, lane: 1),
  _OrbitSlot(index: 5, radius: 118, speed: 0.92, lane: 0),
];

/// Onboarding page 3 — orbiting care network + medical copy.
class OnboardingPageThree extends StatefulWidget {
  const OnboardingPageThree({
    super.key,
    this.isActive = false,
    this.prepare = false,
  });

  final bool isActive;

  /// When true, run the entrance once early (previous page) to avoid blink on arrival.
  final bool prepare;

  @override
  State<OnboardingPageThree> createState() => _OnboardingPageThreeState();
}

class _OnboardingPageThreeState extends State<OnboardingPageThree>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _orbit;
  final Stopwatch _spinClock = Stopwatch();
  bool _introStarted = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    // Lightweight ticker for continuous orbit frames.
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    SchedulerBinding.instance.addPostFrameCallback((_) => _maybeStartIntro());
  }

  void _maybeStartIntro() {
    if (!mounted || _introStarted) return;
    if (!widget.isActive && !widget.prepare) return;

    _introStarted = true;
    _spinClock
      ..reset()
      ..start();
    // Never restart from 0 again — that was the page-arrival blink.
    if (_enter.value < 1) {
      _enter.forward();
    }
  }

  @override
  void didUpdateWidget(covariant OnboardingPageThree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive || widget.prepare) {
      _maybeStartIntro();
    }
    if (widget.isActive && !oldWidget.isActive) {
      if (!_spinClock.isRunning) _spinClock.start();
      if (!_orbit.isAnimating) _orbit.repeat();
    }
  }

  @override
  void dispose() {
    _spinClock.stop();
    _enter.dispose();
    _orbit.dispose();
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
              child: AnimatedBuilder(
                animation: Listenable.merge([_enter, _orbit]),
                builder: (context, _) {
                  final e = _OrbitMotion.magnetic(_enter.value);
                  final seconds = _spinClock.isRunning
                      ? _spinClock.elapsedMilliseconds / 1000.0
                      : 0.0;
                  final spin = _OrbitMotion.orbitAngle(seconds);
                  final phase = spin;
                  final counterSpin = -spin * 0.55;

                  final placements = <({
                    int i,
                    Offset pos,
                    double depth,
                    double angle,
                    double pop,
                    _OrbitSlot slot,
                  })>[];

                  for (final slot in _orbitSlots) {
                    final i = slot.index;
                    final base =
                        (i / _avatars.length) * math.pi * 2 - math.pi / 2;
                    final a = base + spin * slot.speed;
                    final pos = _OrbitMotion.circle(
                      a,
                      radius: slot.radius,
                    );
                    final pop = _OrbitMotion.scaleIn(
                      _OrbitMotion.channel(
                        _enter.value,
                        start: 0.08 + i * 0.07,
                        end: 0.62 + i * 0.04,
                      ),
                    );
                    placements.add((
                      i: i,
                      pos: pos,
                      depth: _OrbitMotion.depth(a),
                      angle: a,
                      pop: pop,
                      slot: slot,
                    ));
                  }
                  placements.sort((a, b) => a.depth.compareTo(b.depth));

                  return SizedBox(
                    width: 400,
                    height: 380,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Opacity(
                          opacity: (0.75 * e).clamp(0.0, 1.0),
                          child: Container(
                            width: 340,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.22),
                                  AppColors.glowBlue.withValues(alpha: 0.45),
                                  AppColors.glowPurple.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                                stops: const [0, 0.28, 0.55, 1],
                              ),
                            ),
                          ),
                        ),

                        Opacity(
                          opacity: e.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 0.88 + 0.12 * e,
                            child: CustomPaint(
                              size: const Size(380, 360),
                              painter: _OrbitFieldPainter(
                                spin: spin,
                                counterSpin: counterSpin,
                                seconds: seconds,
                                avatarAngles: {
                                  for (final p in placements)
                                    p.i: (
                                      angle: p.angle,
                                      pos: p.pos,
                                      lane: p.slot.lane,
                                    ),
                                },
                              ),
                            ),
                          ),
                        ),

                        ...placements.map((p) {
                          final highlight = p.i == 3;
                          final dScale = _OrbitMotion.depthScale(p.depth);
                          final dOpacity = _OrbitMotion.depthOpacity(p.depth);
                          final size = _avatarSizes[p.i] * dScale;

                          return Opacity(
                            opacity: (p.pop * dOpacity).clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: p.pos,
                              child: Transform.scale(
                                scale: p.pop * (0.94 + 0.06 * dScale),
                                alignment: Alignment.center,
                                filterQuality: FilterQuality.medium,
                                child: _OrbitAvatar(
                                  url: _avatars[p.i],
                                  size: size,
                                  glow: highlight,
                                  phase: phase + p.i * 0.7,
                                  accentIndex: p.i,
                                ),
                              ),
                            ),
                          );
                        }),

                        // Center pill
                        Opacity(
                          opacity: _OrbitMotion
                              .magnetic(
                                _OrbitMotion.channel(
                                  _enter.value,
                                  start: 0.2,
                                  end: 0.75,
                                ),
                              )
                              .clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: _OrbitMotion.float(phase, ampY: 3),
                            child: Transform.scale(
                              scale: _OrbitMotion.breath(phase),
                              child: const _CenterPill(label: 'booked!'),
                            ),
                          ),
                        ),

                        // Cursor cue
                        Opacity(
                          opacity: _OrbitMotion
                              .magnetic(
                                _OrbitMotion.channel(
                                  _enter.value,
                                  start: 0.45,
                                  end: 0.95,
                                ),
                              )
                              .clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(
                              46,
                              28 + _OrbitMotion.float(phase + 0.8, ampY: 2).dy,
                            ),
                            child: Icon(
                              Icons.near_me_rounded,
                              size: 20,
                              color: AppColors.text,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Sparkles
                        Positioned(
                          top: 70,
                          child: Opacity(
                            opacity: _OrbitMotion
                                .magnetic(
                                  _OrbitMotion.channel(
                                    _enter.value,
                                    start: 0.5,
                                    end: 1,
                                  ),
                                )
                                .clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: _OrbitMotion.breath(
                                phase * 1.5,
                                lo: 0.85,
                                hi: 1.2,
                              ),
                              child: Icon(
                                LucideIcons.sparkles,
                                size: 13,
                                color: AppColors.text.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 88,
                          right: 108,
                          child: Opacity(
                            opacity: _OrbitMotion
                                .magnetic(
                                  _OrbitMotion.channel(
                                    _enter.value,
                                    start: 0.55,
                                    end: 1,
                                  ),
                                )
                                .clamp(0.0, 1.0),
                            child: Icon(
                              LucideIcons.sparkles,
                              size: 10,
                              color: AppColors.text.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          Text(
            'Your Health Circle.\nAlways Connected.',
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
            'Manage appointments, prescriptions, and family\ncare in one calm place — anytime you need support.',
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

class _OrbitFieldPainter extends CustomPainter {
  const _OrbitFieldPainter({
    required this.spin,
    required this.counterSpin,
    required this.seconds,
    required this.avatarAngles,
  });

  final double spin;
  final double counterSpin;
  final double seconds;
  final Map<int, ({double angle, Offset pos, int lane})> avatarAngles;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // Core energy disc
    canvas.drawCircle(
      c,
      118,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.18),
            AppColors.glowPurple.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: c, radius: 118)),
    );

    // Dual circular lanes
    _drawCircleLane(
      canvas,
      c,
      radius: 118,
      color: const Color(0xFF7C6BFF).withValues(alpha: 0.28),
      dashPhase: spin,
      dashed: true,
    );
    _drawCircleLane(
      canvas,
      c,
      radius: 148,
      color: AppColors.accent.withValues(alpha: 0.26),
      dashPhase: counterSpin,
      dashed: true,
      strokeWidth: 1.25,
    );

    // Soft solid guide ring
    _drawCircleLane(
      canvas,
      c,
      radius: 92,
      color: Colors.white.withValues(alpha: 0.08),
      dashPhase: 0,
      dashed: false,
      strokeWidth: 1,
    );

    // Expanding circular ripples
    for (var i = 0; i < 3; i++) {
      final t = ((spin / (math.pi * 2)) + i / 3) % 1.0;
      final radius = 70 + t * 100;
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = AppColors.accent.withValues(alpha: (1 - t) * 0.26),
      );
    }

    // Orbit tick marks / nodes on outer lane
    for (var i = 0; i < 18; i++) {
      final a = counterSpin + (i / 18) * math.pi * 2;
      final p = Offset(c.dx + math.cos(a) * 148, c.dy + math.sin(a) * 148);
      final pulse = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(seconds * 3 + i));
      canvas.drawCircle(
        p,
        i % 3 == 0 ? 2.2 : 1.3,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.2 + 0.35 * pulse),
      );
    }

    // Soft tether lines from center → avatars
    for (final entry in avatarAngles.entries) {
      final data = entry.value;
      final end = c + data.pos;
      final depth = _OrbitMotion.depth(data.angle);
      final alpha = 0.06 + 0.12 * ((depth + 1) * 0.5);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = data.lane == 1 ? 1.1 : 0.9
        ..shader = LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: alpha * 1.4),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(c, end));
      canvas.drawLine(c, end, paint);

      // Motion trail arc behind each avatar
      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = (data.lane == 0
                ? const Color(0xFF7C6BFF)
                : AppColors.accent)
            .withValues(alpha: 0.18 + 0.12 * ((depth + 1) * 0.5));

      final r = data.lane == 0 ? 118.0 : 148.0;
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawArc(rect, data.angle - 0.55, 0.5, false, trailPaint);
    }

    // Rotating accent wedge (scanner feel)
    final sweep = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          AppColors.accent.withValues(alpha: 0.0),
          AppColors.accent.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.62, 0.78, 1.0],
        transform: GradientRotation(spin * 0.85),
      ).createShader(Rect.fromCircle(center: c, radius: 160));
    canvas.drawCircle(c, 160, sweep);
  }

  void _drawCircleLane(
    Canvas canvas,
    Offset c, {
    required double radius,
    required Color color,
    required double dashPhase,
    required bool dashed,
    double strokeWidth = 1.15,
  }) {
    final rect = Rect.fromCircle(center: c, radius: radius);
    if (!dashed) {
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = color,
      );
      return;
    }

    const segments = 48;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    for (var i = 0; i < segments; i++) {
      if (i.isOdd) continue;
      final a0 = dashPhase + (i / segments) * math.pi * 2;
      final a1 = dashPhase + ((i + 0.7) / segments) * math.pi * 2;
      canvas.drawArc(rect, a0, a1 - a0, false, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _OrbitFieldPainter oldDelegate) =>
      oldDelegate.spin != spin ||
      oldDelegate.counterSpin != counterSpin ||
      oldDelegate.seconds != seconds;
}

class _OrbitAvatar extends StatelessWidget {
  const _OrbitAvatar({
    required this.url,
    required this.size,
    required this.phase,
    required this.accentIndex,
    this.glow = false,
  });

  final String url;
  final double size;
  final double phase;
  final int accentIndex;
  final bool glow;

  static const _lime = Color(0xFFC8FF3D);
  static const _ringAccents = [
    Color(0xFF4B7BFF),
    Color(0xFF7C6BFF),
    Color(0xFF5AD1E6),
    Color(0xFFC8FF3D),
    Color(0xFF8B9CFF),
    Color(0xFF4FD1C5),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = glow
        ? _lime
        : _ringAccents[accentIndex % _ringAccents.length];
    final breath = 0.92 + 0.08 * (0.5 + 0.5 * math.sin(phase * 1.4));
    final haloPulse = 0.55 + 0.45 * (0.5 + 0.5 * math.sin(phase * 1.1));
    final rim = size * 0.055;
    final outerPad = glow ? 5.0 : 3.5;

    return SizedBox(
      width: size + outerPad * 2 + 10,
      height: size + outerPad * 2 + 10,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Soft colored halo
          Transform.scale(
            scale: breath,
            child: Container(
              width: size + 18,
              height: size + 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: (glow ? 0.42 : 0.22) * haloPulse),
                    accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Animated dashed accent ring (glow avatar)
          if (glow)
            Transform.rotate(
              angle: phase * 0.35,
              child: CustomPaint(
                size: Size(size + 14, size + 14),
                painter: _AvatarOrbitRingPainter(
                  color: _lime.withValues(alpha: 0.7),
                  strokeWidth: 1.4,
                ),
              ),
            ),

          // Gradient border shell
          Container(
            width: size + outerPad * 2,
            height: size + outerPad * 2,
            padding: EdgeInsets.all(rim),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: glow
                    ? [
                        _lime,
                        const Color(0xFFE8FF9A),
                        Colors.white,
                        _lime,
                      ]
                    : [
                        accent.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                        accent.withValues(alpha: 0.55),
                        Colors.white.withValues(alpha: 0.7),
                        accent.withValues(alpha: 0.95),
                      ],
                transform: GradientRotation(phase * 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: glow ? 0.5 : 0.28),
                  blurRadius: glow ? 18 : 12,
                  spreadRadius: glow ? 1 : 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A0A0E),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 0.8,
                ),
              ),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      url,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: const Color(0xFF1C1C24),
                        child: Icon(
                          LucideIcons.user,
                          size: size * 0.38,
                          color: Colors.white24,
                        ),
                      ),
                    ),

                    // Soft vignette for depth
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.28),
                          ],
                          stops: const [0.55, 1],
                        ),
                      ),
                    ),

                    // Specular glass highlight
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.center,
                          colors: [
                            Colors.white.withValues(alpha: 0.38),
                            Colors.white.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.35, 0.7],
                        ),
                      ),
                    ),

                    // Bottom contact shadow inside circle
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: size * 0.28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Online / available status pip
          Positioned(
            right: glow ? 4 : 6,
            bottom: glow ? 6 : 8,
            child: Container(
              width: glow ? 12 : 10,
              height: glow ? 12 : 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glow ? _lime : const Color(0xFF3DDC97),
                border: Border.all(
                  color: const Color(0xFF0A0A0E),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (glow ? _lime : const Color(0xFF3DDC97))
                        .withValues(alpha: 0.65),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarOrbitRingPainter extends CustomPainter {
  const _AvatarOrbitRingPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 - strokeWidth;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    const gaps = 8;
    const sweep = (math.pi * 2) / gaps;
    for (var i = 0; i < gaps; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        i * sweep,
        sweep * 0.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarOrbitRingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

class _CenterPill extends StatelessWidget {
  const _CenterPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.caveat(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
          height: 1,
        ),
      ),
    );
  }
}
