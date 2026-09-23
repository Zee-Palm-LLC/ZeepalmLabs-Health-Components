import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../data/cycle.dart';
import '../widgets/surface.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key, required this.cycle, required this.enter, required this.pulse, required this.onLog});

  static const rows = [
    (Glyph.bell, 'Reminders', 'Period, ovulation and pills'),
    (Glyph.calendar, 'Cycle length', 'Currently 28 days'),
    (Glyph.heartPulse, 'Health data', 'Sync with Apple Health'),
    (Glyph.sparkles, 'Lunara Plus', 'Deeper insights every month'),
  ];

  final Cycle cycle;
  final Animation<double> enter;
  final Animation<double> pulse;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 25,
          top: 56,
          child: Staged(
            animation: enter,
            begin: 0,
            end: 0.45,
            offset: const Offset(-16, 0),
            child: Text('You', style: display(24, 600, color: Colors.white, height: 1)),
          ),
        ),
        Positioned(
          left: 26,
          top: 88,
          child: Staged(
            animation: enter,
            begin: 0.05,
            end: 0.5,
            child: Text('Your rhythm, your way', style: sans(12.5, 400, color: Colors.white70, height: 1)),
          ),
        ),
        Positioned(
          left: 20,
          top: 126,
          width: 353,
          height: 116,
          child: Staged(
            animation: enter,
            begin: 0.1,
            end: 0.6,
            offset: const Offset(0, 30),
            scale: 0.97,
            child: _Profile(cycle: cycle, pulse: pulse),
          ),
        ),
        for (final (i, row) in rows.indexed)
          Positioned(
            left: 20,
            top: 262.0 + i * 74,
            width: 353,
            height: 64,
            child: Staged(
              animation: enter,
              begin: 0.2 + i * 0.07,
              end: 0.72 + i * 0.07,
              offset: const Offset(0, 26),
              child: _Row(glyph: row.$1, title: row.$2, caption: row.$3, onTap: onLog),
            ),
          ),
        Positioned(
          left: 20,
          top: 566,
          width: 353,
          height: 92,
          child: Staged(
            animation: enter,
            begin: 0.5,
            end: 1.0,
            offset: const Offset(0, 26),
            child: _Streak(cycle: cycle, pulse: pulse),
          ),
        ),
      ],
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.cycle, required this.pulse});

  final Cycle cycle;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withValues(alpha: 0.10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 18,
            top: 20,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, child) =>
                  Transform.scale(scale: 1 + 0.02 * math.sin(pulse.value * math.pi * 2), child: child),
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Hue.rose, Hue.peach]),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
                  boxShadow: softShadow(0.8),
                ),
                child: Center(
                  child: Text('A', style: display(22, 600, color: Colors.white, height: 1)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 94,
            top: 26,
            child: Text('Ava Moreau', style: display(18, 600, color: Colors.white, height: 1)),
          ),
          Positioned(
            left: 94,
            top: 53,
            child: Text(
              'Cycle day ${cycle.day} · ${cycle.phase.name}',
              style: sans(12.5, 500, color: Colors.white.withValues(alpha: 0.72), height: 1),
            ),
          ),
          Positioned(
            left: 94,
            top: 74,
            child: Text(
              'Tracking since March 2023',
              style: sans(11.5, 400, color: Colors.white.withValues(alpha: 0.5), height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.glyph, required this.title, required this.caption, required this.onTap});

  final Glyph glyph;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Panel(
        radius: 22,
        child: Stack(
          children: [
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.7)),
                child: Center(child: GlyphIcon(glyph, size: 17, color: Hue.rose, stroke: 1.8)),
              ),
            ),
            Positioned(
              left: 62,
              top: 17,
              child: Text(title, style: sans(13.5, 600, color: Hue.ink, height: 1)),
            ),
            Positioned(
              left: 62,
              top: 36,
              child: Text(caption, style: sans(12, 500, color: Hue.inkSoft, height: 1)),
            ),
            const Positioned(
              right: 16,
              top: 25,
              child: GlyphIcon(Glyph.chevronRight, size: 14, color: Hue.inkMuted, stroke: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _Streak extends StatelessWidget {
  const _Streak({required this.cycle, required this.pulse});

  final Cycle cycle;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Panel(
      radius: 24,
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 14,
            child: Text('Logging streak', style: display(15, 600, color: Hue.ink, height: 1)),
          ),
          Positioned(
            left: 16,
            top: 40,
            child: Text('12 days in a row, keep going', style: sans(12, 500, color: Hue.inkSoft, height: 1)),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 62,
            height: 14,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, _) {
                final beat = pulse.value;
                return Row(
                  children: [
                    for (var i = 0; i < 12; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Transform.scale(
                            scaleY: 1 + 0.18 * math.sin((beat + i * 0.06) * math.pi * 2).clamp(0.0, 1.0),
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: LinearGradient(
                                  colors: [
                                    cycle.phaseOfDay(cycle.day - 11 + i).colour,
                                    cycle.phaseOfDay(cycle.day - 11 + i).tail,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
