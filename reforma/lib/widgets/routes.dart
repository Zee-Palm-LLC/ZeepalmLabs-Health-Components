import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular reveal: the next screen grows out of the tapped control while the
/// current one sinks back and dims.
class RevealRoute<T> extends PageRouteBuilder<T> {
  RevealRoute({required WidgetBuilder builder, required this.origin})
      : super(
          transitionDuration: const Duration(milliseconds: 680),
          reverseTransitionDuration: const Duration(milliseconds: 520),
          pageBuilder: (context, a, b) => builder(context),
        );

  final Offset origin;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final reveal = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic, reverseCurve: Curves.easeInCubic);
    final back = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: Listenable.merge([reveal, back]),
      child: child,
      builder: (context, child) {
        Widget w = child!;
        if (back.value > 0) {
          final s = 1 - 0.06 * back.value;
          w = Transform.scale(scale: s, child: w);
        }
        if (reveal.value < 1) {
          w = ClipPath(clipper: _CircleClip(origin, reveal.value), child: w);
        }
        return w;
      },
    );
  }
}

class _CircleClip extends CustomClipper<Path> {
  _CircleClip(this.origin, this.t);

  final Offset origin;
  final double t;

  @override
  Path getClip(Size size) {
    final far = [Offset.zero, Offset(size.width, 0), Offset(0, size.height), Offset(size.width, size.height)]
        .map((c) => (c - origin).distance)
        .reduce(math.max);
    return Path()..addOval(Rect.fromCircle(center: origin, radius: 24 + (far - 24) * t));
  }

  @override
  bool shouldReclip(_CircleClip old) => old.t != t || old.origin != origin;
}

/// Pushes [builder] revealing from the centre of [from].
Future<T?> pushReveal<T>(BuildContext from, WidgetBuilder builder) {
  final nav = Navigator.of(from);
  final box = from.findRenderObject() as RenderBox?;
  final navBox = nav.context.findRenderObject() as RenderBox?;
  var origin = Offset.zero;
  if (box != null && navBox != null) {
    origin = navBox.globalToLocal(box.localToGlobal(box.size.center(Offset.zero)));
  }
  return nav.push(RevealRoute<T>(builder: builder, origin: origin));
}
