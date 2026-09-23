import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';

enum SwapStyle { depth, reveal, dissolve }

class ScreenSwap extends StatelessWidget {
  const ScreenSwap({
    super.key,
    required this.t,
    required this.style,
    required this.origin,
    required this.incoming,
    this.outgoing,
    this.forward = true,
  });

  final double t;
  final SwapStyle style;
  final Offset origin;
  final Widget incoming;
  final Widget? outgoing;
  final bool forward;

  double get _t => outgoing == null ? 1.0 : t;

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final sign = forward ? 1.0 : -1.0;
    final out = switch (style) {
      SwapStyle.depth => gentle.transform(t),
      SwapStyle.dissolve => span(t, 0.0, 0.55, Curves.easeIn),
      SwapStyle.reveal => Curves.easeInOutCubic.transform(t),
    };
    final into = switch (style) {
      SwapStyle.depth => span(t, 0.12, 1.0, gentle),
      SwapStyle.dissolve => span(t, 0.18, 1.0, gentle),
      SwapStyle.reveal => span(t, 0.0, 0.35),
    };

    final outMatrix = Matrix4.identity()..setEntry(3, 2, 0.0009);
    final inMatrix = Matrix4.identity()..setEntry(3, 2, 0.0009);
    switch (style) {
      case SwapStyle.depth:
        outMatrix
          ..translateByDouble(0, -34 * out * sign, 0, 1)
          ..scaleByDouble(1 - 0.12 * out, 1 - 0.12 * out, 1, 1)
          ..rotateX(0.10 * out * sign);
        inMatrix
          ..translateByDouble(0, 54 * (1 - into) * sign, 0, 1)
          ..scaleByDouble(1 + 0.07 * (1 - into), 1 + 0.07 * (1 - into), 1, 1)
          ..rotateX(-0.12 * (1 - into) * sign);
      case SwapStyle.dissolve:
        outMatrix.scaleByDouble(1 - 0.05 * out, 1 - 0.05 * out, 1, 1);
        inMatrix.scaleByDouble(1 + 0.04 * (1 - into), 1 + 0.04 * (1 - into), 1, 1);
      case SwapStyle.reveal:
        outMatrix.scaleByDouble(1 - 0.06 * out, 1 - 0.06 * out, 1, 1);
        inMatrix.scaleByDouble(1 + 0.10 * (1 - out), 1 + 0.10 * (1 - out), 1, 1);
    }

    final outOpacity = switch (style) {
      SwapStyle.depth => 1 - out * 1.35,
      SwapStyle.dissolve => 1 - out,
      SwapStyle.reveal => 1 - 0.45 * out,
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: outOpacity.clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.center,
            transform: outMatrix,
            child: outgoing ?? const SizedBox.shrink(),
          ),
        ),
        ClipPath(
          clipper: _CircleReveal(origin, style == SwapStyle.reveal ? out : 1.0),
          child: Opacity(
            opacity: into.clamp(0.0, 1.0),
            child: Transform(alignment: Alignment.center, transform: inMatrix, child: incoming),
          ),
        ),
      ],
    );
  }
}

class _CircleReveal extends CustomClipper<Path> {
  const _CircleReveal(this.origin, this.t);

  final Offset origin;
  final double t;

  @override
  Path getClip(Size size) {
    if (t >= 1) return Path()..addRect(Rect.largest);
    final far = [
      (origin - Offset.zero).distance,
      (origin - Offset(size.width, 0)).distance,
      (origin - Offset(0, size.height)).distance,
      (origin - Offset(size.width, size.height)).distance,
    ].reduce(math.max);
    return Path()..addOval(Rect.fromCircle(center: origin, radius: far * t));
  }

  @override
  bool shouldReclip(_CircleReveal old) => old.t != t || old.origin != origin;
}
