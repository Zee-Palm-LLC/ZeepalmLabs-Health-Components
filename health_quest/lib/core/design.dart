import 'package:flutter/animation.dart';

/// Layout and motion tokens.
///
/// Every distance was measured on the reference frame (a 450 x 990 px phone
/// screen) and scaled to a 393-wide logical canvas, so the numbers here are
/// logical pixels at that width. The layout flexes for other sizes: the top
/// and bottom blocks are fixed and the hero stage takes what is left.
class D {
  D._();

  static const double refWidth = 393;
  static const double refHeight = 864;
  static const double gutter = 46;

  // Top block ------------------------------------------------------------
  static const double headlineTop = 34;
  static const double levelUpSize = 30;
  static const double yourHealthSize = 40;
  static const double headlineGap = 4;
  static const double subGap = 18;
  static const double subSize = 15.5;
  static const double subLineHeight = 1.22;

  // Hero art -------------------------------------------------------------
  //
  // The art is full-bleed behind the interface, exactly as in the reference.
  // The defocused plate covers the screen; the cut-out figure is placed by
  // fractions of the screen so the composition survives any phone.

  /// The source frame both hero layers and the intro clip come from.
  static const double frameWidth = 720;
  static const double frameHeight = 1280;

  /// Where the cut-out was taken from inside that frame.
  static const double cutLeft = 91;
  static const double cutTop = 331;
  static const double cutWidth = 539;
  static const double cutHeight = 780;

  /// Aspect of the cut-out figure, head to the underside of the rock.
  static const double heroAspect = cutWidth / cutHeight;

  /// Top of the figure's hair, as a fraction of screen height.
  static const double heroTopFraction = 0.258;

  /// Height of the whole cut-out, as a fraction of screen height.
  static const double heroHeightFraction = 0.520;

  /// Nudged left of centre, matching the reference's slightly off-axis pose.
  static const double heroCentreFraction = 0.497;

  // Stat badges, as fractions of screen height ---------------------------
  static const double hexWidth = 52;
  static const double hexHeight = 60;
  static const double badgeSlot = 104;
  static const double statLabelSize = 12.5;
  static const double statLevelSize = 11;

  /// Hex centres. The lower row splays a little wider because the character
  /// is widest at the legs, which is what the reference does too.
  static const List<double> statFractionY = <double>[0.318, 0.482];
  static const List<double> statCentreX = <double>[65, 328, 58, 335];

  // Bottom block ---------------------------------------------------------
  static const double cardHeight = 72;
  static const double cardRadius = 22;
  static const double lvlBadgeWidth = 46;
  static const double lvlBadgeHeight = 64;
  static const double xpTrackHeight = 12;
  static const double cardToButton = 18;
  static const double buttonHeight = 57;
  static const double buttonToFooter = 25;
  static const double footerSize = 13;
  static const double footerBottom = 26;

  // Dashboard, quest detail and vault -------------------------------------
  //
  // Measured off reference screens two and three, which share a 467 px wide
  // phone, scaled to the same 393-wide canvas.
  static const double pageGutter = 18;
  static const double cardRadiusLarge = 20;
  static const double cardRadiusSmall = 16;
  static const double questCardHeight = 74;
  static const double questGap = 10;
  static const double questIconSize = 44;
  static const double navHeight = 71;
  static const double navRadius = 22;
  static const double headerAvatar = 58;
  static const double headerButton = 42;
  static const double xpPanelHeight = 48;
  static const double levelHex = 39;
  static const double scoreRing = 128;
  static const double scoreRingStroke = 11;
  static const double questRing = 236;
  static const double questRingStroke = 15;
  static const double milestoneHex = 34;
  static const double ctaHeight = 56;

  // Motion ---------------------------------------------------------------

  /// The whole screen arrives on one controller; each element reads a slice.
  static const Duration entrance = Duration(milliseconds: 2600);

  /// The dashboard and the other pages are quicker; there is no film to sit
  /// through, just a page assembling itself.
  static const Duration pageEntrance = Duration(milliseconds: 1250);

  static const Interval headerIn = Interval(0.00, 0.34, curve: outExpo);
  static const Interval xpPanelIn = Interval(0.08, 0.42, curve: outExpo);
  static const Interval scoreIn = Interval(0.16, 0.62, curve: emphasized);
  static const Interval sectionIn = Interval(0.30, 0.56, curve: out);
  static const double rowsStart = 0.34;
  static const double rowStagger = 0.07;
  static const double rowSpan = 0.34;
  static const Interval navIn = Interval(0.58, 0.88, curve: softPop);

  /// Quest detail.
  static const Interval questHeadIn = Interval(0.00, 0.34, curve: outExpo);
  static const Interval questRingIn = Interval(0.10, 0.78, curve: emphasized);
  static const Interval questCountIn = Interval(0.22, 0.70, curve: outExpo);
  static const Interval questRewardIn = Interval(0.42, 0.68, curve: outExpo);
  static const double milestonesStart = 0.50;
  static const double milestoneStagger = 0.06;
  static const double milestoneSpan = 0.26;
  static const Interval questCtaIn = Interval(0.70, 0.96, curve: softPop);

  /// One clean overshoot. Stock elasticOut peaks +27% and rings twice.
  static const Curve pop = ElasticOutCurve(0.62);
  static const Curve softPop = ElasticOutCurve(0.75);
  static const Curve out = Curves.easeOutCubic;
  static const Curve outExpo = Curves.easeOutExpo;
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1.0);

  // The plate and the character come in fast. They have to: pressing the CTA
  // replays this whole sequence, and a slow sky means a second of black
  // behind the launch flash.
  static const Interval plateIn = Interval(0.00, 0.34, curve: outExpo);
  static const Interval heroIn = Interval(0.04, 0.42, curve: emphasized);
  static const Interval platformFlash = Interval(0.22, 0.52, curve: Curves.easeOut);
  static const Interval levelUpIn = Interval(0.22, 0.50, curve: outExpo);
  static const Interval yourHealthIn = Interval(0.30, 0.60, curve: outExpo);
  static const Interval subIn = Interval(0.44, 0.66, curve: out);

  /// The four badges land one after another, clockwise from top-left.
  static const double statsStart = 0.52;
  static const double statStagger = 0.055;
  static const double statSpan = 0.26;

  static const Interval cardIn = Interval(0.72, 0.92, curve: softPop);
  static const Interval buttonIn = Interval(0.78, 1.00, curve: softPop);
  static const Interval footerIn = Interval(0.88, 1.00, curve: out);

  /// Progress 0..1 for the [index]th item of a staggered group.
  static double stagger(
    double t,
    double start,
    int index,
    double step,
    double span,
  ) =>
      ((t - (start + index * step)) / span).clamp(0.0, 1.0);
}
