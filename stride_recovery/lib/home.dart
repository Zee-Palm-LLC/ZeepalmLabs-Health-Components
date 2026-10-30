import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'figure.dart';
import 'painters.dart';
import 'theme.dart';

/// One day of the streak strip.
class Day {
  const Day(this.letter, this.date, this.steps, {this.future = false});
  final String letter;
  final int date, steps;
  final bool future;
}

const goal = 8000;
const week = [
  Day('M', 5, 9820),
  Day('T', 6, 6140),
  Day('W', 7, 5310),
  Day('T', 8, 4985),
  Day('F', 9, 8460),
  Day('S', 10, 19538),
  Day('S', 11, 0, future: true),
];

// ── Timeline (seconds from launch) ──────────────────────────────────────────
const _drawA = 0.3, _drawB = 2.4;
const _moveA = 3.4, _moveB = 4.35;
const _homeA = 3.95;

// ── Layout on the 390 × 844 canvas ──────────────────────────────────────────
const _splashFigure = Rect.fromLTWH(45, 168, 300, 300 * 712 / 700);
const _homeFigure = Rect.fromLTWH(128, 68, 262, 262 * 712 / 700);
const _cardTop = 316.0;

/// Splash (the figure drawn line by line, then filled and lit) that flows
/// straight into the home screen: the figure flies up into the header and the
/// dashboard assembles around it.
class StrideApp extends StatefulWidget {
  const StrideApp({super.key});

  @override
  State<StrideApp> createState() => _StrideAppState();
}

class _StrideAppState extends State<StrideApp> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  Duration _origin = Duration.zero;
  double _t = 0;
  ui.Image? _body;

  int _selected = 5; // index into [week]
  int _tab = 0;
  double _fromSteps = 0, _toSteps = 19538, _switchAt = _homeA + 0.75, _switchDur = 1.6;
  double _tabAt = -10;
  int _prevTab = 0;

  @override
  void initState() {
    super.initState();
    _ticker.start();
    rootBundle.load('assets/images/body.png').then((d) async {
      final img = await decodeImageFromList(d.buffer.asUint8List());
      if (mounted) setState(() => _body = img);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration e) {
    if (_origin == Duration.zero) _origin = e;
    setState(() => _t = (e - _origin).inMicroseconds / 1e6);
  }

  void _replay() {
    HapticFeedback.lightImpact();
    setState(() {
      _origin = Duration.zero;
      _t = 0;
      _selected = 5;
      _fromSteps = 0;
      _toSteps = week[5].steps.toDouble();
      _switchAt = _homeA + 0.75;
      _switchDur = 1.6;
    });
  }

  double get _steps => _fromSteps + (_toSteps - _fromSteps) * win(_t, _switchAt, _switchAt + _switchDur, Curves.easeOutCubic);

  void _select(int i) {
    if (week[i].future || i == _selected || _t < _moveB) return;
    HapticFeedback.selectionClick();
    setState(() {
      _fromSteps = _steps;
      _toSteps = week[i].steps.toDouble();
      _switchAt = _t;
      _switchDur = 0.9;
      _selected = i;
    });
  }

  void _setTab(int i) {
    if (i == _tab) return;
    HapticFeedback.selectionClick();
    setState(() {
      _prevTab = _tab;
      _tab = i;
      _tabAt = _t;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final move = win(t, _moveA, _moveB, Curves.easeInOutCubic);
    final figRect = Rect.lerp(_splashFigure, _homeFigure, move)!;

    // Home entrance helper: fade + rise, staggered by [a].
    Widget rise(double a, Widget child, {double dy = 18, double dur = 0.6}) {
      final p = win(t, a, a + dur);
      if (p <= 0) return const SizedBox.shrink();
      return Opacity(
        opacity: p,
        child: Transform.translate(offset: Offset(0, (1 - p) * dy), child: child),
      );
    }

    return SizedBox(
      width: 390,
      height: 844,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(child: CustomPaint(painter: _Backdrop(t, move))),
            // ── Header ──
            Positioned(left: 24, top: 60, child: rise(_homeA, _greeting())),
            Positioned(
              left: 24,
              top: 136,
              child: rise(_homeA + 0.12, Text('Keep going, your body\nis getting stronger!', style: t14sub)),
            ),
            // ── Figure (splash drawing → header art) ──
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: FigurePainter(
                    rect: figRect,
                    img: _body,
                    draw: win(t, _drawA, _drawB, Curves.linear),
                    lines: 1 - win(t, 2.7, 3.5),
                    image: win(t, 2.0, 3.0, Curves.easeInOut),
                    hot: win(t, 2.6, 3.6, Curves.linear),
                    time: t,
                  ),
                ),
              ),
            ),
            Positioned(right: 20, top: 58, child: rise(_homeA + 0.2, _headerIcons(), dy: -10)),
            Positioned(left: 38, top: 214, child: _painChip(t)),
            // ── Splash wordmark ──
            ..._wordmark(t),
            // ── Dashboard card ──
            Positioned(
              left: 12,
              right: 12,
              top: _cardTop + (1 - win(t, _homeA + 0.05, _homeA + 0.85, Curves.easeOutCubic)) * 560,
              height: 444,
              child: _card(t),
            ),
            // ── Bottom navigation ──
            Positioned(left: 0, right: 0, bottom: -(1 - win(t, _homeA + 0.1, _homeA + 0.7)) * 90, height: 78, child: _nav(t)),
            Positioned(left: 0, right: 0, top: 0, height: 47, child: _statusBar(t)),
          ],
        ),
      ),
    );
  }

  static final t14sub = tx(14.5, color: C.sub, height: 1.45);

  Widget _greeting() => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: 'Good Morning,\n',
          style: tx(26, w: FontWeight.w700, height: 1.22, ls: -0.4),
        ),
        TextSpan(
          text: 'Zee Palm ',
          style: tx(26, w: FontWeight.w700, height: 1.22, ls: -0.4),
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _Wave(t: _t),
        ),
      ],
    ),
  );

  Widget _headerIcons() => Row(
    children: [
      SizedBox(
        width: 30,
        height: 30,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.rotate(
              angle: 0.18 * math.sin(_t * 9) * math.exp(-((_t - _homeA - 1.4) % 6) * 1.6),
              alignment: Alignment.topCenter,
              child: const Icon(Icons.notifications_none_rounded, size: 27, color: C.ink),
            ),
            Positioned(
              right: 3,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: C.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 14),
      GestureDetector(
        onTap: _replay,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3))],
          ),
          // The portrait is a wide studio shot: zoom in on the face.
          child: ClipOval(
            child: Transform.scale(
              scale: 1.9,
              alignment: const Alignment(0, -0.5),
              child: Image.asset('assets/images/avatar.png', fit: BoxFit.cover, filterQuality: FilterQuality.medium),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _painChip(double t) {
    final p = win(t, _homeA + 0.55, _homeA + 1.15, Curves.easeOutBack);
    if (p <= 0) return const SizedBox.shrink();
    final float = math.sin(t * 1.6) * 3;
    return Opacity(
      opacity: clamp01(p),
      child: Transform.translate(
        offset: Offset(-(1 - p) * 30, float),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 9, 16, 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: const [BoxShadow(color: Color(0x1A2F5D8C), blurRadius: 18, offset: Offset(0, 6))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: Color(0xFFE3F7EE), shape: BoxShape.circle),
                    child: Center(
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Shoulder Pain', style: tx(12.5, w: FontWeight.w600)),
                      const SizedBox(height: 1),
                      Text('improving', style: tx(11, color: C.sub)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _wordmark(double t) {
    final out = win(t, 3.25, 3.7);
    if (out >= 1) return const [];
    const word = 'Stride';
    return [
      Positioned(
        left: 0,
        right: 0,
        top: 500 - out * 30,
        child: Opacity(
          opacity: 1 - out,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < word.length; i++)
                    Builder(
                      builder: (_) {
                        final p = win(t, 1.45 + i * 0.09, 1.95 + i * 0.09, Curves.easeOutBack);
                        return Opacity(
                          opacity: clamp01(p),
                          child: Transform.translate(
                            offset: Offset(0, (1 - p) * 22),
                            child: Text(word[i], style: tx(42, w: FontWeight.w800, ls: -1.2, height: 1)),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: win(t, 2.15, 2.75),
                child: Text(
                  'RECOVER  ·  MOVE  ·  THRIVE',
                  style: tx(11.5, color: C.sub, w: FontWeight.w600, ls: 2.6),
                ),
              ),
              const SizedBox(height: 26),
              // Progress pill that fills while the figure is drawn.
              Opacity(
                opacity: win(t, 0.4, 0.9),
                child: Container(
                  width: 120,
                  height: 4,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(color: C.track, borderRadius: BorderRadius.circular(2)),
                  child: FractionallySizedBox(
                    widthFactor: win(t, 0.3, 3.1, Curves.easeInOut),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [C.sky, C.blue]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _card(double t) {
    final day = week[_selected];
    final steps = _steps;
    final pct = (steps / goal * 100).round();
    final passed = steps >= goal;
    final gaugeIn = win(t, _homeA + 0.75, _homeA + 2.1, Curves.easeOutCubic);
    final idle = t - (_homeA + 2.4);

    String fmt(num n) {
      final s = n.round().toString();
      return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    }

    Widget fade(double a, Widget child) {
      final p = win(t, a, a + 0.5);
      return Opacity(
        opacity: p,
        child: Transform.translate(offset: Offset(0, (1 - p) * 10), child: child),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x142F5D8C), blurRadius: 30, offset: Offset(0, -4)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Date + actions.
          Positioned(
            left: 20,
            top: 16,
            child: fade(
              _homeA + 0.35,
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: a.drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero)),
                        child: c,
                      ),
                    ),
                    child: Text(
                      day.date.toString().padLeft(2, '0'),
                      key: ValueKey(day.date),
                      style: tx(34, w: FontWeight.w800, ls: -1, height: 1.1),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text('Jan', style: tx(19, w: FontWeight.w600)),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: C.ink),
                ],
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 24,
            child: fade(
              _homeA + 0.45,
              const Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 22, color: C.ink),
                  SizedBox(width: 16),
                  Icon(Icons.groups_rounded, size: 24, color: C.ink),
                ],
              ),
            ),
          ),
          // Streak strip.
          for (var i = 0; i < week.length; i++) _dayColumn(i, t),
          // Gauge.
          Positioned(
            left: 33,
            top: 170,
            width: 300,
            height: 200,
            child: CustomPaint(
              painter: GaugePainter(value: (steps / goal).clamp(0.0, 1.0) * gaugeIn, shine: idle > 0 ? (idle % 4.5) / 1.3 : 0),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 238,
            child: Opacity(
              opacity: win(t, _homeA + 0.8, _homeA + 1.3),
              child: Column(
                children: [
                  Text(
                    fmt(steps),
                    style: tx(
                      40,
                      w: FontWeight.w700,
                      ls: -1.4,
                      height: 1.1,
                    ).copyWith(fontFeatures: const [ui.FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(height: 2),
                  Text('steps', style: tx(13.5, color: C.sub)),
                  const SizedBox(height: 8),
                  Text('Daily goal: 8,000', style: tx(13.5, w: FontWeight.w600)),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      passed ? 'Goal passed · $pct%' : '${fmt(goal - steps)} to go · $pct%',
                      key: ValueKey(passed),
                      style: tx(13, w: FontWeight.w600, color: passed ? C.amber : C.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 40,
            top: 356,
            child: fade(_homeA + 1.0, Text('0', style: tx(11.5, color: C.hint))),
          ),
          Positioned(
            right: 26,
            top: 356,
            child: fade(_homeA + 1.0, Text('8,000', style: tx(11.5, color: C.hint))),
          ),
          // Stat pills.
          Positioned(
            left: 0,
            right: 0,
            top: 386,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                fade(_homeA + 1.3, _pill(Icons.straighten_rounded, '${(steps * 0.000668).toStringAsFixed(2)} km')),
                const SizedBox(width: 10),
                fade(_homeA + 1.4, _pill(Icons.local_fire_department_rounded, '${(steps * 0.04136).round()} kcal')),
                const SizedBox(width: 10),
                fade(_homeA + 1.5, _pill(Icons.ios_share_rounded, 'Share', iconColor: C.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayColumn(int i, double t) {
    final d = week[i];
    final x = 14 + i * 48.0;
    final sel = i == _selected;
    final p = win(t, _homeA + 0.45 + i * 0.07, _homeA + 0.95 + i * 0.07, Curves.easeOutBack);
    final lit = d.steps >= goal ? win(t, _homeA + 0.9 + i * 0.09, _homeA + 1.3 + i * 0.09) : 0.0;
    return Positioned(
      left: x,
      top: 74,
      width: 48,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(i),
        child: Opacity(
          opacity: clamp01(p) * (d.future ? 0.6 : 1),
          child: Transform.scale(
            scale: 0.6 + 0.4 * p,
            child: Column(
              children: [
                Text(
                  d.letter,
                  style: tx(12, color: C.hint, w: FontWeight.w500),
                ),
                const SizedBox(height: 7),
                AnimatedScale(
                  scale: sel ? 1.12 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: SizedBox(
                    width: 24,
                    height: 30,
                    child: CustomPaint(
                      painter: FlamePainter(lit: lit, flicker: t + i),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  d.date.toString().padLeft(2, '0'),
                  style: tx(12, color: sel ? C.ink : C.hint, w: sel ? FontWeight.w700 : FontWeight.w500),
                ),
                const SizedBox(height: 5),
                // Scale rather than size: the overshoot of easeOutBack would
                // make a shrinking box's constraints negative.
                AnimatedScale(
                  duration: const Duration(milliseconds: 280),
                  curve: sel ? Curves.easeOutBack : Curves.easeIn,
                  scale: sel ? 1 : 0,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(color: C.orange, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label, {Color iconColor = C.blue}) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.line),
      boxShadow: const [BoxShadow(color: Color(0x0D2F5D8C), blurRadius: 10, offset: Offset(0, 3))],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: iconColor),
        const SizedBox(width: 7),
        Text(label, style: tx(13, w: FontWeight.w600)),
      ],
    ),
  );

  Widget _nav(double t) {
    const items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.account_tree_rounded, Icons.account_tree_outlined, 'Exercises'),
      (Icons.insights_rounded, Icons.insights_outlined, 'Progress'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];
    final k = win(t, _tabAt, _tabAt + 0.45, Curves.easeOutBack);
    final pillX = (_prevTab + (_tab - _prevTab) * k) * (390 / 4);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: C.line)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: pillX + 390 / 8 - 22,
            top: 0,
            child: Container(
              width: 44,
              height: 3,
              decoration: BoxDecoration(color: C.blue, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _setTab(i),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        children: [
                          AnimatedScale(
                            scale: i == _tab ? 1.1 : 1,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(i == _tab ? items[i].$1 : items[i].$2, size: 24, color: i == _tab ? C.blue : C.sub),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[i].$3,
                            style: tx(11, color: i == _tab ? C.blue : C.sub, w: i == _tab ? FontWeight.w600 : FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            bottom: 8,
            left: (390 - 134) / 2,
            child: Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(color: C.ink, borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBar(double t) => Padding(
    padding: const EdgeInsets.fromLTRB(34, 16, 26, 0),
    child: Row(
      children: [
        Text('9:41', style: tx(16, w: FontWeight.w600)),
        const Spacer(),
        const Icon(Icons.signal_cellular_alt_rounded, size: 18, color: C.ink),
        const SizedBox(width: 4),
        const Icon(Icons.wifi_rounded, size: 18, color: C.ink),
        const SizedBox(width: 4),
        const RotatedBox(quarterTurns: 1, child: Icon(Icons.battery_full_rounded, size: 20, color: C.ink)),
      ],
    ),
  );
}

/// Waving hand: a couple of quick waves after the greeting lands, then rest.
class _Wave extends StatelessWidget {
  const _Wave({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    final local = t - (_homeA + 0.6);
    final a = local > 0 && local < 1.6 ? math.sin(local * 14) * 0.35 * (1 - local / 1.6) : 0.0;
    return Transform.rotate(
      angle: a,
      alignment: const Alignment(0.4, 0.8),
      child: const Text('👋', style: TextStyle(fontSize: 24, height: 1.1, fontFamilyFallback: ['Segoe UI Emoji', 'Apple Color Emoji', 'Noto Color Emoji'])),
    );
  }
}

/// Page backdrop: icy gradient with a soft glow that sits behind the figure
/// during the splash and drifts up with it.
class _Backdrop extends CustomPainter {
  _Backdrop(this.t, this.move);
  final double t, move;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.bgTop, C.bgBottom],
        ).createShader(rect),
    );
    final c = Offset.lerp(const Offset(195, 330), const Offset(270, 180), move)!;
    final r = 210 - 40 * move + 8 * math.sin(t * 1.3);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFBFE3FF).withValues(alpha: 0.75), const Color(0xFFBFE3FF).withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_Backdrop old) => true;
}
