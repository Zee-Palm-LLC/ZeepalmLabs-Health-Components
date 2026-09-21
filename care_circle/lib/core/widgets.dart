import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/store.dart';
import 'glyphs.dart';
import 'motion.dart';
import 'theme.dart';

class HaloAvatar extends StatelessWidget {
  const HaloAvatar({
    super.key,
    required this.photo,
    required this.size,
    this.halo = Hue.iris,
    this.glow = 1,
    this.ring = 3,
    this.badge,
  });

  final String photo;
  final double size;
  final Color halo;
  final double glow;
  final double ring;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (glow > 0)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: _GlowPainter(halo, glow)),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color.lerp(halo, Colors.white, 0.35)!,
                    halo,
                    Color.lerp(halo, Colors.white, 0.55)!,
                    Color.lerp(halo, Colors.white, 0.35)!,
                  ],
                  stops: const [0, 0.35, 0.7, 1],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(ring),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Padding(
                    padding: EdgeInsets.all(ring * 0.8),
                    child: ClipOval(
                      child: Image.asset(
                        photo,
                        fit: BoxFit.cover,
                        cacheWidth: (size * dpr).round(),
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (badge != null) Positioned(right: -size * 0.02, bottom: size * 0.02, child: badge!),
        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.color, this.strength);

  final Color color;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r * 1.02,
      Paint()
        ..color = color.withValues(alpha: 0.42 * strength)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.28),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) => oldDelegate.color != color || oldDelegate.strength != strength;
}

class MoodBadge extends StatelessWidget {
  const MoodBadge({super.key, required this.mood, this.size = 22});

  final Mood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (mood == Mood.nudge) return const SizedBox.shrink();
    final good = mood == Mood.good;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: good ? Hue.sage : Hue.honey,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: (good ? Hue.sage : Hue.honey).withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      alignment: Alignment.center,
      child: GlyphIcon(good ? Glyph.check : Glyph.alert, size: size * 0.6, color: Colors.white, stroke: 2.4),
    );
  }
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 22,
    this.color = Hue.card,
    this.border,
    this.shadow = 1,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final Color? border;
  final double shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? const Color(0xFFF1ECF4), width: 1),
        boxShadow: shadow > 0 ? softShadow(shadow) : null,
      ),
      child: child,
    );
  }
}

class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.glyph,
    required this.tone,
    this.size = 44,
    this.iconSize,
    this.soft,
  });

  final Glyph glyph;
  final Color tone;
  final double size;
  final double? iconSize;
  final Color? soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [Colors.white, soft ?? tone.withValues(alpha: 0.14)],
          stops: const [0, 1],
        ),
      ),
      alignment: Alignment.center,
      child: GlyphIcon(glyph, size: iconSize ?? size * 0.5, color: tone, stroke: 1.9),
    );
  }
}

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.trailing,
    this.height = 56,
    this.done = false,
    this.doneLabel,
  });

  final String label;
  final VoidCallback? onTap;
  final Glyph? leading;
  final Glyph? trailing;
  final double height;
  final bool done;
  final String? doneLabel;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late final AnimationController _shine;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.done;
    return Pressable(
      onTap: widget.onTap,
      scale: 0.96,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: done ? 1 : 0),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          final a = Color.lerp(const Color(0xFF9A7BFF), const Color(0xFF52C995), t)!;
          final b = Color.lerp(const Color(0xFF6B48EC), const Color(0xFF26A56D), t)!;
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              gradient: LinearGradient(colors: [a, b]),
              boxShadow: [
                BoxShadow(color: b.withValues(alpha: 0.32), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.height / 2),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _ShinePainter(_shine)),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0)],
                          stops: const [0, 0.55],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 360),
                      switchInCurve: Curves.easeOutBack,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(animation), child: child),
                      ),
                      child: Row(
                        key: ValueKey(done),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (done)
                            const GlyphIcon(Glyph.check, size: 20, color: Colors.white, stroke: 2.4)
                          else if (widget.leading != null)
                            GlyphIcon(widget.leading!, size: 20, color: Colors.white, stroke: 2),
                          if (done || widget.leading != null) const SizedBox(width: 10),
                          Text(
                            done ? (widget.doneLabel ?? widget.label) : widget.label,
                            style: jakarta(16.5, 700, color: Colors.white, spacing: -0.1),
                          ),
                          if (!done && widget.trailing != null) ...[
                            const SizedBox(width: 12),
                            _Nudging(child: GlyphIcon(widget.trailing!, size: 20, color: Colors.white, stroke: 2.2)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShinePainter extends CustomPainter {
  _ShinePainter(this.clock) : super(repaint: clock);

  final Animation<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    if (t > 0.4) return;
    final x = lerp(-0.4, 1.4, t / 0.4) * size.width;
    final rect = Rect.fromLTWH(x - 60, 0, 120, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.centerLeft,
          rect.centerRight,
          [const Color(0x00FFFFFF), const Color(0x38FFFFFF), const Color(0x00FFFFFF)],
          const [0, 0.5, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_ShinePainter oldDelegate) => false;
}

class _Nudging extends StatefulWidget {
  const _Nudging({required this.child});

  final Widget child;

  @override
  State<_Nudging> createState() => _NudgingState();
}

class _NudgingState extends State<_Nudging> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final push = math.sin(math.pi * span(_c.value, 0.55, 0.85));
        return Transform.translate(offset: Offset(push * 5, 0), child: child);
      },
    );
  }
}

class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.delay = 0,
    this.format,
    this.duration = const Duration(milliseconds: 1100),
  });

  final double value;
  final TextStyle style;
  final double delay;
  final String Function(double value)? format;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      builder: (context, t, _) {
        final eased = Curves.easeOutCubic.transform(span(t, delay, 1));
        final v = value * eased;
        return Text(format != null ? format!(v) : v.round().toString(), style: style);
      },
    );
  }
}

class SoftChip extends StatelessWidget {
  const SoftChip({super.key, required this.label, required this.tone, this.soft, this.glyph, this.dense = false});

  final String label;
  final Color tone;
  final Color? soft;
  final Glyph? glyph;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 9 : 12, vertical: dense ? 4 : 6),
      decoration: BoxDecoration(
        color: soft ?? tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (glyph != null) ...[
            GlyphIcon(glyph!, size: dense ? 13 : 15, color: tone, stroke: 2),
            SizedBox(width: dense ? 4 : 6),
          ],
          Text(label, style: jakarta(dense ? 11.5 : 12.5, 650, color: tone)),
        ],
      ),
    );
  }
}

class HeartBurst extends StatefulWidget {
  const HeartBurst({super.key, required this.trigger, required this.child, this.color = Hue.coral});

  final int trigger;
  final Widget child;
  final Color color;

  @override
  State<HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<HeartBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void didUpdateWidget(HeartBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        final pop = t == 0 || t == 1 ? 1.0 : 1 + math.sin(math.pi * span(t, 0, 0.5)) * 0.35;
        return CustomPaint(
          foregroundPainter: t > 0 && t < 1 ? _BurstPainter(t, widget.color) : null,
          child: Transform.scale(scale: pop, child: child),
        );
      },
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter(this.t, this.color);

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final ease = Curves.easeOutCubic.transform(t);
    final paint = Paint()..color = color.withValues(alpha: (1 - t).clamp(0.0, 1.0));
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + 0.3;
      final d = 8 + ease * 16;
      canvas.drawCircle(c + Offset(math.cos(a) * d, math.sin(a) * d), 2.2 * (1 - t) + 0.6, paint);
    }
    canvas.drawCircle(
      c,
      6 + ease * 14,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * (1 - t)
        ..color = color.withValues(alpha: 0.5 * (1 - t)),
    );
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.t != t;
}

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style, this.gradient = Hue.irisGradient});

  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(text, style: style),
    );
  }
}
