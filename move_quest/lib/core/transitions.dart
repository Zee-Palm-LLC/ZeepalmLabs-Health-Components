import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

Path hexagon(Offset c, double r, [double turn = 0]) {
  final p = Path();
  for (var i = 0; i < 6; i++) {
    final a = -math.pi / 2 + i * math.pi / 3 + turn;
    final pt = c + Offset(math.cos(a), math.sin(a)) * r;
    i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
  }
  return p..close();
}

class PortalRoute<T> extends PageRouteBuilder<T> {
  PortalRoute({required WidgetBuilder builder, required this.origin})
    : super(
        transitionDuration: const Duration(milliseconds: 980),
        reverseTransitionDuration: const Duration(milliseconds: 720),
        pageBuilder: (context, _, _) => builder(context),
      );

  final Offset origin;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, page) {
        final t = animation.value;
        final size = MediaQuery.sizeOf(context);
        final reach = math.sqrt(size.width * size.width + size.height * size.height) * 1.22;
        final open = span(t, 0.0, 1.0, const Cubic(0.62, 0.0, 0.2, 1.0));
        final radius = reach * open;
        final turn = (1 - open) * 0.9;
        final inner = Transform.scale(scale: lerp(1.18, 1.0, open), child: page);
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(clipper: _HexClip(origin, radius, turn), child: inner),
            IgnorePointer(
              child: CustomPaint(
                painter: _HexRim(origin, radius, turn, t >= 1 ? 0 : 1 - span(t, 0.7, 1.0, Curves.easeOut)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HexClip extends CustomClipper<Path> {
  _HexClip(this.c, this.r, this.turn);

  final Offset c;
  final double r;
  final double turn;

  @override
  Path getClip(Size size) => hexagon(c, math.max(r, 0.01), turn);

  @override
  bool shouldReclip(_HexClip old) => old.r != r || old.c != c || old.turn != turn;
}

class _HexRim extends CustomPainter {
  _HexRim(this.c, this.r, this.turn, this.alpha);

  final Offset c;
  final double r;
  final double turn;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    if (alpha <= 0 || r < 1) return;
    final path = hexagon(c, r, turn);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..color = const Color(0xFF6A4BFF).withValues(alpha: 0.55 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xFF4FD8FF).withValues(alpha: 0.9 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_HexRim old) => old.r != r || old.alpha != alpha || old.turn != turn;
}

class DescendRoute<T> extends PageRouteBuilder<T> {
  DescendRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 1100),
        reverseTransitionDuration: const Duration(milliseconds: 760),
        pageBuilder: (context, _, _) => builder(context),
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, page) {
        final t = animation.value;
        final land = span(t, 0.0, 1.0, const Cubic(0.2, 0.9, 0.3, 1.0));
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.0011)
          ..translateByDouble(0, (1 - land) * 140, 0, 1)
          ..rotateX((1 - land) * 1.05)
          ..scaleByDouble(lerp(0.72, 1, land), lerp(0.72, 1, land), 1, 1);
        return Opacity(
          opacity: span(t, 0.0, 0.35, Curves.easeOut),
          child: Transform(alignment: Alignment.bottomCenter, transform: m, child: page),
        );
      },
    );
  }
}

class ExpandRoute<T> extends PageRouteBuilder<T> {
  ExpandRoute({required WidgetBuilder builder, required this.from, this.radius = 22})
    : super(
        transitionDuration: const Duration(milliseconds: 820),
        reverseTransitionDuration: const Duration(milliseconds: 640),
        pageBuilder: (context, _, _) => builder(context),
      );

  final Rect from;
  final double radius;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, page) {
        final t = animation.value;
        final size = MediaQuery.sizeOf(context);
        final grow = span(t, 0.0, 1.0, const Cubic(0.3, 0.0, 0.1, 1.0));
        final full = Offset.zero & size;
        final rect = Rect.lerp(from, full, grow)!;
        final r = lerp(radius, 0, grow);
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fromRect(
              rect: rect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(r),
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  child: SizedBox.fromSize(
                    size: size,
                    child: Opacity(opacity: span(t, 0.05, 0.4, Curves.easeOut), child: page),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
