import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'layout.dart';
import 'mood.dart';
import 'painters/gauge_painter.dart';
import 'painters/orb_painter.dart';
import 'painters/sky_painter.dart';
import 'widgets/glass_nav.dart';
import 'widgets/header.dart';
import 'widgets/mood_switch.dart';
import 'widgets/stats_row.dart';

class LullHome extends StatefulWidget {
  const LullHome({super.key, this.framed = false});

  /// Draws a fake iOS status bar when shown inside the desktop/web phone frame.
  final bool framed;

  @override
  State<LullHome> createState() => LullHomeState();
}

class LullHomeState extends State<LullHome> with TickerProviderStateMixin {
  static const _spring = SpringDescription(mass: 1, stiffness: 380, damping: 21);
  static final _stops = Mood.values.length;

  /// Seconds since start; drives every ambient loop without rebuilding widgets.
  final _time = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker((e) => _time.value = e.inMicroseconds / 1e6);

  late final AnimationController _morph =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100), value: 1);
  late final AnimationController _knob = AnimationController.unbounded(vsync: this, value: 1);
  late final AnimationController _poke = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  Mood _target = Mood.radiant;

  /// Snapshot of what was on screen when the current morph started, so a new
  /// mood can interrupt a running morph without any jump.
  MoodVisual _from = kMoods[Mood.radiant]!.visual;
  int _dir = -1;
  int _tab = 0;
  int? _hoverChip;
  bool _dragging = false;

  double get _mt => Curves.easeInOutCubic.transform(_morph.value);
  MoodVisual get visual => MoodVisual.lerp(_from, kMoods[_target]!.visual, _mt);

  static double _detent(Mood m) => m.index / (_stops - 1);

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    _morph.dispose();
    _knob.dispose();
    _poke.dispose();
    super.dispose();
  }

  void _setMood(Mood m) {
    if (m == _target) return;
    _from = visual;
    setState(() => _target = m);
    _morph.forward(from: 0);
    HapticFeedback.selectionClick();
  }

  void _springKnob([double velocity = 0]) =>
      _knob.animateWith(SpringSimulation(_spring, _knob.value, _detent(_target), velocity));

  void step(int dir) {
    _setMood(Mood.values[(_target.index + dir).clamp(0, _stops - 1)]);
    _springKnob();
  }

  /// Taps ping-pong across the stops, like flicking the original toggle.
  void tapSwitch() {
    var next = _target.index + _dir;
    if (next < 0 || next >= _stops) {
      _dir = -_dir;
      next = _target.index + _dir;
    }
    _setMood(Mood.values[next]);
    _springKnob();
  }

  void dragSwitch(double pos) {
    _dragging = true;
    final p = pos.clamp(0.0, 1.0);
    _knob.value = p;
    _setMood(Mood.values[(p * (_stops - 1)).round()]);
  }

  void endDrag(double velocity) {
    _dragging = false;
    _springKnob(velocity);
  }

  void pokeOrb() {
    HapticFeedback.lightImpact();
    _poke.forward(from: 0);
  }

  void selectTab(int i) {
    HapticFeedback.selectionClick();
    setState(() => _tab = i);
  }

  void hoverChip(int? i) {
    if (i != _hoverChip) setState(() => _hoverChip = i);
  }

  void goTo(Mood m) {
    _setMood(m);
    _springKnob();
  }

  Mood get mood => _target;
  double get knob => _knob.value;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return LayoutBuilder(builder: (context, c) {
      final geo = Geo(Size(c.maxWidth, c.maxHeight), safeTop: mq.padding.top, safeBottom: mq.padding.bottom);
      final s = geo.s;
      return AnimatedBuilder(
        animation: _morph,
        builder: (context, _) {
          final v = visual;
          final spec = kMoods[_target]!;
          final dip = sin(pi * _morph.value) * (_dragging ? 8 : 26) * s;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: v.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (d) {
                final vx = d.primaryVelocity ?? 0;
                if (vx.abs() > 250) step(vx > 0 ? 1 : -1);
              },
              onTapUp: (d) {
                if ((d.localPosition - (geo.orbCenter + Offset(0, dip))).distance < geo.orbR) pokeOrb();
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(child: CustomPaint(painter: SkyPainter(v: v, time: _time, geo: geo))),
                  ),
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: OrbPainter(v: v, time: _time, geo: geo, dip: dip, poke: _poke),
                      ),
                    ),
                  ),
                  Positioned.fill(child: CustomPaint(painter: GaugePainter(v: v, geo: geo, value: v.gauge / 100))),
                  if (widget.framed) _StatusBar(color: v.isDark ? Colors.white : Colors.black),
                  Positioned(
                    left: 14 * s,
                    right: 14 * s,
                    top: geo.y(42),
                    height: 40 * s,
                    child: LullHeader(v: v, s: s),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: geo.y(108),
                    height: 90 * s,
                    child: StatsRow(
                      mood: _target,
                      spec: spec,
                      v: v,
                      s: s,
                      hovered: _hoverChip,
                      onHover: hoverChip,
                    ),
                  ),
                  Positioned(
                    left: geo.x(195 - 13),
                    top: geo.y(257 - 13),
                    width: 26 * s,
                    height: 26 * s,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: v.chip, shape: BoxShape.circle),
                      child: _fadeSwap(Icon(spec.gaugeIcon, key: ValueKey(_target), size: 13 * s, color: v.ink)),
                    ),
                  ),
                  _at(geo, 305, 60, Text('${v.gauge.round()}',
                      style: inter(50 * s, FontWeight.w600, v.ink, ls: -1.5 * s, height: 1, tabular: true))),
                  _at(geo, 337, 14, _fadeSwap(Text(spec.gaugeLabel,
                      key: ValueKey(_target), style: inter(9.5 * s, FontWeight.w700, v.ink, ls: 1.8 * s)))),
                  _at(geo, 386.5, 56, _slideSwap(Text(spec.headline,
                      key: ValueKey(_target),
                      textAlign: TextAlign.center,
                      style: inter(20.5 * s, FontWeight.w800, v.headline, ls: -0.3 * s, height: 1.22)))),
                  _at(geo, 424, 16, _slideSwap(Text(spec.sub,
                      key: ValueKey(_target), style: inter(10.5 * s, FontWeight.w500, v.inkSoft)))),
                  Positioned(
                    left: geo.x(195 - 59),
                    top: geo.y(474 - 23),
                    width: 118 * s,
                    height: 46 * s,
                    child: AnimatedBuilder(
                      animation: _knob,
                      builder: (context, _) => MoodSwitch(
                        position: _knob.value,
                        v: v,
                        s: s,
                        stops: _stops,
                        onTap: tapSwitch,
                        onDrag: dragSwitch,
                        onDragEnd: endDrag,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16 * s,
                    width: 287 * s,
                    height: 58 * s,
                    bottom: max(28 * s, geo.safeBottom + 6),
                    child: GlassNav(v: v, s: s, index: _tab, onTap: selectTab),
                  ),
                  Positioned(
                    left: (348 - 29) * s,
                    width: 58 * s,
                    height: 58 * s,
                    bottom: max(28 * s, geo.safeBottom + 6),
                    child: GlassPlus(v: v, s: s),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  /// Centres [child] on design line [y] in a band [h] points tall.
  static Widget _at(Geo g, double y, double h, Widget child) => Positioned(
        left: 0,
        right: 0,
        top: g.y(y) - h * g.s / 2,
        height: h * g.s,
        child: Center(child: child),
      );

  static Widget _fadeSwap(Widget child) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: child,
      );

  static Widget _slideSwap(Widget child) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 560),
        reverseDuration: const Duration(milliseconds: 260),
        switchInCurve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: anim.drive(Tween(begin: const Offset(0, 0.28), end: Offset.zero)),
            child: child,
          ),
        ),
        child: child,
      );
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 47,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(38, 14, 30, 0),
        child: Row(
          children: [
            Text('9:41', style: inter(15.5, FontWeight.w600, color)),
            const Spacer(),
            Icon(Icons.signal_cellular_alt_rounded, size: 17, color: color),
            const SizedBox(width: 5),
            Icon(Icons.wifi_rounded, size: 17, color: color),
            const SizedBox(width: 5),
            Icon(Icons.battery_full_rounded, size: 21, color: color),
          ],
        ),
      ),
    );
  }
}
