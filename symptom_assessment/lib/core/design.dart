import 'package:flutter/animation.dart';

/// Layout and motion tokens.
///
/// Distances were measured on the reference frames (289 px wide) and scaled
/// to a 393-wide logical canvas, so every value here is in logical pixels
/// against that width. The layout flexes for other widths; the ratios hold.
class D {
  D._();

  static const double refWidth = 393;
  static const double gutter = 14;
  static const double radius = 22;
  static const double tileRadius = 18;

  // Header
  static const double headerTop = 12;
  static const double headerButton = 40;
  static const double headerHeight = 56;

  // Assess screen
  static const double haloOuter = 164;
  static const double haloInner = 124;
  static const double orb = 78;
  static const double orbBlockTop = 44;
  static const double headlineGap = 30;
  static const double fieldHeight = 56;
  static const double fieldGap = 34;
  static const double micGap = 8;
  static const double chipsGap = 26;
  static const double chipHeight = 52;
  static const double chipIcon = 40;
  static const double chipEmoji = 24;
  static const double privacyHeight = 108;

  // Results screen
  static const double tileGap = 10;
  static const double tilePadding = 16;
  static const double badge = 20;

  // Report screen
  static const double reportHeadHeight = 112;
  static const double ctaHeight = 50;
  static const double sectionHeight = 76;

  // Motion ---------------------------------------------------------------

  /// One entrance controller per screen; each element reads its own slice.
  static const Duration entrance = Duration(milliseconds: 1400);
  static const Duration route = Duration(milliseconds: 620);
  static const Duration containerRoute = Duration(milliseconds: 720);
  static const Duration press = Duration(milliseconds: 120);
  static const Duration release = Duration(milliseconds: 520);

  static const Curve out = Curves.easeOutCubic;
  static const Curve outExpo = Curves.easeOutExpo;
  static const Curve outBack = Curves.easeOutBack;

  /// A single, clean overshoot. Stock elasticOut rings twice and peaks high.
  static const Curve pop = ElasticOutCurve(0.62);
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1.0);

  // Assess entrance intervals
  static const Interval headerIn = Interval(0.00, 0.30, curve: out);
  static const Interval haloIn = Interval(0.05, 0.55, curve: pop);
  static const Interval orbIn = Interval(0.12, 0.62, curve: pop);
  static const Interval headlineIn = Interval(0.22, 0.60, curve: outExpo);
  static const Interval subIn = Interval(0.34, 0.66, curve: out);
  static const Interval fieldIn = Interval(0.40, 0.78, curve: pop);
  static const Interval micIn = Interval(0.48, 0.84, curve: pop);
  static const Interval chipsLabelIn = Interval(0.52, 0.78, curve: out);
  static const double chipsStart = 0.56;
  static const double chipStagger = 0.05;
  static const double chipSpan = 0.30;
  static const Interval privacyIn = Interval(0.62, 1.00, curve: outExpo);

  // Results entrance
  static const Interval hintIn = Interval(0.00, 0.35, curve: out);
  static const Interval foundIn = Interval(0.10, 0.45, curve: out);
  static const double tilesStart = 0.12;
  static const double tileStagger = 0.055;
  static const double tileSpan = 0.42;

  // Report entrance
  static const Interval reportHeadIn = Interval(0.00, 0.40, curve: outExpo);
  static const Interval reportOrbIn = Interval(0.18, 0.62, curve: pop);
  static const Interval reportCardIn = Interval(0.12, 0.52, curve: outExpo);
  static const Interval attentionIn = Interval(0.30, 0.60, curve: pop);
  static const Interval explainIn = Interval(0.36, 0.66, curve: out);
  static const Interval conditionIn = Interval(0.42, 0.70, curve: out);
  static const Interval actionIn = Interval(0.48, 0.78, curve: outBack);
  static const Interval ctaIn = Interval(0.56, 0.86, curve: pop);
  static const double sectionsStart = 0.64;
  static const double sectionStagger = 0.08;
  static const double sectionSpan = 0.32;

  /// Progress 0..1 for the [index]th item of a staggered group.
  static double stagger(
    double t,
    double start,
    int index,
    double stagger,
    double span,
  ) =>
      ((t - (start + index * stagger)) / span).clamp(0.0, 1.0);
}
