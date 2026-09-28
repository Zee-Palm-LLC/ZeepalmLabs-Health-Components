import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';
import 'palette.dart';

Offset centerOf(BuildContext context, GlobalKey key) => rectOf(context, key).center;

Rect rectOf(BuildContext context, GlobalKey key) {
  final box = key.currentContext?.findRenderObject() as RenderBox?;
  final nav = Navigator.of(context).context.findRenderObject() as RenderBox?;
  if (box == null || nav == null || !box.hasSize) return Rect.zero;
  final topLeft = nav.globalToLocal(box.localToGlobal(Offset.zero));
  final bottomRight = nav.globalToLocal(box.localToGlobal(box.size.bottomRight(Offset.zero)));
  return Rect.fromPoints(topLeft, bottomRight);
}

class RevealRoute<T> extends PageRouteBuilder<T> {
  RevealRoute({required this.center, required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 900),
        reverseTransitionDuration: const Duration(milliseconds: 520),
        opaque: true,
        pageBuilder: (context, a, b) => builder(context),
      );

  final Offset center;

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
        final reverse = animation.status == AnimationStatus.reverse;
        final red = reverse
            ? Curves.easeInCubic.transform(animation.value)
            : glide.transform(span(animation.value, 0, 0.62, Curves.linear));
        final page = reverse ? red : glide.transform(span(animation.value, 0.22, 1, Curves.linear));
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _Circle(center, far * red),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [Palette.tomatoHi, Palette.tomato, Color(0xFFE0112B)], stops: [0.0, 0.6, 1.0]),
                ),
              ),
            ),
            ClipPath(
              clipper: _Circle(center, far * page),
              child: Transform.scale(scale: lerp(1.06, 1, page), child: inner),
            ),
          ],
        );
      },
      child: child,
    );
  }
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

class MorphRoute<T> extends PageRouteBuilder<T> {
  MorphRoute({required this.from, required this.radius, required WidgetBuilder builder, this.snapshot})
    : super(
        transitionDuration: const Duration(milliseconds: 760),
        reverseTransitionDuration: const Duration(milliseconds: 560),
        opaque: false,
        barrierColor: null,
        pageBuilder: (context, a, b) => builder(context),
      );

  final Rect from;
  final double radius;
  final Widget? snapshot;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        final size = MediaQuery.sizeOf(context);
        final reverse = animation.status == AnimationStatus.reverse;
        final t = reverse ? Curves.easeInOutCubic.transform(animation.value) : const Cubic(0.3, 0.0, 0.08, 1.0).transform(animation.value);
        final full = Offset.zero & size;
        final rect = Rect.lerp(from, full, t)!;
        final r = lerp(radius, 0, t);
        final veil = span(animation.value, 0, 0.5, Curves.easeOut);
        final fadeIn = span(animation.value, 0.12, 0.55, Curves.easeOut);
        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: Color.fromRGBO(24, 12, 16, 0.28 * veil))),
            ),
            Positioned.fromRect(
              rect: rect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(r),
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minWidth: size.width,
                  maxWidth: size.width,
                  minHeight: size.height,
                  maxHeight: size.height,
                  child: Transform.scale(
                    scale: rect.width / size.width,
                    alignment: Alignment.topCenter,
                    child: Stack(
                      children: [
                        inner!,
                        if (snapshot != null && fadeIn < 1)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Opacity(opacity: 1 - fadeIn, child: snapshot),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

class FadeThroughRoute<T> extends PageRouteBuilder<T> {
  FadeThroughRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (context, a, b) => builder(context),
      );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final t = CurvedAnimation(parent: animation, curve: gentle, reverseCurve: Curves.easeInCubic);
    return FadeTransition(
      opacity: t,
      child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(t), child: child),
    );
  }
}
