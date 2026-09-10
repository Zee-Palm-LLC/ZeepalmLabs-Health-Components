import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LotusMark extends StatefulWidget {
  const LotusMark({
    super.key,
    required this.size,
    this.color = AppColors.gold,
    this.animate = true,
  });

  final double size;
  final Color color;
  final bool animate;

  @override
  State<LotusMark> createState() => _LotusMarkState();
}

class _LotusMarkState extends State<LotusMark> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _LotusPainter(color: widget.color, bloom: _controller.value),
        ),
      ),
    );
  }
}

class _LotusPainter extends CustomPainter {
  const _LotusPainter({required this.color, required this.bloom});
  final Color color;
  final double bloom;

  static const _petals = [
    (angle: 0.0, height: 1.00, width: 0.26, delay: 0.0),
    (angle: -1.337, height: 0.78, width: 0.24, delay: 0.18),
    (angle: 1.337, height: 0.78, width: 0.24, delay: 0.30),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final base = Offset(size.width / 2, size.height * 0.96);
    final span = size.height * 0.9;

    for (final petal in _petals) {
      final local = ((bloom - petal.delay) / (1 - petal.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final t = Curves.easeOutBack.transform(local);

      canvas
        ..save()
        ..translate(base.dx, base.dy)
        ..rotate(petal.angle * t)
        ..scale(1.0, t);

      final height = span * petal.height;
      final width = size.width * petal.width;
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(width, -height * 0.35, width * 0.5, -height * 0.9, 0, -height)
        ..cubicTo(-width * 0.5, -height * 0.9, -width, -height * 0.35, 0, 0)
        ..close();

      canvas
        ..drawPath(
          path,
          Paint()
            ..color = color.withValues(
              alpha: (petal.angle == 0 ? 1.0 : 0.85) * local.clamp(0.0, 1.0),
            ),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_LotusPainter oldDelegate) =>
      oldDelegate.bloom != bloom || oldDelegate.color != color;
}
