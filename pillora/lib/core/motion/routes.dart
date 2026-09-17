import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class RevealRoute<T> extends PageRouteBuilder<T> {
  RevealRoute({
    required WidgetBuilder builder,
    required this.origin,
    Duration duration = const Duration(milliseconds: 1050),
  }) : super(
         transitionDuration: duration,
         reverseTransitionDuration: const Duration(milliseconds: 800),
         pageBuilder: (context, animation, secondary) => builder(context),
         transitionsBuilder: (context, animation, secondary, child) {
           final eased = CurvedAnimation(
             parent: animation,
             curve: const Cubic(0.7, 0, 0.2, 1),
             reverseCurve: const Cubic(0.7, 0, 0.2, 1).flipped,
           );
           return AnimatedBuilder(
             animation: eased,
             child: child,
             builder: (context, child) {
               if (eased.value >= 1) return child!;
               final settle = 1.06 - 0.06 * eased.value;
               return ClipPath(
                 clipper: _CircleClipper(origin, eased.value),
                 child: Transform.scale(scale: settle, child: child),
               );
             },
           );
         },
       );

  final Offset origin;
}

class _CircleClipper extends CustomClipper<Path> {
  _CircleClipper(this.origin, this.progress);

  final Offset origin;
  final double progress;

  @override
  Path getClip(Size size) {
    final corners = [Offset.zero, Offset(size.width, 0), Offset(0, size.height), Offset(size.width, size.height)];
    final reach = corners.map((c) => (c - origin).distance).reduce(math.max);
    return Path()..addOval(Rect.fromCircle(center: origin, radius: reach * progress + 1));
  }

  @override
  bool shouldReclip(_CircleClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.origin != origin;
  }
}

class StageRoute<T> extends PageRouteBuilder<T> {
  StageRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 900),
        reverseTransitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (context, animation, secondary) => builder(context),
        transitionsBuilder: (context, animation, secondary, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.35, curve: Curves.easeOut),
            reverseCurve: const Interval(0.3, 1, curve: Curves.easeIn),
          );
          return FadeTransition(opacity: fade, child: child);
        },
      );
}
