import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/palette.dart';

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    this.radius = 26,
    this.opacity = 0.56,
    this.tailAt,
    this.tailWidth = 20,
    this.tailDrop = 14,
    this.glow = 0.0,
    this.glowColor = Ember.gold,
    this.child,
  });

  final double radius;
  final double opacity;
  final double? tailAt;
  final double tailWidth;
  final double tailDrop;
  final double glow;
  final Color glowColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PanelPainter(radius, opacity, tailAt, tailWidth, tailDrop, glow, glowColor),
      child: child,
    );
  }
}

Path panelPath(Size size, double radius, double? tailAt, double tailWidth, double tailDrop) {
  final body = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
  if (tailAt == null) return body;
  final tail = Path()
    ..moveTo(tailAt, size.height - 10)
    ..lineTo(tailAt, size.height + tailDrop - 2)
    ..quadraticBezierTo(tailAt, size.height + tailDrop, tailAt + 1.6, size.height + tailDrop - 0.6)
    ..lineTo(tailAt + tailWidth, size.height - 10)
    ..close();
  return Path.combine(PathOperation.union, body, tail);
}

class _PanelPainter extends CustomPainter {
  _PanelPainter(
    this.radius,
    this.opacity,
    this.tailAt,
    this.tailWidth,
    this.tailDrop,
    this.glow,
    this.glowColor,
  );

  final double radius;
  final double opacity;
  final double? tailAt;
  final double tailWidth;
  final double tailDrop;
  final double glow;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = panelPath(size, radius, tailAt, tailWidth, tailDrop);
    final rect = Offset.zero & size;

    canvas.drawPath(
      path.shift(const Offset(0, 10)),
      Paint()
        ..color = const Color(0x4D000000)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 16),
    );

    canvas.drawPath(path, Paint()..color = const Color(0xFF0A0402).withValues(alpha: opacity));
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          const [Color(0x1AFFD4A0), Color(0x00FFD4A0)],
          const [0.0, 0.7],
        ),
    );

    if (glow > 0.002) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = glowColor.withValues(alpha: 0.55 * glow)
          ..maskFilter = ui.MaskFilter.blur(BlurStyle.outer, 7 * glow),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          const [Color(0x3DFFE2C4), Color(0x14FFE2C4), Color(0x0AFFE2C4)],
          const [0.0, 0.45, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(_PanelPainter old) =>
      old.radius != radius || old.opacity != opacity || old.tailAt != tailAt || old.glow != glow;
}

class Hairpill extends StatelessWidget {
  const Hairpill({
    super.key,
    required this.child,
    this.height = 32,
    this.padding = const EdgeInsets.symmetric(horizontal: 13),
    this.filled = 0.0,
    this.border = hairline,
  });

  final Widget child;
  final double height;
  final EdgeInsets padding;
  final double filled;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: Color.lerp(const Color(0x1F0A0402), const Color(0x66120703), filled),
        border: Border.all(color: border, width: 1),
      ),
      child: Center(widthFactor: 1, child: child),
    );
  }
}
