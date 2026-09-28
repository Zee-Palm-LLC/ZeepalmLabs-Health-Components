import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/motion.dart';
import '../../core/type.dart';

class Category {
  const Category(this.label, this.icon, this.x, this.center, this.edge, this.ring);

  final String label;
  final Sprite icon;
  final double x;
  final Color center;
  final Color edge;
  final Color ring;
}

const categories = [
  Category('Breakfast', Art.catBreakfast, 57.14, Color(0xFFFFEDC7), Color(0xFFFBE7CA), Color(0xFFF7B32B)),
  Category('Lunch', Art.catLunch, 151.27, Color(0xFFFEDCD6), Color(0xFFFBDCD8), Color(0xFFF2334A)),
  Category('Dinner', Art.catDinner, 245.28, Color(0xFFD9F3FD), Color(0xFFD5EDFA), Color(0xFF2A93F0)),
  Category('Snacks', Art.catSnacks, 339.19, Color(0xFFFAE4FF), Color(0xFFEDE1FA), Color(0xFFB03CF2)),
];

class CategoryRow extends StatefulWidget {
  const CategoryRow({super.key, required this.entrance});

  static const cy = 486.0;
  static const r = 35.25;

  final Animation<double> entrance;

  @override
  State<CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> with TickerProviderStateMixin {
  int? _picked;
  late final List<AnimationController> _jelly;

  @override
  void initState() {
    super.initState();
    _jelly = [for (final _ in categories) AnimationController(vsync: this, duration: const Duration(milliseconds: 900), value: 1)];
  }

  @override
  void dispose() {
    for (final c in _jelly) {
      c.dispose();
    }
    super.dispose();
  }

  void _tap(int i) {
    setState(() => _picked = _picked == i ? null : i);
    _jelly[i].forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final label = inter(13.35, 500, color: const Color(0xFF3D3B43));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final (i, c) in categories.indexed) ...[
          Positioned(
            left: c.x - 46,
            top: CategoryRow.cy - 46,
            width: 92,
            height: 92,
            child: AnimatedBuilder(
              animation: widget.entrance,
              builder: (context, child) {
                final begin = 0.44 + i * 0.06;
                final raw = ((widget.entrance.value - begin) / 0.34).clamp(0.0, 1.0);
                final s = spring(raw, bounce: 0.55, freq: 2.5);
                return Opacity(
                  opacity: (raw * 5).clamp(0.0, 1.0),
                  child: Transform.scale(scale: s, child: child),
                );
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _tap(i),
                child: _Bubble(category: c, index: i, picked: _picked == i, jelly: _jelly[i]),
              ),
            ),
          ),
          Positioned(
            left: c.x - 60,
            width: 120,
            top: 541 - 100,
            child: Staged(
              animation: widget.entrance,
              begin: 0.52 + i * 0.06,
              end: 0.8 + i * 0.06,
              offset: const Offset(0, 8),
              child: Baseline(
                baseline: 100,
                baselineType: TextBaseline.alphabetic,
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 240),
                    style: _picked == i
                        ? label.copyWith(color: c.ring, fontVariations: const [FontVariation('wght', 600), FontVariation('opsz', 14)])
                        : label,
                    child: Text(c.label, softWrap: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.category, required this.index, required this.picked, required this.jelly});

  final Category category;
  final int index;
  final bool picked;
  final AnimationController jelly;

  @override
  Widget build(BuildContext context) {
    final c = category;
    const r = CategoryRow.r;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: settle,
          width: picked ? r * 2 + 8 : r * 2,
          height: picked ? r * 2 + 8 : r * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.ring.withValues(alpha: picked ? 0.55 : 0), width: 1.6),
          ),
        ),
        AnimatedBuilder(
          animation: jelly,
          builder: (context, child) {
            final t = jelly.value;
            final w = math.sin(t * math.pi * 4) * 0.14 * (1 - t);
            return Transform(alignment: Alignment.center, transform: Matrix4.diagonal3Values(1 + w, 1 - w, 1), child: child);
          },
          child: Container(
            width: r * 2,
            height: r * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [c.center, c.edge], stops: const [0.0, 1.0]),
            ),
          ),
        ),
        Positioned(
          left: c.icon.left - (c.x - 46),
          top: c.icon.top - (CategoryRow.cy - 46),
          width: c.icon.width,
          height: c.icon.height,
          child: AnimatedBuilder(
            animation: jelly,
            builder: (context, child) {
              final t = jelly.value;
              final hop = math.sin(t * math.pi) * (1 - t) * 14;
              final spin = math.sin(t * math.pi * 3) * 0.3 * (1 - t);
              return Transform.translate(
                offset: Offset(0, -hop),
                child: Transform.rotate(angle: spin, child: child),
              );
            },
            child: Tick(builder: (context, s, child) => _idle(s, child!), child: c.icon.image()),
          ),
        ),
      ],
    );
  }

  Widget _idle(double s, Widget child) {
    final u = ((s + index * 1.3) % 6) / 6;
    final k = u < 0.18 ? math.sin(u / 0.18 * math.pi) : 0.0;
    switch (index) {
      case 0:
        return Transform.rotate(angle: s * 0.35, child: child);
      case 1:
        return Transform.translate(offset: Offset(0, -2.5 * k), child: child);
      case 2:
        return Transform.rotate(angle: 0.18 * math.sin(u / 0.18 * math.pi * 2) * k, alignment: Alignment.bottomCenter, child: child);
      default:
        return Transform(alignment: Alignment.bottomCenter, transform: Matrix4.diagonal3Values(1 + 0.08 * k, 1 - 0.1 * k, 1), child: child);
    }
  }
}
