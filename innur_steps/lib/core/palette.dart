import 'package:flutter/widgets.dart';

/// Sampled off the reference.
///
/// The screen is not flat black: it is a very dark near-black at the top that
/// warms into a deep navy at the bottom, which is what stops a dark UI from
/// looking like a switched-off panel.
class Ground {
  const Ground._();

  static const Color top = Color(0xFF08070C);
  static const Color upper = Color(0xFF0A0A12);
  static const Color mid = Color(0xFF121527);
  static const Color low = Color(0xFF16293F);
  static const Color bottom = Color(0xFF1B3A5E);

  static const LinearGradient page = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[top, upper, mid, low, bottom],
    stops: <double>[0, 0.34, 0.62, 0.83, 1],
  );

  /// Splash runs the same ramp, just further into the blue at the bottom.
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF060609), Color(0xFF0A0B14), Color(0xFF15304E)],
    stops: <double>[0, 0.45, 1],
  );
}

class Paper {
  const Paper._();

  static const Color primary = Color(0xFFF6F7F9);
  static const Color secondary = Color(0xFF9AA3B2);
  static const Color muted = Color(0xFF5C6675);

  /// Fills for the pills and cards that sit on the page.
  static const Color surface = Color(0xFF161A24);
  static const Color surfaceRaised = Color(0xFF232733);
  static const Color selected = Color(0xFFF2F3F5);
  static const Color onSelected = Color(0xFF12151C);

  static const Color rowEdge = Color(0x14FFFFFF);

  static const Color block = Color(0xFF1A2238);
  static const Color blockEdge = Color(0xFF2A3550);
}

class Accent {
  const Accent._();

  /// The ring progress and the active tab. A saturated indigo rather than a
  /// friendly blue — it has to hold up against a near-black ground.
  static const Color blue = Color(0xFF3D5AFE);
  static const Color blueSoft = Color(0xFF5C74FF);

  /// Days that are done with: present, but not competing with today.
  static const Color blueDim = Color(0xFF2B3FB8);

  static const Color flame = Color(0xFFE8502F);
  static const Color gold = Color(0xFFE8B33A);

  /// Live-data dot. Green reads as "connected" without a label.
  static const Color mint = Color(0xFF35C88A);
}

/// Gold, silver, bronze.
///
/// Each medal is a pair — a lit top and a body — because a flat fill at this
/// size reads as coloured card, not as metal. The ring is what goes round the
/// avatar, and is brighter than either so it survives against a photograph.
@immutable
class Medal {
  const Medal(this.top, this.body, this.ring, this.numeral);

  final Color top;
  final Color body;
  final Color ring;

  /// The big numeral on the block. Dark, so it sits *in* the metal.
  final Color numeral;

  static const Medal gold =
      Medal(Color(0xFFF6D272), Color(0xFFC8912A), Color(0xFFFFD766), Color(0xFF4A3407));
  static const Medal silver =
      Medal(Color(0xFFDCE6F2), Color(0xFF8C9AAC), Color(0xFFE6EFFA), Color(0xFF2C3542));
  static const Medal bronze =
      Medal(Color(0xFFEBA873), Color(0xFFA76733), Color(0xFFF2AE74), Color(0xFF43220B));

  /// Indexed by place, 1-based.
  static Medal forPlace(int place) => switch (place) {
        1 => gold,
        2 => silver,
        _ => bronze,
      };
}
