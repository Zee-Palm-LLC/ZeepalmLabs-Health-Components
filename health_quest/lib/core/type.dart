import 'package:flutter/widgets.dart';

import 'palette.dart';

class T {
  T._();

  static const String display = 'Saira';
  static const String body = 'Inter';

  static TextStyle disp(
    double size, {
    double weight = 800,
    double width = 100,
    Color color = Ink2.bright,
    double height = 1.0,
    double letterSpacing = 0,
    bool italic = true,
  }) =>
      TextStyle(
        fontFamily: display,
        fontSize: size,
        height: height,
        color: color,
        letterSpacing: letterSpacing,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        fontVariations: <FontVariation>[
          FontVariation('wght', weight),
          FontVariation('wdth', width),
        ],
      );

  static TextStyle text(
    double size, {
    double weight = 500,
    Color color = Ink2.secondary,
    double height = 1.3,
    double letterSpacing = 0,
  }) =>
      TextStyle(
        fontFamily: body,
        fontSize: size,
        height: height,
        color: color,
        letterSpacing: letterSpacing,
        fontVariations: <FontVariation>[FontVariation('wght', weight)],
      );

  static TextStyle get levelUp =>
      disp(30, weight: 900, letterSpacing: 1.6, height: 1.0);
  static TextStyle get yourHealth =>
      disp(40, weight: 900, letterSpacing: 0.4, height: 1.0);
  static TextStyle get sub => text(15.5,
      weight: 400, color: Ink2.secondary, height: 1.22);
  static TextStyle get subAccent => text(15.5,
      weight: 700, color: Spectrum.blue, height: 1.22);
  static TextStyle get statLabel => disp(12.5,
      weight: 800, color: Ink2.primary, letterSpacing: 0.9, italic: false);
  static TextStyle get statLevel =>
      text(11, weight: 500, color: Ink2.secondary);
  static TextStyle get lvlWord => disp(11,
      weight: 800, color: Ink2.secondary, letterSpacing: 1.4, italic: false);
  static TextStyle get lvlNumber =>
      disp(24, weight: 900, color: Ink2.bright, italic: false);
  static TextStyle get xpCount =>
      text(15, weight: 600, color: Ink2.primary);
  static TextStyle get button => disp(19,
      weight: 900, color: Ink2.bright, letterSpacing: 1.4);
  static TextStyle get footer =>
      text(13, weight: 400, color: Ink2.muted);

  static TextStyle get greeting => disp(12.5,
      weight: 700, color: Ink2.secondary, letterSpacing: 1.3, italic: false);
  static TextStyle get playerName =>
      disp(25, weight: 900, color: Ink2.bright, italic: false);
  static TextStyle get playerMeta => disp(11,
      weight: 700, color: Ink2.secondary, letterSpacing: 0.3, italic: false);
  static TextStyle get sectionTitle => disp(15,
      weight: 800, color: Ink2.bright, letterSpacing: 1.1, italic: false);
  static TextStyle get sectionMeta =>
      text(12.5, weight: 500, color: Ink2.muted);
  static TextStyle get cardLabel => disp(12.5,
      weight: 700, color: Ink2.secondary, letterSpacing: 1.0, italic: false);
  static TextStyle get bigScore =>
      disp(46, weight: 900, color: Ink2.bright, italic: false, height: 1.0);
  static TextStyle get scoreOutOf =>
      text(13, weight: 500, color: Ink2.muted);
  static TextStyle get streakValue =>
      disp(19, weight: 900, italic: false, color: Quests.gold);
  static TextStyle get multiplier =>
      disp(28, weight: 900, italic: false, color: Quests.blue, height: 1.0);
  static TextStyle get questTitle =>
      text(15, weight: 600, color: Ink2.bright);
  static TextStyle get questBlurb =>
      text(12.5, weight: 400, color: Ink2.muted);
  static TextStyle get questXp => text(13.5, weight: 700);
  static TextStyle get questPercent => text(12.5, weight: 700);
  static TextStyle get navLabel => disp(10.5,
      weight: 700, letterSpacing: 0.9, italic: false, color: Ink2.muted);

  static TextStyle get questKicker => disp(12.5,
      weight: 800, color: Ink2.secondary, letterSpacing: 2.2, italic: false);
  static TextStyle get questHeadline => disp(32,
      weight: 900, color: Ink2.bright, letterSpacing: 0.4, height: 1.0);
  static TextStyle get questCheer =>
      text(15, weight: 400, color: Ink2.secondary);
  static TextStyle get bigCount =>
      disp(46, weight: 900, color: Ink2.bright, italic: false, height: 1.0);
  static TextStyle get bigCountOf =>
      disp(19, weight: 600, color: Ink2.secondary, italic: false);
  static TextStyle get bigCountUnit => disp(12.5,
      weight: 700, color: Ink2.muted, letterSpacing: 1.8, italic: false);
  static TextStyle get completed => disp(14,
      weight: 800, letterSpacing: 1.2, italic: false, color: Quests.green);
  static TextStyle get rewardLabel => disp(11.5,
      weight: 700, color: Ink2.muted, letterSpacing: 1.2, italic: false);
  static TextStyle get rewardValue =>
      disp(20, weight: 900, italic: false, color: Quests.gold);
  static TextStyle get rewardName =>
      text(15, weight: 600, color: Ink2.bright);
  static TextStyle get milestoneValue =>
      text(13, weight: 700, color: Ink2.bright);
  static TextStyle get milestoneUnit =>
      text(11.5, weight: 400, color: Ink2.muted);
  static TextStyle get ctaDark => disp(19,
      weight: 900, color: Color(0xFF0B1405), letterSpacing: 1.3);
}
