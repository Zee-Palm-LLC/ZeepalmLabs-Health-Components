import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/fx.dart';
import '../widgets/parts.dart';
import '../tutorial/showcase.dart';
import '../widgets/place.dart';
import 'player.dart';

/// s3 is 782.3 pt tall; bottom-pinned art shifts by this onto the 784 frame.
const _s3 = 1.67;

/// Home: the hero beams down onto his cliff, the level card flips in and its
/// XP pours, stats cascade in and count up, and the gift bobs until opened.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onStart, this.navKey});

  final void Function(Offset origin) onStart;

  /// The shell's dock, spotlit by the tutorial.
  final GlobalKey? navKey;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _gift;
  late final AnimationController _flare;
  bool _landed = false;
  final _kAvatar = GlobalKey();
  final _kFire = GlobalKey();
  final _kLevel = GlobalKey();
  final _kStats = GlobalKey();
  final _kStatus = GlobalKey();
  final _kGift = GlobalKey();
  final _kStart = GlobalKey();

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..addListener(_cues)
      ..forward();
    _gift = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _flare = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    Future.delayed(const Duration(milliseconds: 2900), () {
      if (!mounted) return;
      final p = Player.read(context);
      if (p.seen.add('home')) _tutorial();
    });
  }

  void _tutorial() {
    ShowcaseHost.of(context).queue(
      Chapter(
        id: 'home',
        name: 'Training Grounds',
        reward: 100,
        steps: [
          ShowStep(targets: [_kAvatar], radius: 40, title: 'Meet your hero', body: 'This is you, Legend. Every workout makes your hero stronger and unlocks new worlds to explore.'),
          ShowStep(targets: [_kFire], radius: 16, title: 'Guard your streak', body: 'Train every day to keep the flame burning. Twelve days strong. Miss one and it fizzles out!'),
          ShowStep(targets: [_kLevel], radius: 22, title: 'Level up', body: 'Workouts, quests and loot all pour XP into this bar. Fill it to reach Level 13 and a new rank.'),
          ShowStep(targets: [_kStats], radius: 20, title: 'Adventure stats', body: 'Workouts, time trained and calories burned update the moment you finish a session.'),
          ShowStep(targets: [_kStatus], radius: 15, title: 'Hero status', body: 'Stamina refills with rest and water. Focus grows with your streak. Keep both high for bonus XP.'),
          ShowStep(targets: [_kGift], radius: 18, tap: true, title: 'Daily loot', body: 'A mystery gift just dropped beside you. Tap it to crack it open and claim your reward!', hint: 'Tap the gift'),
          if (widget.navKey != null)
            ShowStep(targets: [widget.navKey!], pad: 0, radius: 28, title: 'Your world map', body: 'Quests, friends and your profile live in the dock. The glowing orb always shows where you are.'),
          ShowStep(
            targets: [_kStart],
            radius: 34,
            tap: true,
            title: 'Your first quest',
            body: "Ready, Legend? Tap Start Workout to begin today's training and earn your first rewards.",
            hint: 'Tap Start Workout',
          ),
        ],
      ),
    );
  }

  void _cues() {
    if (!_landed && _intro.value > 0.5) {
      _landed = true;
      final f = Frame.read(context);
      FxLayer.of(context).ring(Offset(241, f.b(520 + _s3)), color: const Color(0xFF8FE9FF), radius: 120, life: 0.8, squash: 0.22);
      FxLayer.of(context).burst(Offset(241, f.b(515 + _s3)), count: 18, power: 120, colors: const [Color(0xFFBDEFFF), Color(0xFF8C6BFF), Colors.white], size: 2.2);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _gift.dispose();
    _flare.dispose();
    super.dispose();
  }

  void _openGift() {
    if (_gift.isAnimating) return;
    final f = Frame.read(context);
    final player = Player.read(context);
    HapticFeedback.mediumImpact();
    _gift.forward(from: 0).then((_) {
      if (!mounted) return;
      final c = Offset(Art.gift.rect.center.dx, f.b(Art.gift.rect.center.dy + _s3));
      final fx = FxLayer.of(context);
      fx.burst(c, count: 36, power: 200, colors: const [Color(0xFFFF7BE5), Tone.goldHi, Colors.white, Color(0xFFB98CFF)]);
      fx.ring(c, color: const Color(0xFFFF9BEA), radius: 80);
      fx.float(c + const Offset(-6, -30), '+50 XP');
      player.gainXp(50);
    });
  }

  void _flareFire() {
    HapticFeedback.lightImpact();
    _flare.forward(from: 0);
    final f = Frame.read(context);
    FxLayer.of(context).burst(Offset(331, f.y(84)), count: 14, power: 90, colors: const [Color(0xFFFFC34A), Color(0xFFFF6A1F), Color(0xFFFFF0B0)], gravity: -1.2, stars: false);
  }

  @override
  Widget build(BuildContext context) {
    final f = Frame.of(context);
    final a = _intro;
    final p = Player.of(context);
    return AnimatedBuilder(
      animation: a,
      builder: (context, _) => Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.scale(
            scale: 1 + 0.06 * (1 - span(a.value, 0, 0.7)),
            alignment: const Alignment(0.2, 0.2),
            child: const Plate(asset: Art.bgHome, size: Size(402, 782.33), offsetY: _s3, sky: Color(0xFF161B53), ground: Color(0xFF3C2F4A)),
          ),
          _castle(f),
          const Positioned.fill(child: Fog(colors: [Color(0x22FFFFFF), Color(0x1AC9B8FF)], blobs: 4, seed: 12, speed: 1.4)),
          const Positioned.fill(
            child: Motes(count: 22, colors: [Color(0xFFFFE9A0), Color(0xFFB3F0FF)], speed: 8, seed: 21, size: (0.8, 2.0)),
          ),
          _hero(f, a),
          _giftBox(f, a),
          ..._stats(f, a, p),
          _status(f, a, p),
          _header(f, a, p),
          _levelCard(f, a, p),
          _help(f, a),
          Positioned(
            left: 72,
            top: f.b(607 + _s3),
            child: Staged(
              animation: a,
              begin: 0.55,
              end: 0.85,
              offset: const Offset(0, 40),
              scale: 0.8,
              curve: pop,
              child: GoldButton(
                label: 'Start Workout',
                icon: Ph.arrowUpRight,
                width: 260,
                height: 63,
                style: Typo.button.copyWith(fontSize: 18.7),
                onTap: () => widget.onStart(Offset(202, f.b(638.5 + _s3))),
              ),
            ),
          ),
          ..._anchors(f),
        ],
      ),
    );
  }

  /// Invisible boxes the tutorial spotlights.
  List<Widget> _anchors(Frame f) {
    Widget at(GlobalKey k, Rect r) => Positioned.fromRect(
      rect: r,
      child: IgnorePointer(child: SizedBox.expand(key: k)),
    );
    return [
      at(_kAvatar, Rect.fromCircle(center: Offset(54.2, f.y(90.2)), radius: 37)),
      at(_kFire, Rect.fromLTRB(309, f.y(64), 384, f.y(114))),
      at(_kLevel, Rect.fromLTWH(16, f.y(140), 368, 86)),
      at(_kStats, Rect.fromLTWH(18, f.b(383 + _s3), 146, 194)),
      at(_kStatus, Rect.fromLTWH(300, f.b(386 + _s3), 86, 62)),
      at(_kGift, Rect.fromLTWH(Art.gift.x - 4, f.b(Art.gift.y + _s3) - 4, Art.gift.w + 8, Art.gift.h + 8)),
      at(_kStart, Rect.fromLTWH(72, f.b(607 + _s3), 260, 63)),
    ];
  }

  Widget _help(Frame f, Animation<double> a) {
    return Positioned(
      left: 281,
      top: f.y(76),
      child: Staged(
        animation: a,
        begin: 0.3,
        end: 0.6,
        scale: 0.2,
        curve: pop,
        child: RoundButton(
          size: 28,
          onTap: _tutorial,
          child: Tick(
            builder: (context, s, _) => Transform.rotate(
              angle: wave(s, 3) * 0.15,
              child: const PhIcon(Ph.question, size: 14, color: Tone.butter),
            ),
          ),
        ),
      ),
    );
  }

  /// RPG unit frame beside the hero: stamina and focus.
  Widget _status(Frame f, Animation<double> a, Player p) {
    Widget line(IconData icon, Color tint, int v, List<Color> colors, int i) {
      return Row(
        children: [
          PhIcon(icon, size: 9, color: tint),
          const SizedBox(width: 4),
          LiquidBar(
            value: v / 100,
            width: 35,
            height: 5,
            track: const Color(0x33FFFFFF),
            colors: colors,
            delay: Duration(milliseconds: 1500 + i * 200),
          ),
          const SizedBox(width: 5),
          Line('$v', style: poppins(9, FontWeight.w700, color: tint)),
        ],
      );
    }

    return Positioned(
      left: 300,
      top: f.b(386 + _s3),
      width: 86,
      height: 62,
      child: Staged(
        animation: a,
        begin: 0.55,
        end: 0.85,
        offset: const Offset(40, 0),
        child: Bob(
          amplitude: 2,
          period: 3.8,
          child: Glass(
            radius: 14,
            blur: 10,
            fill: const [Color(0xB3221D52), Color(0xA6151240)],
            line: const Color(0x40B59CFF),
            padding: const EdgeInsets.fromLTRB(9, 8, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Line('HERO STATUS', style: poppins(7.4, FontWeight.w700, color: const Color(0xFFB59CFF), tracking: 1.1)),
                const SizedBox(height: 6),
                line(Ph.heart, const Color(0xFFFF7FA6), p.stamina, const [Color(0xFFFF9FBD), Color(0xFFFF4F7E)], 0),
                const SizedBox(height: 6),
                line(Ph.lightning, const Color(0xFF6BE3FF), p.focus, const [Color(0xFF9FF0FF), Color(0xFF3FB8D4)], 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _castle(Frame f) {
    const lights = [(342.0, 324.0, 12.0), (329.0, 297.0, 7.0), (352.0, 280.0, 6.0), (318.0, 262.0, 6.0), (164.0, 283.0, 6.0)];
    return Positioned.fill(
      child: IgnorePointer(
        child: Tick(
          builder: (context, s, _) => Stack(
            children: [
              for (var i = 0; i < lights.length; i++)
                Positioned(
                  left: lights[i].$1 - lights[i].$3 * 1.6,
                  top: f.b(lights[i].$2 + _s3) - lights[i].$3 * 1.6,
                  width: lights[i].$3 * 3.2,
                  height: lights[i].$3 * 3.2,
                  child: Glow(color: const Color(0xFFFFB347), opacity: 0.4 + 0.3 * math.sin(s * (4 + i) + i) * math.sin(s * 1.7 + i * 2)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(Frame f, Animation<double> a, Player p) {
    return Stack(
      children: [
        // Avatar with a rotating rune ring and a pulsing online dot.
        Positioned(
          left: 54.2 - 37,
          top: f.y(90.2) - 37,
          width: 74,
          height: 74,
          child: Staged(
            animation: a,
            begin: 0.0,
            end: 0.3,
            scale: 0.3,
            rotateZ: -1.5,
            curve: pop,
            child: Pressable(
              onTap: () {
                HapticFeedback.selectionClick();
                FxLayer.of(context).ring(Offset(54.2, f.y(90.2)), color: const Color(0xFFA98BFF), radius: 56, life: 0.6);
              },
              child: Tick(
                builder: (context, s, _) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _AvatarRing(s))),
                    Positioned(left: 4.8, top: 4.8, width: 64.33, height: 64.33, child: ClipOval(child: Art.avatar.image())),
                    Positioned(
                      left: 76 - 54.2 + 37 - 7.5,
                      top: 112 - 90.2 + 37 - 7.5,
                      width: 15,
                      height: 15,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Tone.green,
                          border: Border.all(color: const Color(0xFF14183F), width: 2.2),
                          boxShadow: [BoxShadow(color: Tone.green.withValues(alpha: 0.4 + 0.4 * (wave(s, 1.6) + 1) / 2), blurRadius: 8)],
                        ),
                        child: const Center(child: PhIcon(Ph.check, size: 7, color: Color(0xFF0D3B1E))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Staged(
            animation: a,
            begin: 0.08,
            end: 0.36,
            offset: const Offset(-24, 0),
            child: Stack(
              children: [
                TextAt('Hey, Legend!', style: Typo.greet, x: 102, baseline: f.y(83.8)),
                TextAt('Keep going!', style: Typo.greetSub, x: 102, baseline: f.y(107.2)),
              ],
            ),
          ),
        ),
        // Streak: a living flame with embers, and the count rolling up.
        Positioned(
          left: Art.fire.x - 6,
          top: f.y(Art.fire.y) - 8,
          width: Art.fire.w + 12,
          height: Art.fire.h + 12,
          child: Staged(
            animation: a,
            begin: 0.12,
            end: 0.42,
            scale: 0.2,
            curve: pop,
            child: Pressable(
              onTap: _flareFire,
              child: AnimatedBuilder(
                animation: _flare,
                builder: (context, _) => Tick(
                  builder: (context, s, _) {
                    final flick = wave(s, 0.9) * 0.04 + wave(s, 0.37) * 0.025;
                    final flare = math.sin(_flare.value * math.pi) * 0.35;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: -10,
                          right: -10,
                          top: -6,
                          bottom: -14,
                          child: Glow(color: const Color(0xFFFF8A1F), opacity: 0.35 + flare + 0.1 * wave(s, 0.8)),
                        ),
                        Positioned(
                          left: 6,
                          top: 8,
                          width: Art.fire.w,
                          height: Art.fire.h,
                          child: Transform(
                            alignment: Alignment.bottomCenter,
                            transform: Matrix4.identity()
                              ..scaleByDouble(1 - flick * 0.6 + flare * 0.3, 1 + flick + flare * 0.4, 1, 1)
                              ..setEntry(0, 1, wave(s, 1.3) * 0.06),
                            child: Art.fire.image(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 330,
          right: 0,
          top: f.y(40),
          height: 70,
          child: Opacity(
            opacity: span(a.value, 0.3, 0.5),
            child: const Motes(count: 7, colors: [Color(0xFFFFB13B), Color(0xFFFF6A1F)], speed: 9, sway: 4, seed: 33, size: (0.7, 1.6), life: 3),
          ),
        ),
        Positioned.fill(
          child: Staged(
            animation: a,
            begin: 0.16,
            end: 0.46,
            offset: const Offset(16, 0),
            child: Stack(
              children: [
                Positioned(
                  left: 354.5,
                  top: f.y(97 - ascent * 24.2),
                  child: CountUp(value: p.streak, from: p.streak - 5, style: tight(Typo.streak), delay: const Duration(milliseconds: 500)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _levelCard(Frame f, Animation<double> a, Player p) {
    final shieldSpin = (1 - span(a.value, 0.2, 0.55, swift)) * math.pi * 2;
    return Positioned(
      left: 16,
      top: f.y(140),
      width: 368,
      height: 86,
      child: Staged(
        animation: a,
        begin: 0.12,
        end: 0.42,
        rotateX: -1.3,
        offset: const Offset(0, -20),
        alignment: Alignment.topCenter,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(
              child: Sheen(
                period: 5,
                delay: 2,
                strength: 0.12,
                width: 0.3,
                child: Glass(radius: 20, fill: [Color(0x804464C4), Color(0x66223C9A), Color(0x592B2A7A)], line: Color(0x33CBD8FF), child: SizedBox.expand()),
              ),
            ),
            Positioned(
              left: Art.shieldGold.x - 16,
              top: Art.shieldGold.y - 140,
              width: Art.shieldGold.w,
              height: Art.shieldGold.h,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateY(shieldSpin),
                child: Sheen(period: 3.6, delay: 0.8, strength: 0.7, width: 0.18, child: Art.shieldGold.image()),
              ),
            ),
            TextAt('Level ${p.level}', style: Typo.level, x: 96, baseline: 38),
            Positioned(
              left: 179,
              top: 24,
              child: Opacity(
                opacity: span(a.value, 0.35, 0.55),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(colors: [Color(0xFF8A6CE0), Color(0xFF5B3BC8)]),
                    border: Border.all(color: const Color(0x66D7C4FF)),
                  ),
                  child: Line('WARRIOR', style: poppins(8, FontWeight.w700, tracking: 1)),
                ),
              ),
            ),
            Positioned(
              left: 296,
              top: 51.5,
              child: Opacity(
                opacity: span(a.value, 0.5, 0.7),
                child: Tick(
                  builder: (context, s, child) => Container(
                    padding: const EdgeInsets.fromLTRB(5, 1.5, 7, 1.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0x26FFD45A),
                      border: Border.all(color: Color.lerp(const Color(0x55FFD45A), const Color(0xAAFFD45A), (wave(s, 2) + 1) / 2)!),
                    ),
                    child: child,
                  ),
                  child: Row(
                    children: [
                      const PhIcon(Ph.star, size: 9, color: Tone.butter),
                      const SizedBox(width: 3),
                      Line('Lv ${p.level + 1}', style: poppins(9.5, FontWeight.w700, color: Tone.butter)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 94.8,
              top: 54.8,
              child: Opacity(
                opacity: span(a.value, 0.3, 0.45),
                child: LiquidBar(
                  value: p.xp / p.xpGoal,
                  width: 190,
                  height: 12,
                  track: const Color(0x08FFFFFF),
                  colors: const [Color(0xFFFFCB34), Color(0xFFFFB21C)],
                  delay: const Duration(milliseconds: 900),
                ),
              ),
            ),
            Positioned(
              left: 242,
              top: 39 - ascent * 14.1,
              child: Rolling(
                value: p.xp.toDouble(),
                from: 0,
                delay: const Duration(milliseconds: 900),
                duration: const Duration(milliseconds: 1400),
                builder: (context, v) => Line('${v.round()} / ${p.xpGoal} XP', style: tight(Typo.xp)),
              ),
            ),
            Positioned(
              left: 340,
              top: 25,
              child: Tick(
                builder: (context, s, _) => Transform.translate(
                  offset: Offset(wave(s, 1.6) * 1.5, -wave(s, 1.6) * 1.5),
                  child: const PhIcon(Ph.arrowUpRight, size: 13, color: Color(0x668C93C8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _stats(Frame f, Animation<double> a, Player p) {
    final rows = [
      (Art.icWorkouts, 'Workouts', p.workouts, (int v) => '$v', const Color(0xFF4AD2D7)),
      (Art.icTimer, 'Total Time', p.minutes, (int v) => '${v ~/ 60}h ${v % 60}m', const Color(0xFF39A8FF)),
      (Art.icCalories, 'Calories', p.calories, (int v) => '$v', const Color(0xFFFF8A1F)),
    ];
    return [
      for (var i = 0; i < 3; i++)
        Positioned(
          left: 18,
          top: f.b(383 + i * 67 + _s3),
          width: 146,
          height: 60,
          child: Staged(
            animation: a,
            begin: 0.3 + i * 0.07,
            end: 0.62 + i * 0.07,
            offset: const Offset(-80, 0),
            rotateY: 0.9,
            alignment: Alignment.centerLeft,
            child: Glass(
              radius: 18,
              fill: const [Color(0xB3272A5C), Color(0xA61A1C46)],
              child: Stack(
                children: [
                  Positioned(
                    left: 4,
                    top: 5,
                    width: 50,
                    height: 50,
                    child: Tick(
                      builder: (context, s, child) => DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF161837),
                          boxShadow: [BoxShadow(color: rows[i].$5.withValues(alpha: 0.12 + 0.1 * (wave(s, 2.4, i * 0.3) + 1) / 2), blurRadius: 12)],
                        ),
                        child: child,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Positioned(
                    left: rows[i].$1.x - 18,
                    top: rows[i].$1.y - (383 + i * 67),
                    width: rows[i].$1.w,
                    height: rows[i].$1.h,
                    child: Bob(amplitude: 1.4, period: 2.2, phase: i * 0.25, child: rows[i].$1.image()),
                  ),
                  TextAt(rows[i].$2, style: Typo.statLabel, x: 63, baseline: 24),
                  Positioned(
                    left: 63,
                    top: 49 - ascent * 18.4,
                    child: CountUp(
                      value: rows[i].$3,
                      style: tight(Typo.statValue),
                      format: rows[i].$4,
                      delay: Duration(milliseconds: 700 + i * 150),
                      duration: const Duration(milliseconds: 1300),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  Widget _hero(Frame f, Animation<double> a) {
    const art = Art.heroHome;
    final reveal = span(a.value, 0.12, 0.5, Curves.easeInOutCubic);
    final beam = math.sin(span(a.value, 0.05, 0.62, Curves.linear) * math.pi);
    return Positioned(
      left: art.x - 60,
      top: f.b(art.y + _s3) - 260,
      width: art.w + 120,
      height: art.h + 260,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // The teleport beam.
            Positioned(
              left: 60 + art.w / 2 - 40,
              top: 0,
              width: 80,
              bottom: 10,
              child: Opacity(
                opacity: beam,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0x00A8E8FF), Color(0xAAE6F8FF), Color(0x00A8E8FF)])),
                ),
              ),
            ),
            Positioned(
              left: 60,
              top: 260,
              width: art.w,
              height: art.h,
              child: Tick(
                builder: (context, s, child) {
                  final breath = (wave(s, 3.4) + 1) / 2;
                  return Transform.scale(scale: 1 + breath * 0.012, alignment: Alignment.bottomCenter, child: child);
                },
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: const [Colors.white, Colors.white, Colors.transparent],
                    stops: [0, (reveal - 0.02).clamp(0, 1), reveal.clamp(0, 1)],
                  ).createShader(r),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(const Color(0xFFDFF6FF).withValues(alpha: (1 - span(a.value, 0.35, 0.6)) * 0.85), BlendMode.srcATop),
                    child: art.image(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _giftBox(Frame f, Animation<double> a) {
    const art = Art.gift;
    final drop = span(a.value, 0.5, 0.9, Curves.linear);
    final y = drop <= 0 ? -300.0 : -(1 - spring(drop, bounce: 0.6, freq: 3)) * 200;
    return Positioned(
      left: art.x - 10,
      top: f.b(art.y + _s3) - 10 + y,
      width: art.w + 20,
      height: art.h + 20,
      child: Opacity(
        opacity: drop > 0 ? 1 : 0,
        child: Pressable(
          onTap: _openGift,
          child: AnimatedBuilder(
            animation: _gift,
            builder: (context, child) {
              final g = _gift.value;
              final wob = shake(g, freq: 5, decay: 1.5);
              final pop = g > 0.85 ? (g - 0.85) / 0.15 : 0.0;
              return Tick(
                builder: (context, s, _) {
                  // Every few seconds the gift does an impatient little hop.
                  final hop = cycle(s, 4.2);
                  final jump = hop < 0.12 ? math.sin(hop / 0.12 * math.pi) : 0.0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Glow(color: const Color(0xFFFF7BE5), opacity: 0.35 + 0.2 * wave(s, 2) + g * 0.5),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        width: art.w,
                        height: art.h,
                        child: Transform.translate(
                          offset: Offset(0, wave(s, 2.6) * 3 - jump * 8),
                          child: Transform.rotate(
                            angle: wob * 0.3 + jump * 0.08 * math.sin(hop * 60),
                            child: Transform.scale(scale: (1 + g * 0.15) * (1 - pop * 0.3), child: child),
                          ),
                        ),
                      ),
                      const Positioned(left: 0, top: 0, right: 0, bottom: 0, child: Twinkles(points: [(8, 14, 5), (70, 20, 4), (60, 74, 4)], period: 2)),
                    ],
                  );
                },
              );
            },
            child: art.image(),
          ),
        ),
      ),
    );
  }
}

class _AvatarRing extends CustomPainter {
  _AvatarRing(this.s);

  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = 34.6;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r + 2,
      Paint()
        ..color = const Color(0x557A6BFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(s * 0.9);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..shader = const SweepGradient(colors: [Color(0xFF8E7BFF), Color(0xFF5AC8FF), Color(0xFFC6A8FF), Color(0xFF6E5BFF), Color(0xFF8E7BFF)]).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AvatarRing old) => old.s != s;
}
