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

/// The tablet-layout Quests mock re-flowed for a phone: tabs on top, the
/// treasure chest as a banner, then the daily quest list.
///
/// The tab pill slides between tabs, the chest floats on god rays and rattles
/// when tapped, and tapping a quest advances it — completing one stamps it,
/// pours its bar and flies the XP to your level.
class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key, required this.onStart});

  final void Function(Offset origin) onStart;

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _rattle;
  int _tab = 0;
  final _scroll = ScrollController();
  final _kTabs = GlobalKey();
  final _kChest = GlobalKey();
  final _kDaily = GlobalKey();
  final _kRow = GlobalKey();
  final _kXp = GlobalKey();

  static const _tabs = [(16.0, 112.0, 'Quests'), (136.0, 140.0, 'Achievements'), (284.0, 102.0, 'Rewards')];

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..forward();
    _rattle = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      if (Player.read(context).seen.add('quests')) _tutorial();
    });
  }

  void _tutorial() {
    ShowcaseHost.of(context).queue(
      Chapter(
        id: 'quests',
        name: 'Quest Board',
        reward: 80,
        steps: [
          ShowStep(targets: [_kTabs], radius: 16, title: 'Your quest log', body: 'Switch between daily quests, achievements you are chasing and rewards waiting to be claimed.'),
          ShowStep(targets: [_kChest], radius: 26, title: 'The treasure chest', body: 'Complete your daily quests to unlock this chest. Tap it any time to see what it needs.'),
          ShowStep(targets: [_kDaily], radius: 16, title: 'Daily chest progress', body: 'Each finished quest lights a gem. The board resets at midnight, so do not wait too long!'),
          ShowStep(
            targets: [_kRow],
            radius: 18,
            tap: true,
            title: 'Log progress',
            body: 'Drank another glass? Tap a quest to log it. Finishing one pays out its XP instantly.',
            hint: 'Tap the water quest',
          ),
          ShowStep(targets: [_kXp], radius: 16, title: 'Bounty', body: 'This badge shows each quest bounty. Claimed ones flip to a gold check.'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _rattle.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _tapChest(Offset at) {
    HapticFeedback.mediumImpact();
    _rattle.forward(from: 0);
    final fx = FxLayer.of(context);
    fx.burst(at, count: 24, power: 150, colors: const [Tone.goldHi, Color(0xFFE77BFF), Colors.white], gravity: 1.4);
    fx.float(at + const Offset(0, -40), 'Finish 3 quests!', style: Typo.toast.copyWith(fontSize: 13));
  }

  void _advance(Quest q, Offset at) {
    final p = Player.read(context);
    if (q.done) return;
    final step = q.unit == 'steps' ? 1190 : 1;
    p.advance(q, step);
    HapticFeedback.selectionClick();
    final fx = FxLayer.of(context);
    if (q.done) {
      HapticFeedback.mediumImpact();
      fx.burst(at, count: 30, power: 190, colors: const [Tone.goldHi, Color(0xFF6BE3FF), Colors.white]);
      fx.float(at + const Offset(0, -26), '+${q.xp} XP');
      p.gainXp(q.xp);
    } else {
      fx.burst(at, count: 8, power: 80, colors: const [Color(0xFF6BE3FF), Colors.white], stars: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = Frame.of(context);
    final p = Player.of(context);
    final a = _intro;
    return AnimatedBuilder(
      animation: a,
      builder: (context, _) => Stack(
        clipBehavior: Clip.none,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0E0F33), Color(0xFF14102E), Color(0xFF0D0B22)]),
            ),
            child: SizedBox.expand(),
          ),
          Positioned(
            left: -140,
            top: f.y(80),
            width: 360,
            height: 360,
            child: const Glow(color: Color(0xFFB24C9C), opacity: 0.45),
          ),
          Positioned(
            left: 150,
            top: f.y(110),
            width: 260,
            height: 260,
            child: Glow(color: const Color(0xFFFFA43A), opacity: 0.45 * span(a.value, 0.1, 0.5)),
          ),
          const Positioned.fill(child: Fog(colors: [Color(0x22B44CFF), Color(0x1AFF9C4A)], blobs: 5, seed: 31, speed: 1)),
          Positioned.fill(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                stops: [f.y(92) / r.height, f.y(104) / r.height, (f.b(668) / r.height).clamp(0, 1), (f.b(708) / r.height).clamp(0, 1)],
              ).createShader(r),
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  height: math.max(f.height, f.y(720) + 40),
                  child: Stack(clipBehavior: Clip.none, children: [_banner(f, a), _section(f, a), for (var i = 0; i < p.quests.length; i++) _row(f, a, p, i), _dailyChest(f, a, p), ..._anchors(f)]),
                ),
              ),
            ),
          ),
          _tabBar(f, a),
        ],
      ),
    );
  }

  List<Widget> _anchors(Frame f) {
    Widget at(GlobalKey k, Rect r) => Positioned.fromRect(
      rect: r,
      child: IgnorePointer(child: SizedBox.expand(key: k)),
    );
    return [
      at(_kChest, Rect.fromLTWH(180, f.y(110), 192, 230)),
      at(_kDaily, Rect.fromLTWH(24, f.y(244), 150, 88)),
      at(_kRow, Rect.fromLTWH(16, f.y(402), 370, 62)),
      at(_kXp, Rect.fromLTWH(319, f.y(402), 67, 62)),
    ];
  }

  /// Daily chest tracker: one gem per finished quest and a live reset countdown.
  Widget _dailyChest(Frame f, Animation<double> a, Player p) {
    final done = p.quests.where((q) => q.done).length;
    return Positioned(
      left: 24,
      top: f.y(244),
      width: 150,
      height: 88,
      child: Staged(
        animation: a,
        begin: 0.45,
        end: 0.8,
        offset: const Offset(-30, 0),
        child: Glass(
          radius: 16,
          blur: 10,
          fill: const [Color(0xB32A1E48), Color(0xA61A1436)],
          line: const Color(0x40FFD45A),
          padding: const EdgeInsets.fromLTRB(11, 9, 11, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Line('DAILY CHEST', style: poppins(8, FontWeight.w700, color: Tone.butter, tracking: 1.3)),
                  const Spacer(),
                  Line('$done/${p.quests.length}', style: poppins(9.5, FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < p.quests.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          gradient: i < done ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE07A), Color(0xFFF08A10)]) : null,
                          color: i < done ? null : const Color(0x1AFFFFFF),
                          border: Border.all(color: i < done ? const Color(0xFFFFF2B0) : const Color(0x26FFFFFF)),
                          boxShadow: i < done ? const [BoxShadow(color: Color(0x88FFB02E), blurRadius: 8)] : null,
                        ),
                        child: Center(child: PhIcon(i < done ? Ph.check : Ph.star, size: 11, color: i < done ? const Color(0xFF4A2300) : const Color(0x40FFFFFF))),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Tick(
                builder: (context, s, _) {
                  final now = DateTime.now();
                  final left = DateTime(now.year, now.month, now.day + 1).difference(now);
                  String two(int v) => v.toString().padLeft(2, '0');
                  return Row(
                    children: [
                      Line('Resets in ', style: poppins(9.5, FontWeight.w400, color: const Color(0xFF9C98BC))),
                      Line('${two(left.inHours)}:${two(left.inMinutes % 60)}:${two(left.inSeconds % 60)}', style: poppins(9.5, FontWeight.w700, color: const Color(0xFFE6E3F5))),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBar(Frame f, Animation<double> a) {
    final cur = _tabs[_tab];
    return Positioned(
      key: _kTabs,
      left: 0,
      right: 0,
      top: f.y(51),
      height: 42,
      child: Staged(
        animation: a,
        begin: 0,
        end: 0.35,
        offset: const Offset(0, -24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final t in _tabs)
              Positioned(
                left: t.$1,
                width: t.$2,
                top: 0,
                bottom: 0,
                child: const Glass(radius: 13, blur: 8, fill: [Color(0xCC111433), Color(0xCC0D1030)], line: Color(0x332C2F63), shadow: false, child: SizedBox.expand()),
              ),
            TweenAnimationBuilder<Rect?>(
              tween: RectTween(end: Rect.fromLTWH(cur.$1, 0, cur.$2, 42)),
              duration: const Duration(milliseconds: 560),
              curve: settle,
              builder: (context, r, _) => Positioned.fromRect(
                rect: r!,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8A6CE0), Color(0xFF6B4AD0)]),
                    border: Border.all(color: const Color(0x80C6B3FF)),
                    boxShadow: const [BoxShadow(color: Color(0x667A4CFF), blurRadius: 16)],
                  ),
                ),
              ),
            ),
            for (var i = 0; i < _tabs.length; i++)
              Positioned(
                left: _tabs[i].$1,
                width: _tabs[i].$2,
                top: 0,
                bottom: 0,
                child: Pressable(
                  onTap: () {
                    if (_tab == i) return;
                    HapticFeedback.selectionClick();
                    setState(() => _tab = i);
                  },
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tabIcon(i),
                        const SizedBox(width: 8),
                        Line(_tabs[i].$3, style: tight(Typo.tab.copyWith(color: i == _tab ? Colors.white : const Color(0xFFDAD6F0)))),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              left: _tabs[1].$1 + _tabs[1].$2 - 12,
              top: -6,
              child: IgnorePointer(
                child: Tick(
                  builder: (context, s, _) => Transform.scale(
                    scale: 1 + math.max(0, math.sin(s * 3.2)) * 0.12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(colors: [Color(0xFFFF5F8F), Color(0xFFE5306A)]),
                        border: Border.all(color: const Color(0xFF110D2E), width: 1.5),
                        boxShadow: const [BoxShadow(color: Color(0x88FF5F8F), blurRadius: 6)],
                      ),
                      child: Line('2', style: poppins(9, FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabIcon(int i) {
    final active = i == _tab;
    Widget icon;
    if (i == 0) {
      icon = SizedBox(width: 26, height: 23, child: Art.trophy.image(fit: BoxFit.contain));
    } else {
      icon = GradientIcon(i == 1 ? Ph.star : Ph.gift, size: 22, colors: const [Color(0xFFC9C3E8), Color(0xFF8E88B8)]);
    }
    return AnimatedScale(scale: active ? 1.12 : 1, duration: const Duration(milliseconds: 400), curve: pop, child: icon);
  }

  Widget _banner(Frame f, Animation<double> a) {
    const art = Art.chestPedestal;
    const k = 0.88;
    final w = art.w * k;
    final h = art.h * k;
    const left = 186.0;
    final top = f.y(116);
    final chestCenter = Offset(left + w * 0.5, top + h * 0.3);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: chestCenter.dx - 130,
          top: chestCenter.dy - 130,
          width: 260,
          height: 260,
          child: Opacity(
            opacity: span(a.value, 0.15, 0.6),
            child: const GodRays(color: Color(0xFFFFC85A), rays: 14, opacity: 0.32, speed: 0.03, spread: 0.4),
          ),
        ),
        Positioned(
          left: chestCenter.dx - 70,
          top: chestCenter.dy - 70,
          width: 140,
          height: 140,
          child: Opacity(
            opacity: span(a.value, 0.15, 0.6),
            child: const Glow(color: Color(0xFFFFD27A), opacity: 0.8),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          width: w,
          height: h,
          child: Staged(
            animation: a,
            begin: 0.05,
            end: 0.5,
            offset: const Offset(0, 60),
            scale: 0.6,
            curve: pop,
            child: GestureDetector(
              onTap: () => _tapChest(chestCenter),
              child: AnimatedBuilder(
                animation: _rattle,
                builder: (context, child) => Transform.rotate(angle: shake(_rattle.value, freq: 6, decay: 3) * 0.08, alignment: Alignment.bottomCenter, child: child),
                child: Tick(
                  builder: (context, s, child) {
                    final hop = cycle(s, 3.6);
                    final lid = hop < 0.14 ? math.sin(hop / 0.14 * math.pi) : 0.0;
                    return Transform(alignment: Alignment.bottomCenter, transform: Matrix4.identity()..scaleByDouble(1 + lid * 0.025, 1 - lid * 0.02 + 0.006 * wave(s, 2.8), 1, 1), child: child);
                  },
                  child: art.image(),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: left - 10,
          top: top - 30,
          width: w + 20,
          height: h * 0.6,
          child: Opacity(
            opacity: span(a.value, 0.4, 0.7),
            child: const Stack(
              children: [
                Positioned.fill(
                  child: Motes(count: 12, colors: [Color(0xFFFFE07A), Color(0xFFE77BFF)], speed: 10, sway: 6, seed: 41, size: (0.8, 2.0), life: 4),
                ),
                Positioned.fill(
                  child: Twinkles(points: [(30, 50, 6), (170, 30, 7), (150, 110, 5), (16, 120, 4)], color: Color(0xFFFFF0B8), period: 2.2),
                ),
              ],
            ),
          ),
        ),
        _bubble(f, a),
      ],
    );
  }

  Widget _bubble(Frame f, Animation<double> a) {
    final pop0 = span(a.value, 0.35, 0.65, pop);
    final typed = span(a.value, 0.45, 0.85, Curves.linear);
    const text = 'Small steps...\nbig rewards!';
    final shown = text.substring(0, (text.length * typed).round());
    return Positioned(
      left: 34,
      top: f.y(134),
      width: 150,
      height: 92,
      child: Opacity(
        opacity: span(a.value, 0.35, 0.45, Curves.linear),
        child: Bob(
          amplitude: 3,
          period: 3.6,
          child: Transform.rotate(
            angle: -0.06,
            child: Transform.scale(
              scale: pop0,
              alignment: Alignment.bottomRight,
              child: CustomPaint(
                painter: _BubblePainter(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 20),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 0,
                        child: Text(text, style: Typo.bubble, textAlign: TextAlign.center),
                      ),
                      Positioned.fill(
                        child: Text(shown, style: Typo.bubble, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(Frame f, Animation<double> a) {
    return Positioned.fill(
      child: Staged(
        animation: a,
        begin: 0.2,
        end: 0.5,
        offset: const Offset(0, 16),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: f.y(364 - ascent * 19.8),
              child: GradientText('Daily Quests', style: tight(Typo.section), colors: const [Color(0xFFFFF7D6), Color(0xFFF6E3A0)]),
            ),
            Positioned(
              right: 16,
              top: f.y(362 - ascent * 12.6),
              child: Pressable(
                onTap: () => HapticFeedback.selectionClick(),
                child: Row(
                  children: [
                    Line('See All', style: tight(Typo.seeAll)),
                    const SizedBox(width: 6),
                    Tick(
                      builder: (context, s, _) => Transform.translate(
                        offset: Offset(math.max(0, wave(s, 1.4)) * 3, 0),
                        child: const PhIcon(Ph.arrowRight, size: 15, color: Tone.butter),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextAt('Complete daily tasks and earn rewards!', style: Typo.caption, x: 16, baseline: f.y(386)),
          ],
        ),
      ),
    );
  }

  static const _icons = [Art.icWater, Art.icShoe, Art.icDumbbell, Art.icWater];

  Widget _row(Frame f, Animation<double> a, Player p, int i) {
    final q = p.quests[i];
    final top = f.y(402 + i * 74.0);
    final value = q.progress / q.goal;
    final alt = _tab != 0;
    return Positioned(
      left: 16,
      top: top,
      width: 370,
      height: 62,
      child: Staged(
        animation: a,
        begin: 0.3 + i * 0.08,
        end: 0.65 + i * 0.08,
        offset: const Offset(0, 40),
        rotateX: 0.9,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(begin: const Offset(0.15, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: gentle)),
              child: child,
            ),
          ),
          child: alt ? _altRow(i, key: ValueKey('alt$_tab$i')) : _questRow(q, i, value, top, key: ValueKey('q$i')),
        ),
      ),
    );
  }

  Widget _questRow(Quest q, int i, double value, double top, {Key? key}) {
    final icon = i == 3 ? null : _icons[i];
    String? sub;
    String? count;
    if (q.unit == 'steps') {
      sub = _thousands(q.progress);
    } else if (i == 0) {
      count = '${q.progress} / ${q.goal}';
    } else {
      sub = '${q.progress}';
    }
    return Pressable(
      key: key,
      scale: 0.97,
      onTap: () => _advance(q, Offset(16 + 50, top + 31 - _scroll.offset)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: q.done ? const [BoxShadow(color: Color(0x55FFC94A), blurRadius: 18)] : null,
              ),
              child: Glass(
                radius: 16,
                blur: 10,
                fill: q.done ? const [Color(0xCC3A3050), Color(0xBF2A2340)] : const [Color(0xB32E2B4A), Color(0xA6221F3C)],
                line: q.done ? const Color(0x80FFD45A) : const Color(0x26C9C3FF),
                shadow: false,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: 70,
            height: 62,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF45345F), Color(0xFF33284D)]),
                border: Border.all(color: const Color(0x1FFFFFFF)),
              ),
              child: Center(
                child: icon == null
                    ? const GradientIcon(Ph.sparkle, size: 26, colors: [Color(0xFFE2D6FF), Color(0xFF9D86E8)])
                    : SizedBox(
                        width: icon.w * 0.92,
                        height: icon.h * 0.92,
                        child: Bob(amplitude: 1.6, period: 2.4, phase: i * 0.3, tilt: 0.05, child: icon.image()),
                      ),
              ),
            ),
          ),
          if (q.done)
            Positioned(
              left: 46,
              top: 36,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: pop,
                builder: (context, t, _) => Transform.scale(
                  scale: t,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Tone.green,
                      border: Border.all(color: const Color(0xFF221D3A), width: 2),
                    ),
                    child: const Center(child: PhIcon(Ph.check, size: 11, color: Colors.white)),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 84,
            top: 22 - ascent * 12.6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Line(q.title, style: tight(Typo.rowTitle)),
                const SizedBox(width: 6),
                _Tier(i),
              ],
            ),
          ),
          if (count != null) TextAt(count, style: Typo.rowCount, right: 82, baseline: 28),
          if (sub != null)
            Positioned(
              left: 84,
              top: 43 - ascent * 13,
              child: Row(
                children: [
                  Line(sub, style: tight(Typo.rowSub)),
                  Line(' / ${q.unit == 'steps' ? _thousands(q.goal) : '${q.goal}'}', style: tight(Typo.rowSubDim)),
                ],
              ),
            ),
          Positioned(
            left: 84,
            top: count != null ? 42 : 51,
            child: LiquidBar(
              value: value,
              width: 200,
              height: count != null ? 8 : 6,
              track: const Color(0xFF34314F),
              colors: q.done ? const [Color(0xFFFFE07A), Color(0xFFFFB21C)] : const [Color(0xFF52E1D6), Color(0xFF3FB8D4)],
              delay: Duration(milliseconds: 800 + i * 120),
            ),
          ),
          if (count == null) Positioned(left: 272, top: 15, child: PhIcon(Ph.caretRight, size: 12, color: const Color(0xFF8E8AB0).withValues(alpha: 0.7))),
          Positioned(
            right: 0,
            top: 0,
            width: 67,
            height: 62,
            child: _XpBadge(xp: q.xp, done: q.done),
          ),
        ],
      ),
    );
  }

  Widget _altRow(int i, {Key? key}) {
    final achievements = [
      (Art.shieldGold, 'Iron Will', 'Keep a 12 day streak', 'Earned'),
      (Art.shieldPurple, 'Push-up Prodigy', '100 push-ups in a week', '64 / 100'),
      (Art.trophy, 'Quest Master', 'Finish 50 daily quests', '31 / 50'),
      (Art.fire, 'On Fire', 'Burn 5,000 calories', '2,840 / 5,000'),
    ];
    final rewards = [
      (Art.chestSmall, 'Epic Chest', 'Unlocks at Level 13', 'Lv 13'),
      (Art.gift, 'Daily Gift', 'Ready to open on Home', 'Ready'),
      (Art.shieldPurple, 'Mythic Frame', 'Avatar border', '1,200 XP'),
      (Art.icBolt, '2x XP Boost', '30 minutes of double XP', '800 XP'),
    ];
    final (art, title, sub, tag) = (_tab == 1 ? achievements : rewards)[i];
    return Glass(
      key: key,
      radius: 16,
      blur: 10,
      fill: const [Color(0xB32E2B4A), Color(0xA6221F3C)],
      shadow: false,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: 70,
            height: 62,
            child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xFF3B2E58)),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Bob(
                    amplitude: 1.5,
                    period: 2.6,
                    phase: i * 0.2,
                    child: Image.asset(art.path, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
          TextAt(title, style: Typo.rowTitle, x: 84, baseline: 25),
          TextAt(sub, style: Typo.caption, x: 84, baseline: 45),
          Positioned(
            right: 12,
            top: 19,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0x33FFD45A),
                border: Border.all(color: const Color(0x66FFD45A)),
              ),
              child: Line(tag, style: tight(Typo.seeAll.copyWith(fontSize: 11.5))),
            ),
          ),
        ],
      ),
    );
  }

  static String _thousands(int v) {
    final s = '$v';
    return s.length > 3 ? '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}' : s;
  }
}

/// Difficulty tag beside each quest title.
class _Tier extends StatelessWidget {
  const _Tier(this.i);

  final int i;

  static const _tiers = [('EASY', Color(0xFF3AD06B)), ('MED', Color(0xFFFFB02E)), ('HARD', Color(0xFFFF5F8F)), ('EASY', Color(0xFF3AD06B))];

  @override
  Widget build(BuildContext context) {
    final (label, c) = _tiers[i % _tiers.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 0.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: c.withValues(alpha: 0.16),
        border: Border.all(color: c.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Line(label, style: poppins(7, FontWeight.w700, color: c, tracking: 0.8)),
    );
  }
}

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.xp, required this.done});

  final int xp;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: done ? 1 : 0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutBack,
      builder: (context, t, _) {
        final flip = t * math.pi;
        final back = flip > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.003)
            ..rotateY(flip),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: back ? const Color(0xFF3A2E1A) : const Color(0xFF272341),
              border: Border.all(color: back ? const Color(0x99FFD45A) : const Color(0x1AFFFFFF)),
            ),
            child: back
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: const Center(child: PhIcon(Ph.check, size: 26, color: Tone.butter)),
                  )
                : Sheen(
                    period: 3.5,
                    delay: xp / 100,
                    strength: 0.45,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 28 - ascent * 16,
                          child: Center(
                            child: GradientText('XP', style: tight(Typo.xpLabel), colors: const [Color(0xFFFFB0F0), Color(0xFFE89BFF), Color(0xFFFFD36B)]),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 50 - ascent * 16.6,
                          child: Center(child: Line('$xp', style: tight(Typo.xpValue))),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height - 12), const Radius.circular(16));
    final tail = Path()
      ..moveTo(size.width - 44, size.height - 13)
      ..lineTo(size.width - 18, size.height + 2)
      ..lineTo(size.width - 26, size.height - 13)
      ..close();
    final path = Path()
      ..addRRect(body)
      ..addPath(tail, Offset.zero);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x99FFB02E)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawPath(
      path,
      Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFCD48A), Color(0xFFF2B865)]).createShader(Offset.zero & size),
    );
    canvas.drawRRect(
      body.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x99FFF2D0),
    );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;
}
