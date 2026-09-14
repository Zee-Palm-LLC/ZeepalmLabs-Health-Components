import 'package:flutter/widgets.dart';

/// Every dimension in this app is expressed in *design units*.
///
/// One design unit == one logical pixel on an iPhone 16 Pro Max (440 x 956),
/// which is the device the reference recording was captured on. The whole
/// screen is laid out at that exact size and then uniformly scaled to fit the
/// real viewport, so the proportions are identical on every device instead of
/// drifting the way ad-hoc padding does.
class Design {
  const Design._();

  static const double width = 440;
  static const double height = 956;

  /// Horizontal gutter used by the header, the copy and the picker row.
  static const double gutter = 32;

  // ---- Header -------------------------------------------------------------
  static const double headerButtonSize = 44;
  static const double headerButtonCenterY = 104;
  static const double headerGlyphSize = 18;

  // ---- Copy ---------------------------------------------------------------
  /// Small caps line above the headline. Gives the page a top edge to sit
  /// against so the headline is not floating under the status bar.
  static const double eyebrowTop = 150;
  static const double eyebrowSize = 10.5;
  static const double eyebrowTracking = 2.2;

  static const double titleTop = 174;
  static const double titleSize = 25;
  static const double titleMaxWidth = 340;

  // ---- Face ---------------------------------------------------------------
  /// The top of the eyes never moves; only their height changes, so a "squint"
  /// collapses downward from a fixed brow line.
  static const double faceEyeTop = 274;
  static const double faceCenterX = width / 2;
  static const double faceMouthStroke = 12;

  // ---- Mood word ----------------------------------------------------------
  /// Sized so the longest word (OVERWHELMED) fills the measure at full size.
  /// Every mood then renders at effectively the same optical weight, instead
  /// of the short ones towering over the long ones.
  static const double wordCenterY = 516;
  static const double wordSize = 52;
  static const double wordTracking = -1.8;
  static const double wordMaxWidth = width - gutter * 2;
  static const double wordBandHeight = 88;

  // ---- Mood blurb ---------------------------------------------------------
  /// One plain-language line under the word. It fills what was dead space and
  /// gives the page something to say.
  static const double blurbTop = 571;
  static const double blurbSize = 13.5;
  static const double blurbMaxWidth = 300;

  // ---- Mood picker --------------------------------------------------------
  /// A row of five circular faces. Slots are a fixed pitch and each face
  /// scales about its own centre, so the selected one can spring past full
  /// size without shoving its neighbours around.
  static const double moodRowTop = 626;
  static const double moodRowHeight = 128;
  static const double moodRowCenterY = 690;

  /// The circles sit on a tray that echoes the action bar below them, so the
  /// bottom third reads as a deck of controls instead of five dots adrift in
  /// empty colour.
  static const double pickerTrayHeight = 104;
  static double get pickerTrayWidth => barWidth;
  static const double pickerTrayRadius = pickerTrayHeight / 2;
  static const double moodDotSize = 52;
  static const double moodDotSelectedSize = 82;

  /// Fraction of the circle the face itself occupies.
  static const double moodDotFaceFit = 0.66;

  /// Floor for the mouth stroke inside a picker circle, in on-screen units.
  static const double moodDotMinStroke = 2.8;

  static double get moodRowPitch => (width - gutter * 2) / 5;
  static double moodDotCenterX(int index) =>
      gutter + moodRowPitch / 2 + moodRowPitch * index;

  // ---- Bottom action bar --------------------------------------------------
  static const double barGutter = 28;
  static const double barTop = 816;
  static const double barHeight = 64;
  static const double barRadius = barHeight / 2;
  static const double barWidth = width - barGutter * 2;
  static const double barLabelSize = 15;

  /// Breathing room between the pill's edge and the controls sitting inside
  /// it. The submit button floats in the bar rather than being flush with it,
  /// so the bar reads as a container and the button as a thing inside it.
  static const double barInset = 7;

  /// Outer footprint of the submit button, inset included.
  static const double submitWidth = 146;
  static const double controlHeight = barHeight - barInset * 2;
  static const double controlRadius = controlHeight / 2;

  /// Leading chip inside the note field, on the same inset as the button.
  static const double noteChipSize = controlHeight;

  // ---- Motion -------------------------------------------------------------
  /// One controller drives the whole screen; the parts differ only by curve,
  /// which is what keeps a mood change reading as a single object moving.
  static const Duration transition = Duration(milliseconds: 580);

  /// Colour is the one thing that must not overshoot — springing past a mood
  /// would flash a colour that is not on the scale. So it runs smooth, and
  /// lands before the spring has finished ringing.
  static const Curve colorCurve = Interval(0, 0.62, curve: Curves.easeOutCubic);

  /// Face and picker circles: a spring, but a *damped* one.
  ///
  /// The stock `Curves.elasticOut` (period 0.4) peaks around +27% and rings
  /// twice — it reads as wobble rather than weight. A longer period gives a
  /// single clean overshoot of roughly +12% that settles almost immediately,
  /// which is the difference between bouncy and expensive.
  static const Curve bounceCurve = ElasticOutCurve(0.62);

  /// The word pager gets a single overshoot rather than a full spring —
  /// a ringing PageView reveals its neighbours and reads as a glitch.
  static const Duration wordTransition = Duration(milliseconds: 400);
  static const Curve wordCurve = Curves.easeOutBack;

  /// The blurb swaps out rather than morphing, so it gets its own short fade.
  static const Duration blurbTransition = Duration(milliseconds: 260);
}

/// Ink used for the title and the face.
const Color kInk = Color(0xFF0B0B0B);

/// The submit pill is the one element that does not take part in the colour
/// animation — that is what makes it read as the primary action.
const Color kSubmitFill = Color(0xFFEBDBCE);
const Color kSubmitInk = Color(0xFF42251A);
