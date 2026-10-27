import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../home.dart';
import '../layout.dart';
import '../mood.dart';
import '../widgets/phone_frame.dart';

/// Side effects the reel asks the host for (sound effects, end of take).
class ReelHooks {
  const ReelHooks({required this.sfx, required this.onDone});
  final void Function(String kind) sfx;
  final VoidCallback onDone;
}

class ReelController {
  VoidCallback? onStart;
  bool started = false;

  void start() {
    if (started) return;
    started = true;
    onStart?.call();
  }
}

class ReelApp extends StatelessWidget {
  const ReelApp({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lull Reel',
      home: Scaffold(backgroundColor: Colors.black, body: FittedBox(child: child)),
    );
  }
}

// ── Script ────────────────────────────────────────────────────────────────

const reelLength = 24.0;

/// Stage is 1080 × 1920. The phone (412 × 866 with bezel) is scaled 1.48×.
const _k = 1.48;
const _phoneW = 412 * _k;
const _phoneH = 866 * _k;
const _phoneLeft = (1080 - _phoneW) / 2;
const _phoneTop = 400.0;

/// Finger keyframes in phone-screen design points: (time, x, y, pressed).
const _keys = <(double, double, double, bool)>[
  (2.2, 300, 820, false),
  (2.75, 195, 700, false),
  (2.85, 195, 700, true),
  (3.0, 195, 700, false),
  (3.6, 195, 700, false),
  (4.15, 231, 474, false),
  (4.25, 231, 474, true),
  (4.42, 231, 474, false),
  (5.55, 231, 474, false),
  (5.85, 213, 474, false),
  (5.9, 213, 474, true),
  (6.07, 213, 474, false),
  (7.2, 213, 474, false),
  (7.6, 195, 474, false),
  (7.7, 195, 474, true),
  (7.85, 195, 474, true),
  (9.6, 159, 474, true),
  (9.75, 159, 474, false),
  (10.4, 175, 560, false),
  (11.5, 110, 610, false),
  (11.75, 110, 610, true),
  (12.15, 290, 610, true),
  (12.2, 290, 610, false),
  (12.85, 110, 610, false),
  (13.05, 110, 610, true),
  (13.45, 290, 610, true),
  (13.5, 290, 610, false),
  (14.15, 110, 610, false),
  (14.35, 110, 610, true),
  (14.75, 290, 610, true),
  (14.8, 290, 610, false),
  (15.45, 290, 610, false),
  (15.9, 231, 474, false),
  (15.95, 231, 474, true),
  (16.12, 231, 474, false),
  (16.9, 231, 474, false),
  (17.45, 195, 700, false),
  (17.5, 195, 700, true),
  (17.65, 195, 700, false),
  (17.95, 195, 700, false),
  (18.0, 195, 700, true),
  (18.15, 195, 700, false),
  (18.7, 195, 700, false),
  (19.2, 159, 787, false),
  (19.25, 159, 787, true),
  (19.4, 159, 787, false),
  (19.85, 252, 787, false),
  (19.9, 252, 787, true),
  (20.05, 252, 787, false),
  (20.5, 67, 787, false),
  (20.55, 67, 787, true),
  (20.7, 67, 787, false),
  (21.2, 120, 860, false),
];

const _fingerShown = [(2.2, 10.5), (11.4, 21.1)];

typedef _Tag = ({double start, double end, IconData icon, String word, String sub});

const _tags = <_Tag>[
  (start: 2.3, end: 3.6, icon: Icons.touch_app_rounded, word: 'POKE', sub: 'Say hi to your mood buddy'),
  (start: 3.7, end: 7.25, icon: Icons.ads_click_rounded, word: 'TAP', sub: 'Flip the switch, shift the mood'),
  (start: 7.3, end: 11.2, icon: Icons.pan_tool_alt_rounded, word: 'DRAG', sub: 'Slide through every mood, live'),
  (start: 11.3, end: 15.4, icon: Icons.swipe_rounded, word: 'SWIPE', sub: 'Anywhere on the screen'),
  (start: 15.5, end: 16.85, icon: Icons.ads_click_rounded, word: 'TAP', sub: 'Back to full energy'),
  (start: 16.9, end: 18.6, icon: Icons.touch_app_rounded, word: 'POKE', sub: 'Yes, it giggles'),
  (start: 18.65, end: 21.05, icon: Icons.tab_rounded, word: 'TABS', sub: 'Glassy nav with a springy pill'),
];

const _moodNames = {
  Mood.sleepy: 'Sleepy',
  Mood.low: 'Low',
  Mood.calm: 'Calm',
  Mood.stressed: 'Stressed',
  Mood.radiant: 'Radiant',
};

double _ease(double x) => Curves.easeInOutCubic.transform(x.clamp(0.0, 1.0));
double _win(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

class LullReel extends StatefulWidget {
  const LullReel({super.key, required this.controller, required this.hooks});
  final ReelController controller;
  final ReelHooks hooks;

  @override
  State<LullReel> createState() => _LullReelState();
}

class _LullReelState extends State<LullReel> with SingleTickerProviderStateMixin {
  final _home = GlobalKey<LullHomeState>();
  late final Widget _phone = FittedBox(child: PhoneFrame(homeKey: _home));
  late final Ticker _ticker = createTicker(_tick);

  Duration? _origin;
  double _t = 0;
  int _nextEvent = 0;
  Mood? _dragMood;
  bool _done = false;
  final _trail = <(double, Offset)>[];
  final _presses = <(double, Offset)>[];
  bool _wasDown = false;

  late final List<(double, void Function())> _events = [
    (0.25, () => _sfx('chime')),
    (2.9, () => _poke()),
    (4.3, () => _tapSwitch()),
    (5.95, () => _tapSwitch()),
    (7.72, () {
      _sfx('tap');
      _dragMood = _homeState.mood;
    }),
    (9.75, () {
      _homeState.endDrag(0);
      _dragMood = null;
    }),
    (11.8, () => _sfx('whoosh')),
    (12.0, () => _homeState.step(1)),
    (13.1, () => _sfx('whoosh')),
    (13.3, () => _homeState.step(1)),
    (14.4, () => _sfx('whoosh')),
    (14.6, () => _homeState.step(1)),
    (15.97, () {
      _sfx('tap');
      _homeState.step(1);
    }),
    (17.52, () => _poke()),
    (18.02, () => _poke()),
    (19.3, () => _tab(1)),
    (19.95, () => _tab(2)),
    (20.6, () => _tab(0)),
    (21.4, () => _sfx('chime')),
  ];

  LullHomeState get _homeState => _home.currentState!;
  void _sfx(String kind) => widget.hooks.sfx(kind);

  void _poke() {
    _sfx('pop');
    _homeState.pokeOrb();
  }

  void _tapSwitch() {
    _sfx('tap');
    _homeState.tapSwitch();
  }

  void _tab(int i) {
    _sfx('tab');
    _homeState.selectTab(i);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.onStart = () => _ticker.start();
    if (widget.controller.started) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    _origin ??= elapsed;
    final t = (elapsed - _origin!).inMicroseconds / 1e6;

    while (_nextEvent < _events.length && _events[_nextEvent].$1 <= t) {
      _events[_nextEvent].$2();
      _nextEvent++;
    }
    if (t >= 7.85 && t <= 9.6 && _dragMood != null) {
      _homeState.dragSwitch(0.5 * (1 - _ease(_win(t, 7.85, 9.6))));
      if (_homeState.mood != _dragMood) {
        _dragMood = _homeState.mood;
        _sfx('tick');
      }
    }

    final f = _finger(t);
    if (f.down && f.pos != null) {
      _trail.add((t, f.pos!));
      if (!_wasDown) _presses.add((t, f.pos!));
    }
    _wasDown = f.down;
    _trail.removeWhere((e) => t - e.$1 > 0.28);
    _presses.removeWhere((e) => t - e.$1 > 0.7);

    if (t >= reelLength + 0.15 && !_done) {
      _done = true;
      widget.hooks.onDone();
    }
    setState(() => _t = t);
  }

  /// Maps a phone-screen design point to the 1080 × 1920 stage.
  static Offset _toStage(double x, double y) => Offset(_phoneLeft + (11 + x) * _k, _phoneTop + (11 + y) * _k);

  ({Offset? pos, bool down, double vis}) _finger(double t) {
    var vis = 0.0;
    for (final (a, b) in _fingerShown) {
      vis = max(vis, min(_win(t, a, a + 0.25), 1 - _win(t, b - 0.25, b)));
    }
    if (t < _keys.first.$1) return (pos: null, down: false, vis: 0);
    for (var i = 0; i < _keys.length - 1; i++) {
      final a = _keys[i], b = _keys[i + 1];
      if (t >= a.$1 && t < b.$1) {
        final e = _ease(_win(t, a.$1, b.$1));
        final p = Offset.lerp(_toStage(a.$2, a.$3), _toStage(b.$2, b.$3), e)!;
        return (pos: p, down: a.$4, vis: vis);
      }
    }
    final l = _keys.last;
    return (pos: _toStage(l.$2, l.$3), down: false, vis: vis);
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final v = _home.currentState?.visual ?? kMoods[Mood.radiant]!.visual;
    final mood = _home.currentState?.mood ?? Mood.radiant;

    final intro = Curves.easeOutCubic.transform(_win(t, 0.15, 1.45));
    final outro = _ease(_win(t, 21.15, 22.4));
    final phoneTransform = Matrix4.identity()
      ..setEntry(3, 2, 0.0011)
      ..translateByDouble(0.0, (1 - intro) * 300 + outro * 170, 0.0, 1.0)
      ..rotateX((1 - intro) * 0.42)
      ..scaleByDouble(1 - outro * 0.16, 1 - outro * 0.16, 1.0, 1.0);

    final finger = _finger(t);
    final chipVis = min(_win(t, 1.6, 2.1), 1 - _win(t, 20.9, 21.3));

    return SizedBox(
      width: 1080,
      height: 1920,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _Backdrop(v, t))),
          Positioned(
            left: _phoneLeft,
            top: _phoneTop,
            width: _phoneW,
            height: _phoneH,
            child: Transform(
              alignment: Alignment.center,
              transform: phoneTransform,
              child: Opacity(opacity: intro, child: _phone),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FingerPainter(
                  t: t,
                  pos: finger.pos,
                  down: finger.down,
                  vis: finger.vis,
                  trail: List.of(_trail),
                  presses: List.of(_presses),
                ),
              ),
            ),
          ),
          _intro(t, v),
          for (final tag in _tags)
            if (t >= tag.start && t <= tag.end) _tagCard(t, tag, v),
          Positioned(
            left: 0,
            right: 0,
            top: 1716,
            child: Opacity(opacity: chipVis, child: Center(child: _moodChip(mood, v))),
          ),
          _outro(t, v),
        ],
      ),
    );
  }

  Widget _intro(double t, MoodVisual v) {
    final a = min(_win(t, 0.1, 0.6), 1 - _win(t, 1.85, 2.25));
    if (a <= 0) return const SizedBox.shrink();
    final rise = (1 - Curves.easeOutCubic.transform(_win(t, 0.1, 0.8))) * 40;
    return Positioned(
      left: 0,
      right: 0,
      top: 168 + rise,
      child: Opacity(
        opacity: a,
        child: Column(
          children: [
            Text('Meet Lull', style: inter(104, FontWeight.w900, v.ink, ls: -3, height: 1)),
            const SizedBox(height: 18),
            Text('Your mood has a face now.', style: inter(40, FontWeight.w600, v.inkSoft, ls: -0.5)),
          ],
        ),
      ),
    );
  }

  Widget _tagCard(double t, _Tag tag, MoodVisual v) {
    final inP = _win(t, tag.start, tag.start + 0.38);
    final outP = _win(t, tag.end - 0.25, tag.end);
    final scale = 0.82 + 0.18 * Curves.easeOutBack.transform(inP);
    final opacity = (Curves.easeOut.transform(inP) * (1 - outP)).clamp(0.0, 1.0);
    final dy = (1 - Curves.easeOutCubic.transform(inP)) * 36 - outP * 30;
    final bg = Color.lerp(v.skyTop, Colors.white, v.isDark ? 0.0 : 0.55)!;

    return Positioned(
      left: 0,
      right: 0,
      top: 196 + dy,
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 44, 22),
              decoration: BoxDecoration(
                color: v.isDark ? Colors.white.withValues(alpha: 0.1) : bg.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(80),
                border: Border.all(color: Colors.white.withValues(alpha: v.isDark ? 0.18 : 0.6), width: 2),
                boxShadow: [
                  BoxShadow(color: v.ink.withValues(alpha: 0.12), blurRadius: 40, offset: const Offset(0, 16)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(color: v.ink, shape: BoxShape.circle),
                    child: Icon(tag.icon, size: 54, color: v.isDark ? v.skyTop : bg),
                  ),
                  const SizedBox(width: 28),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tag.word, style: inter(76, FontWeight.w900, v.ink, ls: -1.5, height: 1)),
                      const SizedBox(height: 6),
                      Text(tag.sub, style: inter(31, FontWeight.w600, v.inkSoft, ls: -0.3)),
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

  Widget _moodChip(Mood mood, MoodVisual v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 20),
      decoration: BoxDecoration(
        color: v.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: Colors.white.withValues(alpha: v.isDark ? 0.16 : 0.55), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: v.knob,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: v.knob.withValues(alpha: 0.5), blurRadius: 10)],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 196,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: anim.drive(Tween(begin: const Offset(0, 0.4), end: Offset.zero)),
                  child: child,
                ),
              ),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              child: Text(
                _moodNames[mood]!,
                key: ValueKey(mood),
                style: inter(40, FontWeight.w800, v.ink, ls: -0.8),
              ),
            ),
          ),
          for (final m in Mood.values)
            AnimatedContainer(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(left: 9),
              width: m == mood ? 34 : 11,
              height: 11,
              decoration: BoxDecoration(
                color: v.ink.withValues(alpha: m == mood ? 0.9 : 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _outro(double t, MoodVisual v) {
    final a = _win(t, 21.5, 22.2);
    if (a <= 0) return const SizedBox.shrink();
    final e = Curves.easeOutCubic.transform(a);
    return Positioned(
      left: 0,
      right: 0,
      top: 150 + (1 - e) * 40,
      child: Opacity(
        opacity: e,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.nightlight_round, size: 70, color: v.ink),
                const SizedBox(width: 18),
                Text('LULL', style: inter(118, FontWeight.w800, v.ink, ls: 22, height: 1)),
              ],
            ),
            const SizedBox(height: 20),
            Text('Five moods. One little face.', style: inter(42, FontWeight.w700, v.inkSoft, ls: -0.6)),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              decoration: BoxDecoration(color: v.ink, borderRadius: BorderRadius.circular(40)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flutter_dash, size: 34, color: v.skyTop),
                  const SizedBox(width: 10),
                  Text('Built with Flutter', style: inter(28, FontWeight.w700, v.skyTop)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mood-tinted stage behind the phone with slow drifting glows.
class _Backdrop extends CustomPainter {
  _Backdrop(this.v, this.t);
  final MoodVisual v;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final top = Color.lerp(v.skyTop, Colors.white, v.isDark ? 0.04 : 0.28)!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, v.skyBottom],
        ).createShader(rect),
    );
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
    for (var i = 0; i < 6; i++) {
      final ph = i * 1.7;
      final c = Offset(
        size.width * (0.5 + 0.42 * sin(t * 0.18 + ph)),
        size.height * (0.5 + 0.4 * cos(t * 0.14 + ph * 1.3)),
      );
      glow.color = (i.isEven ? v.orbLight : v.halo).withValues(alpha: 0.32);
      canvas.drawCircle(c, 170 + 60 * sin(ph), glow);
    }
  }

  @override
  bool shouldRepaint(_Backdrop old) => true;
}

class _FingerPainter extends CustomPainter {
  _FingerPainter({
    required this.t,
    required this.pos,
    required this.down,
    required this.vis,
    required this.trail,
    required this.presses,
  });

  final double t;
  final Offset? pos;
  final bool down;
  final double vis;
  final List<(double, Offset)> trail;
  final List<(double, Offset)> presses;

  @override
  void paint(Canvas canvas, Size size) {
    if (pos == null || vis <= 0) return;

    for (final (start, p) in presses) {
      final k = ((t - start) / 0.7).clamp(0.0, 1.0);
      final e = Curves.easeOutCubic.transform(k);
      canvas.drawCircle(
        p,
        36 + e * 90,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 * (1 - k) + 1
          ..color = Colors.white.withValues(alpha: 0.75 * (1 - k) * vis),
      );
    }

    for (var i = 1; i < trail.length; i++) {
      final age = (t - trail[i].$1) / 0.28;
      canvas.drawLine(
        trail[i - 1].$2,
        trail[i].$2,
        Paint()
          ..strokeWidth = 30 * (1 - age).clamp(0.2, 1.0)
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.42 * (1 - age).clamp(0.0, 1.0) * vis),
      );
    }

    final r = down ? 34.0 : 40.0;
    canvas.drawCircle(
      pos! + const Offset(0, 6),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16 * vis)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(pos!, r, Paint()..color = Colors.white.withValues(alpha: (down ? 0.55 : 0.32) * vis));
    canvas.drawCircle(
      pos!,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..color = Colors.white.withValues(alpha: 0.95 * vis),
    );
    canvas.drawCircle(pos!, 9, Paint()..color = Colors.white.withValues(alpha: 0.95 * vis));
  }

  @override
  bool shouldRepaint(_FingerPainter old) => true;
}
