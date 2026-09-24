import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/phosphor.dart';
import '../../core/type.dart';

class RouteSheet extends StatelessWidget {
  const RouteSheet({super.key, required this.enter, required this.lift, required this.seconds});

  final double enter;
  final double lift;
  final double seconds;

  static const _paragraph = [
    'A beautiful and peaceful loop around the river',
    'with lush greenery, benches and scenic views.',
    'Perfect for beginners and casual walkers.',
  ];

  @override
  Widget build(BuildContext context) {
    double at(double begin, [double length = 0.3]) => span(enter, begin, begin + length, swift);
    Widget rise(double t, Widget child, {double distance = 14}) => Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(offset: Offset(0, (1 - t) * distance), child: child),
    );
    final muted = font(16.35, 500, color: const Color(0xFF7E8794));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 196.5 - 21.5 * at(0.0, 0.25),
          top: 344.5 + lift,
          width: 43 * at(0.0, 0.25),
          height: 5.3,
          child: DecoratedBox(
            decoration: BoxDecoration(color: const Color(0xFFD0D7E4), borderRadius: BorderRadius.circular(3)),
          ),
        ),
        Positioned(
          left: 26.9,
          top: 351.3 + lift,
          width: 73.1,
          height: 23.7,
          child: Transform.scale(
            alignment: Alignment.centerLeft,
            scale: spring(span(enter, 0.05, 0.35, Curves.linear), bounce: 0.45, freq: 2.4),
            child: DecoratedBox(
              decoration: BoxDecoration(color: const Color(0xFFD2F4E6), borderRadius: BorderRadius.circular(11.85)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 16.5 - 7,
                    top: 11 - 7,
                    width: 14,
                    height: 14,
                    child: Transform.rotate(
                      angle: (1 - at(0.12)) * -math.pi * 1.2,
                      child: const Icon(PhosphorFill.star, size: 13, color: Color(0xFF0E9C6C)),
                    ),
                  ),
                  Label('Easy', x: 30.6, base: 17.1, style: font(14.1, 600, color: const Color(0xFF155D4D))),
                ],
              ),
            ),
          ),
        ),
        _Line(t: at(0.08), child: Label('Riverside Park Loop', x: 26.4, base: 402.7 + lift, style: font(22.4, 700, color: const Color(0xFF10213E)))),
        _Line(
          t: at(0.13),
          child: Stack(
            children: [
              Label('Park Route', x: 26.6, base: 426 + lift, style: muted),
              Positioned(
                left: 121.4 - 1.9,
                top: 420.8 - 1.9 + lift,
                width: 3.8,
                height: 3.8,
                child: const DecoratedBox(decoration: BoxDecoration(color: Color(0xFF8C95A2), shape: BoxShape.circle)),
              ),
              Label('Outdoor', x: 136.0, base: 426 + lift, style: muted),
            ],
          ),
        ),
        for (var i = 0; i < 3; i++) _stat(i, enter, lift, seconds),
        rise(at(0.4), Stack(children: [Label('About This Route', x: 27.0, base: 580.7 + lift, style: font(15.2, 700, color: const Color(0xFF16233C)))])),
        for (var i = 0; i < 3; i++)
          rise(
            at(0.45 + i * 0.04),
            Stack(children: [Label(_paragraph[i], x: 27.2, base: [605.0, 622.2, 639.8][i] + lift, style: font(14.5, 500, color: const Color(0xFF7D8693)))]),
            distance: 8,
          ),
        rise(at(0.55), Stack(children: [Label('Highlights', x: 26.9, base: 672.2 + lift, style: font(15.6, 700, color: const Color(0xFF15223B)))])),
        for (final x in const [112.5, 205.0, 297.5])
          Positioned(
            left: x - 0.5,
            top: 713 + lift - 30 * at(0.62),
            width: 1,
            height: 60 * at(0.62),
            child: const ColoredBox(color: Color(0xFFEFF1F5)),
          ),
        for (var i = 0; i < 4; i++) _highlight(i, enter, lift, seconds),
      ],
    );
  }

  Widget _stat(int i, double enter, double lift, double seconds) {
    final left = [20.5, 142.5, 264.5][i];
    final cx = left + 54.25;
    final local = span(enter, 0.22 + i * 0.07, 0.62 + i * 0.07, Curves.linear);
    final pop = spring(local, bounce: 0.3, freq: 2.2);
    final count = span(enter, 0.3 + i * 0.07, 0.95, Curves.easeOutCubic);
    final value = switch (i) {
      0 => '${(2.4 * count).toStringAsFixed(1)} km',
      1 => '${(30 * count).round()} min',
      _ => '~${(180 * count).round()} kcal',
    };
    final label = ['Distance', 'Est. Time', 'Calories'][i];
    final tint = [const Color(0xFFEFF2FA), const Color(0xFFE8F1FC), const Color(0xFFFDF0E3)][i];
    final icon = switch (i) {
      0 => Transform.translate(
        offset: Offset(0, -math.sin(math.pi * span(enter, 0.5, 0.75, Curves.easeOut)) * 6),
        child: const Icon(PhosphorFill.mapPin, size: 23, color: Color(0xFF0E3F58)),
      ),
      1 => Transform.rotate(
        angle: (1 - span(enter, 0.4, 0.95, Curves.easeOutBack)) * -math.pi * 2,
        child: const Icon(PhosphorBold.clock, size: 23, color: Color(0xFF2667D8)),
      ),
      _ => Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.diagonal3Values(1 - 0.03 * _flicker(seconds + 0.4), 1 + 0.06 * _flicker(seconds) * span(enter, 0.8, 1.0, Curves.linear), 1),
        child: ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFA726), Color(0xFFF4511E)],
          ).createShader(r),
          child: const Icon(PhosphorFill.fire, size: 23, color: Colors.white),
        ),
      ),
    };
    return Positioned(
      left: left,
      top: 442 + lift,
      width: 108.5,
      height: 104,
      child: Opacity(
        opacity: span(local, 0.0, 0.3).clamp(0.0, 1.0),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..translateByDouble(0, (1 - pop) * 24, 0, 1)
            ..rotateX((1 - pop) * 0.6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Palette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F3F7), width: 1),
              boxShadow: [BoxShadow(color: Palette.shadow.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 54.25 - 19.8,
                  top: 29.7 - 19.8,
                  width: 39.6,
                  height: 39.6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                    child: Center(child: icon),
                  ),
                ),
                Label.centered(value, cx: cx - left + 0.5, base: 70.5, span: 108, style: font(16.1, 700, color: const Color(0xFF182744))),
                Label.centered(label, cx: cx - left + 0.6, base: 88, span: 108, style: font(14.3, 500, color: const Color(0xFF878F9B))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static double _flicker(double t) => (math.sin(t * 9.1) + math.sin(t * 14.7) * 0.6) * 0.5;

  Widget _highlight(int i, double enter, double lift, double seconds) {
    final cx = [65.5, 160.0, 252.0, 341.5][i];
    final tint = [const Color(0xFFF1EEFC), const Color(0xFFE6F2FD), const Color(0xFFE4F5F8), const Color(0xFFECEEF5)][i];
    final color = [const Color(0xFF1D46BE), const Color(0xFF4FA2E8), const Color(0xFF16707A), const Color(0xFF1D3557)][i];
    final glyph = [PhosphorDuotone.mountains, PhosphorDuotone.drop, PhosphorDuotone.park, PhosphorDuotone.shieldCheck][i];
    final lines = [['Scenic', 'Views'], ['Water', 'Fountain'], ['Rest', 'Areas'], ['Safe', 'Route']][i];
    final local = span(enter, 0.6 + i * 0.06, 0.92 + i * 0.06, Curves.linear);
    final pop = spring(local, bounce: 0.5, freq: 2.5);
    final style = font(12.25, 600, color: const Color(0xFF3D4A5B), height: 1.17);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: cx - 18.5,
          top: 697 - 18.5 + lift,
          width: 37,
          height: 37,
          child: Transform.scale(
            scale: pop,
            child: DecoratedBox(
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Center(child: Duotone(glyph, size: 21, color: color)),
            ),
          ),
        ),
        for (var k = 0; k < 2; k++)
          Opacity(
            opacity: span(local, 0.2, 0.7).clamp(0.0, 1.0),
            child: Stack(children: [Label.centered(lines[k], cx: cx + 0.1, base: [729.1, 743.1][k] + lift + (1 - span(local, 0.2, 1.0)) * 8, span: 90, style: style)]),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.t, required this.child});

  final double t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset((1 - t) * -18, 0), child: Stack(clipBehavior: Clip.none, children: [child])),
      ),
    );
  }
}
