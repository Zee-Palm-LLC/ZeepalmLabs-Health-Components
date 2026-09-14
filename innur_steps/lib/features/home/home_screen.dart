import 'package:flutter/widgets.dart';

import '../../core/design.dart';
import '../../core/palette.dart';
import '../../data/today.dart';
import 'widgets/flame.dart';
import 'widgets/rank_podium.dart';
import 'widgets/rank_row.dart';
import 'widgets/week_strip.dart';

/// The today screen.
///
/// Laid out at a fixed 440 width and uniformly scaled, so every measured offset
/// holds. Vertically it flows and scrolls — the leaderboard runs to tenth
/// place, which is past the bottom of any phone.
///
/// One controller drives the whole entrance and each section reads its own
/// slice of it, which is what makes the page arrive as a single considered
/// move rather than as eleven widgets each doing their own thing.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.data = TodayData.sample});

  final TodayData data;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in;
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: D.entrance)..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: Ground.page),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: D.w,
            height: D.h,
            child: AnimatedBuilder(
              animation: _in,
              builder: (context, _) => _page(_in.value),
            ),
          ),
        ),
      ),
    );
  }

  Widget _page(double t) {
    final data = widget.data;
    final ranked = data.ranked;

    return ListView(
      padding: const EdgeInsets.only(
        top: D.headerTop,
        bottom: D.listBottomPadding,
      ),
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        _rise(D.headerIn.transform(t), _header()),
        const SizedBox(height: D.gapHeaderToWeek),

        WeekStrip(days: data.week, t: D.weekIn.transform(t)),
        const SizedBox(height: D.gapWeekToStanding),

        _rise(D.standingIn.transform(t), _standing()),
        const SizedBox(height: D.gapStandingToSteps),

        _steps(D.countIn.transform(t)),
        const SizedBox(height: D.gapStepsToStats),

        _rise(D.statsIn.transform(t), _stats()),
        const SizedBox(height: D.gapStatsToNote),
        _rise(D.statsIn.transform(t), _note()),
        const SizedBox(height: D.gapNoteToChips),

        _rise(D.chipsIn.transform(t), _chips(), gutter: false),
        const SizedBox(height: D.gapChipsToRank),

        _rise(D.rankIn.transform(t), _rankHeader()),
        const SizedBox(height: D.gapRankToPodium),

        RankPodium(podium: data.podium, t: t),
        const SizedBox(height: D.gapPodiumToList),

        // Fourth place down. The podium already showed the top three, so the
        // list starts at four rather than repeating them.
        for (var i = 3; i < ranked.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: D.gutter),
            child: RankRow(
              place: i + 1,
              racer: ranked[i],
              t: _rowProgress(t, i - 3),
            ),
          ),
      ],
    );
  }

  /// Where row [index] is in its own slice of the entrance.
  double _rowProgress(double t, int index) {
    final start = D.rowsStart + index * D.rowStagger;
    return ((t - start) / D.rowSpan).clamp(0.0, 1.0);
  }

  /// The standard entrance: fade up a few units. Used by everything that does
  /// not have a more specific move of its own.
  Widget _rise(double t, Widget child, {bool gutter = true}) {
    final settled = t.clamp(0.0, 1.0);
    final body = gutter
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: D.gutter),
            child: child,
          )
        : child;

    if (settled >= 1) return body;
    return Opacity(
      opacity: settled,
      child: Transform.translate(
        offset: Offset(0, (1 - settled) * 16),
        child: body,
      ),
    );
  }

  // ---- Header ---------------------------------------------------------

  Widget _header() => Row(
        children: <Widget>[
          const Text(
            'Today',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: D.titleSize,
              height: 1.1,
              letterSpacing: -0.8,
              color: Paper.primary,
              fontVariations: <FontVariation>[FontVariation('wght', 700)],
            ),
          ),
          const SizedBox(width: 7),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: CustomPaint(size: Size(11, 18), painter: _SortGlyph()),
          ),
          const Spacer(),
          _StreakPill(count: widget.data.streak),
        ],
      );

  Widget _standing() => Text.rich(
        TextSpan(
          children: <InlineSpan>[
            const TextSpan(text: "You're "),
            TextSpan(
              text: '#${widget.data.standing}',
              style: const TextStyle(
                color: Paper.primary,
                fontVariations: <FontVariation>[FontVariation('wght', 600)],
              ),
            ),
            TextSpan(text: ' of ${widget.data.field}  '),
            const TextSpan(text: '•', style: TextStyle(color: Accent.blueSoft)),
          ],
        ),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: D.standingSize,
          height: 1.2,
          color: Paper.muted,
          fontVariations: <FontVariation>[FontVariation('wght', 500)],
        ),
      );

  // ---- The number -----------------------------------------------------

  /// Counts up rather than appearing. It is the one figure the user opened the
  /// app for, so it earns the extra beat — and a number that climbs says
  /// "today, so far" in a way a static one cannot.
  Widget _steps(double t) {
    final shown = (widget.data.steps * t.clamp(0.0, 1.0)).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: D.gutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          // Shrinks rather than overflows: a six-figure count, or a system
          // font wider than Inter, would otherwise run off the edge.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                grouped(shown),
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: D.stepsSize,
                  height: 1.05,
                  // Tight: at this size default tracking opens the number up
                  // into separate digits.
                  letterSpacing: -3.2,
                  color: Paper.primary,
                  fontVariations: <FontVariation>[FontVariation('wght', 700)],
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              'steps',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: D.stepsUnitSize,
                height: 1.1,
                letterSpacing: -0.3,
                color: Paper.secondary,
                fontVariations: <FontVariation>[FontVariation('wght', 500)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats() => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            _Stat(
              glyph: _StatGlyph.distance,
              label: '${widget.data.kilometres.toStringAsFixed(2)} km',
            ),
            const SizedBox(width: 16),
            _Stat(glyph: _StatGlyph.flame, label: '${widget.data.kcal} kcal'),
            const SizedBox(width: 16),
            _Stat(
              glyph: _StatGlyph.goal,
              label: '${widget.data.goalPercent}% of goal',
            ),
          ],
        ),
      );

  /// Where the numbers came from. On a health screen the user should never
  /// have to wonder whether what they are reading is live.
  Widget _note() => Row(
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Accent.mint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          // The sync string is server-shaped — a longer relative time or a
          // different source name must truncate, not overflow.
          Flexible(
            child: Text(
              widget.data.syncNote,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: D.noteSize,
                height: 1.3,
                color: Paper.muted,
                fontVariations: <FontVariation>[FontVariation('wght', 500)],
              ),
            ),
          ),
        ],
      );

  // ---- Filters --------------------------------------------------------

  /// Filters scroll rather than squeeze: with a fourth group, or a longer
  /// name, a fixed row would break outright.
  Widget _chips() => SizedBox(
        height: D.chipHeight,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: D.gutter),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            _Chip(
              label: 'Global',
              leading: const _Globe(),
              selected: _filter == 0,
              onTap: () => setState(() => _filter = 0),
            ),
            const SizedBox(width: D.chipGap),
            _Chip(
              label: 'My team',
              leading: const _Team(),
              selected: _filter == 1,
              onTap: () => setState(() => _filter = 1),
            ),
            const SizedBox(width: D.chipGap),
            const _PlusChip(),
          ],
        ),
      );

  // ---- Rank -----------------------------------------------------------

  Widget _rankHeader() => Row(
        children: <Widget>[
          const Text(
            "Today's rank",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: D.rankSize,
              height: 1.2,
              letterSpacing: -0.4,
              color: Paper.primary,
              fontVariations: <FontVariation>[FontVariation('wght', 700)],
            ),
          ),
          const SizedBox(width: 7),
          const CustomPaint(size: Size(7, 12), painter: _Chevron()),
          const Spacer(),
          const _Globe(size: 15),
          const SizedBox(width: 6),
          const Text(
            'Global',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.2,
              color: Paper.secondary,
              fontVariations: <FontVariation>[FontVariation('wght', 500)],
            ),
          ),
        ],
      );
}

// ---- Small parts --------------------------------------------------------

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: D.streakWidth,
      height: D.streakHeight,
      decoration: BoxDecoration(
        color: Paper.surface,
        borderRadius: BorderRadius.circular(D.streakHeight / 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const FlameMark(size: 13),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              height: 1.1,
              color: Paper.primary,
              fontVariations: <FontVariation>[FontVariation('wght', 600)],
            ),
          ),
        ],
      ),
    );
  }
}

enum _StatGlyph { distance, flame, goal }

class _Stat extends StatelessWidget {
  const _Stat({required this.glyph, required this.label});

  final _StatGlyph glyph;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CustomPaint(size: const Size.square(14), painter: _StatIcon(glyph)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: D.statsSize,
            height: 1.2,
            color: Paper.secondary,
            fontVariations: <FontVariation>[FontVariation('wght', 500)],
          ),
        ),
      ],
    );
  }
}

class _StatIcon extends CustomPainter {
  const _StatIcon(this.glyph);

  final _StatGlyph glyph;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Paper.secondary
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case _StatGlyph.distance:
        // A stride: two short marks and the line between them.
        canvas.drawLine(
            Offset(w * 0.18, h * 0.82), Offset(w * 0.82, h * 0.18), paint);
        canvas.drawLine(
            Offset(w * 0.18, h * 0.82), Offset(w * 0.40, h * 0.82), paint);
        canvas.drawLine(
            Offset(w * 0.82, h * 0.18), Offset(w * 0.82, h * 0.40), paint);
      case _StatGlyph.flame:
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.52, h * 0.06)
            ..cubicTo(w * 0.86, h * 0.32, w * 0.94, h * 0.52, w * 0.86, h * 0.68)
            ..cubicTo(w * 0.76, h * 0.94, w * 0.22, h * 0.96, w * 0.14, h * 0.68)
            ..cubicTo(w * 0.08, h * 0.50, w * 0.28, h * 0.42, w * 0.36, h * 0.55)
            ..cubicTo(w * 0.36, h * 0.30, w * 0.44, h * 0.18, w * 0.52, h * 0.06)
            ..close(),
          paint,
        );
      case _StatGlyph.goal:
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.42, paint);
        canvas.drawCircle(
          Offset(w / 2, h / 2),
          w * 0.13,
          paint..style = PaintingStyle.fill,
        );
    }
  }

  @override
  bool shouldRepaint(_StatIcon old) => old.glyph != glyph;
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.leading,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Widget leading;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        height: D.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: selected ? Paper.selected : Paper.surface,
          borderRadius: BorderRadius.circular(D.chipHeight / 2),
        ),
        child: Row(
          children: <Widget>[
            leading,
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: D.chipTextSize,
                height: 1.2,
                letterSpacing: -0.2,
                color: selected ? Paper.onSelected : Paper.primary,
                fontVariations: const <FontVariation>[
                  FontVariation('wght', 600),
                ],
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusChip extends StatelessWidget {
  const _PlusChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: D.chipHeight,
      height: D.chipHeight,
      decoration: const BoxDecoration(
        color: Paper.surfaceRaised,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CustomPaint(size: Size.square(16), painter: _Plus()),
      ),
    );
  }
}

class _Plus extends CustomPainter {
  const _Plus();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Paper.primary
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), paint);
    canvas.drawLine(Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(_Plus old) => false;
}

/// The sort control beside the title: a pair of small triangles.
class _SortGlyph extends CustomPainter {
  const _SortGlyph();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Paper.secondary
      ..isAntiAlias = true;

    canvas.drawPath(
      Path()
        ..moveTo(w / 2, 0)
        ..lineTo(w, h * 0.36)
        ..lineTo(0, h * 0.36)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w / 2, h)
        ..lineTo(w, h * 0.64)
        ..lineTo(0, h * 0.64)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SortGlyph old) => false;
}

class _Chevron extends CustomPainter {
  const _Chevron();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.1, 0)
        ..lineTo(size.width * 0.9, size.height / 2)
        ..lineTo(size.width * 0.1, size.height),
      Paint()
        ..color = Paper.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Chevron old) => false;
}

/// A globe, for the "everyone" leaderboard.
class _Globe extends StatelessWidget {
  const _Globe({this.size = 19});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _GlobeArt());
}

class _GlobeArt extends CustomPainter {
  const _GlobeArt();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF2B6FD6));

    // One meridian and the equator. At fifteen units a real coastline would
    // just be mud; two lines is all it takes to read as a globe.
    final line = Paint()
      ..color = const Color(0xFF9BD6FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..isAntiAlias = true;
    canvas.drawLine(Offset(r * 0.14, r), Offset(r * 1.86, r), line);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 0.9, height: r * 1.82),
      line,
    );
  }

  @override
  bool shouldRepaint(_GlobeArt old) => false;
}

/// Stand-in badge for a named group.
class _Team extends StatelessWidget {
  const _Team();

  static const double size = 19;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF7A5AE8), Color(0xFF4A7BE8)],
          ),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
      );
}
