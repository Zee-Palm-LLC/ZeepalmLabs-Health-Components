import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/style.dart';

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16), this.color = Tone.card, this.radius = 22});

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x0A101828), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge(this.accent, this.glyph, {super.key, this.size = 32});

  final Accent accent;
  final Glyph glyph;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: accent.gradient),
      alignment: Alignment.center,
      child: GlyphIcon(glyph, size: size / 2, color: Tone.card, weight: 18),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.background = Tone.track, this.color = Tone.ink, this.glyph});

  final String label;
  final Color background;
  final Color color;
  final Glyph? glyph;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (glyph != null) ...[GlyphIcon(glyph!, size: 12, color: color, weight: 20), const SizedBox(width: 4)],
          Text(label, style: Typo.chip.copyWith(color: color), maxLines: 1),
        ],
      ),
    );
  }
}

class CardHead extends StatelessWidget {
  const CardHead({super.key, required this.accent, required this.glyph, required this.title, this.trailing, this.color = Tone.ink});

  final Accent accent;
  final Glyph glyph;
  final String title;
  final Widget? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconBadge(accent, glyph),
        const SizedBox(width: 10),
        if (trailing == null)
          Expanded(child: Text(title, style: Typo.cardTitle.copyWith(color: color), maxLines: 1, overflow: TextOverflow.ellipsis))
        else ...[
          Text(title, style: Typo.cardTitle.copyWith(color: color), maxLines: 1),
          const SizedBox(width: 8),
          Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: trailing)),
        ],
      ],
    );
  }
}

class DashRule extends StatelessWidget {
  const DashRule({super.key, this.color = Tone.line, this.vertical = 0});

  final Color color;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: SizedBox(height: 1, width: double.infinity, child: CustomPaint(painter: DashPainter(color))),
    );
  }
}

class DashPainter extends CustomPainter {
  DashPainter(this.color, {this.dash = 4, this.gap = 4});

  final Color color;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    dashLine(canvas, Offset(0, size.height / 2), size.width, Paint()..color = color, dash: dash, gap: gap);
  }

  @override
  bool shouldRepaint(DashPainter old) => old.color != color;
}

void dashLine(Canvas canvas, Offset from, double length, Paint paint, {double dash = 4, double gap = 4}) {
  paint.strokeWidth = 1;
  for (var x = 0.0; x < length; x += dash + gap) {
    canvas.drawLine(from + Offset(x, 0), from + Offset((x + dash).clamp(0, length), 0), paint);
  }
}

class Dot extends StatelessWidget {
  const Dot(this.color, {super.key, this.size = 8, this.square = false});

  final Color color;
  final double size;
  final bool square;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: square ? BoxShape.rectangle : BoxShape.circle, borderRadius: square ? BorderRadius.circular(2) : null),
    );
  }
}

class LegendKey extends StatelessWidget {
  const LegendKey({super.key, required this.marker, required this.label, this.value});

  final Widget marker;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        marker,
        const SizedBox(width: 6),
        Flexible(
          child: Text.rich(
            TextSpan(text: label, children: [if (value != null) TextSpan(text: ' $value', style: Typo.legendValue)]),
            style: Typo.legend,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class HeloraMark extends StatelessWidget {
  const HeloraMark({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: size, child: CustomPaint(painter: _MarkPainter()));
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    canvas.drawCircle(Offset(9 * s, 12 * s), 6.5 * s, p..color = Tone.ink);
    canvas.drawCircle(Offset(15 * s, 12 * s), 6.5 * s, p..color = Tone.red);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => false;
}
