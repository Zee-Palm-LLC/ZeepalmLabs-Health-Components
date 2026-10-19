import 'package:flutter/widgets.dart';

import '../core/glyphs.dart';
import '../core/style.dart';

/// Poppins' ascent; with `height: 1.4` the line box is exactly ascent + descent,
/// so a baseline in mock pt maps to `top = baseline - 1.05 * size`.
const ascent = 1.05;

/// Text whose baseline sits at [baseline], left-aligned at [x] or centred on [cx].
class TextAt extends StatelessWidget {
  const TextAt(this.text, {super.key, required this.style, required this.baseline, this.x, this.cx, this.right});

  final String text;
  final TextStyle style;
  final double baseline;
  final double? x;
  final double? cx;
  final double? right;

  @override
  Widget build(BuildContext context) {
    final s = style.copyWith(height: 1.4, leadingDistribution: TextLeadingDistribution.even);
    final top = baseline - ascent * style.fontSize!;
    if (cx != null) {
      return Positioned(
        left: cx! - 300,
        width: 600,
        top: top,
        child: Line(text, style: s, align: TextAlign.center),
      );
    }
    if (right != null) {
      return Positioned(
        right: right,
        top: top,
        child: Line(text, style: s, align: TextAlign.right),
      );
    }
    return Positioned(
      left: x,
      top: top,
      child: Line(text, style: s),
    );
  }
}

/// Unpositioned variant for use inside rows and animated wrappers.
TextStyle tight(TextStyle style) => style.copyWith(height: 1.4, leadingDistribution: TextLeadingDistribution.even);

/// Places a cut-out at the exact rect it had on its mock screen, shifted by [dy].
class ArtAt extends StatelessWidget {
  const ArtAt(this.art, {super.key, this.dy = 0, this.dx = 0, this.child});

  final Art art;
  final double dx;
  final double dy;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Positioned(left: art.x + dx, top: art.y + dy, width: art.w, height: art.h, child: child ?? art.image());
  }
}
