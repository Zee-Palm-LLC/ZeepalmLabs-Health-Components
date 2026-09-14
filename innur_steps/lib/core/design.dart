import 'package:flutter/widgets.dart';

/// Every dimension is a *design unit*: one logical pixel on a 440-wide screen.
/// The page is laid out at that width and uniformly scaled, so the proportions
/// hold on any device instead of drifting the way ad-hoc padding does.
///
/// Vertical position is expressed as **gaps between sections** rather than
/// absolute tops. The rhythm is the one measured off the reference; it is
/// written this way because the rank list now runs past the bottom of the
/// screen and the page has to scroll.
class D {
  const D._();

  static const double w = 440;
  static const double h = 956;

  /// Content gutter. The header, the big number and the chip row all start on
  /// this line.
  static const double gutter = 22;

  // ---- Header -------------------------------------------------------------
  static const double headerTop = 64;
  static const double titleSize = 33;
  static const double streakHeight = 34;
  static const double streakWidth = 64;

  // ---- Week strip ---------------------------------------------------------
  static const double gapHeaderToWeek = 16;
  static const double weekLetterSize = 11.5;
  static const double weekLetterHeight = 16;
  static const double weekRingSize = 46;
  static const double weekRingStroke = 2.2;

  // ---- Standing line ------------------------------------------------------
  static const double gapWeekToStanding = 14;
  static const double standingSize = 14.5;

  // ---- The number ---------------------------------------------------------
  /// The whole point of the screen, so it gets the most room — but the rhythm
  /// around it stays tight. Dead space between sections reads as an unfinished
  /// screen, not as breathing room.
  static const double gapStandingToSteps = 18;
  static const double stepsSize = 74;
  static const double stepsUnitSize = 21;

  // ---- Stats --------------------------------------------------------------
  static const double gapStepsToStats = 14;
  static const double statsSize = 14.5;

  static const double gapStatsToNote = 14;
  static const double noteSize = 12.8;

  // ---- Chips --------------------------------------------------------------
  static const double gapNoteToChips = 24;
  static const double chipHeight = 46;
  static const double chipGap = 11;
  static const double chipTextSize = 15;

  // ---- Rank ---------------------------------------------------------------
  static const double gapChipsToRank = 24;
  static const double rankSize = 19.5;

  static const double gapRankToPodium = 24;

  /// Heights of the three medal blocks, first place tallest.
  static const double blockFirst = 96;
  static const double blockSecond = 64;
  static const double blockThird = 50;

  /// Room above a block for its avatar, name and score.
  static const double contenderHeight = 112;

  /// Gap between a contender's score and the top of their block. Small on
  /// purpose — the two belong together, and any more reads as two separate
  /// things stacked.
  static const double podiumPointsGap = 5;

  static const double gapPodiumToList = 20;

  // ---- Rank list ----------------------------------------------------------
  static const double rowHeight = 62;
  static const double rowGap = 8;
  static const double rowRadius = 20;

  /// Clears the home indicator now that no bar sits on it.
  static const double listBottomPadding = 44;

  // ---- Motion -------------------------------------------------------------
  /// How long the mark takes to draw itself on the splash. Long enough to read
  /// as a hand moving, short enough that a returning user is not held up.
  static const Duration draw = Duration(milliseconds: 1500);

  static const Interval wordmarkIn =
      Interval(0.62, 0.92, curve: Curves.easeOutCubic);

  static const Duration hold = Duration(milliseconds: 620);

  /// The home screen's entrance. One controller, each section takes a slice —
  /// which is what makes the page arrive as a single considered move rather
  /// than as eleven widgets each doing their own thing.
  static const Duration entrance = Duration(milliseconds: 1650);

  static const Interval headerIn = Interval(0, 0.22, curve: Curves.easeOutCubic);
  static const Interval weekIn = Interval(0.06, 0.40, curve: Curves.easeOutCubic);
  static const Interval standingIn =
      Interval(0.12, 0.34, curve: Curves.easeOutCubic);

  /// The number counts up rather than appearing. It is the one figure the user
  /// opened the app for, so it earns the extra beat.
  static const Interval countIn =
      Interval(0.14, 0.72, curve: Curves.easeOutExpo);

  static const Interval statsIn = Interval(0.30, 0.52, curve: Curves.easeOutCubic);
  static const Interval chipsIn = Interval(0.36, 0.58, curve: Curves.easeOutCubic);
  static const Interval rankIn = Interval(0.42, 0.62, curve: Curves.easeOutCubic);

  /// Blocks grow out of the floor, third then second then first, so the eye is
  /// walked up to the winner instead of being shown the answer.
  static const List<Interval> blockIn = <Interval>[
    Interval(0.50, 0.80, curve: Curves.easeOutBack), // second
    Interval(0.58, 0.92, curve: Curves.easeOutBack), // first
    Interval(0.46, 0.76, curve: Curves.easeOutBack), // third
  ];

  /// Each contender lands just after their own block has.
  static const List<Interval> contenderIn = <Interval>[
    Interval(0.62, 0.86, curve: Curves.easeOutBack),
    Interval(0.70, 0.98, curve: Curves.easeOutBack),
    Interval(0.58, 0.82, curve: Curves.easeOutBack),
  ];

  /// Rows 4..10 stagger in after the podium has settled.
  static const double rowsStart = 0.66;
  static const double rowStagger = 0.035;
  static const double rowSpan = 0.22;

  /// The week rings sweep their arcs rather than appearing at full length.
  static const double ringStagger = 0.035;
}
