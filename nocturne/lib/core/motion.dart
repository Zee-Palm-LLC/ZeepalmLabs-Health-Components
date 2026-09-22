import 'package:flutter/material.dart';

abstract final class Ease {
  static const out = Cubic(0.22, 1, 0.36, 1);
  static const inOut = Cubic(0.65, 0, 0.35, 1);
  static const soft = Cubic(0.33, 0.9, 0.35, 1);
}

class Staged extends StatelessWidget {
  const Staged({
    super.key,
    required this.controller,
    required this.child,
    this.begin = 0,
    this.end = 1,
    this.slide = 0,
    this.scaleFrom = 1,
  });

  final Animation<double> controller;
  final Widget child;
  final double begin;
  final double end;
  final double slide;
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final raw = ((controller.value - begin) / (end - begin)).clamp(
          0.0,
          1.0,
        );
        final t = Ease.out.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, slide * (1 - t)),
            child: Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

Route<T> dreamRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 650),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: Duration(
      milliseconds: (duration.inMilliseconds * 0.85).round(),
    ),
    pageBuilder: (context, a, b) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final enter = CurvedAnimation(
        parent: animation,
        curve: Ease.out,
        reverseCurve: Curves.easeInCubic,
      );
      final leave = CurvedAnimation(parent: secondary, curve: Ease.inOut);
      return FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(leave),
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 0.97).animate(leave),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0, 0.7, curve: Curves.easeOut),
              reverseCurve: const Interval(0.2, 1, curve: Curves.easeIn),
            ),
            child: ScaleTransition(
              scale: Tween(begin: 1.04, end: 1.0).animate(enter),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

Route<T> riseRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 700),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 520),
    pageBuilder: (context, a, b) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final t = CurvedAnimation(
        parent: animation,
        curve: Ease.out,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.6, curve: Curves.easeOut),
        ),
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(t),
          child: child,
        ),
      );
    },
  );
}

RectTween arcTween(Rect? begin, Rect? end) =>
    MaterialRectArcTween(begin: begin, end: end);
