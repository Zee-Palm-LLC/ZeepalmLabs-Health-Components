import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

/// The geometry of the face for a single mood, in design units.
///
/// Nothing here is a bitmap: the face is five numbers, which is what lets one
/// mood morph continuously into the next instead of cross-fading between
/// pre-drawn assets.
@immutable
class FaceShape {
  const FaceShape({
    required this.eyeWidth,
    required this.eyeHeight,
    required this.eyeGap,
    required this.mouthCenterY,
    required this.mouthWidth,
    required this.mouthArc,
  });

  /// Eyes are rounded rectangles; when width == height they read as circles,
  /// and as the height collapses they become a squint.
  final double eyeWidth;
  final double eyeHeight;

  /// Horizontal space between the two eyes.
  final double eyeGap;

  final double mouthCenterY;
  final double mouthWidth;

  /// Signed sagitta of the mouth arc: negative frowns, zero is a flat line,
  /// positive smiles.
  final double mouthArc;

  /// [t] is deliberately *not* clamped: an elastic curve feeds values above 1
  /// and the shape extrapolates past the target, which is what produces the
  /// overshoot-and-settle. Sizes are floored so a hard overshoot can never
  /// invert an eye.
  static FaceShape lerp(FaceShape a, FaceShape b, double t) => FaceShape(
    eyeWidth: _atLeast(lerpDouble(a.eyeWidth, b.eyeWidth, t)!, 8),
    eyeHeight: _atLeast(lerpDouble(a.eyeHeight, b.eyeHeight, t)!, 8),
    eyeGap: _atLeast(lerpDouble(a.eyeGap, b.eyeGap, t)!, 0),
    mouthCenterY: lerpDouble(a.mouthCenterY, b.mouthCenterY, t)!,
    mouthWidth: _atLeast(lerpDouble(a.mouthWidth, b.mouthWidth, t)!, 12),
    mouthArc: lerpDouble(a.mouthArc, b.mouthArc, t)!,
  );

  static double _atLeast(double value, double floor) =>
      value < floor ? floor : value;

  @override
  bool operator ==(Object other) =>
      other is FaceShape &&
      other.eyeWidth == eyeWidth &&
      other.eyeHeight == eyeHeight &&
      other.eyeGap == eyeGap &&
      other.mouthCenterY == mouthCenterY &&
      other.mouthWidth == mouthWidth &&
      other.mouthArc == mouthArc;

  @override
  int get hashCode =>
      Object.hash(eyeWidth, eyeHeight, eyeGap, mouthCenterY, mouthWidth, mouthArc);
}

/// One point on the five-step ADHD mood scale.
@immutable
class Mood {
  const Mood({
    required this.word,
    required this.tick,
    required this.blurb,
    required this.color,
    required this.face,
  });

  /// The large animated word.
  final String word;

  /// Short label, used in the legend and for accessibility.
  final String tick;

  /// Plain-language description, used for accessibility and for whatever
  /// storage layer you bolt on later.
  final String blurb;

  /// Background colour. Every other colour on the screen is derived from it.
  final Color color;

  final FaceShape face;

  /// The big word: the background darkened until it sits just behind the face.
  Color get wordColor => shade(color, 0.72);

  /// Note bar and header buttons.
  Color get surfaceColor => shade(color, 0.84);

  /// Scales a colour's lightness, keeping its hue and saturation. Every other
  /// colour on the screen is this function applied to the background, which is
  /// why the palette can never fall out of tune with itself.
  static Color shade(Color c, double factor) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
  }

  /// Ordered worst-to-best. The index doubles as the position on the scale.
  static const List<Mood> values = <Mood>[
    Mood(
      word: 'OVERWHELMED',
      tick: 'Overwhelmed',
      blurb: 'Too much input, everything at once.',
      color: Color(0xFFF15A45),
      face: FaceShape(
        eyeWidth: 69,
        eyeHeight: 69,
        eyeGap: 22,
        mouthCenterY: 384,
        mouthWidth: 62,
        mouthArc: -26,
      ),
    ),
    Mood(
      word: 'DRAINED',
      tick: 'Drained',
      blurb: 'Running on empty, hard to start anything.',
      color: Color(0xFFF08327),
      face: FaceShape(
        eyeWidth: 69,
        eyeHeight: 30,
        eyeGap: 22,
        mouthCenterY: 344,
        mouthWidth: 60,
        mouthArc: -18,
      ),
    ),
    Mood(
      word: 'OKAY',
      tick: 'Okay',
      blurb: 'Neutral. Not great, not bad.',
      color: Color(0xFFEBAA08),
      face: FaceShape(
        eyeWidth: 90,
        eyeHeight: 90,
        eyeGap: 22,
        mouthCenterY: 396,
        mouthWidth: 64,
        mouthArc: 0,
      ),
    ),
    Mood(
      word: 'FOCUSED',
      tick: 'Focused',
      blurb: 'Locked in, one thing at a time.',
      color: Color(0xFFD1D41C),
      face: FaceShape(
        eyeWidth: 100,
        eyeHeight: 46,
        eyeGap: 22,
        mouthCenterY: 360,
        mouthWidth: 66,
        mouthArc: 15,
      ),
    ),
    Mood(
      word: 'ENERGIZED',
      tick: 'Energized',
      blurb: 'Buzzing with energy and ideas.',
      color: Color(0xFFA4DC3B),
      face: FaceShape(
        eyeWidth: 106,
        eyeHeight: 106,
        eyeGap: 22,
        mouthCenterY: 428,
        mouthWidth: 64,
        mouthArc: 26,
      ),
    ),
  ];

  static int get last => values.length - 1;

  /// Sample the scale at any continuous position, so the screen can be halfway
  /// between two moods mid-drag.
  static Color colorAt(double t) {
    final (a, b, f) = _span(t);
    return Color.lerp(values[a].color, values[b].color, f)!;
  }

  static Color wordColorAt(double t) {
    final (a, b, f) = _span(t);
    return Color.lerp(values[a].wordColor, values[b].wordColor, f)!;
  }

  static Color surfaceColorAt(double t) {
    final (a, b, f) = _span(t);
    return Color.lerp(values[a].surfaceColor, values[b].surfaceColor, f)!;
  }

  static FaceShape faceAt(double t) {
    final (a, b, f) = _span(t);
    return FaceShape.lerp(values[a].face, values[b].face, f);
  }

  static (int, int, double) _span(double t) {
    final clamped = t.clamp(0.0, last.toDouble());
    final lower = clamped.floor();
    final upper = (lower + 1).clamp(0, last);
    return (lower, upper, clamped - lower);
  }
}
