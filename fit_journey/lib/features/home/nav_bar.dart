import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/canvas.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/phosphor.dart';
import '../../core/type.dart';

enum Section { home, progress, map, profile }

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    required this.top,
    required this.active,
    required this.enter,
    required this.onSelect,
  });

  final double top;
  final Section active;
  final double enter;
  final ValueChanged<Section> onSelect;

  static const height = 66.0;
  static const fabDrop = 32.0;

  static double topIn(CanvasScope scope) => scope.floor - height;

  static Offset fabCenter(CanvasScope scope) => Offset(199.3, topIn(scope) + fabDrop);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  late final AnimationController _switch;
  Section _previous = Section.home;

  @override
  void initState() {
    super.initState();
    _switch = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: 1);
  }

  @override
  void didUpdateWidget(NavBar old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) {
      _previous = old.active;
      _switch.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _switch.dispose();
    super.dispose();
  }

  static const _items = [
    (Section.home, 'Home', 44.2, PhosphorRegular.house, PhosphorFill.house),
    (Section.progress, 'Progress', 121.7, PhosphorRegular.chartLineUp, PhosphorFill.chartLineUp),
    (Section.map, 'Map', 276.8, PhosphorRegular.mapPin, PhosphorFill.mapPin),
    (Section.profile, 'Profile', 352.2, PhosphorRegular.user, PhosphorFill.user),
  ];

  @override
  Widget build(BuildContext context) {
    final rise = span(widget.enter, 0.0, 1.0, const Cubic(0.2, 0.9, 0.3, 1.0));
    final hidden = (1 - rise) * 120;
    return Positioned(
      left: 0,
      right: 0,
      top: widget.top + hidden,
      bottom: -hidden,
      child: AnimatedBuilder(
        animation: _switch,
        builder: (context, _) {
          final s = _switch.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Palette.card,
                    boxShadow: [
                      BoxShadow(color: Palette.shadow.withValues(alpha: 0.07), blurRadius: 22, offset: const Offset(0, -4)),
                    ],
                  ),
                ),
              ),
              for (final item in _items)
                () {
                  final active = item.$1 == widget.active;
                  final was = item.$1 == _previous;
                  final on = active ? span(s, 0.0, 0.6) : (was ? 1 - span(s, 0.0, 0.5) : 0.0);
                  final hop = active ? math.sin(math.pi * span(s, 0.0, 0.7, Curves.easeOut)) : 0.0;
                  final color = Color.lerp(const Color(0xFF8A94A2), Palette.cobalt, on)!;
                  return Positioned(
                    left: item.$3 - 38,
                    top: 0,
                    width: 76,
                    height: NavBar.height,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onSelect(item.$1),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 38 - 13,
                            top: 22 - 13 - hop * 5,
                            width: 26,
                            height: 26,
                            child: Transform.scale(
                              scale: 1 + hop * 0.12,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(opacity: 1 - on, child: Icon(item.$4, size: 25, color: color)),
                                  Opacity(opacity: on, child: Icon(item.$5, size: 25, color: color)),
                                ],
                              ),
                            ),
                          ),
                          Label.centered(
                            item.$2,
                            cx: 38,
                            base: 52.5,
                            span: 76,
                            style: font(12.45, 600, color: Color.lerp(const Color(0xFF858F9D), Palette.cobalt, on)!),
                          ),
                        ],
                      ),
                    ),
                  );
                }(),
            ],
          );
        },
      ),
    );
  }
}

class NavFab extends StatelessWidget {
  const NavFab({super.key, required this.center, required this.enter, required this.open, required this.onTap});

  final Offset center;
  final double enter;
  final double open;
  final VoidCallback onTap;

  static const radius = 24.4;

  @override
  Widget build(BuildContext context) {
    final rise = span(enter, 0.0, 1.0, const Cubic(0.2, 0.9, 0.3, 1.0));
    final spin = 1 - spring(span(enter, 0.3, 1.0, Curves.linear));
    return Positioned(
      left: center.dx - radius,
      top: center.dy - radius + (1 - rise) * 150,
      width: radius * 2,
      height: radius * 2,
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        child: Transform.rotate(
          angle: open * math.pi * 0.75 - spin * math.pi,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF08AE88), Color(0xFF009B7A)],
              ),
              boxShadow: [
                BoxShadow(color: Palette.fern.withValues(alpha: 0.28 + 0.12 * open), blurRadius: 14 + 8 * open, offset: const Offset(0, 5)),
              ],
            ),
            child: const Center(child: Icon(PhosphorBold.plus, size: 24, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
