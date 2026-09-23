import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.radius = 26, this.padding = EdgeInsets.zero, this.shadow = 1});

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final double shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Hue.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: shadow <= 0 ? null : softShadow(shadow),
      ),
      child: child,
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.radius = 26, this.tint = 0.12});

  final Widget child;
  final double radius;
  final double tint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.white.withValues(alpha: tint),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}

class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.glyph,
    required this.tone,
    this.size = 44,
    this.iconSize = 20,
    this.background,
    this.radius = 15,
  });

  final Glyph glyph;
  final Color tone;
  final double size;
  final double iconSize;
  final Color? background;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? tone.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: GlyphIcon(glyph, size: iconSize, color: tone, stroke: 2),
      ),
    );
  }
}

class WarmButton extends StatelessWidget {
  const WarmButton({
    super.key,
    required this.label,
    this.trailing,
    this.onTap,
    this.height = 58,
    this.radius,
    this.style,
    this.glow = 1,
    this.gradient = warmGradient,
  });

  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double height;
  final double? radius;
  final TextStyle? style;
  final double glow;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final corner = radius ?? height / 2;
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(corner),
          gradient: gradient,
          boxShadow: lifted(Hue.rose, glow),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(label, style: style ?? sans(16.5, 700, color: Colors.white, height: 1)),
            if (trailing != null) Positioned(right: 22, child: trailing!),
          ],
        ),
      ),
    );
  }
}

class Sprig extends StatelessWidget {
  const Sprig({super.key, this.tone = Hue.rose, this.opacity = 1, this.size = 74});

  final Color tone;
  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: SprigPainter(tone, opacity: opacity)),
    );
  }
}

class SprigPainter extends CustomPainter {
  const SprigPainter(this.tone, {this.opacity = 1});

  final Color tone;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = tone.withValues(alpha: 0.5 * opacity);
    final leaf = Paint()..color = tone.withValues(alpha: 0.26 * opacity);

    final base = Offset(size.width * 0.86, size.height * 0.98);
    final tip = Offset(size.width * 0.3, size.height * 0.12);
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..cubicTo(
        base.dx - size.width * 0.18,
        base.dy - size.height * 0.34,
        tip.dx + size.width * 0.2,
        tip.dy + size.height * 0.36,
        tip.dx,
        tip.dy,
      );
    canvas.drawPath(path, stem);

    final metric = path.computeMetrics().first;
    for (var i = 1; i <= 5; i++) {
      final d = metric.length * (i / 6);
      final tangent = metric.getTangentForOffset(d)!;
      for (final side in [-1.0, 1.0]) {
        final angle = math.atan2(tangent.vector.dy, tangent.vector.dx) + side * 0.85;
        final length = size.width * (0.17 - i * 0.012);
        canvas.save();
        canvas.translate(tangent.position.dx, tangent.position.dy);
        canvas.rotate(angle);
        final petal = Path()
          ..moveTo(0, 0)
          ..cubicTo(length * 0.35, -length * 0.34, length * 0.82, -length * 0.26, length, 0)
          ..cubicTo(length * 0.82, length * 0.26, length * 0.35, length * 0.34, 0, 0)
          ..close();
        canvas.drawPath(petal, leaf);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(SprigPainter oldDelegate) => oldDelegate.tone != tone || oldDelegate.opacity != opacity;
}
