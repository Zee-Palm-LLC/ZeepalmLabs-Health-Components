import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../core/palette.dart';

class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.from,
    required this.to,
    required this.progress,
    required this.center,
    this.opacity = 1,
  });

  final int count;
  final int from;
  final int to;
  final double progress;
  final Offset center;
  final double opacity;

  static const gap = 20.4;
  static const radius = 4.5;

  @override
  Widget build(BuildContext context) {
    final width = gap * (count - 1) + radius * 2 + 8;
    return Positioned(
      left: center.dx - width / 2,
      top: center.dy - 8,
      width: width,
      height: 16,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: CustomPaint(painter: _DotsPainter(count: count, from: from, to: to, progress: progress)),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.count, required this.from, required this.to, required this.progress});

  final int count;
  final int from;
  final int to;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final x0 = size.width / 2 - PageDots.gap * (count - 1) / 2;
    double at(int i) => x0 + PageDots.gap * i;
    final idle = Paint()..color = Palette.haze;
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(Offset(at(i), cy), PageDots.radius, idle);
    }
    final p = progress.clamp(0.0, 1.0);
    final head = lerp(at(from), at(to), Curves.easeOutCubic.transform(span(p, 0.0, 0.6, Curves.linear)));
    final tail = lerp(at(from), at(to), Curves.easeInOutCubic.transform(span(p, 0.2, 1.0, Curves.linear)));
    final left = (head < tail ? head : tail) - PageDots.radius;
    final right = (head < tail ? tail : head) + PageDots.radius;
    final squeeze = 1 - 0.18 * (1 - (2 * p - 1).abs()) * (from == to ? 0 : 1);
    final r = PageDots.radius * squeeze;
    canvas.drawRRect(
      RRect.fromLTRBR(left, cy - r, right, cy + r, Radius.circular(r)),
      Paint()..color = Palette.lagoon,
    );
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.progress != progress || old.from != from || old.to != to;
}
