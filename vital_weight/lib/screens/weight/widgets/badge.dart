import 'package:flutter/material.dart';

class WeightBadge extends StatelessWidget {
  const WeightBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3CB46E).withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(72, 72), painter: _BadgePainter()),
          const Icon(
            Icons.monitor_weight_outlined,
            size: 30,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..isAntiAlias = true
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFBDF0CF),
            Color(0xFF8FE8B4),
            Color(0xFF6FE3A3),
            Color(0xFF49D584),
            Color(0xFF2FBF6D),
            Color(0xFF2AAD63),
            Color(0xFF3FC87A),
            Color(0xFF8FE8B4),
            Color(0xFFBDF0CF),
          ],
          stops: [0.0, 0.12, 0.25, 0.38, 0.5, 0.62, 0.75, 0.88, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
