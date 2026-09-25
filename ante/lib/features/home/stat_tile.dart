import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';
import '../../widgets/rolling_number.dart';

class Stat {
  const Stat({
    required this.rect,
    required this.value,
    required this.label,
    required this.delta,
    required this.up,
    required this.sprite,
    required this.fill,
    required this.edge,
    required this.ink,
    required this.labelInk,
    required this.pillX,
    required this.valueX,
    required this.labelX,
  });

  final Rect rect;
  final String value;
  final String label;
  final String delta;
  final bool up;
  final Sprite sprite;
  final List<Color> fill;
  final Color edge;
  final Color ink;
  final Color labelInk;
  final double pillX;
  final double valueX;
  final double labelX;
}

const stats = [
  Stat(
    rect: Rect.fromLTRB(11.7, 715.7, 191.7, 780.3),
    value: r'$140',
    label: 'Money Saved',
    delta: '+12%',
    up: true,
    sprite: Art.sBag,
    fill: [Color(0xFF0A2E2F), Color(0xFF042024)],
    edge: Color(0xFF1B4A47),
    ink: Color(0xFF5ED3A6),
    labelInk: Color(0xFF7E9DA0),
    pillX: 144.2,
    valueX: 64.67,
    labelX: 64.5,
  ),
  Stat(
    rect: Rect.fromLTRB(205.1, 715.7, 382.4, 780.3),
    value: '12',
    label: 'Day Streak',
    delta: '+3',
    up: true,
    sprite: Art.sFlame,
    fill: [Color(0xFF2A1C29), Color(0xFF1D1520)],
    edge: Color(0xFF45383F),
    ink: Color(0xFFF2A55B),
    labelInk: Color(0xFF8E8C9F),
    pillX: 335.6,
    valueX: 264.0,
    labelX: 263.5,
  ),
  Stat(
    rect: Rect.fromLTRB(11.7, 788.3, 191.7, 852.3),
    value: '3',
    label: 'Pools Joined',
    delta: '+1',
    up: true,
    sprite: Art.sPeople,
    fill: [Color(0xFF0D1B38), Color(0xFF08132B)],
    edge: Color(0xFF1F2A44),
    ink: Color(0xFF6E9BFF),
    labelInk: Color(0xFF7F8AA7),
    pillX: 146.0,
    valueX: 67.5,
    labelX: 67.0,
  ),
  Stat(
    rect: Rect.fromLTRB(205.1, 788.3, 382.4, 852.3),
    value: '18',
    label: 'At Risk',
    delta: '-4',
    up: false,
    sprite: Art.sWarn,
    fill: [Color(0xFF221428), Color(0xFF170F22)],
    edge: Color(0xFF34253A),
    ink: Color(0xFFF26B7C),
    labelInk: Color(0xFF8C889F),
    pillX: 335.6,
    valueX: 264.0,
    labelX: 263.0,
  ),
];

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.stat, required this.entrance, required this.order});

  final Stat stat;
  final Animation<double> entrance;
  final int order;

  @override
  Widget build(BuildContext context) {
    final r = stat.rect;
    final value = inter(17.6, 700, color: const Color(0xFFE8EBF0));
    final label = inter(11, 400, color: stat.labelInk);
    final pill = inter(9.4, 600, color: stat.ink);
    final s = stat.sprite;
    final begin = 0.55 + order * 0.06;
    final cap = r.top + 16.9;
    return Pressable(
      onTap: () {},
      scale: 0.965,
      child: SizedBox(
        width: r.width,
        height: r.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: stat.fill),
                  border: Border.all(color: stat.edge, width: 1.1),
                ),
              ),
            ),
            Positioned(
              left: s.left - r.left,
              top: s.top - r.top,
              width: s.width,
              height: s.height,
              child: _Icon(stat: stat, child: s.image()),
            ),
            Positioned(
              left: stat.valueX - r.left - bearing(stat.value, value),
              top: cap - r.top - capInset(value),
              child: AnimatedBuilder(
                animation: entrance,
                builder: (context, _) => RollingNumber(
                  text: stat.value,
                  style: value,
                  progress: span(entrance.value, begin + 0.05, begin + 0.4, Curves.linear),
                ),
              ),
            ),
            Positioned(
              left: stat.labelX - r.left - bearing(stat.label, label),
              top: 40.8 - capInset(label),
              child: Text(stat.label, style: label),
            ),
            Positioned(
              left: stat.pillX - r.left,
              top: 23.8 - 8.1,
              child: Staged(
                animation: entrance,
                begin: begin + 0.18,
                end: begin + 0.42,
                offset: const Offset(10, 0),
                scale: 0.6,
                curve: settle,
                child: Container(
                  height: 16.2,
                  padding: const EdgeInsets.symmetric(horizontal: 5.4),
                  decoration: BoxDecoration(
                    color: stat.ink.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(8.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: stat.up ? 0 : math.pi,
                        child: PhIcon(Ph.arrowUp, size: 8.5, color: stat.ink),
                      ),
                      const SizedBox(width: 3),
                      Text(stat.delta, style: pill),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.stat, required this.child});

  final Stat stat;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, s, inner) {
        final phase = stat.value.length * 0.21;
        final a = wave(s, 2.4, phase) - wave(0, 2.4, phase);
        return Transform.scale(scale: 1 + a * 0.035, child: inner);
      },
      child: child,
    );
  }
}
