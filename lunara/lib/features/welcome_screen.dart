import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../widgets/surface.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.enter, required this.pulse, required this.onBegin, required this.fade});

  static const features = [
    (Glyph.calendar, 'Smart predictions', "Know what's coming next", Hue.rose),
    (Glyph.heartPulse, 'Symptom tracking', 'Log what matters to you', Hue.mint),
    (Glyph.sparkles, 'Personalized insights', 'Learn patterns unique to you', Hue.amber),
  ];

  final Animation<double> enter;
  final Animation<double> pulse;
  final VoidCallback onBegin;
  final double fade;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: fade,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 26,
            top: 296,
            child: _Wordmark(enter: enter, pulse: pulse),
          ),
          Positioned(
            left: 28,
            top: 362,
            child: Staged(
              animation: enter,
              begin: 0.42,
              end: 0.9,
              offset: const Offset(0, 14),
              child: Text(
                'Embrace your rhythm',
                style: sans(14, 400, color: Colors.white.withValues(alpha: 0.7), height: 1, spacing: 0.2),
              ),
            ),
          ),
          for (final (i, feature) in features.indexed)
            Positioned(
              left: 22,
              top: 430.0 + i * 74,
              width: 349,
              height: 64,
              child: Staged(
                animation: enter,
                begin: 0.5 + i * 0.08,
                end: 1.0,
                offset: const Offset(28, 0),
                child: _Feature(
                  glyph: feature.$1,
                  title: feature.$2,
                  caption: feature.$3,
                  tone: feature.$4,
                  pulse: pulse,
                  index: i,
                ),
              ),
            ),
          Positioned(
            left: 22,
            top: 672,
            width: 349,
            child: Staged(
              animation: enter,
              begin: 0.72,
              end: 1.0,
              offset: const Offset(0, 26),
              scale: 0.96,
              child: AnimatedBuilder(
                animation: pulse,
                builder: (context, _) => Shimmer(
                  animation: pulse,
                  child: WarmButton(
                    label: 'Get started',
                    height: 56,
                    glow: 0.9 + 0.2 * math.sin(pulse.value * math.pi * 2),
                    onTap: onBegin,
                    style: sans(15.5, 600, color: Colors.white, height: 1),
                    trailing: Transform.translate(
                      offset: Offset(2.5 * math.sin(pulse.value * math.pi * 2), 0),
                      child: const GlyphIcon(Glyph.arrowRight, size: 19, color: Colors.white, stroke: 2.2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 748,
            child: Staged(
              animation: enter,
              begin: 0.84,
              end: 1.0,
              offset: const Offset(0, 12),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already have an account?',
                      style: sans(13, 500, color: Colors.white.withValues(alpha: 0.55), height: 1),
                    ),
                    const SizedBox(width: 7),
                    Pressable(
                      onTap: onBegin,
                      child: Text('Log in', style: sans(13, 700, color: Hue.amber, height: 1)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.enter, required this.pulse});

  final Animation<double> enter;
  final Animation<double> pulse;

  static const _letters = ['L', 'u', 'n', 'a', 'r', 'a'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([enter, pulse]),
      builder: (context, _) {
        final beat = pulse.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            for (final (i, letter) in _letters.indexed)
              Builder(
                builder: (context) {
                  final t = span(enter.value, 0.08 + i * 0.05, 0.58 + i * 0.05, gentle);
                  final shimmer = 0.82 + 0.18 * math.sin((beat * 2 + i * 0.12) * math.pi * 2);
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 28 * (1 - t)),
                      child: ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: 6 * (1 - t),
                          sigmaY: 6 * (1 - t),
                          tileMode: TileMode.decal,
                        ),
                        child: Text(
                          letter,
                          style: display(40, 600, color: Colors.white, height: 1).copyWith(
                            shadows: [
                              Shadow(color: Hue.moonlight.withValues(alpha: 0.45 * shimmer), blurRadius: 26),
                              Shadow(color: Hue.rose.withValues(alpha: 0.28 * shimmer), blurRadius: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.glyph,
    required this.title,
    required this.caption,
    required this.tone,
    required this.pulse,
    required this.index,
  });

  final Glyph glyph;
  final String title;
  final String caption;
  final Color tone;
  final Animation<double> pulse;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 22,
      tint: 0.09,
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, child) =>
                  Transform.scale(scale: 1 + 0.05 * math.sin((pulse.value + index * 0.22) * math.pi * 2), child: child),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: tone.withValues(alpha: 0.2),
                  border: Border.all(color: tone.withValues(alpha: 0.35)),
                ),
                child: Center(child: GlyphIcon(glyph, size: 20, color: tone, stroke: 2)),
              ),
            ),
          ),
          Positioned(
            left: 68,
            top: 15,
            child: Text(title, style: sans(14, 600, color: Colors.white, height: 1)),
          ),
          Positioned(
            left: 68,
            top: 36,
            child: Text(caption, style: sans(12, 400, color: Colors.white.withValues(alpha: 0.6), height: 1)),
          ),
        ],
      ),
    );
  }
}
