import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  const TrianglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3BCF6E);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
