import 'package:flutter/material.dart';

/// Weighted spring physics for a slower, premium page snap.
class LuxuryPageScrollPhysics extends ScrollPhysics {
  const LuxuryPageScrollPhysics({super.parent});

  @override
  LuxuryPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return LuxuryPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1.05,
        stiffness: 88,
        damping: 21,
      );
}
