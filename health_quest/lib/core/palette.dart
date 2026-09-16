import 'package:flutter/widgets.dart';

class Night {
  Night._();

  static const Color voidBlack = Color(0xFF04050C);
  static const Color deep = Color(0xFF080A16);
  static const Color panel = Color(0xCC0B0D1C);
  static const Color panelEdge = Color(0x1AFFFFFF);
  static const Color panelEdgeLit = Color(0x33B79BFF);
  static const Color track = Color(0xFF171937);
  static const Color trackEdge = Color(0x14FFFFFF);
}

class Ink2 {
  Ink2._();

  static const Color bright = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFF2F2F7);
  static const Color secondary = Color(0xFFC9CEDD);
  static const Color muted = Color(0xFF8A90A6);
  static const Color faint = Color(0xFF5C6178);
}

class Spectrum {
  Spectrum._();

  static const Color violet = Color(0xFFC77DFF);
  static const Color violetDeep = Color(0xFF8B44F7);
  static const Color indigo = Color(0xFF5B4BE0);
  static const Color blue = Color(0xFF4D8DF6);
  static const Color blueDeep = Color(0xFF2B3ECB);
  static const Color cyan = Color(0xFF6FD3FF);

  static const LinearGradient headline = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Color(0xFFD98BFF),
      Color(0xFF9A6CFF),
      Color(0xFF4D8DF6),
    ],
    stops: <double>[0.0, 0.46, 1.0],
  );

  static const LinearGradient action = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Color(0xFFA855F7),
      Color(0xFF7C4DEE),
      Color(0xFF3B6BF0),
    ],
    stops: <double>[0.0, 0.5, 1.0],
  );

  static const LinearGradient xp = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFFC77DFF), Color(0xFF6FD3FF)],
  );
}

class Quests {
  Quests._();

  static const Color green = Color(0xFF8BE24F);
  static const Color greenBright = Color(0xFFA9EC5E);
  static const Color greenDeep = Color(0xFF5FB52E);
  static const Color blue = Color(0xFF3B9EFF);
  static const Color blueBright = Color(0xFF7CC4FF);
  static const Color purple = Color(0xFFA855F7);
  static const Color purpleBright = Color(0xFFC98BFF);
  static const Color gold = Color(0xFFF5B027);
  static const Color goldBright = Color(0xFFFFD166);
  static const Color rose = Color(0xFFF85877);
  static const Color locked = Color(0xFF7A8296);

  static const Color page = Color(0xFF05060C);
  static const Color card = Color(0xFF0E1018);
  static const Color cardRaised = Color(0xFF141726);
  static const Color cardEdge = Color(0x14FFFFFF);
  static const Color divider = Color(0x1AFFFFFF);

  static const LinearGradient keepGoing = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF9BE84F), Color(0xFF7FD93C)],
  );
}

@immutable
class StatTone {
  const StatTone({required this.core, required this.tip, required this.glow});

  final Color core;
  final Color tip;
  final Color glow;

  static const StatTone physical = StatTone(
    core: Color(0xFFF85877),
    tip: Color(0xFFFF9AAE),
    glow: Color(0x66F85877),
  );
  static const StatTone mental = StatTone(
    core: Color(0xFFC44DFF),
    tip: Color(0xFFE2A6FF),
    glow: Color(0x66C44DFF),
  );
  static const StatTone energy = StatTone(
    core: Color(0xFFF9BE3A),
    tip: Color(0xFFFFE08A),
    glow: Color(0x66F9BE3A),
  );
  static const StatTone hydration = StatTone(
    core: Color(0xFF39A3F8),
    tip: Color(0xFF9AD4FF),
    glow: Color(0x6639A3F8),
  );
}
