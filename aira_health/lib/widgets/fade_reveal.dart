import 'dart:ui';

import 'package:flutter/material.dart';

class FadeReveal extends StatefulWidget {
  const FadeReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<FadeReveal> createState() => _FadeRevealState();
}

class _FadeRevealState extends State<FadeReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    const curve = Cubic(0.16, 1, 0.3, 1);
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: curve,
      child: AnimatedScale(
        scale: _visible ? 1 : 0.96,
        duration: widget.duration,
        curve: curve,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: _visible ? 0 : 8),
          duration: widget.duration,
          curve: curve,
          builder: (context, blur, child) {
            if (blur < 0.35) return child!;
            return ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

class SoftFadeRoute<T> extends PageRouteBuilder<T> {
  SoftFadeRoute({required Widget page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.16, 1, 0.3, 1),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1).animate(fade),
              child: child,
            ),
          );
        },
      );
}
