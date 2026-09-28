import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/chef_hat.dart';
import '../../widgets/pop_text.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.entrance, required this.onAvatar});

  final Animation<double> entrance;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) {
    final e = entrance;
    final morning = inter(20.76, 400, color: Palette.inkSoft);
    final name = inter(30.3, 700, color: const Color(0xFF0A0919));
    final tag = inter(16.65, 400, color: const Color(0xFF7C7B7E));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 23 - bearing('G', morning),
          top: 87 - 100,
          child: Staged(
            animation: e,
            begin: 0,
            end: 0.32,
            offset: const Offset(-18, 0),
            child: Baseline(
              baseline: 100,
              baselineType: TextBaseline.alphabetic,
              child: Text('Good morning,', style: morning),
            ),
          ),
        ),
        Positioned(
          left: 22.67 - bearing('J', name),
          top: 122 - 100,
          child: Baseline(
            baseline: 100,
            baselineType: TextBaseline.alphabetic,
            child: PopText(text: 'John Doe', style: name, animation: e, begin: 0.06, end: 0.4, rise: 16, spin: 0.16),
          ),
        ),
        Positioned(
          left: 183.5 - 14,
          top: 109.4 - 14,
          child: AnimatedBuilder(
            animation: e,
            builder: (context, child) {
              final raw = ((e.value - 0.28) / 0.3).clamp(0.0, 1.0);
              final s = spring(raw, bounce: 0.6, freq: 2.6);
              return Opacity(
                opacity: (raw * 4).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: -1.4 * (1 - s),
                  child: Transform.scale(scale: s, child: child),
                ),
              );
            },
            child: Tick(
              builder: (context, s, child) {
                final u = (s % 5.5) / 5.5;
                final tip = u < 0.14 ? math.sin(u / 0.14 * math.pi * 3) * 0.2 * (1 - u / 0.14) : 0.0;
                return Transform.rotate(angle: tip, alignment: Alignment.bottomCenter, child: child);
              },
              child: const ChefHat(size: 28, color: Color(0xFFF0233A), stroke: 2.3),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          width: 260,
          height: 170,
          child: AnimatedBuilder(
            animation: e,
            builder: (context, child) {
              final t = span(e.value, 0.22, 0.52, Curves.easeOutCubic);
              return ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => LinearGradient(
                  colors: const [Colors.white, Colors.white, Color(0x00FFFFFF)],
                  stops: [0, t, math.min(1.0, t + 0.15)],
                ).createShader(rect),
                child: child,
              );
            },
            child: Stack(
              children: [Pin(x: 23, base: 150, text: 'Great food. Happy you!', style: tag)],
            ),
          ),
        ),
        Positioned(
          left: 290 - 14,
          top: 90.6 - 14,
          child: Staged(animation: e, begin: 0.18, end: 0.46, scale: 0.2, child: const _Bell()),
        ),
        Positioned(
          left: Art.homeAvatar.left,
          top: Art.homeAvatar.top,
          child: AnimatedBuilder(
            animation: e,
            builder: (context, child) {
              final raw = ((e.value - 0.14) / 0.36).clamp(0.0, 1.0);
              final s = spring(raw, bounce: 0.5, freq: 2.4);
              return Opacity(
                opacity: (raw * 4).clamp(0.0, 1.0),
                child: Transform.scale(scale: s, child: child),
              );
            },
            child: GestureDetector(
              onTap: onAvatar,
              child: Tick(
                builder: (context, s, child) {
                  final b = wave(s, 3.1);
                  return Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.diagonal3Values(1 + 0.012 * b, 1 - 0.012 * b, 1),
                    child: child,
                  );
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Palette.tomato.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Art.homeAvatar.image(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bell extends StatelessWidget {
  const _Bell();

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, s, _) {
        final u = ((s + 5.2) % 7) / 7;
        final ring = u < 0.2 ? math.sin(u / 0.2 * math.pi * 5) * 0.34 * (1 - u / 0.2) : 0.0;
        final dot = u < 0.2 ? 1 + 0.35 * math.sin(u / 0.2 * math.pi) : 1.0;
        final halo = (s % 2.4) / 2.4;
        return SizedBox.square(
          dimension: 28,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Transform.rotate(
                angle: ring,
                alignment: const Alignment(0, -0.78),
                child: const PhIcon(Ph.bell, size: 28, color: Color(0xFF151419)),
              ),
              Positioned(
                left: 22.2 - 4.4,
                top: 6 - 4.4,
                width: 8.8,
                height: 8.8,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    OverflowBox(
                      maxWidth: 30,
                      maxHeight: 30,
                      child: Container(
                        width: 8.8 + 10 * halo,
                        height: 8.8 + 10 * halo,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Palette.tomato.withValues(alpha: 0.25 * (1 - halo)),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: dot,
                      child: Container(
                        width: 8.8,
                        height: 8.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF5203A),
                          border: Border.all(color: const Color(0xFFFFD1D8), width: 1.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
