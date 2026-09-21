import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.index, required this.onSelect, required this.onAdd});

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  static const items = [(Glyph.home, 'Home'), (Glyph.clock, 'Timeline'), (Glyph.pill, 'Meds'), (Glyph.user, 'Profile')];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 68,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF1ECF4)),
                boxShadow: [
                  BoxShadow(color: Hue.shadow.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 12)),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  final slot = box.maxWidth / 5;
                  final position = index < 2 ? index : index + 1;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutBack,
                        left: slot * position + slot / 2 - 12,
                        bottom: 7,
                        child: Container(
                          width: 24,
                          height: 4,
                          decoration: BoxDecoration(gradient: Hue.irisGradient, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < 5; i++)
                            Expanded(
                              child: i == 2
                                  ? const SizedBox()
                                  : _Item(
                                      glyph: items[i < 2 ? i : i - 1].$1,
                                      label: items[i < 2 ? i : i - 1].$2,
                                      active: (i < 2 ? i : i - 1) == index,
                                      onTap: () => onSelect(i < 2 ? i : i - 1),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Pressable(
              onTap: onAdd,
              scale: 0.9,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: Hue.irisGradient,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Hue.iris.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
                ),
                alignment: Alignment.center,
                child: const GlyphIcon(Glyph.plus, size: 26, color: Colors.white, stroke: 2.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.glyph, required this.label, required this.active, required this.onTap});

  final Glyph glyph;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: active ? 1 : 0),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutBack,
        builder: (context, t, _) {
          final color = Color.lerp(Hue.inkMute, Hue.iris, t.clamp(0.0, 1.0))!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, -2 * t),
                child: Transform.scale(
                  scale: 1 + 0.08 * t,
                  child: GlyphIcon(
                    glyph,
                    size: 23,
                    color: color,
                    stroke: 1.8,
                    fill: glyph == Glyph.home && t > 0.5 ? Hue.iris.withValues(alpha: 0.18) : null,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: jakarta(11, lerp(550, 750, t.clamp(0.0, 1.0)), color: color)),
              const SizedBox(height: 6),
            ],
          );
        },
      ),
    );
  }
}
