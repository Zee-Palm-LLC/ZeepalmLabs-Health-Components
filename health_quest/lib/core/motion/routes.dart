import 'package:flutter/widgets.dart';

import '../design.dart';

PageRouteBuilder<T> hudRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 520),
  reverseTransitionDuration: const Duration(milliseconds: 420),
  pageBuilder:
      (BuildContext context, Animation<double> a1, Animation<double> a2) =>
          page,
  transitionsBuilder:
      (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        final a = CurvedAnimation(
          parent: animation,
          curve: D.emphasized,
          reverseCurve: D.emphasized.flipped,
        );
        return FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(a),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1).animate(a),
              child: child,
            ),
          ),
        );
      },
);
