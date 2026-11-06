import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Floating dark pill. The white capsule springs to the tapped tab, stretching
/// a little while it travels, and the tab's label unfolds as it lands.
class FloatingNav extends StatefulWidget {
  const FloatingNav({super.key, this.onChanged});

  final ValueChanged<int>? onChanged;

  @override
  State<FloatingNav> createState() => _FloatingNavState();
}

class _FloatingNavState extends State<FloatingNav> with TickerProviderStateMixin {
  static const _tabs = [(Icons.home_rounded, 'Today'), (Icons.fitness_center_rounded, 'Train'), (Icons.insights_rounded, 'Progress')];

  static const _width = 197.0;
  static const _height = 50.0;
  static const _inset = 5.0;
  static const _pill = 91.0;
  static const _slot = (_width - _inset * 2 - _pill) / 2;

  static const _spring = SpringDescription(mass: 1, stiffness: 260, damping: 24);

  late final AnimationController _t = AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _enter.forward();
    });
  }

  @override
  void dispose() {
    _t.dispose();
    _enter.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    _index = i;
    _t.animateWith(SpringSimulation(_spring, _t.value, i.toDouble(), _t.velocity));
    widget.onChanged?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_t, _enter]),
      builder: (context, _) {
        final t = _t.value;
        final rise = Curves.easeOutBack.transform(_enter.value);
        // Stretch with speed, so the capsule reads as moving liquid.
        final v = _t.isAnimating ? _t.velocity : 0.0;
        final stretch = (v.abs() * 7).clamp(0.0, 18.0);
        final activeness = [for (var j = 0; j < _tabs.length; j++) (1 - (t - j).abs()).clamp(0.0, 1.0)];
        final widths = [for (final a in activeness) _slot + (_pill - _slot) * a];

        return Transform.translate(
          offset: Offset(0, (1 - rise) * 110),
          child: Opacity(
            opacity: _enter.value.clamp(0.0, 1.0),
            child: Container(
              width: _width,
              height: _height,
              padding: const EdgeInsets.all(_inset),
              decoration: BoxDecoration(
                color: Tone.night,
                borderRadius: BorderRadius.circular(_height / 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
                  BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    // Lead with the front edge: the stretch trails behind.
                    left: t * _slot - (v < 0 ? 0 : stretch),
                    top: 0,
                    bottom: 0,
                    width: _pill + stretch,
                    child: Transform.scale(
                      scaleY: 1 - stretch / 160,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular((_height - _inset * 2) / 2)),
                      ),
                    ),
                  ),
                  for (var j = 0; j < _tabs.length; j++)
                    Positioned(
                      left: widths.take(j).fold<double>(0, (a, b) => a + b),
                      width: widths[j],
                      top: 0,
                      bottom: 0,
                      child: _Tab(icon: _tabs[j].$1, label: _tabs[j].$2, active: activeness[j], onTap: () => _go(j)),
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

class _Tab extends StatefulWidget {
  const _Tab({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final double active;
  final VoidCallback onTap;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.active;
    final colour = Color.lerp(Colors.white, Tone.night, a)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.86 : 1,
        duration: Duration(milliseconds: _down ? 90 : 450),
        curve: _down ? Curves.easeOut : Curves.elasticOut,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: lerpDouble(17, 18, a), color: colour),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: Curves.easeOut.transform(a),
                  child: Opacity(
                    opacity: math.pow(a, 2).toDouble(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(widget.label, maxLines: 1, style: sans(14, weight: FontWeight.w500, spacing: -0.2)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
