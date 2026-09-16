import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/palette.dart';
import '../../../core/type.dart';
import '../../../widgets/hud.dart';
import '../../../widgets/painters/polygon.dart';

class XpCard extends StatelessWidget {
  const XpCard({
    super.key,
    required this.level,
    required this.xp,
    required this.maxXp,
    required this.idle,
    this.charge = 0,
  });

  final int level;

  final double xp;
  final int maxXp;
  final double idle;

  final double charge;

  @override
  Widget build(BuildContext context) {
    final fraction = (xp / maxXp).clamp(0.0, 1.0);
    final shown = xp.round();
    final glint = 0.5 + 0.5 * math.sin(idle * 0.9);

    return HudPanel(
      cut: 16,
      fill: Night.panel,
      accent: Spectrum.violet,
      accentStrength: 0.6 + 0.4 * charge,
      edge: Color.lerp(
        Night.panelEdge,
        Night.panelEdgeLit,
        0.25 * glint + charge * 0.75,
      )!,
      rail: true,
      glow: charge * 0.8,
      padding: const EdgeInsets.fromLTRB(12, 0, 18, 0),
      child: SizedBox(
      height: D.cardHeight,
      child: Row(
        children: <Widget>[
          _LevelBadge(level: level, charge: charge, glint: glint),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('$shown / $maxXp XP', style: T.xpCount),
                const SizedBox(height: 9),
                SegmentedMeter(
                  value: fraction,
                  color: Spectrum.violet,
                  height: D.xpTrackHeight,
                  segments: 16,
                  shimmer: idle,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({
    required this.level,
    required this.charge,
    required this.glint,
  });

  final int level;
  final double charge;
  final double glint;

  @override
  Widget build(BuildContext context) {
    return PolygonPane(
      size: const Size(D.lvlBadgeWidth, D.lvlBadgeHeight),
      sides: 8,
      rotation: -math.pi / 2 + math.pi / 8,
      cornerRadius: 4,
      edgeWidth: 1.4,
      edge: Color.lerp(
        const Color(0xFF6A5A92),
        Spectrum.violet,
        0.3 * glint + charge * 0.7,
      )!,
      glow: Spectrum.violet.withValues(alpha: 0.5),
      glowStrength: charge * 0.9,
      fill: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFF15182B), Color(0xFF0A0C18)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('LVL', style: T.lvlWord),
          const SizedBox(height: 1),
          _RollingLevel(level: level),
        ],
      ),
    );
  }
}

class _RollingLevel extends StatelessWidget {
  const _RollingLevel({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final style = T.lvlNumber;
    final line = (style.fontSize ?? 24) * (style.height ?? 1.0);
    return ClipRect(
      child: SizedBox(
        height: line,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: level.toDouble()),
          duration: const Duration(milliseconds: 620),
          curve: D.emphasized,
          builder: (BuildContext context, double v, Widget? _) {
            final low = v.floor();
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    height: line,
                    child: Text('00', style: style),
                  ),
                ),
                for (final d in <int>[low, low + 1])
                  Positioned(
                    left: 0,
                    right: 0,
                    top: (d - v) * line,
                    height: line,
                    child: Text(
                      d.toString().padLeft(2, '0'),
                      textAlign: TextAlign.center,
                      style: style,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
