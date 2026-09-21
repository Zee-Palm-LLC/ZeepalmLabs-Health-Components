import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'glyphs.dart';
import 'motion.dart';
import 'theme.dart';

class MicDisc extends StatelessWidget {
  const MicDisc({super.key, required this.size, this.fill = 1, this.glyph = Glyph.mic, this.glyphSize, this.glow = 0});

  final double size;
  final double fill;
  final Glyph glyph;
  final double? glyphSize;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _DiscPainter(fill, glow),
        child: Center(
          child: GlyphIcon(glyph, size: glyphSize ?? size * 0.5, color: const Color(0xFFEDEDED), stroke: 1.9),
        ),
      ),
    );
  }
}

class _DiscPainter extends CustomPainter {
  const _DiscPainter(this.fill, this.glow);

  final double fill;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (fill <= 0.001) return;
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    if (glow > 0) {
      canvas.drawCircle(
        c,
        r * (1 + 0.08 * glow),
        Paint()
          ..color = Tone.flame.withValues(alpha: 0.45 * glow * fill)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.45),
      );
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          c + Offset(-r * 0.42, -r * 0.5),
          r * 1.9,
          [
            const Color(0xFFF9951A).withValues(alpha: fill),
            const Color(0xFFEE640C).withValues(alpha: fill),
            const Color(0xFFC92A00).withValues(alpha: fill),
          ],
          const [0.0, 0.45, 1.0],
        ),
    );
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          c + Offset(-r, -r),
          c + Offset(r, r),
          [
            const Color(0x00FFC08A),
            const Color(0x00FFC08A),
            const Color(0xB3FFC08A).withValues(alpha: 0.7 * fill),
          ],
          const [0.0, 0.55, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(_DiscPainter oldDelegate) => oldDelegate.fill != fill || oldDelegate.glow != glow;
}

class GlassCircle extends StatelessWidget {
  const GlassCircle({super.key, required this.child, this.size = 40, this.onTap, this.tint = 0.12});

  final Widget child;
  final double size;
  final VoidCallback? onTap;
  final double tint;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromRGBO(255, 255, 255, tint),
          border: Border.all(color: const Color(0x1FFFFFFF), width: 0.8),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class ClosePill extends StatelessWidget {
  const ClosePill({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.only(left: 14, right: 16),
        decoration: BoxDecoration(
          color: const Color(0x1CFFFFFF),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0x14FFFFFF), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GlyphIcon(Glyph.close, size: 16, color: Color(0xFFE9E3E0), stroke: 1.3),
            const SizedBox(width: 5),
            Text('Close chat', style: inter(13, 450, color: const Color(0xFFEDE6E3), height: 1.2)),
          ],
        ),
      ),
    );
  }
}

class ShimmerText extends StatefulWidget {
  const ShimmerText(this.text, {super.key, required this.style, this.active = true});

  final String text;
  final TextStyle style;
  final bool active;

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(ShimmerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_c.isAnimating) _c.repeat();
    if (!widget.active && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.style.color ?? Tone.ash;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value * 1.8 - 0.4;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return ui.Gradient.linear(
              Offset(bounds.width * (t - 0.35), 0),
              Offset(bounds.width * (t + 0.35), 0),
              [base, const Color(0xFFD9D2CF), base],
              const [0.0, 0.5, 1.0],
            );
          },
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}

class Dots extends StatefulWidget {
  const Dots({super.key, this.color = const Color(0xFFBDB6B3)});

  final Color color;

  @override
  State<Dots> createState() => _DotsState();
}

class _DotsState extends State<Dots> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(28, 8),
        painter: _DotsPainter(_c, widget.color),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.clock, this.color) : super(repaint: clock);

  final Animation<double> clock;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final phase = (clock.value - i * 0.16) % 1.0;
      final lift = math.sin(math.pi * span(phase, 0, 0.5)) ;
      canvas.drawCircle(
        Offset(4 + i * 10.0, size.height / 2 - lift * 2.6),
        2.6,
        Paint()..color = color.withValues(alpha: 0.35 + 0.65 * lift),
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) => false;
}
