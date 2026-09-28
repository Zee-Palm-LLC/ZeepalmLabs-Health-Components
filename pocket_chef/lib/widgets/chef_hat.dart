import 'package:flutter/material.dart';

class ChefHat extends StatelessWidget {
  const ChefHat({
    super.key,
    this.size = 40,
    this.color = const Color(0xFFFB1630),
    this.stripe = const Color(0xFFFFB3BD),
    this.puff = 0,
    this.stroke = 0,
  });

  final double size;
  final Color color;
  final Color stripe;
  final double puff;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _HatPainter(color, stripe, puff, stroke));
  }
}

class _HatPainter extends CustomPainter {
  _HatPainter(this.color, this.stripe, this.puff, this.stroke);

  final Color color;
  final Color stripe;
  final double puff;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 40;
    canvas.save();
    canvas.scale(k);
    final p = 1 + puff;
    final crown = Path()
      ..addOval(Rect.fromCircle(center: const Offset(9.2, 15.6), radius: 8.6 * p))
      ..addOval(Rect.fromCircle(center: const Offset(20, 10.4), radius: 10.2 * p))
      ..addOval(Rect.fromCircle(center: const Offset(30.8, 15.6), radius: 8.6 * p))
      ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(6.6, 14, 33.4, 27), const Radius.circular(3)));
    final band = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTRB(7.4, 25.2, 32.6, 39.2),
          topLeft: const Radius.circular(1.5),
          topRight: const Radius.circular(1.5),
          bottomLeft: const Radius.circular(4.2),
          bottomRight: const Radius.circular(4.2),
        ),
      );
    final hat = Path.combine(PathOperation.union, crown, band);
    if (stroke > 0) {
      final w = stroke / k;
      final inset = Matrix4.identity()
        ..translateByDouble(20, 20, 0, 1)
        ..scaleByDouble(1 - w / 40, 1 - w / 40, 1, 1)
        ..translateByDouble(-20, -20, 0, 1);
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawPath(hat.transform(inset.storage), line);
      canvas.drawLine(Offset(8.4 + w / 2, 26.4), Offset(31.6 - w / 2, 26.4), line);
    } else {
      canvas.drawPath(hat, Paint()..color = color);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTRB(12.2, 31.4, 27.8, 33.8), const Radius.circular(1.2)),
        Paint()..color = stripe,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatPainter old) => old.color != color || old.stripe != stripe || old.puff != puff || old.stroke != stroke;
}
