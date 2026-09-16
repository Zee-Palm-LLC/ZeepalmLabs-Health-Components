import 'dart:math' as math;

import 'package:flutter/widgets.dart';

Path polygonPath(
  Size size, {
  required int sides,
  double cornerRadius = 6,
  double rotation = -math.pi / 2,
}) {
  final unit = <Offset>[
    for (var i = 0; i < sides; i++)
      Offset(
        math.cos(rotation + i * 2 * math.pi / sides),
        math.sin(rotation + i * 2 * math.pi / sides),
      ),
  ];

  var minX = double.infinity, maxX = -double.infinity;
  var minY = double.infinity, maxY = -double.infinity;
  for (final p in unit) {
    minX = math.min(minX, p.dx);
    maxX = math.max(maxX, p.dx);
    minY = math.min(minY, p.dy);
    maxY = math.max(maxY, p.dy);
  }
  final spanX = math.max(maxX - minX, 1e-6);
  final spanY = math.max(maxY - minY, 1e-6);

  final points = <Offset>[
    for (final p in unit)
      Offset(
        (p.dx - minX) / spanX * size.width,
        (p.dy - minY) / spanY * size.height,
      ),
  ];

  final path = Path();
  for (var i = 0; i < sides; i++) {
    final prev = points[(i - 1 + sides) % sides];
    final cur = points[i];
    final next = points[(i + 1) % sides];

    final toPrev = prev - cur;
    final toNext = next - cur;
    final lenPrev = toPrev.distance;
    final lenNext = toNext.distance;
    final r = math.min(
      cornerRadius,
      math.min(lenPrev, lenNext) / 2.2,
    );

    final a = cur + toPrev / lenPrev * r;
    final b = cur + toNext / lenNext * r;

    if (i == 0) {
      path.moveTo(a.dx, a.dy);
    } else {
      path.lineTo(a.dx, a.dy);
    }
    path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
  }
  path.close();
  return path;
}

class PolygonPane extends StatelessWidget {
  const PolygonPane({
    super.key,
    required this.size,
    required this.sides,
    required this.edge,
    this.fill,
    this.glow,
    this.glowStrength = 1,
    this.edgeWidth = 1.5,
    this.cornerRadius = 6,
    this.rotation = -math.pi / 2,
    this.child,
  });

  final Size size;
  final int sides;
  final Color edge;
  final Gradient? fill;
  final Color? glow;
  final double glowStrength;
  final double edgeWidth;
  final double cornerRadius;
  final double rotation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: CustomPaint(
        painter: _PolygonPainter(
          sides: sides,
          edge: edge,
          fill: fill,
          glow: glow,
          glowStrength: glowStrength,
          edgeWidth: edgeWidth,
          cornerRadius: cornerRadius,
          rotation: rotation,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _PolygonPainter extends CustomPainter {
  const _PolygonPainter({
    required this.sides,
    required this.edge,
    required this.fill,
    required this.glow,
    required this.glowStrength,
    required this.edgeWidth,
    required this.cornerRadius,
    required this.rotation,
  });

  final int sides;
  final Color edge;
  final Gradient? fill;
  final Color? glow;
  final double glowStrength;
  final double edgeWidth;
  final double cornerRadius;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final path = polygonPath(
      size,
      sides: sides,
      cornerRadius: cornerRadius,
      rotation: rotation,
    );
    final rect = Offset.zero & size;

    final g = glow;
    if (g != null && glowStrength > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = g.withValues(alpha: g.a * glowStrength.clamp(0.0, 1.0))
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            10 + 10 * glowStrength.clamp(0.0, 1.0),
          ),
      );
    }

    final f = fill;
    if (f != null) {
      canvas.drawPath(path, Paint()..shader = f.createShader(rect));
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = edgeWidth
        ..strokeJoin = StrokeJoin.round
        ..color = edge
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_PolygonPainter old) =>
      old.sides != sides ||
      old.edge != edge ||
      old.fill != fill ||
      old.glow != glow ||
      old.glowStrength != glowStrength ||
      old.edgeWidth != edgeWidth ||
      old.cornerRadius != cornerRadius ||
      old.rotation != rotation;
}
