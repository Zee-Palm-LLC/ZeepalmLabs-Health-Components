import 'dart:math' as math;

import 'package:flutter/material.dart' hide Chip;

import '../theme.dart';
import 'orb.dart';
import 'sections.dart';
import 'session_card.dart';

/// Plays a 0→1 fill once, a beat after the card is built.
class _Grow extends StatelessWidget {
  const _Grow({required this.builder, this.delay = 0});

  final Widget Function(double t) builder;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 1400 + (delay * 1000).round()),
      curve: Interval(delay / (1.4 + delay), 1, curve: Curves.easeOutCubic),
      builder: (context, t, _) => builder(t),
    );
  }
}

/// Steps: a ring that fills around a glowing green orb.
class StepsCard extends StatelessWidget {
  const StepsCard({super.key});

  static const steps = 7842;
  static const goal = 10000;

  @override
  Widget build(BuildContext context) {
    return Surface(
      height: 170,
      child: Stack(
        children: [
          const Positioned(left: 14, top: 15, child: Chip(icon: Icons.directions_walk_rounded, label: 'Steps')),
          Positioned(
            left: 0,
            right: 0,
            top: 46,
            child: Center(
              child: _Grow(
                builder: (t) => SizedBox.square(
                  dimension: 64,
                  child: CustomPaint(
                    painter: _RingPainter(progress: t * steps / goal, colour: Mood.green.deep),
                    child: const Center(child: Orb(size: 38, mood: Mood.green, glow: 0.9)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 120,
            child: _Grow(
              builder: (t) => Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: _thousands((steps * t).round()), style: sans(24, spacing: -0.6, height: 1.1)),
                    TextSpan(text: ' / 10k', style: sans(11, color: Tone.faint)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _thousands(int n) {
  final s = n.toString();
  return s.length > 3 ? '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}' : s;
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.colour});

  final double progress;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(3);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..color = Tone.chip,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: [colour.withValues(alpha: 0.5), colour],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

/// Heart: a live pulse line that keeps drawing across the card.
class HeartCard extends StatefulWidget {
  const HeartCard({super.key});

  @override
  State<HeartCard> createState() => _HeartCardState();
}

class _HeartCardState extends State<HeartCard> with SingleTickerProviderStateMixin {
  late final AnimationController _beat = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Surface(
      height: 170,
      child: Stack(
        children: [
          const Positioned(left: 14, top: 15, child: Chip(icon: Icons.favorite_rounded, label: 'Heart')),
          Positioned(
            right: 14,
            top: 21,
            child: AnimatedBuilder(
              animation: _beat,
              builder: (context, _) {
                final p = (_beat.value * 2) % 1;
                final s = 1 + 0.35 * math.exp(-p * 9);
                return Transform.scale(
                  scale: s,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: Mood.rose.deep, shape: BoxShape.circle),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 52,
            height: 52,
            child: AnimatedBuilder(
              animation: _beat,
              builder: (context, _) => CustomPaint(painter: _PulsePainter(_beat.value, Mood.rose.deep)),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 120,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '58', style: sans(24, spacing: -0.6, height: 1.1)),
                  TextSpan(text: ' bpm rest', style: sans(11, color: Tone.faint)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  const _PulsePainter(this.t, this.colour);

  final double t;
  final Color colour;

  /// One heartbeat over [0, 1): flat, small P bump, sharp QRS, soft T wave.
  static double _beat(double x) {
    double g(double c, double w, double a) => a * math.exp(-math.pow((x - c) / w, 2));
    return g(0.18, 0.04, 0.12) + g(0.36, 0.012, -0.18) + g(0.4, 0.014, 1) + g(0.44, 0.014, -0.35) + g(0.66, 0.06, 0.24);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const beats = 2.0;
    final head = t * size.width;
    final path = Path();
    for (var x = 0.0; x <= size.width; x += 1) {
      final phase = (x / size.width * beats) % 1;
      final y = size.height * 0.62 - _beat(phase) * size.height * 0.56;
      x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    // The trace fades out just ahead of the drawing head, like a monitor.
    final shader = LinearGradient(
      colors: [colour.withValues(alpha: 0.25), colour, colour, colour.withValues(alpha: 0), colour.withValues(alpha: 0.25)],
      stops: [0, math.max(0, t - 0.02), t, math.min(1, t + 0.06), 1],
    ).createShader(Offset.zero & size);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round
        ..shader = shader,
    );
    final phase = (head / size.width * beats) % 1;
    final hy = size.height * 0.62 - _beat(phase) * size.height * 0.56;
    canvas.drawCircle(Offset(head, hy), 6, Paint()..color = colour.withValues(alpha: 0.18));
    canvas.drawCircle(Offset(head, hy), 2.6, Paint()..color = colour);
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.t != t;
}

/// Fuel: calories with macro bars and a row of water drops.
class FuelCard extends StatelessWidget {
  const FuelCard({super.key});

  static const _macros = [
    ('Protein', 112, 150, Mood.orange),
    ('Carbs', 168, 260, Mood.amber),
    ('Fat', 41, 70, Mood.lilac),
  ];

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
      child: _Grow(
        delay: 0.15,
        builder: (t) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Chip(icon: Icons.restaurant_rounded, label: 'Fuel'),
                const Spacer(),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: _thousands((1640 * t).round()), style: sans(20, spacing: -0.5)),
                      TextSpan(text: ' / 2,300 kcal', style: sans(11, color: Tone.faint)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final (name, got, goal, mood) in _macros) ...[
              Row(
                children: [
                  SizedBox(width: 56, child: Text(name, style: sans(11.5, color: const Color(0xFF6E6A66)))),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(color: Tone.chip, borderRadius: BorderRadius.circular(4)),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: got / goal * t,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(colors: [mood.light, mood.deep]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    child: Text('${(got * t).round()}g', textAlign: TextAlign.right, style: sans(11.5, weight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Water', style: sans(11.5, color: const Color(0xFF6E6A66))),
                const Spacer(),
                for (var i = 0; i < 8; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Icon(
                      Icons.water_drop_rounded,
                      size: 17,
                      color: Color.lerp(Tone.hair, Mood.sky.deep, ((t * 8) - i).clamp(0.0, 1.0) * (i < 6 ? 1 : 0))!,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Recovery: readiness score with sleep and HRV underneath.
class RecoveryCard extends StatelessWidget {
  const RecoveryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
      child: _Grow(
        delay: 0.3,
        builder: (t) => Row(
          children: [
            SizedBox.square(
              dimension: 74,
              child: CustomPaint(
                painter: _RingPainter(progress: 0.82 * t, colour: Mood.sky.deep),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(82 * t).round()}', style: sans(22, spacing: -0.6, height: 1)),
                      Text('ready', style: sans(9.5, color: Tone.faint)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Primed to train', style: sans(15.3, spacing: -0.2)),
                  const SizedBox(height: 3),
                  Text('Go hard on today’s push session.', style: sans(11.5, color: Tone.faint)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Stat(icon: Icons.bedtime_rounded, value: '7h 40m', label: 'sleep'),
                      const SizedBox(width: 18),
                      _Stat(icon: Icons.monitor_heart_rounded, value: '64 ms', label: 'HRV'),
                    ],
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

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Tone.night),
        const SizedBox(width: 4),
        Text(value, style: sans(12, weight: FontWeight.w500)),
        const SizedBox(width: 3),
        Text(label, style: sans(11, color: Tone.faint)),
      ],
    );
  }
}

/// Tomorrow's session, one row.
class UpNextCard extends StatelessWidget {
  const UpNextCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: [
          const Orb(size: 40, mood: Mood.amber, glow: 0.8),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leg day, squat focus', style: sans(14.6, spacing: -0.2)),
                const SizedBox(height: 2),
                Text('50 min  ·  Tomorrow 7:00 am', style: sans(12, color: Tone.faint)),
              ],
            ),
          ),
          const PlayButton(size: 30),
        ],
      ),
    );
  }
}
