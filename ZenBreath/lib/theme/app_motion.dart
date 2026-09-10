import 'package:flutter/material.dart';

/// Motion tokens. Everything in the app eases on the same two curves so screen
/// changes, list entrances and press feedback feel like one system.
class AppMotion {
  const AppMotion._();

  static const enter = Duration(milliseconds: 420);
  static const exit = Duration(milliseconds: 300);
  static const tab = Duration(milliseconds: 380);
  static const stagger = Duration(milliseconds: 55);
  static const press = Duration(milliseconds: 120);

  static const enterCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;
}

/// Route transition used across the app: the incoming page fades up from a few
/// pixels below while the page it covers drifts back and dims slightly.
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
    return _AppPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class _AppPageTransition extends StatelessWidget {
  const _AppPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final entering = CurvedAnimation(
      parent: animation,
      curve: AppMotion.enterCurve,
      reverseCurve: AppMotion.exitCurve,
    );
    final leaving = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.enterCurve,
      reverseCurve: AppMotion.exitCurve,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([entering, leaving]),
      child: child,
      builder: (context, child) {
        final t = entering.value;
        final away = leaving.value;
        return Opacity(
          opacity: (t * (1 - away * 0.45)).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 26 - away * 12),
            child: Transform.scale(scale: (0.985 + t * 0.015) - away * 0.02, child: child),
          ),
        );
      },
    );
  }
}

/// Convenience route so pushes outside `MaterialPageRoute` share the same feel.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: AppMotion.enter,
        reverseTransitionDuration: AppMotion.exit,
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _AppPageTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            ),
      );
}
