import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../core/design.dart';
import '../core/motion/idle.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import '../core/type.dart';
import 'painters/polygon.dart';
import 'painters/quest_icons.dart';

/// The four tabs from the reference.
enum NavTab { quests, stats, rewards, profile }

extension NavTabInfo on NavTab {
  String get label => switch (this) {
        NavTab.quests => 'QUESTS',
        NavTab.stats => 'STATS',
        NavTab.rewards => 'REWARDS',
        NavTab.profile => 'PROFILE',
      };

  QuestGlyph get glyph => switch (this) {
        NavTab.quests => QuestGlyph.swords,
        NavTab.stats => QuestGlyph.bars,
        NavTab.rewards => QuestGlyph.trophy,
        NavTab.profile => QuestGlyph.person,
      };

  Color get tone => switch (this) {
        NavTab.quests => Quests.purple,
        NavTab.stats => Quests.blue,
        NavTab.rewards => Quests.gold,
        NavTab.profile => Quests.green,
      };
}

/// The command bar.
///
/// The plate is chamfered and carries a notch in its top edge, and the notch
/// travels to whichever tab is selected. The active tab's hex rises out of
/// that notch and sits proud of the bar, lit in its own colour, with a blade
/// of light under it. A pill sliding along a rounded rectangle is what every
/// app does; a bar that opens to let the selected station stand up is what a
/// game does, and it makes the selection readable from the corner of the eye.
///
/// Underneath, a charge line runs the length of the plate on a slow loop, so
/// the bar is never completely still.
class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.current,
    required this.onChanged,
    this.t = 1,
  });

  final NavTab current;
  final ValueChanged<NavTab> onChanged;

  /// Entrance progress.
  final double t;

  static const double _riser = 20;

  @override
  Widget build(BuildContext context) {
    final settled = t.clamp(0.0, 1.0);

    return Opacity(
      opacity: settled,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 26),
        child: SizedBox(
          height: D.navHeight + _riser,
          child: IdleBuilder(
            builder: (BuildContext context, double idle, Widget? _) =>
                LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                final slot = c.maxWidth / NavTab.values.length;
                final target = slot * (current.index + 0.5);

                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: target),
                  duration: const Duration(milliseconds: 460),
                  curve: D.emphasized,
                  builder: (BuildContext context, double notchX, Widget? _) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        // The plate, with a notch that follows the selection.
                        Positioned(
                          left: 0,
                          right: 0,
                          top: _riser,
                          height: D.navHeight,
                          child: CustomPaint(
                            painter: _PlatePainter(
                              notchX: notchX,
                              notchWidth: slot * 0.62,
                              tone: current.tone,
                              idle: idle,
                            ),
                          ),
                        ),

                        // Inactive tabs sit inside the plate.
                        Positioned(
                          left: 0,
                          right: 0,
                          top: _riser,
                          height: D.navHeight,
                          child: Row(
                            children: <Widget>[
                              for (final tab in NavTab.values)
                                Expanded(
                                  child: Pressable(
                                    haptic: false,
                                    pressedScale: 0.9,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      onChanged(tab);
                                    },
                                    child: _Station(
                                      tab: tab,
                                      selected: tab == current,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // The active hex, standing up out of the notch.
                        Positioned(
                          left: notchX - 27,
                          top: 0,
                          width: 54,
                          height: 58,
                          child: IgnorePointer(
                            child: _ActiveCrest(
                              tab: current,
                              idle: idle,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// One station: the label, and the icon when it is not the selected one.
///
/// The selected tab's icon lives in the crest above instead, so the slot below
/// it carries only the name - which is what stops the bar from showing the
/// same glyph twice.
class _Station extends StatelessWidget {
  const _Station({required this.tab, required this.selected});

  final NavTab tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? tab.tone : Ink2.muted;
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedOpacity(
            duration: const Duration(milliseconds: 280),
            opacity: selected ? 0 : 1,
            child: QuestIcon(
              glyph: tab.glyph,
              size: 23,
              color: color,
              highlight: color,
              strokeWidth: 7,
            ),
          ),
          SizedBox(height: selected ? 0 : 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 280),
            style: T.navLabel.copyWith(
              color: selected ? Color.lerp(color, Ink2.bright, 0.4) : color,
              fontSize: selected ? 11 : 10.5,
            ),
            child: Text(tab.label),
          ),
        ],
      ),
    );
  }
}

/// The hexagon that rises out of the notch, carrying the active glyph.
class _ActiveCrest extends StatelessWidget {
  const _ActiveCrest({required this.tab, required this.idle});

  final NavTab tab;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.5 + 0.5 * math.sin(idle * 2.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PolygonPane(
          size: const Size(46, 52),
          sides: 6,
          cornerRadius: 5,
          edgeWidth: 1.8,
          edge: Color.lerp(tab.tone, Ink2.bright, 0.25 + 0.2 * pulse)!,
          glow: tab.tone.withValues(alpha: 0.75),
          glowStrength: 0.55 + 0.35 * pulse,
          fill: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.lerp(tab.tone, const Color(0xFF000000), 0.45)!,
              const Color(0xFF080B16),
            ],
          ),
          child: QuestIcon(
            glyph: tab.glyph,
            size: 23,
            color: Color.lerp(tab.tone, Ink2.bright, 0.35)!,
            highlight: Ink2.bright,
            strokeWidth: 7,
          ),
        ),
        const SizedBox(height: 3),
        // The blade of light the crest stands on.
        CustomPaint(
          size: const Size(34, 3),
          painter: _BladeGlow(tab.tone, pulse),
        ),
      ],
    );
  }
}

class _BladeGlow extends CustomPainter {
  const _BladeGlow(this.color, this.pulse);

  final Color color;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)),
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            color.withValues(alpha: 0),
            color,
            color.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)),
      Paint()
        ..color = color.withValues(alpha: 0.45 + 0.3 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_BladeGlow old) =>
      old.color != color || old.pulse != pulse;
}

/// The chamfered plate with a travelling notch in its top edge.
class _PlatePainter extends CustomPainter {
  const _PlatePainter({
    required this.notchX,
    required this.notchWidth,
    required this.tone,
    required this.idle,
  });

  final double notchX;
  final double notchWidth;
  final Color tone;
  final double idle;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const cut = 16.0;
    final w = size.width;
    final h = size.height;
    final depth = 15.0;
    final half = notchWidth / 2;
    final slope = notchWidth * 0.22;

    final left = (notchX - half).clamp(cut + 2, w - cut - 2 - notchWidth);
    final right = left + notchWidth;

    final path = Path()
      ..moveTo(0, cut)
      ..lineTo(cut, 0)
      ..lineTo(left, 0)
      ..lineTo(left + slope, depth)
      ..lineTo(right - slope, depth)
      ..lineTo(right, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w, cut)
      ..lineTo(w, h - cut)
      ..lineTo(w - cut, h)
      ..lineTo(cut, h)
      ..lineTo(0, h - cut)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF000000).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xF2131726), Color(0xF20A0C16)],
        ).createShader(Offset.zero & size),
    );

    // Weave, so the plate has a surface rather than being a flat fill.
    canvas.save();
    canvas.clipPath(path);
    final weave = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.02)
      ..strokeWidth = 1;
    for (var y = 0.0; y < h; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(w, y), weave);
    }

    // A charge line running the length of the plate, on a slow loop.
    final travel = (idle * 0.22) % 1.4 - 0.2;
    canvas.drawRect(
      Rect.fromLTWH(0, h - 2.5, w, 2.5),
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = LinearGradient(
          begin: Alignment(travel * 2 - 1 - 0.35, 0),
          end: Alignment(travel * 2 - 1 + 0.35, 0),
          colors: <Color>[
            tone.withValues(alpha: 0),
            tone.withValues(alpha: 0.75),
            tone.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, h - 2.5, w, 2.5)),
    );
    canvas.restore();

    // Edge, then a brighter run along the notch so the opening reads as lit.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.miter
        ..color = const Color(0x1FFFFFFF),
    );
    canvas.drawPath(
      Path()
        ..moveTo(left, 0)
        ..lineTo(left + slope, depth)
        ..lineTo(right - slope, depth)
        ..lineTo(right, 0),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round
        ..color = tone.withValues(alpha: 0.85),
    );
    canvas.drawPath(
      Path()
        ..moveTo(left, 0)
        ..lineTo(left + slope, depth)
        ..lineTo(right - slope, depth)
        ..lineTo(right, 0),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = tone.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Rivets between the stations.
    final stations = NavTab.values.length;
    for (var i = 1; i < stations; i++) {
      final x = w / stations * i;
      canvas.drawLine(
        Offset(x, h * 0.34),
        Offset(x, h * 0.70),
        Paint()
          ..strokeWidth = 1
          ..color = const Color(0x14FFFFFF),
      );
    }
  }

  @override
  bool shouldRepaint(_PlatePainter old) =>
      old.notchX != notchX ||
      old.notchWidth != notchWidth ||
      old.tone != tone ||
      old.idle != idle;
}
