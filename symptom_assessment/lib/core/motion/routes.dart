import 'package:flutter/material.dart';

import '../design.dart';

/// Vertical shared-axis: the incoming page rises and fades while the outgoing
/// page sinks a little and fades. Heroes fly across on top. This is the move
/// between the assess screen and the results.
class SharedAxisRoute<T> extends PageRoute<T> {
  SharedAxisRoute({required this.builder, super.settings});

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => D.route;

  @override
  Duration get reverseTransitionDuration => D.route;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = CurvedAnimation(
      parent: animation,
      curve: D.emphasized,
      reverseCurve: D.emphasized.flipped,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: D.emphasized,
    );

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[incoming, outgoing]),
      builder: (BuildContext context, Widget? _) {
        final a = incoming.value;
        final b = outgoing.value;
        return Opacity(
          opacity: (a * (1 - b)).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - a) * 40 - b * 28),
            child: Transform.scale(
              scale: 1 - b * 0.04,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Container transform: a card grows from its own rectangle into the full
/// screen, its content cross-fading into the new page. The origin rectangle
/// is captured from the tapped widget at push time, so the page arrives out
/// of exactly the thing that was touched.
class ContainerTransformRoute<T> extends PageRoute<T> {
  ContainerTransformRoute({
    required this.builder,
    required this.origin,
    this.originRadius = D.tileRadius,
    this.originColor = Colors.white,
    this.originChild,
    super.settings,
  });

  final WidgetBuilder builder;
  final Rect origin;
  final double originRadius;
  final Color originColor;

  /// A snapshot of what sat in the origin rect, faded out during the flight.
  final Widget? originChild;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => D.containerRoute;

  @override
  Duration get reverseTransitionDuration => D.containerRoute;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final size = MediaQuery.sizeOf(context);
    final full = Offset.zero & size;
    final curved = CurvedAnimation(
      parent: animation,
      curve: D.emphasized,
      reverseCurve: D.emphasized.flipped,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (BuildContext context, Widget? _) {
        final t = curved.value;
        final rect = Rect.lerp(origin, full, t)!;
        final radius = originRadius * (1 - t) + 0 * t;
        // Content fades in over the second half of the flight; the origin's
        // own content fades out over the first third.
        final contentIn = ((t - 0.35) / 0.55).clamp(0.0, 1.0);
        final originOut = 1 - (t / 0.3).clamp(0.0, 1.0);

        return Stack(
          children: <Widget>[
            // Scrim over the page beneath so the growing card reads on top.
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.6 * t),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: rect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: ColoredBox(
                  color: originColor,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      // The destination page, laid out at full size and
                      // pinned to the top-left so it slides into place as
                      // the rect grows rather than being squashed.
                      OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: size.width,
                        maxWidth: size.width,
                        minHeight: size.height,
                        maxHeight: size.height,
                        child: Opacity(
                          opacity: contentIn,
                          child: Transform.translate(
                            offset: Offset(0, (1 - contentIn) * 24),
                            child: child,
                          ),
                        ),
                      ),
                      if (originChild != null && originOut > 0)
                        Positioned(
                          left: 0,
                          top: 0,
                          width: origin.width,
                          height: origin.height,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: originOut,
                              child: originChild,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Reads a widget's on-screen rectangle from its [GlobalKey].
Rect? rectOf(GlobalKey key) {
  final ctx = key.currentContext;
  if (ctx == null) return null;
  final box = ctx.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}
