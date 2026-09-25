import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

Offset centerOf(BuildContext context, GlobalKey key) {
  final box = key.currentContext?.findRenderObject() as RenderBox?;
  final nav = Navigator.of(context).context.findRenderObject() as RenderBox?;
  if (box == null || nav == null) return Offset.zero;
  return nav.globalToLocal(box.localToGlobal(box.size.center(Offset.zero)));
}

class RevealRoute<T> extends PageRouteBuilder<T> {
  RevealRoute({required this.center, required WidgetBuilder builder, this.tint = const [Color(0xFF6A3BFF), Color(0xFFFF5C8A)]})
      : super(
          transitionDuration: const Duration(milliseconds: 820),
          reverseTransitionDuration: const Duration(milliseconds: 560),
          opaque: true,
          pageBuilder: (context, a, b) => builder(context),
        );

  final Offset center;
  final List<Color> tint;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        final size = MediaQuery.sizeOf(context);
        final far = [
          Offset.zero,
          Offset(size.width, 0),
          Offset(0, size.height),
          Offset(size.width, size.height),
        ].map((p) => (p - center).distance).reduce(math.max);
        final t = animation.status == AnimationStatus.reverse
            ? Curves.easeInCubic.transform(animation.value)
            : glide.transform(animation.value);
        final r = far * t;
        final edge = (1 - t).clamp(0.0, 1.0);
        final bloom = 1 - span(animation.value, 0.28, 0.9, Curves.easeInOut);
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _Circle(center, r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  recede(secondaryAnimation, inner!),
                  if (bloom > 0)
                    IgnorePointer(
                      child: Opacity(
                        opacity: bloom,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(center.dx / size.width * 2 - 1, center.dy / size.height * 2 - 1),
                              radius: 1.4,
                              colors: [tint.last.withValues(alpha: 0.95), tint.first, const Color(0xFF0A0B24)],
                              stops: const [0.0, 0.35, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (t > 0 && t < 1)
              IgnorePointer(
                child: CustomPaint(painter: _Edge(center: center, radius: r, strength: edge, tint: tint)),
              ),
          ],
        );
      },
      child: child,
    );
  }
}

Widget recede(Animation<double> secondary, Widget child) {
  return AnimatedBuilder(
    animation: secondary,
    builder: (context, inner) {
      final k = Curves.easeOutCubic.transform(secondary.value);
      if (k == 0) return inner!;
      return Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(scale: 1 - 0.06 * k, child: inner),
          IgnorePointer(child: ColoredBox(color: Color.fromRGBO(0, 2, 10, 0.55 * k))),
        ],
      );
    },
    child: child,
  );
}

class _Circle extends CustomClipper<Path> {
  _Circle(this.center, this.radius);

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) => Path()..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(_Circle old) => old.radius != radius || old.center != center;
}

class _Edge extends CustomPainter {
  _Edge({required this.center, required this.radius, required this.strength, required this.tint});

  final Offset center;
  final double radius;
  final double strength;
  final List<Color> tint;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22 * strength + 2
      ..shader = SweepGradient(colors: [...tint, tint.first], transform: GradientRotation(radius / 120)).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * strength + 2);
    p.color = p.color.withValues(alpha: strength);
    canvas.saveLayer(Offset.zero & size, Paint()..color = Color.fromRGBO(255, 255, 255, strength));
    canvas.drawCircle(center, radius, p);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Edge old) => old.radius != radius || old.strength != strength;
}

class LiftRoute<T> extends PageRouteBuilder<T> {
  LiftRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 700),
          reverseTransitionDuration: const Duration(milliseconds: 480),
          pageBuilder: (context, a, b) => builder(context),
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        final t = animation.status == AnimationStatus.reverse
            ? Curves.easeInCubic.transform(animation.value)
            : gentle.transform(animation.value);
        return Opacity(
          opacity: span(animation.value, 0, 0.3, Curves.linear),
          child: Transform.translate(
            offset: Offset(0, 90 * (1 - t)),
            child: Transform.scale(scale: lerp(0.92, 1, t), child: recede(secondaryAnimation, inner!)),
          ),
        );
      },
      child: child,
    );
  }
}
