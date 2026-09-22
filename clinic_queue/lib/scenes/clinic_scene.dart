import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../core/theme.dart';

class ClinicScene extends CustomPainter {
  const ClinicScene();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(0, h), const [Color(0xFFD1EEE5), Color(0xFFE4F5EF)]),
    );

    const sun = Offset(295.3, 32);
    canvas.drawCircle(
      sun,
      28,
      Paint()..shader = ui.Gradient.radial(sun, 28, const [Color(0x66FFD6AE), Color(0x00FFD6AE)], const [0.55, 1]),
    );
    canvas.drawCircle(sun, 17.5, Paint()..color = const Color(0xFFFFCB9A));

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(196, 23.6), width: 51, height: 16),
      Paint()..color = const Color(0x8CF4FBF8),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 119, w, h - 119),
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, 119), Offset(0, h), const [Color(0xFFBEE3D6), Color(0xFFB6DDD0)]),
    );
    canvas.drawOval(
      const Rect.fromLTRB(46, 112, 305, 136),
      Paint()
        ..color = const Color(0x2E4E9C88)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawCircle(const Offset(63.3, 92.5), 16, Paint()..color = const Color(0xFF8CCBB5));
    canvas.drawRRect(
      RRect.fromLTRBR(42.8, 105.7, 71, 121.2, const Radius.circular(8)),
      Paint()..color = const Color(0xFFF7FBFA),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(58, 107.5, 66, 119.5, const Radius.circular(3)),
      Paint()..color = const Color(0xFFE2EEEA),
    );

    canvas.drawRRect(
      RRect.fromLTRBR(268.5, 95.7, 276, 118.2, const Radius.circular(3.5)),
      Paint()..color = const Color(0xFF6AAFA6),
    );
    canvas.drawCircle(const Offset(272, 80), 18.9, Paint()..color = const Color(0xFF94D2BB));
    canvas.drawCircle(const Offset(268, 74), 12, Paint()..color = const Color(0xFFA6DBC7));

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        96,
        50,
        257,
        120.7,
        bottomLeft: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFEFF8F4),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(96, 40.7, 257.8, 56.5, const Radius.circular(8)),
      Paint()..color = const Color(0xFF0E766C),
    );

    final window = Paint()
      ..shader = ui.Gradient.linear(const Offset(0, 67), const Offset(0, 92), const [
        Color(0xFFA4DACC),
        Color(0xFFC0E6DC),
      ]);
    for (final x in [107.75, 150.25, 192.25]) {
      canvas.drawRRect(RRect.fromLTRBR(x, 67, x + 33.5, 92, const Radius.circular(7)), window);
    }

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        156.5,
        90.7,
        184,
        120.7,
        topLeft: const Radius.circular(13.75),
        topRight: const Radius.circular(13.75),
      ),
      Paint()..color = const Color(0xFF35BFAE),
    );

    _person(canvas, const Offset(125.75, 93.25), const Color(0xFFF5C7C9));
    _person(canvas, const Offset(219, 94.5), const Color(0xFFCDE9E2));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(239, 88.25), width: 19, height: 19),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFF9FCFB),
    );
    final plus = Paint()
      ..color = Hue.orange
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(233.3, 88.25), const Offset(244.7, 88.25), plus);
    canvas.drawLine(const Offset(239, 82.5), const Offset(239, 94), plus);
  }

  void _person(Canvas canvas, Offset head, Color body) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        head.dx - 9.9,
        head.dy + 7.5,
        head.dx + 9.9,
        head.dy + 27.5,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      Paint()..color = body,
    );
    canvas.drawCircle(head, 7.6, Paint()..color = const Color(0xFFF0B98F));
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(head.dx - 9, head.dy - 9, head.dx + 9, head.dy - 0.6));
    canvas.drawCircle(head, 7.8, Paint()..color = const Color(0xFF4A2E22));
    canvas.restore();
  }

  @override
  bool shouldRepaint(ClinicScene oldDelegate) => false;
}
