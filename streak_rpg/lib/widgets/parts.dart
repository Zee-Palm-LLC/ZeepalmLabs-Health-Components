import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import 'fx.dart';

/// Frosted panel used for every card in the mockup.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 18,
    this.blur = 14,
    this.fill = const [Color(0x99242A5E), Color(0x8C171B45)],
    this.line = Tone.glassLine,
    this.shadow = true,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double radius;
  final double blur;
  final List<Color> fill;
  final Color line;
  final bool shadow;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: shadow ? const [BoxShadow(color: Color(0x55050318), blurRadius: 18, offset: Offset(0, 8))] : null,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: fill),
              border: Border.all(color: line, width: 1),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: r,
                        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)], stops: [0, 0.5]),
                      ),
                    ),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The big yellow pill: breathing glow, a sheen pass and a nudging arrow.
class GoldButton extends StatelessWidget {
  const GoldButton({super.key, required this.label, required this.icon, required this.onTap, this.width = 270, this.height = 70, this.style});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double width;
  final double height;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(height / 2);
    return Pressable(
      onTap: onTap,
      scale: 0.94,
      child: Tick(
        builder: (context, s, _) {
          final breath = (wave(s, 2.4) + 1) / 2;
          return SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                boxShadow: [
                  BoxShadow(
                    color: Tone.gold.withValues(alpha: 0.28 + breath * 0.22),
                    blurRadius: 22 + breath * 14,
                    spreadRadius: breath * 2,
                  ),
                  const BoxShadow(color: Color(0x66391600), blurRadius: 10, offset: Offset(0, 6)),
                ],
              ),
              child: Sheen(
                period: 3.4,
                strength: 0.55,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: r,
                    gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFBDE4C), Tone.gold, Tone.goldDeep], stops: [0, 0.5, 1]),
                    border: Border.all(color: const Color(0x99FFF1A8), width: 1.2),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: height * 0.35,
                        right: height * 0.35,
                        top: 3,
                        height: height * 0.32,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(height),
                            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x80FFFDE8), Color(0x00FFFDE8)]),
                          ),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Line(label, style: style ?? Typo.button),
                            const SizedBox(width: 10),
                            Transform.translate(
                              offset: Offset(math.max(0, wave(s, 1.2)) * 4, 0),
                              child: PhIcon(icon, size: 22, color: Tone.buttonInk),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The violet pill used for Next and Complete Set.
class VioletButton extends StatelessWidget {
  const VioletButton({super.key, required this.child, required this.onTap, required this.width, required this.height, this.radius});

  final Widget child;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius ?? height / 2);
    return Pressable(
      onTap: onTap,
      scale: 0.95,
      child: Tick(
        builder: (context, s, _) {
          final breath = (wave(s, 2.8) + 1) / 2;
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: r,
              boxShadow: [
                BoxShadow(
                  color: Tone.violet.withValues(alpha: 0.35 + breath * 0.25),
                  blurRadius: 20 + breath * 10,
                ),
              ],
            ),
            child: Sheen(
              period: 4,
              delay: 1.2,
              strength: 0.35,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: r,
                  gradient: LinearGradient(begin: Alignment(-1 + wave(s, 5) * 0.4, -1), end: Alignment(1 + wave(s, 5) * 0.4, 1), colors: const [Color(0xFF9A63F4), Tone.violet, Color(0xFF6E38F2)]),
                  border: Border.all(color: const Color(0x66D7C4FF), width: 1),
                ),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Page dots: the active dot is white and the others dim; switching stretches.
class Dots extends StatelessWidget {
  const Dots({super.key, required this.index, this.count = 3, this.size = 10, this.gap = 12});

  final int index;
  final int count;
  final double size;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: gap),
          AnimatedContainer(
            duration: const Duration(milliseconds: 520),
            curve: settle,
            width: i == index ? size : size * 0.9,
            height: i == index ? size : size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == index ? Colors.white : const Color(0x80B4B0D6),
              boxShadow: i == index ? const [BoxShadow(color: Color(0x99FFFFFF), blurRadius: 8)] : null,
            ),
          ),
        ],
      ],
    );
  }
}

/// A rounded progress bar whose fill pours in, with a moving glint and a hot tip.
class LiquidBar extends StatelessWidget {
  const LiquidBar({
    super.key,
    required this.value,
    required this.width,
    this.height = 10,
    this.colors = const [Color(0xFFFFD54A), Color(0xFFFFA61C)],
    this.track = Tone.track,
    this.glow,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1400),
  });

  final double value;
  final double width;
  final double height;
  final List<Color> colors;
  final Color track;
  final Color? glow;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(height / 2);
    return Rolling(
      value: value.clamp(0, 1).toDouble(),
      delay: delay,
      duration: duration,
      curve: const Cubic(0.3, 1.2, 0.4, 1),
      builder: (context, v) {
        final w = (width * v.clamp(0.0, 1.0)).clamp(0.0, width);
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: track, borderRadius: r),
                ),
              ),
              if (w > 0.5)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: math.max(w, height),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: r,
                      boxShadow: [BoxShadow(color: (glow ?? colors.last).withValues(alpha: 0.55), blurRadius: 10)],
                    ),
                    child: ClipRRect(
                      borderRadius: r,
                      child: Tick(
                        builder: (context, s, _) {
                          final g = cycle(s, 2.2);
                          return DecoratedBox(
                            decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 1,
                                  height: height * 0.38,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.35), borderRadius: r),
                                  ),
                                ),
                                Positioned(
                                  left: lerp(-40, math.max(w, height) + 10, g),
                                  top: 0,
                                  bottom: 0,
                                  width: 30,
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0x00FFFFFF), Color(0x99FFFFFF), Color(0x00FFFFFF)])),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              if (w > 2 && v < 0.999)
                Positioned(
                  left: w - height * 0.9,
                  top: -height * 0.4,
                  width: height * 1.8,
                  height: height * 1.8,
                  child: Glow(color: Color.lerp(colors.last, Colors.white, 0.6)!, opacity: 0.9),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Integer count-up text.
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.style, this.from = 0, this.delay = Duration.zero, this.duration = const Duration(milliseconds: 1100), this.format});

  final int value;
  final int from;
  final TextStyle style;
  final Duration delay;
  final Duration duration;
  final String Function(int v)? format;

  @override
  Widget build(BuildContext context) {
    return Rolling(
      value: value.toDouble(),
      from: from.toDouble(),
      delay: delay,
      duration: duration,
      builder: (context, v) {
        final n = v.round();
        return Line(format?.call(n) ?? '$n', style: style);
      },
    );
  }
}

/// Tints a glyph with a vertical gradient.
class GradientIcon extends StatelessWidget {
  const GradientIcon(this.icon, {super.key, required this.size, required this.colors});

  final IconData icon;
  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(r),
      child: PhIcon(icon, size: size),
    );
  }
}

/// Round frosted icon button (back, settings, pause).
class RoundButton extends StatelessWidget {
  const RoundButton({super.key, required this.child, required this.onTap, this.size = 38});

  final Widget child;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.88,
      child: SizedBox.square(
        dimension: size,
        child: Glass(
          radius: size / 2,
          blur: 10,
          fill: const [Color(0x8C2C2A5C), Color(0x80191A44)],
          shadow: false,
          child: Center(child: child),
        ),
      ),
    );
  }
}
