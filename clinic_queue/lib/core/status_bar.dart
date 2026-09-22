import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';

final darkChrome = ValueNotifier(false);

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkChrome,
      builder: (context, dark, _) => _bar(context, dark ? const Color(0xFFFFFFFF) : const Color(0xFF0F3B3A)),
    );
  }

  Widget _bar(BuildContext context, Color tint) {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: 59,
      child: Stack(
        children: [
          Positioned(
            left: 37,
            top: 19,
            child: Text('9:41', style: jakarta(16.5, 700, color: tint, spacing: -0.2, height: 1.35)),
          ),
          Positioned(
            left: width / 2 - 62,
            top: 12,
            child: Container(
              width: 124,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(18)),
              alignment: const Alignment(0.72, 0),
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Color(0xFF1C2238), Color(0xFF07080D)]),
                ),
              ),
            ),
          ),
          Positioned(
            right: 26,
            top: 24,
            child: SizedBox(width: 78, height: 13, child: CustomPaint(painter: _Icons(tint))),
          ),
        ],
      ),
    );
  }
}

class _Icons extends CustomPainter {
  const _Icons(this.tint);

  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = tint;
    for (var i = 0; i < 4; i++) {
      final h = 4.2 + i * 2.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(i * 5.0, size.height - h - 0.4, 3.2, h), const Radius.circular(1)),
        fill,
      );
    }
    final wifi = Paint()
      ..color = tint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;
    const c = Offset(34.8, 12.4);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx - 2.6, c.dy - 2.8)
        ..arcToPoint(Offset(c.dx + 2.6, c.dy - 2.8), radius: const Radius.circular(3.8))
        ..close(),
      fill,
    );
    for (final r in [7.2, 11.2]) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi * 0.75, math.pi * 0.5, false, wifi);
    }
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(50.5, 0.3, 25, 12.4), const Radius.circular(3.8));
    canvas.drawRRect(
      body,
      Paint()
        ..color = tint.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(52.5, 2.3, 21, 8.4), const Radius.circular(2.2)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(76.6, 4.4, 1.4, 4.2), const Radius.circular(1)),
      Paint()..color = tint.withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(_Icons oldDelegate) => oldDelegate.tint != tint;
}
