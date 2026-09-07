import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../theme/nutrx_colors.dart';
import '../../../theme/nutrx_text.dart';
import 'math_motion.dart';
import 'reveal.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 236,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Reveal(
              delay: revealDelay(0),
              child: const _StepCard(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Reveal(
                    delay: revealDelay(1),
                    offset: const Offset(18, 14),
                    child: const _MetricCard(
                      icon: LucideIcons.flame,
                      label: 'Calories',
                      value: '1,024',
                      unit: '  Cal',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Reveal(
                    delay: revealDelay(2),
                    offset: const Offset(18, 14),
                    child: const _MetricCard(
                      icon: LucideIcons.droplet,
                      label: 'Weight',
                      value: '65.0',
                      unit: ' /75kg',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  const _StepCard();

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard>
    with TickerProviderStateMixin {
  late final AnimationController _draw;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _draw = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _draw.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LabelRow(icon: LucideIcons.footprints, label: 'Step (km)'),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 128,
              height: 128,
              child: AnimatedBuilder(
                animation: Listenable.merge([_draw, _pulse]),
                builder: (context, _) {
                  final t = _draw.value;
                  final progress = (MathMotion.softBounce(t) * 0.65)
                      .clamp(0.0, 0.65);
                  final phase = _pulse.value * math.pi * 2;
                  final glow = 0.16 + 0.14 * (0.5 + 0.5 * math.sin(phase));
                  final tick = 0.012 * math.sin(phase * 1.5);

                  return Transform.scale(
                    scale: 1 + tick,
                    child: CustomPaint(
                      painter: _RingPainter(
                        progress: progress,
                        glowAlpha: glow,
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: MathMotion.breath(phase, lo: 0.96, hi: 1.04),
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: NutrxText.percent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Average',
                style: NutrxText.meta.copyWith(color: NutrxColors.textDim),
              ),
              Text(
                '1800',
                style: NutrxText.meta.copyWith(color: NutrxColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabelRow(icon: icon, label: label),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: NutrxText.metricSm),
                TextSpan(
                  text: unit,
                  style: NutrxText.cardLabel.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: NutrxColors.textMuted),
        const SizedBox(width: 6),
        Text(label, style: NutrxText.cardLabel),
      ],
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: NutrxColors.card,
  borderRadius: BorderRadius.circular(24),
);

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    this.glowAlpha = 0.22,
  });

  final double progress;
  final double glowAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = size.width * 0.11;
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final sweep = progress.clamp(0.0, 1.0) * math.pi * 2;

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = NutrxColors.ringTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = NutrxColors.yellow.withValues(alpha: glowAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 6 + glowAlpha * 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [NutrxColors.yellowSoft, NutrxColors.yellow],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    // Leading tip spark using polar math.
    if (sweep > 0.05) {
      final tip = start + sweep;
      final tipOffset = Offset(
        center.dx + radius * math.cos(tip),
        center.dy + radius * math.sin(tip),
      );
      canvas.drawCircle(
        tipOffset,
        stroke * 0.42,
        Paint()..color = NutrxColors.yellowSoft,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.glowAlpha != glowAlpha;
}
