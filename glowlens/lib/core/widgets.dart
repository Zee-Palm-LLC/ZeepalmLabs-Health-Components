import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'glyphs.dart';
import 'motion.dart';
import 'shaders.dart';
import 'theme.dart';

class HoloTone {
  const HoloTone(this.a, this.b, this.c, {this.seed = 0});

  final Color a;
  final Color b;
  final Color c;
  final double seed;

  static const upload = HoloTone(Palette.peach, Palette.sky, Palette.cream, seed: 0.1);
  static const area = HoloTone(Palette.mint, Palette.surface, Palette.petal, seed: 0.4);
  static const score = HoloTone(Palette.sky, Color(0xFFFAD9F0), Color(0xFFF7C9E2), seed: 0.7);
  static const total = HoloTone(Palette.mint, Palette.lavender, Palette.peach, seed: 0.9);
}

class HoloSurface extends StatefulWidget {
  const HoloSurface({
    super.key,
    required this.child,
    this.tone = HoloTone.upload,
    this.radius = 22,
    this.dots = 0,
    this.border = true,
  });

  final Widget child;
  final HoloTone tone;
  final double radius;
  final double dots;
  final bool border;

  @override
  State<HoloSurface> createState() => _HoloSurfaceState();
}

class _HoloSurfaceState extends State<HoloSurface> with SingleTickerProviderStateMixin, ClockMixin {
  final ValueNotifier<Offset> _tilt = ValueNotifier(Offset.zero);
  Offset _target = Offset.zero;

  @override
  void initState() {
    super.initState();
    startClock();
    clock.addListener(_ease);
  }

  void _ease() {
    final next = Offset.lerp(_tilt.value, _target, 0.08)!;
    if ((next - _tilt.value).distanceSquared > 0.00001) _tilt.value = next;
  }

  @override
  void dispose() {
    clock.removeListener(_ease);
    _tilt.dispose();
    disposeClock();
    super.dispose();
  }

  void _aim(Offset local, Size size) {
    _target = Offset(local.dx / size.width * 2 - 1, local.dy / size.height * 2 - 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return MouseRegion(
          onHover: (e) => _aim(e.localPosition, size),
          onExit: (_) => _target = Offset.zero,
          child: Listener(
            onPointerMove: (e) => _aim(e.localPosition, size),
            onPointerUp: (_) => _target = Offset.zero,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                border: widget.border ? Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2) : null,
                boxShadow: const [BoxShadow(color: Color(0x0F7A4FA0), blurRadius: 24, offset: Offset(0, 10))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius),
                child: CustomPaint(
                  painter: HoloPainter(clock: clock, tilt: _tilt, tone: widget.tone, dots: widget.dots),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HoloPainter extends CustomPainter {
  HoloPainter({required this.clock, required this.tilt, required this.tone, this.dots = 0})
    : super(repaint: Listenable.merge([clock, tilt]));

  final ValueNotifier<double> clock;
  final ValueNotifier<Offset> tilt;
  final HoloTone tone;
  final double dots;
  ui.FragmentShader? _shader;

  @override
  void paint(Canvas canvas, Size size) {
    final program = Shaders.holo;
    final rect = Offset.zero & size;
    if (program == null) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tone.a, Colors.white, tone.b, tone.c],
          ).createShader(rect),
      );
      return;
    }
    final shader = _shader ??= program.fragmentShader();
    var i = 0;
    void f(double v) => shader.setFloat(i++, v);
    f(size.width);
    f(size.height);
    f(clock.value);
    f(tilt.value.dx);
    f(tilt.value.dy);
    f(dots);
    for (final c in [tone.a, tone.b, tone.c]) {
      f(c.r);
      f(c.g);
      f(c.b);
    }
    f(tone.seed);
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(HoloPainter oldDelegate) => oldDelegate.tone != tone || oldDelegate.dots != dots;
}

class Backdrop extends StatefulWidget {
  const Backdrop({super.key, this.child});

  final Widget? child;

  @override
  State<Backdrop> createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop> with SingleTickerProviderStateMixin, ClockMixin {
  @override
  void initState() {
    super.initState();
    startClock();
  }

  @override
  void dispose() {
    disposeClock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackdropPainter(clock), child: widget.child ?? const SizedBox.expand());
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.clock) : super(repaint: clock);

  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    final s = clock.value;
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          const [Palette.lilacTop, Palette.lilacMid, Palette.canvas, Palette.canvas],
          const [0, 0.22, 0.55, 1],
        ),
    );
    void blob(Offset c, double r, Color color) {
      canvas.drawCircle(c, r, Paint()..shader = ui.Gradient.radial(c, r, [color, color.withValues(alpha: 0)]));
    }

    blob(Offset(w * (0.1 + 0.05 * wave(s, 17)), h * (0.42 + 0.03 * wave(s, 13))), w * 0.7, const Color(0x66FBE3F1));
    blob(
      Offset(w * (0.95 + 0.04 * wave(s, 19, 0.3)), h * (0.1 + 0.02 * wave(s, 11))),
      w * 0.6,
      const Color(0x55E2D4FB),
    );
    blob(
      Offset(w * (0.7 + 0.06 * wave(s, 23, 0.6)), h * (0.78 + 0.03 * wave(s, 15))),
      w * 0.65,
      const Color(0x40F7E1EC),
    );
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) => false;
}

class GradientPill extends StatefulWidget {
  const GradientPill({
    super.key,
    required this.label,
    this.glyph,
    this.onTap,
    this.height = 56,
    this.fontSize = 15,
    this.progress,
    this.shimmer = true,
    this.textColor = const Color(0xF2FFFFFF),
    this.labelKey,
  });

  final String label;
  final Glyph? glyph;
  final VoidCallback? onTap;
  final double height;
  final double fontSize;
  final double? progress;
  final bool shimmer;
  final Color textColor;
  final Object? labelKey;

  @override
  State<GradientPill> createState() => _GradientPillState();
}

class _GradientPillState extends State<GradientPill> with SingleTickerProviderStateMixin, ClockMixin {
  @override
  void initState() {
    super.initState();
    startClock();
  }

  @override
  void dispose() {
    disposeClock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: widget.onTap,
      scale: 0.96,
      child: SizedBox(
        height: widget.height,
        child: CustomPaint(
          painter: _PillPainter(clock: clock, progress: widget.progress, shimmer: widget.shimmer),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: Row(
                key: ValueKey(widget.labelKey ?? '${widget.label}${widget.glyph}'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.glyph != null) ...[
                    GlyphIcon(widget.glyph!, size: widget.fontSize + 3, color: widget.textColor, stroke: 1.6),
                    const SizedBox(width: 8),
                  ],
                  Text(widget.label, style: inter(widget.fontSize, 500, color: widget.textColor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillPainter extends CustomPainter {
  _PillPainter({required this.clock, this.progress, this.shimmer = true}) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final double? progress;
  final bool shimmer;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final shape = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r));
    canvas.drawRRect(
      shape.shift(const Offset(0, 8)),
      Paint()
        ..color = const Color(0x40E583C0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    final s = clock.value;
    final drift = 0.08 * math.sin(s * 0.9);
    canvas.drawRRect(
      shape,
      Paint()
        ..shader = LinearGradient(
          colors: const [Palette.violet, Palette.rose, Palette.coral],
          stops: [0, 0.62 + drift, 1],
        ).createShader(Offset.zero & size),
    );
    canvas.save();
    canvas.clipRRect(shape);
    if (progress != null) {
      final p = progress!.clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTWH(size.width * p, 0, size.width * (1 - p), size.height),
        Paint()..color = const Color(0x55FFFFFF),
      );
      canvas.drawRect(
        Rect.fromLTWH(size.width * p - 1, 0, 2, size.height),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    if (shimmer) {
      final phase = (s / 3.6) % 1;
      if (phase < 0.4) {
        final x = lerp(-size.width * 0.3, size.width * 1.3, phase / 0.4);
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0x00FFFFFF), Color(0x40FFFFFF), Color(0x00FFFFFF)],
              transform: GradientRotation(0.4),
            ).createShader(Rect.fromLTWH(x - 50, 0, 100, size.height)),
        );
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, size.width - 2, size.height * 0.5), Radius.circular(r)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PillPainter oldDelegate) => oldDelegate.progress != progress;
}

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.glyph,
    this.onTap,
    this.size = 42,
    this.iconSize = 20,
    this.badge = 0,
    this.child,
  });

  final Glyph glyph;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final int badge;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.88,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x147A4FA0), blurRadius: 14, offset: Offset(0, 5))],
              ),
              alignment: Alignment.center,
              child: child ?? GlyphIcon(glyph, size: iconSize, stroke: 1.6),
            ),
            if (badge > 0)
              Positioned(
                top: -3,
                right: -3,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(badge),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, t, child) => Transform.scale(scale: t, child: child),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: Palette.brand,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text('$badge', style: inter(10, 700, color: Colors.white, spacing: 0)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style, this.gradient = Palette.brand});

  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(Offset.zero & bounds.size),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class FakeStatusBar extends StatelessWidget {
  const FakeStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Padding(
        padding: const EdgeInsets.only(left: 33, right: 26, top: 6),
        child: Row(
          children: [
            Text('9:41', style: inter(15, 600, spacing: -0.3)),
            const Spacer(),
            const SizedBox(width: 72, height: 13, child: CustomPaint(painter: _StatusIcons())),
          ],
        ),
      ),
    );
  }
}

class _StatusIcons extends CustomPainter {
  const _StatusIcons();

  @override
  void paint(Canvas canvas, Size size) {
    const ink = Palette.ink;
    final fill = Paint()..color = ink;
    for (var i = 0; i < 4; i++) {
      final h = 4.0 + i * 2.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(i * 4.6, size.height - h - 0.5, 3, h), const Radius.circular(1)),
        fill,
      );
    }
    final wifi = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const c = Offset(28.5, 12);
    canvas.drawCircle(c.translate(0, -1.6), 1.6, fill);
    for (final r in [6.6, 10.0]) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi * 0.77, math.pi * 0.54, false, wifi);
    }
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(41, 0, 26, 13), const Radius.circular(4));
    canvas.drawRRect(body, fill);
    final text = TextPainter(
      text: TextSpan(
        text: '99',
        style: inter(9, 700, color: Colors.white, spacing: -0.2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(54 - text.width / 2, 6.5 - text.height / 2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(68.2, 4.4, 1.8, 4.2), const Radius.circular(1)),
      Paint()..color = ink.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(_StatusIcons oldDelegate) => false;
}

class Toast {
  static void show(BuildContext context, String message, {Glyph glyph = Glyph.check}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastView(message: message, glyph: glyph, onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({required this.message, required this.glyph, required this.onDone});

  final String message;
  final Glyph glyph;
  final VoidCallback onDone;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 6;
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final ms = _c.value * 2400;
              final enter = Curves.elasticOut.transform((ms / 700).clamp(0.0, 1.0));
              final leave = Curves.easeInCubic.transform(((ms - 2000) / 400).clamp(0.0, 1.0));
              return Opacity(
                opacity: ((ms / 150).clamp(0.0, 1.0) * (1 - leave)).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, lerp(-36, 0, enter) - leave * 24),
                  child: Transform.scale(scale: lerp(0.7, 1, enter), child: child),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
              decoration: BoxDecoration(
                color: Palette.ink,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(gradient: Palette.brand, shape: BoxShape.circle),
                    child: Center(child: GlyphIcon(widget.glyph, size: 15, color: Colors.white, stroke: 2)),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.message, style: inter(13, 500, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassHeader extends StatelessWidget {
  const GlassHeader({super.key, required this.scroll, required this.child});

  final ScrollController scroll;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnimatedBuilder(
      animation: scroll,
      builder: (context, child) {
        final offset = scroll.hasClients ? scroll.offset : 0.0;
        final t = (offset / 48).clamp(0.0, 1.0);
        return ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18 * t + 0.01, sigmaY: 18 * t + 0.01),
            child: Container(
              padding: EdgeInsets.fromLTRB(21, top + 11, 21, 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Palette.lilacTop.withValues(alpha: 0.88 * t),
                    Colors.white.withValues(alpha: 0.62 * t),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.9 * t)),
                ),
                boxShadow: [BoxShadow(color: const Color(0x0F7A4FA0).withValues(alpha: 0.06 * t), blurRadius: 16)],
              ),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class WavingHand extends StatelessWidget {
  const WavingHand({super.key, required this.clock, this.size = 19});

  final ValueNotifier<double> clock;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: clock,
      builder: (context, s, child) {
        final cycle = s % 3.2;
        final angle = cycle < 1.1 ? math.sin(cycle / 1.1 * math.pi * 4) * 0.35 * (1 - cycle / 1.1) : 0.0;
        return Transform.rotate(angle: angle, alignment: const Alignment(0.4, 0.8), child: child);
      },
      child: Image.asset('assets/images/wave.png', width: size, height: size),
    );
  }
}
