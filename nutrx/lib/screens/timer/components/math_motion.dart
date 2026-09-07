import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// Parametric motion helpers — unique feel without stock Curves.
abstract final class MathMotion {
  static double clamp01(double t) => t.clamp(0.0, 1.0);

  /// Hyperbolic tangent (manual — portable across Dart SDKs).
  static double tanh(double x) {
    final e = math.exp(2 * x.clamp(-20.0, 20.0));
    return (e - 1) / (e + 1);
  }

  /// Classic Hermite smoothstep: `3t² − 2t³`
  static double smoothstep(double t) {
    t = clamp01(t);
    return t * t * (3 - 2 * t);
  }

  /// Ken Perlin smootherstep: `6t⁵ − 15t⁴ + 10t³`
  static double smootherstep(double t) {
    t = clamp01(t);
    return t * t * t * (t * (t * 6 - 15) + 10);
  }

  /// Damped harmonic settle (overshoot then land).
  /// `1 − e^(−αt) · cos(ωt)`
  static double settle(double t, {double alpha = 6.2, double omega = 11.5}) {
    t = clamp01(t);
    return 1 - math.exp(-alpha * t) * math.cos(omega * t);
  }

  /// Soft bounce — one lively pop, then calm.
  /// `1 − 2^(−8t) · cos(π · 3.1 · t)`
  static double softBounce(double t) {
    t = clamp01(t);
    return 1 -
        math.pow(2, -8 * t).toDouble() * math.cos(t * math.pi * 3.1);
  }

  /// Anticipation then surge (great for slides).
  static double anticipate(double t, {double pull = 0.18}) {
    t = clamp01(t);
    if (t < 0.22) {
      final u = t / 0.22;
      return -pull * math.sin(u * math.pi);
    }
    final u = (t - 0.22) / 0.78;
    return settle(u, alpha: 7, omega: 10);
  }

  /// Spiral blend — mixes settle + smootherstep for organic opacity.
  static double spiralBlend(double t) {
    t = clamp01(t);
    final a = smootherstep(t);
    final b = clamp01(settle(t, alpha: 7.5, omega: 9));
    return a * 0.55 + b * 0.45;
  }

  /// Continuous breath wave in `[lo, hi]`.
  static double breath(double phase, {double lo = 0.92, double hi = 1.0}) {
    final w = 0.5 + 0.5 * math.sin(phase);
    return lo + (hi - lo) * w;
  }

  /// Decaying wobble for entrance sway.
  static double wobble(double t, {double amp = 1, double freq = 2.4}) {
    t = clamp01(t);
    return amp * math.sin(t * math.pi * freq) * (1 - t);
  }
}

/// Flutter [Curve] wrappers around [MathMotion].
class MathCurves {
  const MathCurves._();

  static const settle = _FnCurve(MathMotion.settle);
  static const softBounce = _FnCurve(MathMotion.softBounce);
  static const smoother = _FnCurve(MathMotion.smootherstep);
  static const spiral = _FnCurve(MathMotion.spiralBlend);
  static const anticipate = _FnCurve(MathMotion.anticipate);
}

class _FnCurve extends Curve {
  const _FnCurve(this.fn);
  final double Function(double t) fn;

  @override
  double transformInternal(double t) => fn(t);
}
