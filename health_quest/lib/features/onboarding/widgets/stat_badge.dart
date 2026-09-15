import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/motion/pressable.dart';
import '../../../core/palette.dart';
import '../../../core/type.dart';
import '../../../data/stats.dart';
import '../../../widgets/painters/polygon.dart';
import '../../../widgets/painters/stat_icons.dart';

/// One RPG ability badge: a pointy-top hexagon of dark glass with a lit edge,
/// the stat's glyph inside, its name, and its level.
///
/// It lands with a spring and a ring that snaps outward, then idles with a
/// slow glow on its own phase so the four never pulse in lockstep. Tapping
/// one fires the ring again and floods its colour into the character.
class StatBadge extends StatefulWidget {
  const StatBadge({
    super.key,
    required this.stat,
    required this.t,
    required this.idle,
    required this.phase,
    this.onTap,
  });

  final Stat stat;

  /// This badge's own entrance progress, 0..1, may overshoot.
  final double t;

  /// Free-running seconds.
  final double idle;

  /// Offset into the idle cycle, so the four breathe out of step.
  final double phase;

  final VoidCallback? onTap;

  @override
  State<StatBadge> createState() => _StatBadgeState();
}

class _StatBadgeState extends State<StatBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ping = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _ping.dispose();
    super.dispose();
  }

  void _tapped() {
    _ping.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final settled = widget.t.clamp(0.0, 1.0);
    if (widget.t <= 0) {
      return const SizedBox(width: D.badgeSlot);
    }

    final tone = widget.stat.tone;
    // Idle breathing, plus the tail of the entrance ring.
    final breath = 0.5 + 0.5 * math.sin(widget.idle * 1.35 + widget.phase);

    return Opacity(
      opacity: settled,
      child: Transform.translate(
        offset: Offset(0, (1 - widget.t) * 16),
        child: Transform.scale(
          scale: widget.t.clamp(0.02, 1.4),
          child: Pressable(
            onTap: _tapped,
            pressedScale: 0.9,
            child: SizedBox(
              width: D.badgeSlot,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _ping,
                    builder: (BuildContext context, Widget? _) {
                      // The entrance ring and the tap ring are the same ring.
                      final ringT = _ping.isAnimating || _ping.value > 0
                          ? _ping.value
                          : (settled < 1 ? settled : 0.0);
                      return SizedBox(
                        width: D.hexWidth + 34,
                        height: D.hexHeight + 34,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            if (ringT > 0 && ringT < 1)
                              CustomPaint(
                                size: Size(D.hexWidth + 34, D.hexHeight + 34),
                                painter: _Ring(t: ringT, tone: tone),
                              ),
                            PolygonPane(
                              size: const Size(D.hexWidth, D.hexHeight),
                              sides: 6,
                              cornerRadius: 6,
                              edgeWidth: 1.6,
                              edge: Color.lerp(
                                tone.core.withValues(alpha: 0.55),
                                tone.tip,
                                breath * 0.7,
                              )!,
                              glow: tone.glow,
                              glowStrength: 0.45 + 0.4 * breath,
                              fill: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  tone.core.withValues(alpha: 0.26),
                                  const Color(0xCC07080F),
                                ],
                              ),
                              child: StatIcon(
                                glyph: widget.stat.glyph,
                                tone: tone,
                                size: 26,
                                pulse: (widget.idle * 0.45 + widget.phase) % 1.0,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.stat.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: T.statLabel.copyWith(
                      shadows: const <Shadow>[
                        Shadow(color: Color(0xCC000000), blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.stat.levelLabel,
                    textAlign: TextAlign.center,
                    style: T.statLevel.copyWith(
                      shadows: const <Shadow>[
                        Shadow(color: Color(0xCC000000), blurRadius: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A hexagonal ring that snaps outward and fades.
class _Ring extends CustomPainter {
  const _Ring({required this.t, required this.tone});

  final double t;
  final StatTone tone;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
    final fade = (1 - t).clamp(0.0, 1.0);
    final scale = 0.62 + eased * 0.72;
    final w = D.hexWidth * scale;
    final h = D.hexHeight * scale;
    canvas.save();
    canvas.translate((size.width - w) / 2, (size.height - h) / 2);
    canvas.drawPath(
      polygonPath(Size(w, h), sides: 6, cornerRadius: 6 * scale),
      Paint()
        ..blendMode = BlendMode.plus
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 + 2.5 * fade
        ..color = tone.tip.withValues(alpha: 0.7 * fade)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + 4 * fade),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Ring old) => old.t != t || old.tone != tone;
}
