import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../home/player.dart';
import '../widgets/fx.dart';
import '../widgets/parts.dart';
import '../tutorial/showcase.dart';
import '../widgets/place.dart';

/// The tablet-layout Workout mock re-flowed for a phone.
///
/// The background plate keeps the hero at scale 1 (see tool/plates.py), so the
/// hero art sits exactly on its own hole. The hero does real push-ups: each rep
/// thumps the floor, counts into the quest bar and rolls the stats. Twenty reps
/// break the chest open.
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

/// Plate rows sit 177 pt below their landscape rows; the plate's top is mock 0.
const _plateTop = 0.0;

class _WorkoutScreenState extends State<WorkoutScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _rep;
  late final AnimationController _set;
  late final AnimationController _chest;
  late final AnimationController _repPop;
  Timer? _clock;
  int _seconds = 28;
  bool _paused = false;
  double _lastRep = 0;
  final _kQuest = GlobalKey();
  final _kTimer = GlobalKey();
  final _kVitals = GlobalKey();
  final _kHero = GlobalKey();
  final _kMetrics = GlobalKey();
  final _kSet = GlobalKey();
  final _kBack = GlobalKey();

  static const _ring = Offset(201, 282);
  static const _ringR = 61.0;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
    _rep = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));
    _rep.addListener(_repCue);
    _rep.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted && !_paused) _rep.forward(from: 0);
    });
    _set = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _chest = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _repPop = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) _rep.forward();
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && mounted) setState(() => _seconds++);
    });
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      if (Player.read(context).seen.add('workout')) _tutorial();
    });
  }

  void _tutorial() {
    ShowcaseHost.of(context).queue(
      Chapter(
        id: 'workout',
        name: 'Arena of Iron',
        reward: 120,
        steps: [
          ShowStep(targets: [_kQuest], radius: 19, title: "Today's quest", body: 'Finish 20 push-ups to break open the treasure chest. Every rep is counted for you.'),
          ShowStep(targets: [_kHero], radius: 24, title: 'Live rep tracking', body: 'Kai mirrors your form. Each rep shakes the arena, builds your combo and fills the quest bar.'),
          ShowStep(targets: [_kTimer], radius: 70, title: 'Set timer', body: 'The ring tracks your set. Gold is time spent, teal is the final stretch. Finish strong!'),
          ShowStep(targets: [_kVitals], radius: 30, title: 'Vitals and control', body: 'Your heart rate beats live on the left. Pause on the right any time, but your combo resets.'),
          ShowStep(targets: [_kMetrics], radius: 17, title: 'Battle stats', body: 'Reps, sets and calories roll up the moment they change.'),
          ShowStep(targets: [_kSet], radius: 24, tap: true, title: 'Bank your set', body: 'Done with this round? Tap Complete Set to bank it and earn bonus XP.', hint: 'Tap Complete Set'),
          ShowStep(targets: [_kBack], radius: 24, title: 'Return to camp', body: 'Head back home whenever you like. Your progress is saved.'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _clock?.cancel();
    _intro.dispose();
    _rep.dispose();
    _set.dispose();
    _chest.dispose();
    _repPop.dispose();
    super.dispose();
  }

  void _repCue() {
    if (_lastRep < 0.5 && _rep.value >= 0.5) {
      final p = Player.read(context);
      if (p.reps < p.repGoal) {
        p.rep();
        _repPop.forward(from: 0);
        HapticFeedback.selectionClick();
        final f = Frame.read(context);
        final fx = FxLayer.of(context);
        final floor = Offset(208, f.b(_plateTop + 497));
        fx.ring(floor, color: const Color(0xFFFFD45A), radius: 190, life: 0.8, squash: 0.16);
        fx.ring(floor, color: const Color(0xFF5FE6FF), radius: 130, life: 0.6, squash: 0.16);
        fx.float(Offset(296, f.b(_plateTop + 392)), '+1', style: Typo.toast.copyWith(fontSize: 20), rise: 28);
        if (p.reps == p.repGoal) _questDone();
      }
    }
    _lastRep = _rep.value;
  }

  void _questDone() {
    final f = Frame.read(context);
    final p = Player.read(context);
    HapticFeedback.heavyImpact();
    _chest.forward(from: 0).then((_) {
      if (!mounted) return;
      final c = Offset(16 + 301.7 + 25, f.y(88 + 28 + 22));
      final fx = FxLayer.of(context);
      fx.burst(c, count: 44, power: 230, colors: const [Tone.goldHi, Color(0xFFFF9C2E), Colors.white, Color(0xFFFF7BE5)]);
      fx.ring(c, color: Tone.goldHi, radius: 110, life: 0.9);
      fx.float(c + const Offset(-30, -20), '+200 XP');
      p.chestOpened = true;
      p.gainXp(200);
    });
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() => _paused = !_paused);
    if (_paused) {
      Player.read(context).resetCombo();
      _rep.stop();
    } else {
      _rep.forward();
    }
  }

  void _completeSet() {
    if (_set.isAnimating) return;
    final p = Player.read(context);
    final f = Frame.read(context);
    HapticFeedback.mediumImpact();
    _set.forward(from: 0).then((_) {
      if (!mounted) return;
      p.completeSet();
      p.gainXp(50);
      final fx = FxLayer.of(context);
      final c = Offset(158, f.b(665));
      fx.burst(c, count: 40, power: 240, colors: const [Color(0xFFB98CFF), Tone.goldHi, Color(0xFF6BE3FF), Colors.white]);
      fx.float(c + const Offset(0, -46), '+50 XP');
      fx.burst(Offset(201, f.b(575)), count: 14, power: 120, colors: const [Color(0xFF6BE3FF), Colors.white]);
    });
  }

  void _skip() {
    HapticFeedback.selectionClick();
    final f = Frame.read(context);
    FxLayer.of(context).ring(Offset(349, f.b(665)), color: const Color(0xFFB98CFF), radius: 60, life: 0.5);
    setState(() => _seconds = 0);
  }

  @override
  Widget build(BuildContext context) {
    final f = Frame.of(context);
    final p = Player.of(context);
    final a = _intro;
    return Scaffold(
      backgroundColor: Tone.night,
      body: AnimatedBuilder(
        animation: a,
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.scale(
              scale: 1 + 0.08 * (1 - span(a.value, 0, 0.8)),
              child: const Plate(asset: Art.bgWorkout, size: Size(402, 1000), offsetY: _plateTop, sky: Color(0xFF2C2D71), ground: Color(0xFF04082A)),
            ),
            _neon(f),
            const Positioned.fill(child: Fog(colors: [Color(0x307A4CFF), Color(0x2240C8FF)], blobs: 6, seed: 6, speed: 1.6)),
            const Positioned.fill(
              child: Motes(count: 28, colors: [Color(0xFF6BE3FF), Color(0xFFB98CFF), Color(0xFFFFD86B)], speed: 16, seed: 14, size: (0.7, 2.0)),
            ),
            _floor(f),
            _hero(f, a),
            _header(f, a),
            _questCard(f, a, p),
            _timer(f, a),
            _pauseButton(f, a),
            _heartPod(f, a),
            _combo(f, p),
            ..._metrics(f, a, p),
            _buttons(f, a),
            ..._anchors(f),
          ],
        ),
      ),
    );
  }

  List<Widget> _anchors(Frame f) {
    Widget at(GlobalKey k, Rect r) => Positioned.fromRect(
      rect: r,
      child: IgnorePointer(child: SizedBox.expand(key: k)),
    );
    return [
      at(_kQuest, Rect.fromLTWH(16, f.y(91), 370, 99)),
      at(_kTimer, Rect.fromCircle(center: Offset(_ring.dx, f.y(_ring.dy)), radius: 64)),
      at(_kVitals, Rect.fromLTRB(28, f.y(_ring.dy + 30) - 30, 374, f.y(_ring.dy + 30) + 30)),
      at(_kHero, Rect.fromLTWH(30, f.b(352), 342, 160)),
      at(_kMetrics, Rect.fromLTWH(16, f.b(540), 370, 70)),
      at(_kSet, Rect.fromLTWH(16, f.b(636), 284, 59)),
      at(_kBack, Rect.fromCircle(center: Offset(34, f.y(64)), radius: 20)),
    ];
  }

  /// Live heart-rate pod, mirroring the pause button.
  Widget _heartPod(Frame f, Animation<double> a) {
    return Positioned(
      left: 58 - 27,
      top: f.y(_ring.dy + 30) - 27,
      child: Staged(
        animation: a,
        begin: 0.35,
        end: 0.7,
        scale: 0.2,
        curve: pop,
        child: SizedBox.square(
          dimension: 54,
          child: Glass(
            radius: 27,
            blur: 10,
            fill: const [Color(0xCC4A2450), Color(0xBF311F4A)],
            line: const Color(0x40FF7FA6),
            child: Tick(
              builder: (context, s, _) {
                final bpm = 128 + (math.sin(s * 0.7) * 4 + math.sin(s * 1.9) * 2).round() + (_paused ? -14 : 0);
                final beat = math.pow(math.max(0, math.sin(s * math.pi * 2 * bpm / 60)), 8).toDouble();
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: 1 + beat * 0.28,
                        child: PhIcon(Ph.heart, size: 16, color: Color.lerp(const Color(0xFFFF5F8F), const Color(0xFFFFB3C8), beat)!),
                      ),
                      Line('$bpm', style: poppins(12.5, FontWeight.w700, height: 1.15)),
                      Line('BPM', style: poppins(6.5, FontWeight.w700, color: const Color(0xFFFF9FBD), tracking: 1, height: 1)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Combo meter that pops every rep and drops when you pause.
  Widget _combo(Frame f, Player p) {
    return Positioned(
      left: 22,
      top: f.b(366),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: Tween(begin: 1.8, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: p.combo < 2
            ? const SizedBox(key: ValueKey(0))
            : Transform.rotate(
                key: ValueKey(p.combo),
                angle: -0.08,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(9, 3, 10, 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(colors: [Color(0xFFFFD54A), Color(0xFFF2861F)]),
                    border: Border.all(color: const Color(0xFFFFF2B0), width: 1),
                    boxShadow: const [BoxShadow(color: Color(0x88FFB02E), blurRadius: 12)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Line('COMBO', style: poppins(9, FontWeight.w700, color: const Color(0xFF4A2300), tracking: 1.2)),
                      const SizedBox(width: 5),
                      Line('x${p.combo}', style: poppins(16, FontWeight.w700, color: const Color(0xFF3A1A00))),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _neon(Frame f) {
    // Neon signs in the plate flicker like faulty tubes.
    const tubes = [(58.0, 250.0, 34.0, Color(0xFF3FD8FF)), (330.0, 268.0, 40.0, Color(0xFF3FE0E8)), (370.0, 330.0, 26.0, Color(0xFF8C6BFF)), (20.0, 380.0, 30.0, Color(0xFFFF9C4A))];
    return Positioned.fill(
      child: IgnorePointer(
        child: Tick(
          builder: (context, s, _) => Stack(
            children: [
              for (var i = 0; i < tubes.length; i++)
                Positioned(
                  left: tubes[i].$1 - tubes[i].$3,
                  top: f.b(tubes[i].$2) - tubes[i].$3,
                  width: tubes[i].$3 * 2,
                  height: tubes[i].$3 * 2,
                  child: Glow(color: tubes[i].$4, opacity: (math.sin(s * 23 + i * 7) > 0.92 ? 0.1 : 0.35) + 0.15 * math.sin(s * 1.5 + i)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floor(Frame f) {
    return Positioned(
      left: 0,
      right: 0,
      top: f.b(_plateTop + 460),
      height: 80,
      child: AnimatedBuilder(
        animation: _rep,
        builder: (context, _) => Tick(builder: (context, s, _) => CustomPaint(painter: _FloorPainter(s, _rep.value))),
      ),
    );
  }

  Widget _hero(Frame f, Animation<double> a) {
    const art = Art.heroWorkout;
    // Landscape → plate: x - 92, y + 177.
    return Positioned(
      left: art.x - 92,
      top: f.b(_plateTop + art.y + 177),
      width: art.w,
      height: art.h,
      child: Opacity(
        opacity: span(a.value, 0.05, 0.25, Curves.linear),
        child: AnimatedBuilder(
          animation: _rep,
          builder: (context, child) {
            final t = _rep.value;
            final down = t < 0.5 ? Curves.easeInOutSine.transform(t / 0.5) : 1 - Curves.easeOutCubic.transform(((t - 0.5) / 0.5).clamp(0, 1));
            return Transform(
              alignment: const Alignment(-0.9, 0.9),
              transform: Matrix4.identity()
                ..rotateZ(down * 0.035)
                ..scaleByDouble(1, 1 - down * 0.07, 1, 1),
              child: child,
            );
          },
          child: art.image(),
        ),
      ),
    );
  }

  Widget _header(Frame f, Animation<double> a) {
    return Positioned(
      left: 0,
      right: 0,
      top: f.y(45),
      height: 38,
      child: Staged(
        animation: a,
        begin: 0,
        end: 0.35,
        offset: const Offset(0, -20),
        child: Stack(
          children: [
            Positioned(
              left: 15,
              top: 0,
              child: RoundButton(
                onTap: () => Navigator.of(context).maybePop(),
                child: const PhIcon(Ph.arrowLeft, size: 20, color: Color(0xFFD5D0F2)),
              ),
            ),
            Center(child: Line('Workout', style: tight(Typo.header))),
            Positioned(
              right: 15,
              top: 0,
              child: RoundButton(
                onTap: () => HapticFeedback.selectionClick(),
                child: Tick(
                  builder: (context, s, _) => Transform.rotate(
                    angle: s * 0.6,
                    child: const PhIcon(Ph.gear, size: 21, color: Color(0xFFA8A2D2)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questCard(Frame f, Animation<double> a, Player p) {
    return Positioned(
      left: 16,
      top: f.y(91),
      width: 370,
      height: 99,
      child: Staged(
        animation: a,
        begin: 0.1,
        end: 0.45,
        offset: const Offset(0, -24),
        rotateX: -1.0,
        alignment: Alignment.topCenter,
        child: Glass(
          radius: 17,
          fill: const [Color(0x99262A58), Color(0x8C191C46)],
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 17.3,
                top: 11,
                width: Art.shieldPurple.w,
                height: Art.shieldPurple.h,
                child: Tick(
                  builder: (context, s, child) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: -10,
                        right: -10,
                        top: -6,
                        bottom: -6,
                        child: Glow(color: const Color(0xFF9B6BFF), opacity: 0.25 + 0.15 * wave(s, 2.2)),
                      ),
                      child!,
                    ],
                  ),
                  child: Sheen(period: 4, delay: 1.5, strength: 0.55, width: 0.2, child: Art.shieldPurple.image()),
                ),
              ),
              TextAt("Today's Quest", style: Typo.questLabel, x: 98, baseline: 24),
              TextAt('Do 20 Push-ups', style: Typo.questTitle, x: 98, baseline: 48),
              Positioned(
                left: 98,
                top: 70 - ascent * 13.4,
                child: AnimatedBuilder(
                  animation: _repPop,
                  builder: (context, _) => Row(
                    children: [
                      Transform.scale(
                        scale: 1 + math.sin(_repPop.value * math.pi) * 0.35,
                        child: Line('${p.reps}', style: tight(Typo.questCount.copyWith(color: Color.lerp(Colors.white, Tone.butter, math.sin(_repPop.value * math.pi))))),
                      ),
                      Line(' / ${p.repGoal}', style: tight(Typo.questTotal)),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 98,
                top: 80,
                child: LiquidBar(
                  value: p.reps / p.repGoal,
                  width: 192,
                  height: 7,
                  track: const Color(0x803F406D),
                  colors: const [Color(0xFFF6E35A), Color(0xFFE9C83A)],
                  duration: const Duration(milliseconds: 700),
                ),
              ),
              Positioned(
                left: 299,
                top: 75,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0x33FFD45A),
                    border: Border.all(color: const Color(0x66FFD45A)),
                  ),
                  child: Line(p.chestOpened ? 'CLAIMED' : '+200 XP', style: poppins(8.5, FontWeight.w700, color: Tone.butter, tracking: 0.4)),
                ),
              ),
              Positioned(
                right: 12,
                top: 9,
                child: Line('REWARD', style: poppins(7, FontWeight.w700, color: const Color(0xFF9C96C8), tracking: 1.4)),
              ),
              Positioned(
                left: 301.7 - 8,
                top: 24 - 8,
                width: Art.chestSmall.w + 16,
                height: Art.chestSmall.h + 16,
                child: Tick(
                  builder: (context, s, child) {
                    final chest = _chest.value;
                    final rattle = shake(chest, freq: 7, decay: 2) * 0.25;
                    final open = chest > 0.8 || p.chestOpened;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (open) const Positioned(left: -30, right: -30, top: -30, bottom: -30, child: GodRays(color: Color(0xFFFFD45A), rays: 10, opacity: 0.5, speed: 0.1)),
                        Positioned.fill(
                          child: Glow(color: const Color(0xFFFFB02E), opacity: 0.3 + 0.15 * wave(s, 1.8) + chest * 0.5),
                        ),
                        Positioned(
                          left: 8,
                          top: 8 + wave(s, 2.4) * 1.5,
                          width: Art.chestSmall.w,
                          height: Art.chestSmall.h,
                          child: Transform.rotate(
                            angle: rattle,
                            child: Transform.scale(scale: 1 + chest * 0.12, child: child),
                          ),
                        ),
                      ],
                    );
                  },
                  child: Art.chestSmall.image(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timer(Frame f, Animation<double> a) {
    final mm = (_seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_seconds % 60).toString().padLeft(2, '0');
    final enter = span(a.value, 0.2, 0.6, pop);
    return Positioned(
      left: _ring.dx - _ringR - 12,
      top: f.y(_ring.dy) - _ringR - 12,
      width: (_ringR + 12) * 2,
      height: (_ringR + 12) * 2,
      child: Transform.scale(
        scale: enter,
        child: Tick(
          builder: (context, s, _) {
            final p = ((_seconds + (_paused ? 0 : (s % 1))) % 34) / 34;
            return CustomPaint(
              painter: _RingPainter(math.max(0.001, p), span(a.value, 0.25, 0.75, gentle), s),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Line('SET TIME', style: poppins(7.5, FontWeight.w700, color: const Color(0xFF8E88C0), tracking: 1.6, height: 1)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Odometer(text: mm, style: tight(Typo.timer)),
                        Line(':', style: tight(Typo.timer)),
                        _Odometer(text: ss, style: tight(Typo.timer)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: const Color(0x268FF3F0)),
                      child: Line('SET ${Player.of(context).sets} OF ${Player.of(context).setGoal}', style: poppins(7.5, FontWeight.w700, color: Tone.tealHi, tracking: 1.1)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _pauseButton(Frame f, Animation<double> a) {
    return Positioned(
      left: 344 - 27,
      top: f.y(_ring.dy + 30) - 27,
      child: Staged(
        animation: a,
        begin: 0.35,
        end: 0.7,
        scale: 0.2,
        curve: pop,
        child: Pressable(
          onTap: _togglePause,
          scale: 0.85,
          child: SizedBox.square(
            dimension: 54,
            child: Glass(
              radius: 27,
              blur: 10,
              fill: const [Color(0xCC4A396C), Color(0xBF31285A)],
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween(begin: 0.6, end: 1.0).animate(anim),
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: PhIcon(_paused ? Ph.play : Ph.pause, key: ValueKey(_paused), size: 24, color: const Color(0xFFF3F0FF)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _metrics(Frame f, Animation<double> a, Player p) {
    const w = (370 - 20) / 3;
    final cards = [(Art.icBolt, 'Reps', '${p.reps}', '/${p.repGoal}'), (Art.icSets, 'Sets', '${p.sets} / ${p.setGoal}', ''), (Art.icFlame, 'Calories', '${p.burn}', 'kcal')];
    return [
      for (var i = 0; i < 3; i++)
        Positioned(
          left: 16 + i * (w + 10),
          top: f.b(540),
          width: w,
          height: 70,
          child: Staged(
            animation: a,
            begin: 0.35 + i * 0.08,
            end: 0.7 + i * 0.08,
            offset: const Offset(0, 50),
            rotateX: 1.1,
            alignment: Alignment.bottomCenter,
            child: Glass(
              radius: 15,
              fill: const [Color(0xA6201F52), Color(0x99161642)],
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 12,
                    top: 35 - cards[i].$1.h / 2,
                    width: cards[i].$1.w,
                    height: cards[i].$1.h,
                    child: Tick(
                      builder: (context, s, child) {
                        final spin = i == 1 ? s * 1.2 : 0.0;
                        final zap = i == 0 ? (math.sin(s * 9) > 0.85 ? 1.15 : 1.0) : 1 + wave(s, 0.8) * 0.04;
                        return Transform.rotate(
                          angle: spin,
                          child: Transform.scale(scale: zap, child: child),
                        );
                      },
                      child: cards[i].$1.image(),
                    ),
                  ),
                  TextAt(cards[i].$2, style: Typo.metricLabel, x: 47, baseline: 27),
                  Positioned(
                    left: 47,
                    top: 55 - ascent * 21,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 380),
                          transitionBuilder: (child, anim) => SlideTransition(
                            position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          layoutBuilder: (cur, prev) => Stack(alignment: Alignment.topLeft, children: [...prev, ?cur]),
                          child: Line(cards[i].$3, key: ValueKey(cards[i].$3), style: tight(Typo.metricValue)),
                        ),
                        if (cards[i].$4.isNotEmpty) Line(' ${cards[i].$4}', style: tight(poppins(10.5, FontWeight.w500, color: const Color(0xFF9E9AC0)))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buttons(Frame f, Animation<double> a) {
    return Stack(
      children: [
        Positioned(
          left: 16,
          top: f.b(636),
          child: Staged(
            animation: a,
            begin: 0.5,
            end: 0.85,
            offset: const Offset(0, 60),
            curve: pop,
            child: VioletButton(
              width: 284,
              height: 59,
              radius: 22,
              onTap: _completeSet,
              child: AnimatedBuilder(
                animation: _set,
                builder: (context, _) {
                  final t = _set.value;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        // A wave of light fills the button while the set is logged.
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 284 * span(t, 0, 0.6, Curves.easeInOutCubic),
                          child: const DecoratedBox(
                            decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0x00FFFFFF), Color(0x40FFFFFF)])),
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Line('Complete Set', style: tight(Typo.buttonLight.copyWith(fontSize: 15.8, fontWeight: FontWeight.w500))),
                              const SizedBox(width: 9),
                              SizedBox(width: 18, height: 18, child: CustomPaint(painter: _CheckPainter(t == 0 ? 1 : span(t, 0.45, 0.9, Curves.easeOut), t))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          left: 312,
          top: f.b(636),
          child: Staged(
            animation: a,
            begin: 0.58,
            end: 0.9,
            offset: const Offset(0, 60),
            curve: pop,
            child: Pressable(
              onTap: _skip,
              child: SizedBox(
                width: 74,
                height: 59,
                child: Glass(
                  radius: 18,
                  fill: const [Color(0xCC2B2160), Color(0xBF1E1848)],
                  child: Center(
                    child: Tick(
                      builder: (context, s, _) => Transform.translate(
                        offset: Offset(math.max(0, wave(s, 1.3)) * 3, 0),
                        child: const PhIcon(Ph.caretRight, size: 22, color: Color(0xFFEDEAFF)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Digits that roll vertically whenever they change.
class _Odometer extends StatelessWidget {
  const _Odometer({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < text.length; i++)
          ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              transitionBuilder: (child, anim) {
                final incoming = child.key == ValueKey('$i${text[i]}');
                return SlideTransition(
                  position: Tween(begin: Offset(0, incoming ? -1 : 1), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
                  child: child,
                );
              },
              layoutBuilder: (cur, prev) => Stack(alignment: Alignment.center, children: [...prev, ?cur]),
              child: Line(text[i], key: ValueKey('$i${text[i]}'), style: style),
            ),
          ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.p, this.reveal, this.s);

  final double p;
  final double reveal;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = 61.0;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(c, r + 3, Paint()..color = const Color(0xB3141436));
    canvas.drawCircle(c, r - 4, Paint()..shader = const RadialGradient(colors: [Color(0xE618193F), Color(0xF20E0F2E)]).createShader(rect));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.5
        ..color = const Color(0xFF5E5790),
    );
    // Progress runs counter-clockwise from 12 o'clock, gold into teal at the head.
    final sweep = -math.pi * 2 * p * reveal;
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x55FFD24A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(-1, 1);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-c.dx, -c.dy);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(colors: const [Color(0xFFF7D449), Color(0xFFF2C53B), Color(0xFFEFD45A), Color(0xFF8FD3CC)], stops: [0, p * 0.7, p * 0.84, math.max(p, 0.001)]).createShader(rect);
    canvas.drawArc(rect, 0, math.pi * 2 * p * reveal, false, arc);
    canvas.restore();
    final head = -math.pi / 2 + sweep;
    final hp = c + Offset(math.cos(head), math.sin(head)) * r;
    canvas.drawCircle(
      hp,
      7 + math.sin(s * 6) * 1.2,
      Paint()
        ..color = const Color(0x998FF3F0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(hp, 3.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_RingPainter old) => true;
}

class _FloorPainter extends CustomPainter {
  _FloorPainter(this.s, this.rep);

  final double s;
  final double rep;

  @override
  void paint(Canvas canvas, Size size) {
    final c = const Offset(208, 37);
    final thump = rep > 0.5 ? math.exp(-(rep - 0.5) * 10) : 0.0;
    for (var k = 0; k < 2; k++) {
      final rect = Rect.fromCenter(center: c, width: k == 0 ? 350 : 250, height: k == 0 ? 52 : 36);
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 + thump * 2
          ..color = (k == 0 ? const Color(0xFFFFD45A) : const Color(0xFF6BE3FF)).withValues(alpha: 0.18 + thump * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
      for (var j = 0; j < 2; j++) {
        canvas.drawArc(
          rect,
          (k == 0 ? 1 : -1) * s * 0.8 + j * math.pi,
          0.7,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 2.6
            ..color = (k == 0 ? const Color(0xFFFFE07A) : const Color(0xFF9FF0FF)).withValues(alpha: 0.7),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FloorPainter old) => true;
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.draw, this.t);

  final double draw;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.52)
      ..lineTo(size.width * 0.4, size.height * 0.78)
      ..lineTo(size.width * 0.9, size.height * 0.22);
    final m = path.computeMetrics().first;
    final part = m.extractPath(0, m.length * draw.clamp(0, 1));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    if (t > 0 && t < 1) {
      canvas.drawPath(
        part,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = const Color(0x99FFFFFF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    canvas.drawPath(part, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.draw != draw || old.t != t;
}
