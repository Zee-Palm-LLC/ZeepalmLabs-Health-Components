import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../icons.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/art.dart';
import '../widgets/common.dart';
import '../widgets/gauges.dart';
import '../widgets/motion.dart';
import '../widgets/routes.dart';
import 'checkin.dart';
import 'mobility.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500), value: stillMode ? 1 : 0)..forward();
  late final _drift = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();
  late final _sun = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  late final _bell = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  int _tab = 0;

  @override
  void dispose() {
    _enter.dispose();
    _drift.dispose();
    _sun.dispose();
    _bell.dispose();
    super.dispose();
  }

  void _openCheckIn(BuildContext from) => pushReveal(from, (_) => const CheckInScreen());
  void _openSession(BuildContext from) => pushReveal(from, (_) => const MobilityScreen());

  Widget _r(int i, Widget child, {double dy = 22}) => Reveal(anim: _enter, index: i, dy: dy, child: child);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: DesignCanvas(
        child: Builder(builder: (context) {
          final mq = MediaQuery.of(context);
          final top = math.max(0.0, mq.padding.top - 47);
          return PageBackground(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: 57 + top, bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _r(0, _header(), dy: 12),
                        const SizedBox(height: 23),
                        _r(1, _greeting()),
                        const SizedBox(height: 17),
                        _r(2, Builder(builder: (c) => _movementCard(c))),
                        const SizedBox(height: 19),
                        _r(3, _planHeader()),
                        const SizedBox(height: 17),
                        _r(4, _planCards()),
                        const SizedBox(height: 21),
                        _r(
                          5,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 21),
                            child: Builder(
                              builder: (c) => DarkButton(
                                label: 'Continue session',
                                icon: PhRegular.play,
                                heroTag: 'session-cta',
                                onTap: () => _openSession(c),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(left: 0, right: 0, bottom: 0, child: _r(6, _nav(context, mq.padding.bottom), dy: 40)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          const SizedBox(width: 22),
          const LeafLogo(size: 30),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Reforma', style: inter(26, FontWeight.w400, C.ink, ls: -0.4, height: 1.0)),
              const SizedBox(height: 4),
              Text('Better Movement. Brighter Days.', style: inter(10, FontWeight.w400, C.ink2, height: 1.0)),
            ],
          ),
          const Spacer(),
          Pressable(
            onTap: () => _bell.forward(from: 0),
            child: AnimatedBuilder(
              animation: _bell,
              builder: (context, child) {
                final t = _bell.value;
                return Transform.rotate(
                  angle: math.sin(t * math.pi * 6) * (1 - t) * 0.45,
                  alignment: const Alignment(0, -0.9),
                  child: child,
                );
              },
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(PhFill.bell, size: 22, color: C.ink),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _greeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: GlassCard(
        child: SizedBox(
          height: 96,
          child: Row(
            children: [
              const SizedBox(width: 9),
              Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: cardShadow),
                child: const ClipOval(child: ThumbArt(ThumbKind.avatar)),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Good morning,', style: inter(13.5, FontWeight.w400, C.ink, height: 1.1)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text('Alex', style: inter(24, FontWeight.w500, C.ink, ls: -0.3, height: 1.15)),
                      const SizedBox(width: 6),
                      CustomPaint(size: const Size(20, 20), painter: SunPainter(_sun)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Small steps. Big progress.', style: inter(11, FontWeight.w400, C.ink2, height: 1.1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _movementCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Pressable(
        scale: 0.985,
        onTap: () => _openCheckIn(context),
        child: Container(
          height: 226,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: cardShadow,
            border: Border.all(color: const Color(0xCCFFFFFF)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Stack(
              children: [
                const Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: SkyPainter()))),
                // Cloud bank drifting slowly in front of the peak.
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _drift,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(math.sin(_drift.value * math.pi * 2) * 14, 0),
                      child: child,
                    ),
                    child: const RepaintBoundary(child: CustomPaint(painter: CloudPainter())),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 17,
                  child: Text('Movement &\nrecovery', style: inter(22, FontWeight.w400, C.ink, ls: -0.3, height: 1.22)),
                ),
                Positioned(
                  left: 14,
                  top: 78,
                  child: Text('Feel better. Move better.\nLive better.',
                      style: inter(11, FontWeight.w400, C.ink2, height: 1.5)),
                ),
                const Positioned(right: 14, top: 13, child: Opacity(opacity: 0.8, child: LeafLogo(size: 13))),
                const Positioned(left: 15, top: 141, child: Opacity(opacity: 0.35, child: LeafLogo(size: 12, color: C.ink2))),
                Positioned(
                  left: 215,
                  top: 25,
                  child: ValueListenableBuilder(
                    valueListenable: AppState.pain,
                    builder: (context, _, _) => RecoveryRing(value: AppState.recovery),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  top: 159,
                  child: ValueListenableBuilder(
                    valueListenable: AppState.pain,
                    builder: (context, p, _) => Row(
                      children: [
                        _pill(93, _painIcon(), 'Pain', AppState.painChecked.value ? AppState.painWords[p] : 'Low'),
                        const SizedBox(width: 11),
                        _pill(100, const Icon(PhBold.personSimpleRun, size: 19, color: C.teal), 'Mobility', 'Good'),
                        const SizedBox(width: 11),
                        Expanded(child: _pill(null, const Icon(PhRegular.waves, size: 19, color: C.ink2), 'Stiffness', 'Mild')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _painIcon() => Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(color: C.teal, shape: BoxShape.circle),
        child: const Icon(PhBold.smiley, size: 15, color: Colors.white),
      );

  Widget _pill(double? w, Widget icon, String a, String b) {
    return Container(
      width: w,
      height: 48,
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: const Color(0xB3FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x99FFFFFF)),
      ),
      child: Row(
        children: [
          SizedBox(width: 24, child: Center(child: icon)),
          const SizedBox(width: 9),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a, style: inter(11, FontWeight.w400, C.ink, height: 1.25)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(a),
                    child: c,
                  ),
                ),
                child: Text(b, key: ValueKey(b), style: inter(11, FontWeight.w500, C.ink, height: 1.25)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today's plan", style: inter(19, FontWeight.w500, C.ink, ls: -0.2)),
              const SizedBox(height: 3),
              Text('Mon, 26 May', style: inter(10.5, FontWeight.w400, C.ink2)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 2),
              Text('Mon, 26 May', style: inter(10.5, FontWeight.w400, C.ink2)),
              const SizedBox(height: 3),
              Text('3 exercises • 24 min', style: inter(10.5, FontWeight.w400, C.ink2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planCards() {
    Widget card(ThumbKind t, String title, String sub) => Expanded(
          child: Builder(
            builder: (c) => Pressable(
              scale: 0.965,
              onTap: () => _openSession(c),
              child: Container(
                height: 137,
                decoration: BoxDecoration(
                  color: const Color(0xE6FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: SizedBox(height: 91, child: ThumbArt(t)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(title, style: inter(12.5, FontWeight.w500, C.ink)),
                                const SizedBox(height: 3),
                                Text(sub, style: inter(9.5, FontWeight.w400, C.muted)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 19,
                              height: 19,
                              decoration: const BoxDecoration(color: C.button, shape: BoxShape.circle),
                              child: const Icon(PhBold.arrowRight, size: 11, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Row(
        children: [
          card(ThumbKind.glute, 'Glute Bridges', '8 reps • 2 sets'),
          const SizedBox(width: 10),
          card(ThumbKind.hip, 'Hip Thrusts', '8 reps • 2 sets'),
        ],
      ),
    );
  }

  Widget _nav(BuildContext context, double bottomInset) {
    const items = [
      (PhRegular.house, PhFill.house, 'Home'),
      (PhRegular.barbell, PhFill.barbell, 'Exercises'),
      (PhRegular.chartBar, PhFill.chartBar, 'Progress'),
      (PhRegular.user, PhFill.user, 'Profile'),
    ];
    return Container(
      height: 55 + math.max(34.0, bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xF2FFFFFF),
        border: Border(top: BorderSide(color: C.line, width: 0.6)),
      ),
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 55,
        child: Row(
          children: [
            for (final (i, it) in items.indexed)
              Expanded(
                child: Builder(
                  builder: (c) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _tab = i);
                      if (i == 1) _openSession(c);
                      if (i == 2) _openCheckIn(c);
                      if (i != 0) {
                        Future.delayed(const Duration(milliseconds: 700), () {
                          if (mounted) setState(() => _tab = 0);
                        });
                      }
                    },
                    child: _NavItem(icon: it.$1, active: it.$2, label: it.$3, on: _tab == i),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.active, required this.label, required this.on});

  final IconData icon, active;
  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final color = on ? C.teal : const Color(0xFF9A9EA3);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: on ? 1 : 0),
      duration: const Duration(milliseconds: 520),
      curve: springy,
      builder: (context, v, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, -2.5 * v),
              child: Transform.scale(
                scale: 1 + 0.12 * v,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(opacity: (1 - v).clamp(0.0, 1.0), child: Icon(icon, size: 23, color: color)),
                    Opacity(opacity: v.clamp(0.0, 1.0), child: Icon(active, size: 23, color: color)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: inter(10, on ? FontWeight.w500 : FontWeight.w400, color)),
          ],
        );
      },
    );
  }
}
