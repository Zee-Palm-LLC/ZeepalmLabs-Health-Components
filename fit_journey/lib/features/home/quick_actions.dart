import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/phosphor.dart';
import '../../core/type.dart';
import '../../widgets/icon_orb.dart';

class QuickAction {
  const QuickAction(this.label, this.glyph, this.swatch);

  final String label;
  final IconData glyph;
  final Swatch swatch;
}

const quickActions = [
  QuickAction('Log Water', PhosphorFill.drop, Swatch.water),
  QuickAction('Start Run', PhosphorFill.personSimpleRun, Swatch.run),
  QuickAction('Find a Gym', PhosphorFill.barbell, Swatch.gym),
];

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.open, required this.origin, required this.onClose, required this.onPick});

  final double open;
  final Offset origin;
  final VoidCallback onClose;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    if (open <= 0) return const SizedBox.shrink();
    final veil = span(open, 0.0, 0.6, Curves.easeOut);
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onClose,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: _Bloom(origin, veil),
                child: ColoredBox(color: Palette.midnight.withValues(alpha: 0.42)),
              ),
            ),
            for (var i = 0; i < quickActions.length; i++)
              () {
                final action = quickActions[i];
                final local = span(open, 0.1 + i * 0.1, 0.75 + i * 0.1, Curves.linear);
                final e = spring(local, bounce: 0.42, freq: 2.4);
                final angle = math.pi * (1.22 + 0.28 * i);
                final reach = (i == 1 ? 150.0 : 136.0) * e;
                final at = origin + Offset(math.cos(angle), math.sin(angle)) * reach;
                return Positioned(
                  left: at.dx - 44,
                  top: at.dy - 30,
                  width: 88,
                  height: 82,
                  child: Opacity(
                    opacity: local.clamp(0.0, 1.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onPick(i),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 44 - 27,
                            top: 3,
                            width: 54,
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Palette.shadow.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6))],
                              ),
                              child: Center(
                                child: IconOrb(swatch: action.swatch, icon: action.glyph, core: 19, halo: 23.5, iconSize: 22, fill: span(local, 0.1, 1.0, Curves.linear), seconds: open * 3),
                              ),
                            ),
                          ),
                          Label.centered(
                            action.label,
                            cx: 44,
                            base: 76,
                            span: 110,
                            style: font(13, 700, color: Colors.white, shadows: const [Shadow(color: Color(0x66000000), blurRadius: 8)]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }(),
          ],
        ),
      ),
    );
  }
}

class _Bloom extends CustomClipper<Path> {
  _Bloom(this.origin, this.t);

  final Offset origin;
  final double t;

  @override
  Path getClip(Size size) {
    final r = math.sqrt(size.width * size.width + size.height * size.height) * t;
    return Path()..addOval(Rect.fromCircle(center: origin, radius: r));
  }

  @override
  bool shouldReclip(_Bloom old) => old.t != t || old.origin != origin;
}
