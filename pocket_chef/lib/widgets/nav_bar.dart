import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';

class NavItem {
  const NavItem(this.icon, this.active, this.label, this.x);

  final IconData icon;
  final IconData active;
  final String label;
  final double x;
}

const navItems = [
  NavItem(Ph.house, Ph.houseFill, 'Home', 45.2),
  NavItem(Ph.forkKnife, Ph.forkKnifeFill, 'Recipes', 121.7),
  NavItem(Ph.heart, Ph.heartFill, 'Favorites', 273.2),
  NavItem(Ph.user, Ph.userFill, 'Profile', 349.3),
];

class NavBar extends StatefulWidget {
  const NavBar({super.key, required this.index, required this.onSelect, required this.entrance});

  static const reference = 892.9;
  static const top = 804.5;
  static const fab = Offset(196.93, 822.65);

  static double shift(Frame frame) => frame.height - frame.drop - reference;

  final int index;
  final ValueChanged<int> onSelect;
  final Animation<double> entrance;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with TickerProviderStateMixin {
  late final List<AnimationController> _pops;

  @override
  void initState() {
    super.initState();
    _pops = [for (final _ in navItems) AnimationController(vsync: this, duration: const Duration(milliseconds: 720), value: 1)];
  }

  @override
  void didUpdateWidget(NavBar old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _pops[widget.index].forward(from: 0);
  }

  @override
  void dispose() {
    for (final c in _pops) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final dy = NavBar.shift(frame);
    final barTop = NavBar.top + dy;
    return SizedBox(
      width: Frame.width,
      height: frame.height,
      child: AnimatedBuilder(
        animation: widget.entrance,
        builder: (context, child) {
          final t = span(widget.entrance.value, 0.25, 0.85, gentle);
          return Transform.translate(offset: Offset(0, 110 * (1 - t)), child: child);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: barTop - 24,
              height: 24,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00EDE6DF), Color(0x99EAE3DC)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: barTop,
              bottom: 0,
              child: const DecoratedBox(decoration: BoxDecoration(color: Color(0xFFFDF8F2))),
            ),
            for (final (i, item) in navItems.indexed)
              Positioned(
                left: item.x - 36,
                top: barTop,
                width: 72,
                height: frame.height - barTop - frame.bottom + 6,
                child: _Item(
                  item: item,
                  selected: i == widget.index,
                  pop: _pops[i],
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onSelect(i);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.selected, required this.pop, required this.onTap});

  final NavItem item;
  final bool selected;
  final AnimationController pop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFF31E36) : const Color(0xFF8A878B);
    return Pressable(
      onTap: onTap,
      haptic: false,
      scale: 0.88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 36 - 14,
            top: 23.5 - 14 + 0.3,
            child: AnimatedBuilder(
              animation: pop,
              builder: (context, child) {
                final t = pop.value;
                final s = spring(t, bounce: 0.6, freq: 3);
                final squash = math.sin(t * math.pi * 3) * 0.16 * (1 - t);
                return Transform.translate(
                  offset: Offset(0, -6 * math.sin(t * math.pi) * (1 - t)),
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.diagonal3Values(lerp(0.6, 1, s) * (1 + squash), lerp(0.6, 1, s) * (1 - squash), 1),
                    child: child,
                  ),
                );
              },
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: color),
                duration: const Duration(milliseconds: 280),
                builder: (context, c, _) => PhIcon(selected ? item.active : item.icon, size: 28, color: c!),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 52.8 - 100,
            child: Baseline(
              baseline: 100,
              baselineType: TextBaseline.alphabetic,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 280),
                  style: inter(11.8, selected ? 600 : 500, color: color),
                  child: Text(item.label, softWrap: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavFab extends StatelessWidget {
  const NavFab({super.key, required this.open, required this.onTap, required this.entrance});

  final Animation<double> open;
  final VoidCallback onTap;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final c = NavBar.fab + Offset(0, NavBar.shift(frame));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: c.dx - 34,
          top: c.dy - 34,
          child: AnimatedBuilder(
            animation: entrance,
            builder: (context, child) {
              final raw = ((entrance.value - 0.45) / 0.55).clamp(0.0, 1.0);
              final s = spring(raw, bounce: 0.55, freq: 2.4);
              return Transform.translate(
                offset: Offset(0, 90 * (1 - s)),
                child: Transform.rotate(angle: -1.6 * (1 - s), child: child),
              );
            },
            child: _fab(),
          ),
        ),
      ],
    );
  }

  Widget _fab() {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: SizedBox.square(
        dimension: 68,
        child: Tick(
          builder: (context, s, child) {
            final pulse = (s % 3.2) / 3.2;
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFEFBF8),
                    boxShadow: [
                      BoxShadow(color: Palette.tomato.withValues(alpha: 0.16), blurRadius: 18, offset: const Offset(0, 8)),
                      BoxShadow(color: const Color(0xFF7A5040).withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, -1)),
                    ],
                  ),
                ),
                if (pulse < 0.7)
                  Container(
                    width: 52.5 + 26 * Curves.easeOut.transform(pulse / 0.7),
                    height: 52.5 + 26 * Curves.easeOut.transform(pulse / 0.7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Palette.tomato.withValues(alpha: 0.28 * (1 - pulse / 0.7)), width: 1.6),
                    ),
                  ),
                child!,
              ],
            );
          },
          child: Container(
            width: 52.5,
            height: 52.5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFD3350), Color(0xFFF5152F)],
              ),
              boxShadow: [BoxShadow(color: Color(0x55FC2240), blurRadius: 12, offset: Offset(0, 5))],
            ),
            child: AnimatedBuilder(
              animation: open,
              builder: (context, child) => Transform.rotate(angle: open.value * math.pi * 0.75, child: child),
              child: const Center(child: PhIcon(Ph.plus, size: 30, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

class FabMenu extends StatelessWidget {
  const FabMenu({super.key, required this.open, required this.onClose, required this.onPick});

  final Animation<double> open;
  final VoidCallback onClose;
  final ValueChanged<int> onPick;

  static const actions = [
    (Ph.chefHatFill, 'New recipe', Color(0xFFFC2240)),
    (Ph.basket, 'Shopping list', Color(0xFFF59E0B)),
    (Ph.timer, 'Cook timer', Color(0xFF7C3AED)),
  ];

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final center = NavBar.fab + Offset(0, NavBar.shift(frame));
    return AnimatedBuilder(
      animation: open,
      builder: (context, _) {
        final t = open.value;
        if (t == 0) return const SizedBox.shrink();
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: onClose,
                child: ColoredBox(color: Color.fromRGBO(28, 14, 20, 0.34 * Curves.easeOut.transform(t))),
              ),
            ),
            for (final (i, (icon, label, color)) in actions.indexed)
              _Action(
                center: center,
                angle: math.pi * (0.5 + (i - 1) * 0.34),
                reach: 108,
                t: span(t, i * 0.08, 0.72 + i * 0.08, settle),
                icon: icon,
                label: label,
                color: color,
                onTap: () => onPick(i),
              ),
          ],
        );
      },
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.center,
    required this.angle,
    required this.reach,
    required this.t,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final Offset center;
  final double angle;
  final double reach;
  final double t;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = center + Offset(-math.cos(angle), -math.sin(angle)) * reach * t;
    return Positioned(
      left: p.dx - 60,
      top: p.dy - 27,
      width: 120,
      height: 80,
      child: Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: lerp(0.3, 1, t.clamp(0.0, 1.2)),
          child: Pressable(
            onTap: onTap,
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Center(child: PhIcon(icon, size: 26, color: color)),
                ),
                const SizedBox(height: 7),
                Text(label, style: inter(12, 600, color: Colors.white), softWrap: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
