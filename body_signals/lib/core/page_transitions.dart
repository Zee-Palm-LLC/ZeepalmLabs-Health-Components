import 'package:flutter/material.dart';

import 'app_motion.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required this.builder, super.settings})
      : super(
          transitionDuration: AppMotion.route,
          reverseTransitionDuration: AppMotion.medium,
          pageBuilder: (context, _, _) => builder(context),
          transitionsBuilder: (context, animation, secondary, child) {
            final inward = CurvedAnimation(
              parent: animation,
              curve: AppMotion.emphasized,
              reverseCurve: AppMotion.exit,
            );
            final outward = CurvedAnimation(
              parent: secondary,
              curve: AppMotion.emphasized,
            );

            return FadeTransition(
              opacity: inward,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.045),
                  end: Offset.zero,
                ).animate(inward),
                child: ScaleTransition(
                  scale: Tween(begin: 0.97, end: 1.0).animate(inward),
                  child: FadeTransition(
                    opacity: Tween(begin: 1.0, end: 0.0).animate(outward),
                    child: child,
                  ),
                ),
              ),
            );
          },
        );

  final WidgetBuilder builder;
}

class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final inward = CurvedAnimation(
      parent: animation,
      curve: AppMotion.emphasized,
      reverseCurve: AppMotion.exit,
    );

    return FadeTransition(
      opacity: inward,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.045),
          end: Offset.zero,
        ).animate(inward),
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(inward),
          child: child,
        ),
      ),
    );
  }
}
