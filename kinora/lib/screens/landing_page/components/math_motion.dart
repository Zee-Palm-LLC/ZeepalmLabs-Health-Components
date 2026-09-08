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

  /// Remap global time into a delayed / truncated channel ∈ [0, 1].
  static double channel(double t, {required double start, required double end}) {
    assert(end > start);
    return clamp01((t - start) / (end - start));
  }

  /// Magnetic ease — remapped tanh. Feels like soft attraction to rest.
  /// `½ · (1 + tanh(k(2t−1)) / tanh(k))`
  static double magnetic(double t, {double sharpness = 3.0}) {
    t = clamp01(t);
    final k = sharpness;
    final num = tanh(k * (2 * t - 1));
    final den = tanh(k);
    return 0.5 * (1 + num / den);
  }

  /// Critically damped spring (no bounce): `1 − e^(−λt)(1 + λt)`
  static double critical(double t, {double lambda = 6.8}) {
    t = clamp01(t);
    final e = math.exp(-lambda * t);
    return 1 - e * (1 + lambda * t);
  }

  /// Underdamped settle (overshoot then land): `1 − e^(−αt) · cos(ωt)`
  static double settle(double t, {double alpha = 6.2, double omega = 11.5}) {
    t = clamp01(t);
    return 1 - math.exp(-alpha * t) * math.cos(omega * t);
  }

  /// Soft bounce — one lively pop, then calm.
  static double softBounce(double t) {
    t = clamp01(t);
    return 1 -
        math.pow(2, -8 * t).toDouble() * math.cos(t * math.pi * 3.1);
  }

  /// Crisp entrance pop — faster decay, lighter overshoot than [softBounce].
  static double pop(double t) {
    t = clamp01(t);
    return 1 -
        math.pow(2, -9.5 * t).toDouble() * math.cos(t * math.pi * 2.55);
  }

  /// Quintic impulse bump peaking near mid — useful as a micro crest weight.
  /// `t · (1−t)⁴ · normalize`
  static double impulse(double t, {double shape = 4}) {
    t = clamp01(t);
    final h = t * math.pow(1 - t, shape).toDouble();
    // Peak of t(1−t)^n is at t = 1/(n+1).
    final peakT = 1 / (shape + 1);
    final peak = peakT * math.pow(1 - peakT, shape).toDouble();
    return peak == 0 ? 0.0 : h / peak;
  }

  /// Premium rise composite:
  /// magnetic body (82%) + lightly damped settle crest (18%).
  static double premiumRise(double t) {
    t = clamp01(t);
    final body = magnetic(t, sharpness: 2.85);
    final crest = clamp01(settle(t, alpha: 10.8, omega: 7.4));
    return body * 0.82 + crest * 0.18;
  }

  /// Premium scale: critical damp + tiny impulse overshoot (~1.8%).
  static double premiumScale(double t) {
    t = clamp01(t);
    final base = critical(t, lambda: 7.4);
    final crest = impulse(t, shape: 3.2) * 0.018;
    return base + crest;
  }

  /// Opacity that leads motion — magnetic + early window.
  static double premiumFade(double t, {double doneBy = 0.52}) {
    return magnetic(smootherstep(clamp01(t / doneBy)), sharpness: 2.6);
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

  /// Butter-smooth expo ease-out.
  static double silk(double t, {double power = 3.4}) {
    t = clamp01(t);
    return 1 - math.pow(1 - t, power).toDouble();
  }

  /// Soft premium glide — silk + lightly damped settle.
  static double glide(double t) {
    t = clamp01(t);
    final a = silk(t, power: 3.2);
    final b = clamp01(settle(t, alpha: 9.2, omega: 6.8));
    return a * 0.78 + b * 0.22;
  }

  /// Gentle bloom: expands softly past target then rests.
  static double bloom(double t) {
    t = clamp01(t);
    final base = silk(t, power: 2.8);
    final crest = math.sin(math.pi * base) * 0.032 * (1 - silk(t));
    return base + crest;
  }

  /// Fade that finishes early so content feels present sooner.
  static double earlyFade(double t, {double doneBy = 0.58}) {
    return silk(clamp01(t / doneBy), power: 2.4);
  }
}

/// Flutter [Curve] wrappers around [MathMotion].
class MathCurves {
  const MathCurves._();

  static const settle = _FnCurve(MathMotion.settle);
  static const softBounce = _FnCurve(MathMotion.softBounce);
  static const pop = _FnCurve(MathMotion.pop);
  static const smoother = _FnCurve(MathMotion.smootherstep);
  static const spiral = _FnCurve(MathMotion.spiralBlend);
  static const anticipate = _FnCurve(MathMotion.anticipate);
  static const silk = _FnCurve(MathMotion.silk);
  static const glide = _FnCurve(MathMotion.glide);
  static const bloom = _FnCurve(MathMotion.bloom);
  static const magnetic = _FnCurve(MathMotion.magnetic);
  static const critical = _FnCurve(MathMotion.critical);
  static const premiumRise = _FnCurve(MathMotion.premiumRise);
}

class _FnCurve extends Curve {
  const _FnCurve(this.fn);
  final double Function(double t) fn;

  @override
  double transformInternal(double t) => fn(t);
}
