import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../core/palette.dart';
import '../core/type.dart';

/// A rectangle with its corners cut off.
///
/// The chamfer is what separates a game panel from an app card. A rounded
/// rectangle reads as software; a plate with bevelled corners reads as
/// something machined, which is the whole visual argument of a HUD.
///
/// [cut] is the length taken off each corner along both edges, and is clamped
/// so it can never exceed half of the shorter side.
Path chamferPath(
  Size size, {
  double cut = 12,
  bool topLeft = true,
  bool topRight = true,
  bool bottomRight = true,
  bool bottomLeft = true,
}) {
  final c = math.min(cut, math.min(size.width, size.height) / 2);
  final w = size.width;
  final h = size.height;
  final p = Path();

  if (topLeft) {
    p.moveTo(0, c);
    p.lineTo(c, 0);
  } else {
    p.moveTo(0, 0);
  }

  if (topRight) {
    p.lineTo(w - c, 0);
    p.lineTo(w, c);
  } else {
    p.lineTo(w, 0);
  }

  if (bottomRight) {
    p.lineTo(w, h - c);
    p.lineTo(w - c, h);
  } else {
    p.lineTo(w, h);
  }

  if (bottomLeft) {
    p.lineTo(c, h);
    p.lineTo(0, h - c);
  } else {
    p.lineTo(0, h);
  }

  p.close();
  return p;
}

/// Clips its child to a chamfered plate.
class ChamferClipper extends CustomClipper<Path> {
  const ChamferClipper({this.cut = 12});

  final double cut;

  @override
  Path getClip(Size size) => chamferPath(size, cut: cut);

  @override
  bool shouldReclip(ChamferClipper old) => old.cut != cut;
}

/// The workhorse surface: a chamfered plate with a lit edge, an optional
/// accent rail down one side, corner brackets and a faint scanline weave.
///
/// Everything a card does on these screens goes through here, so the dashboard,
/// the quest detail and the vault cannot drift apart.
class HudPanel extends StatelessWidget {
  const HudPanel({
    super.key,
    required this.child,
    this.cut = 14,
    this.fill = Quests.card,
    this.gradient,
    this.edge = Quests.cardEdge,
    this.edgeWidth = 1.2,
    this.accent,
    this.accentStrength = 1,
    this.brackets = true,
    this.bracketLength = 16,
    this.scanlines = true,
    this.rail = false,
    this.padding = EdgeInsets.zero,
    this.glow = 0,
  });

  final Widget child;
  final double cut;
  final Color fill;
  final Gradient? gradient;
  final Color edge;
  final double edgeWidth;

  /// Lights the brackets, the rail and the glow. Defaults to [edge].
  final Color? accent;
  final double accentStrength;

  final bool brackets;
  final double bracketLength;
  final bool scanlines;

  /// A solid bar down the left edge, the way a game marks a panel's faction.
  final bool rail;

  final EdgeInsets padding;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HudPanelPainter(
        cut: cut,
        fill: fill,
        gradient: gradient,
        edge: edge,
        edgeWidth: edgeWidth,
        accent: accent ?? edge,
        accentStrength: accentStrength,
        brackets: brackets,
        bracketLength: bracketLength,
        scanlines: scanlines,
        rail: rail,
        glow: glow,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _HudPanelPainter extends CustomPainter {
  const _HudPanelPainter({
    required this.cut,
    required this.fill,
    required this.gradient,
    required this.edge,
    required this.edgeWidth,
    required this.accent,
    required this.accentStrength,
    required this.brackets,
    required this.bracketLength,
    required this.scanlines,
    required this.rail,
    required this.glow,
  });

  final double cut;
  final Color fill;
  final Gradient? gradient;
  final Color edge;
  final double edgeWidth;
  final Color accent;
  final double accentStrength;
  final bool brackets;
  final double bracketLength;
  final bool scanlines;
  final bool rail;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final path = chamferPath(size, cut: cut);
    final rect = Offset.zero & size;

    if (glow > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = accent.withValues(alpha: 0.30 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + 12 * glow),
      );
    }

    canvas.drawPath(path, Paint()..color = fill);
    final g = gradient;
    if (g != null) {
      canvas.drawPath(path, Paint()..shader = g.createShader(rect));
    }

    if (scanlines) {
      canvas.save();
      canvas.clipPath(path);
      final line = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.018)
        ..strokeWidth = 1;
      for (var y = 0.0; y < size.height; y += 3) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
      }
      canvas.restore();
    }

    // The lit edge, plus a brighter highlight along the top two segments so
    // the plate looks like it is catching a light from above.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = edgeWidth
        ..strokeJoin = StrokeJoin.miter
        ..color = edge
        ..isAntiAlias = true,
    );

    final c = math.min(cut, math.min(size.width, size.height) / 2);
    canvas.drawPath(
      Path()
        ..moveTo(0, c)
        ..lineTo(c, 0)
        ..lineTo(size.width - c, 0),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = edgeWidth
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.10),
    );

    if (rail) {
      canvas.drawPath(
        Path()
          ..moveTo(0, c + 2)
          ..lineTo(0, size.height - c - 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..color = accent.withValues(alpha: 0.85 * accentStrength),
      );
    }

    if (brackets) {
      final b = math.min(bracketLength, math.min(size.width, size.height) / 3);
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.square
        ..color = accent.withValues(alpha: 0.8 * accentStrength)
        ..isAntiAlias = true;
      // Top-left and bottom-right only: four brackets is a targeting
      // reticle, two is a frame.
      canvas.drawPath(
        Path()
          ..moveTo(0, c + b)
          ..lineTo(0, c)
          ..lineTo(c, 0)
          ..lineTo(c + b, 0),
        p,
      );
      canvas.drawPath(
        Path()
          ..moveTo(size.width, size.height - c - b)
          ..lineTo(size.width, size.height - c)
          ..lineTo(size.width - c, size.height)
          ..lineTo(size.width - c - b, size.height),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_HudPanelPainter old) =>
      old.cut != cut ||
      old.fill != fill ||
      old.gradient != gradient ||
      old.edge != edge ||
      old.edgeWidth != edgeWidth ||
      old.accent != accent ||
      old.accentStrength != accentStrength ||
      old.brackets != brackets ||
      old.bracketLength != bracketLength ||
      old.scanlines != scanlines ||
      old.rail != rail ||
      old.glow != glow;
}

/// An energy bar built from discrete cells rather than one smooth fill.
///
/// Segments are how a game says "resource". The partial cell at the leading
/// edge is drawn at fractional width and lit, so the bar still reads
/// continuously while looking built out of parts.
class SegmentedMeter extends StatelessWidget {
  const SegmentedMeter({
    super.key,
    required this.value,
    required this.color,
    this.height = 10,
    this.segments = 20,
    this.gap = 2,
    this.shimmer = 0,
    this.trackColor = const Color(0xFF161B2B),
  });

  final double value;
  final Color color;
  final double height;
  final int segments;
  final double gap;
  final double shimmer;
  final Color trackColor;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: CustomPaint(
          painter: _SegmentPainter(
            value: value,
            color: color,
            segments: segments,
            gap: gap,
            shimmer: shimmer,
            trackColor: trackColor,
          ),
          child: const SizedBox.expand(),
        ),
      );
}

class _SegmentPainter extends CustomPainter {
  const _SegmentPainter({
    required this.value,
    required this.color,
    required this.segments,
    required this.gap,
    required this.shimmer,
    required this.trackColor,
  });

  final double value;
  final Color color;
  final int segments;
  final double gap;
  final double shimmer;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    final n = segments;
    final cell = (size.width - gap * (n - 1)) / n;
    if (cell <= 0) return;
    final v = value.clamp(0.0, 1.0);
    final lit = v * n;
    final skew = size.height * 0.34;

    for (var i = 0; i < n; i++) {
      final x = i * (cell + gap);
      final fillFraction = (lit - i).clamp(0.0, 1.0);

      // Each cell is a parallelogram, leaning the way a power gauge does.
      Path cellPath(double width) => Path()
        ..moveTo(x + skew, 0)
        ..lineTo(x + width, 0)
        ..lineTo(x + width - skew, size.height)
        ..lineTo(x, size.height)
        ..close();

      canvas.drawPath(cellPath(cell), Paint()..color = trackColor);

      if (fillFraction <= 0) continue;
      final w = cell * fillFraction;
      canvas.drawPath(
        cellPath(math.max(w, skew + 0.5)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.lerp(color, const Color(0xFFFFFFFF), 0.35)!,
              color,
            ],
          ).createShader(Rect.fromLTWH(x, 0, cell, size.height)),
      );

      // The last lit cell burns brighter, so the head of the bar is obvious.
      if (fillFraction < 1 || i == (lit.ceil() - 1)) {
        canvas.drawPath(
          cellPath(math.max(w, skew + 0.5)),
          Paint()
            ..color = color.withValues(alpha: 0.55)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.5),
        );
      }
    }

    if (shimmer > 0 && v > 0) {
      final head = ((shimmer * 0.45) % 1.0) * 1.5 - 0.25;
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width * v, size.height));
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = LinearGradient(
            begin: Alignment(head - 0.4, 0),
            end: Alignment(head + 0.4, 0),
            colors: const <Color>[
              Color(0x00FFFFFF),
              Color(0x40FFFFFF),
              Color(0x00FFFFFF),
            ],
          ).createShader(Offset.zero & size),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SegmentPainter old) =>
      old.value != value ||
      old.color != color ||
      old.segments != segments ||
      old.gap != gap ||
      old.shimmer != shimmer ||
      old.trackColor != trackColor;
}

/// A section heading with a leading accent blade, the way a game labels a
/// panel. Optionally carries a trailing readout.
class HudHeading extends StatelessWidget {
  const HudHeading({
    super.key,
    required this.title,
    this.trailing,
    this.accent = Quests.purple,
  });

  final String title;
  final Widget? trailing;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CustomPaint(
          size: const Size(10, 18),
          painter: _BladePainter(accent),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: T.sectionTitle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 6),
            painter: _RulePainter(accent),
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class _BladePainter extends CustomPainter {
  const _BladePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final skew = size.width * 0.45;
    canvas.drawPath(
      Path()
        ..moveTo(skew, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width - skew, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(color, const Color(0xFFFFFFFF), 0.4)!,
            color,
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      Path()
        ..moveTo(skew, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width - skew, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(_BladePainter old) => old.color != color;
}

/// A hairline that fades out to the right, with a small diamond on it.
class _RulePainter extends CustomPainter {
  const _RulePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..strokeWidth = 1
        ..shader = LinearGradient(
          colors: <Color>[
            color.withValues(alpha: 0.45),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      Path()
        ..moveTo(3, y)
        ..lineTo(6, y - 3)
        ..lineTo(9, y)
        ..lineTo(6, y + 3)
        ..close(),
      Paint()..color = color.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(_RulePainter old) => old.color != color;
}

/// The chamfered, bevelled key used for every primary action.
///
/// Three things make it read as a game control rather than a web button: the
/// corners are cut, the face carries a hard top highlight and a bottom shade
/// like moulded plastic, and a sheen crosses it on its own schedule.
class BevelButton extends StatelessWidget {
  const BevelButton({
    super.key,
    required this.child,
    required this.gradient,
    this.height = 56,
    this.cut = 16,
    this.glowColor,
    this.lit = false,
    this.idle = 0,
    this.charge = 0,
  });

  final Widget child;
  final Gradient gradient;
  final double height;
  final double cut;
  final Color? glowColor;
  final bool lit;
  final double idle;

  /// 0..1; wipes a brighter overlay across from the left.
  final double charge;

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? Quests.purple;
    final cycle = (idle / 3.6) % 1.0;
    final sheen = (cycle / 0.3).clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _BevelPainter(
          gradient: gradient,
          cut: cut,
          glow: glow,
          lit: lit,
          sheen: sheen,
          charge: charge,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _BevelPainter extends CustomPainter {
  const _BevelPainter({
    required this.gradient,
    required this.cut,
    required this.glow,
    required this.lit,
    required this.sheen,
    required this.charge,
  });

  final Gradient gradient;
  final double cut;
  final Color glow;
  final bool lit;
  final double sheen;
  final double charge;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final path = chamferPath(size, cut: cut);

    canvas.drawPath(
      path,
      Paint()
        ..color = glow.withValues(alpha: lit ? 0.55 : 0.36)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, lit ? 26 : 18),
    );

    canvas.drawPath(path, Paint()..shader = gradient.createShader(rect));

    canvas.save();
    canvas.clipPath(path);

    // Moulded face: light on the top half, shade on the bottom.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            const Color(0xFFFFFFFF).withValues(alpha: 0.26),
            const Color(0x00FFFFFF),
            const Color(0xFF000000).withValues(alpha: 0.22),
          ],
          stops: const <double>[0, 0.52, 1],
        ).createShader(rect),
    );

    if (charge > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * charge.clamp(0.0, 1.0), size.height),
        Paint()
          ..shader = LinearGradient(
            colors: <Color>[
              Quests.blueBright.withValues(alpha: 0.10),
              Quests.blueBright.withValues(alpha: 0.45),
            ],
          ).createShader(rect),
      );
    }

    if (sheen > 0 && sheen < 1) {
      final x = -1.5 + 3 * Curves.easeInOut.transform(sheen);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment(x - 0.4, 0),
            end: Alignment(x + 0.4, 0),
            colors: const <Color>[
              Color(0x00FFFFFF),
              Color(0x59FFFFFF),
              Color(0x00FFFFFF),
            ],
          ).createShader(rect),
      );
    }
    canvas.restore();

    // Rim, then a hard inner highlight just inside the top edge.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.miter
        ..color = const Color(0xFFFFFFFF).withValues(alpha: lit ? 0.62 : 0.40),
    );
    final c = math.min(cut, math.min(size.width, size.height) / 2);
    canvas.drawPath(
      Path()
        ..moveTo(c + 1.5, 2.2)
        ..lineTo(size.width - c - 1.5, 2.2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_BevelPainter old) =>
      old.gradient != gradient ||
      old.cut != cut ||
      old.glow != glow ||
      old.lit != lit ||
      old.sheen != sheen ||
      old.charge != charge;
}
