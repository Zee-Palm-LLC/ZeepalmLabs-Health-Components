import 'package:flutter/material.dart';

/// Shared timings and curves. Keeping them in one place stops the screens
/// drifting apart as animations are added.
abstract final class AegisMotion {
  /// Press feedback, colour swaps, anything the thumb is waiting on.
  static const fast = Duration(milliseconds: 180);

  /// State changes inside a screen: stepper fills, badge swaps.
  static const medium = Duration(milliseconds: 420);

  /// Route transitions.
  static const slow = Duration(milliseconds: 620);

  /// How long a screen takes to stagger its contents into place.
  static const reveal = Duration(milliseconds: 1000);

  /// One idle breath of the SOS button.
  static const breath = Duration(seconds: 4);

  /// The responder's run across the map, end to end.
  static const route = Duration(milliseconds: 6000);

  /// Fraction of [route] spent travelling; the remainder is the arrival beat.
  static const travelFraction = 0.86;

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const emphasized = Cubic(0.2, 0, 0, 1);
  static const overshoot = Curves.easeOutBack;
}

/// Whether the platform asks for reduced motion. Only decorative loops and
/// long transitions check this; feedback the user is waiting on still plays.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;
