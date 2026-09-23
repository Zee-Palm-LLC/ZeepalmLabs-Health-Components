import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../data/cycle.dart';
import '../widgets/cycle_ring.dart';
import '../widgets/surface.dart';
import '../widgets/week_strip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.cycle,
    required this.enter,
    required this.pulse,
    required this.onLog,
    required this.onInsights,
    required this.onDay,
  });

  static const quick = [
    ('Flow', Glyph.droplet, Hue.rose),
    ('Mood', Glyph.smile, Hue.violet),
    ('Energy', Glyph.zap, Hue.amber),
    ('Symptoms', Glyph.heartPulse, Hue.mint),
  ];

  final Cycle cycle;
  final Animation<double> enter;
  final Animation<double> pulse;
  final void Function(String? focus) onLog;
  final VoidCallback onInsights;
  final ValueChanged<int> onDay;

  Widget _stage(double begin, Widget child, {Offset offset = const Offset(0, 24), double scale = 1}) {
    return Staged(animation: enter, begin: begin, end: begin + 0.45, offset: offset, scale: scale, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 22,
          top: 58,
          child: _stage(0, _Avatar(pulse: pulse), offset: const Offset(-16, 0)),
        ),
        Positioned(
          left: 76,
          top: 60,
          child: _stage(
            0.03,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning', style: sans(12.5, 500, color: Colors.white.withValues(alpha: 0.62), height: 1)),
                const SizedBox(height: 6),
                Text('Ava', style: display(20, 600, color: Colors.white, height: 1)),
              ],
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: 58,
          child: _stage(
            0,
            _Bell(pulse: pulse, onTap: onInsights),
            offset: const Offset(16, 0),
          ),
        ),
        Positioned(
          left: 196.5 - 175,
          top: 302 - 175,
          width: 350,
          height: 350,
          child: CycleRing(cycle: cycle, enter: enter, pulse: pulse),
        ),
        _Centre(cycle: cycle, enter: enter, pulse: pulse, onTap: () => onLog(null)),
        Positioned(
          left: 20,
          top: 452,
          child: _stage(
            0.4,
            WeekStrip(cycle: cycle, onDay: onDay),
            offset: const Offset(0, 30),
          ),
        ),
        Positioned(
          left: 24,
          top: 550,
          child: _stage(0.5, Text('Quick log', style: display(15.5, 600, color: Hue.ink, height: 1))),
        ),
        Positioned(
          right: 24,
          top: 552,
          child: _stage(
            0.5,
            Pressable(
              onTap: () => onLog(null),
              child: Row(
                children: [
                  Text('All', style: sans(12.5, 600, color: Hue.rose, height: 1)),
                  const SizedBox(width: 3),
                  const GlyphIcon(Glyph.chevronRight, size: 13, color: Hue.rose, stroke: 2.4),
                ],
              ),
            ),
          ),
        ),
        for (final (i, item) in quick.indexed)
          Positioned(
            left: 20 + i * 89.5,
            top: 582,
            width: 82,
            height: 88,
            child: Staged(
              animation: enter,
              begin: 0.54 + i * 0.05,
              end: 1.0 + i * 0.05,
              offset: const Offset(0, 26),
              scale: 0.84,
              curve: const Spring(bounce: 0.3),
              child: _Quick(
                label: item.$1,
                glyph: item.$2,
                tone: item.$3,
                pulse: pulse,
                index: i,
                onTap: () => onLog(item.$1),
              ),
            ),
          ),
        Positioned(
          left: 20,
          top: 680,
          width: 353,
          height: 88,
          child: _stage(0.72, _Insight(cycle: cycle, pulse: pulse, onTap: onInsights)),
        ),
      ],
    );
  }
}

class _Centre extends StatelessWidget {
  const _Centre({required this.cycle, required this.enter, required this.pulse, required this.onTap});

  final Cycle cycle;
  final Animation<double> enter;
  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([enter, cycle]),
      builder: (context, _) {
        final t = enter.value;
        final reveal = span(t, 0.28, 0.74, gentle);
        if (reveal <= 0.01) return const SizedBox.shrink();
        final count = span(t, 0.28, 0.86, Curves.easeOutCubic);
        final shown = math.max(1, (cycle.day * count).round());
        final phase = cycle.phase;
        return Positioned(
          left: 96,
          top: 224,
          width: 201,
          height: 176,
          child: Opacity(
            opacity: reveal,
            child: Column(
              children: [
                Text(
                  'CYCLE DAY',
                  style: sans(10, 600, color: Colors.white.withValues(alpha: 0.5), height: 1, spacing: 1.4),
                ),
                const SizedBox(height: 12),
                Transform.scale(
                  scale: lerp(0.84, 1, span(t, 0.28, 0.9, const Spring(bounce: 0.24))),
                  child: Text('$shown', style: display(54, 600, color: Colors.white, height: 0.95, spacing: -1)),
                ),
                const SizedBox(height: 14),
                Opacity(
                  opacity: span(t, 0.48, 0.9),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(13, 7, 13, 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(colors: [phase.colour, phase.tail]),
                      boxShadow: lifted(phase.colour, 0.7),
                    ),
                    child: Text(phase.name, style: sans(12.5, 700, color: Colors.white, height: 1)),
                  ),
                ),
                const SizedBox(height: 12),
                Opacity(
                  opacity: span(t, 0.56, 0.95),
                  child: Text(
                    '${cycle.untilPeriod} days to next period',
                    style: sans(12, 500, color: Colors.white.withValues(alpha: 0.62), height: 1),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) => Transform.scale(scale: 1 + 0.02 * math.sin(pulse.value * math.pi * 2), child: child),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Hue.rose, Hue.peach]),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
          boxShadow: lifted(Hue.rose, 0.6),
        ),
        child: Center(
          child: Text('A', style: display(17, 600, color: Colors.white, height: 1)),
        ),
      ),
    );
  }
}

class _Bell extends StatelessWidget {
  const _Bell({required this.pulse, required this.onTap});

  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GlassPanel(
                radius: 15,
                child: Center(
                  child: AnimatedBuilder(
                    animation: pulse,
                    builder: (context, child) {
                      final phase = (pulse.value * 2) % 1.0;
                      final swing = math.sin(phase * math.pi * 7) * math.exp(-phase * 6) * 0.2;
                      return Transform.rotate(alignment: Alignment.topCenter, angle: swing, child: child);
                    },
                    child: const GlyphIcon(Glyph.bell, size: 20, color: Colors.white, stroke: 1.9),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Hue.rose,
                  shape: BoxShape.circle,
                  border: Border.all(color: Hue.deep, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text('2', style: sans(9, 700, color: Colors.white, height: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick({
    required this.label,
    required this.glyph,
    required this.tone,
    required this.pulse,
    required this.index,
    required this.onTap,
  });

  final String label;
  final Glyph glyph;
  final Color tone;
  final Animation<double> pulse;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Panel(
        radius: 24,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 14,
              child: Center(
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (context, child) {
                    final bob = math.sin((pulse.value + index * 0.18) * math.pi * 2) * 1.6;
                    return Transform.translate(offset: Offset(0, bob), child: child);
                  },
                  child: IconTile(glyph: glyph, tone: tone, size: 42, iconSize: 20, radius: 14),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 62,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: sans(12, 600, color: Hue.ink, height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  const _Insight({required this.cycle, required this.pulse, required this.onTap});

  final Cycle cycle;
  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B2356), Color(0xFF53316F)],
          ),
          boxShadow: softShadow(1.1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(right: -10, bottom: -14, child: Sprig(tone: Hue.peach, opacity: 0.55, size: 92)),
            Positioned(
              left: 16,
              top: 16,
              child: AnimatedBuilder(
                animation: pulse,
                builder: (context, child) =>
                    Transform.scale(scale: 0.85 + 0.18 * math.sin(pulse.value * math.pi * 2).abs(), child: child),
                child: const GlyphIcon(Glyph.sparkles, size: 18, color: Hue.amber, stroke: 1.9),
              ),
            ),
            Positioned(
              left: 42,
              top: 15,
              child: Text("Today's insight", style: display(14.5, 600, color: Colors.white, height: 1)),
            ),
            const Positioned(
              right: 14,
              top: 20,
              child: GlyphIcon(Glyph.chevronRight, size: 14, color: Colors.white54, stroke: 2.2),
            ),
            Positioned(
              left: 16,
              right: 60,
              top: 44,
              child: Text(
                cycle.phase.note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: sans(12, 500, color: Colors.white.withValues(alpha: 0.72), height: 1.38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
