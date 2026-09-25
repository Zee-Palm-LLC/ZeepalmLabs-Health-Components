import 'package:flutter/material.dart';

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.radius = 16,
    this.fill = const [Color(0xFF0F1D3A), Color(0xFF091532)],
    this.edge = const [Color(0xFF26344F), Color(0xFF1A2440), Color(0xFF16203A)],
    this.width = 1.1,
  });

  final Widget child;
  final double radius;
  final List<Color> fill;
  final List<Color> edge;
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _Surface(radius: radius, fill: fill, edge: edge, width: width),
      child: child,
    );
  }
}

class _Surface extends CustomPainter {
  _Surface({required this.radius, required this.fill, required this.edge, required this.width});

  final double radius;
  final List<Color> fill;
  final List<Color> edge;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: fill).createShader(rect),
    );
    canvas.drawRRect(
      rr.deflate(width / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: edge).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_Surface old) => old.fill != fill || old.edge != edge || old.radius != radius;
}

class Tile extends StatelessWidget {
  const Tile({super.key, required this.width, required this.height, required this.fill, required this.edge, this.glow, this.radius = 14});

  final double width;
  final double height;
  final List<Color> fill;
  final Color edge;
  final Color? glow;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: fill),
        border: Border.all(color: edge, width: 1.1),
        boxShadow: glow == null ? null : [BoxShadow(color: glow!, blurRadius: 16)],
      ),
    );
  }
}
