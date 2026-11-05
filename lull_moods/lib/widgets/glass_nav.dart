import 'dart:ui';

import 'package:flutter/material.dart';

import '../layout.dart';
import '../mood.dart';

const _items = [
  (Icons.wb_sunny_outlined, 'Today'),
  (Icons.water_drop_outlined, 'Vitals'),
  (Icons.lightbulb_outline_rounded, 'Rhythm'),
];

/// Frosted tab bar (287 × 58) with a sliding selection pill.
class GlassNav extends StatelessWidget {
  const GlassNav({super.key, required this.v, required this.s, required this.index, required this.onTap});

  final MoodVisual v;
  final double s;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return _Glass(
      v: v,
      radius: 29 * s,
      child: Padding(
        padding: EdgeInsets.all(5 * s),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(index - 1.0, 0),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: v.navSel, borderRadius: BorderRadius.circular(24 * s)),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_items[i].$1, size: 15 * s, color: v.navInk),
                          SizedBox(height: 3 * s),
                          Text(_items[i].$2, style: inter(9.5 * s, FontWeight.w600, v.navInk)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GlassPlus extends StatelessWidget {
  const GlassPlus({super.key, required this.v, required this.s});

  final MoodVisual v;
  final double s;

  @override
  Widget build(BuildContext context) {
    return _Glass(
      v: v,
      radius: 29 * s,
      child: Stack(
        children: [
          Center(child: Icon(Icons.add_rounded, size: 26 * s, color: v.navInk)),
          Positioned(top: 12 * s, right: 12 * s, child: Icon(Icons.auto_awesome, size: 9 * s, color: v.navInk)),
        ],
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.v, required this.radius, required this.child});

  final MoodVisual v;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: v.navFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: child,
        ),
      ),
    );
  }
}
