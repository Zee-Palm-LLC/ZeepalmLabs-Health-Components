import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/type.dart';

class Emoji extends StatelessWidget {
  const Emoji(this.asset, {super.key, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) =>
      Image.asset(asset, width: size, height: size, fit: BoxFit.contain, filterQuality: FilterQuality.medium);
}

class ChevronDisc extends StatelessWidget {
  const ChevronDisc({super.key, required this.colors, required this.chevron, this.size = 27, this.glyph = 14, this.shadow});

  final List<Color> colors;
  final Color chevron;
  final double size;
  final double glyph;
  final Color? shadow;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, seconds, _) {
        final nudge = math.max(0.0, wave(seconds, 2.4, 0.3)) * 1.6;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
            boxShadow: shadow == null ? null : [BoxShadow(color: shadow!, blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Transform.translate(
            offset: Offset(0.6 + nudge, 0),
            child: PhIcon(Ph.caretRight, size: glyph, color: chevron),
          ),
        );
      },
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({super.key, required this.value, required this.progress, required this.style, this.format});

  final double value;
  final Animation<double> progress;
  final TextStyle style;
  final String Function(double v)? format;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(progress.value.clamp(0.0, 1.0));
        final v = value * t;
        final text = format != null ? format!(v) : grouped(v.round());
        return Text(text, style: style, softWrap: false);
      },
    );
  }
}

String grouped(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.size = 16.5, this.track = 0.004});

  final String text;
  final double size;
  final double track;

  @override
  Widget build(BuildContext context) => Cap(text, inter(size, 700, color: const Color(0xFF0B0B12), track: track));
}

class SeeAll extends StatelessWidget {
  const SeeAll({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = inter(14, 600, color: const Color(0xFF6A3FD8), track: -0.014);
    return Pressable(onTap: onTap ?? () {}, child: Cap('See all', style));
  }
}

class SoftShadowBox extends StatelessWidget {
  const SoftShadowBox({super.key, required this.color, required this.radius, this.child, this.shadow = const Color(0x14453A64)});

  final Color color;
  final double radius;
  final Widget? child;
  final Color shadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: shadow, blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }
}

class Shimmer extends StatelessWidget {
  const Shimmer({super.key, required this.child, this.period = 3.6, this.delay = 0, this.strength = 0.35});

  final Widget child;
  final double period;
  final double delay;
  final double strength;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, seconds, inner) {
        final p = ((seconds - delay) % period) / period;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            final x = -rect.width + p * rect.width * 3;
            return ui.Gradient.linear(
              Offset(x, 0),
              Offset(x + rect.width * 0.6, rect.height),
              [const Color(0x00FFFFFF), Color.fromRGBO(255, 255, 255, strength), const Color(0x00FFFFFF)],
              const [0, 0.5, 1],
            );
          },
          child: inner,
        );
      },
      child: child,
    );
  }
}

class Glow extends StatelessWidget {
  const Glow({super.key, required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class Flicker extends StatelessWidget {
  const Flicker({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, seconds, inner) {
        final a = wave(seconds, 0.47) * 0.5 + wave(seconds, 0.31, 0.3) * 0.5;
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..scaleByDouble(1 - 0.04 * a, 1 + 0.07 * a, 1, 1)
            ..rotateZ(0.04 * wave(seconds, 0.9)),
          child: inner,
        );
      },
      child: child,
    );
  }
}
