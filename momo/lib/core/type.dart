import 'package:flutter/widgets.dart';

import 'palette.dart';

const interAscent = 0.96875;
const interCap = 0.7275;

TextStyle inter(double size, double weight, {double opsz = 14, double tracking = 0, Color color = Shade.ink, double? height, bool tabular = false}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight), FontVariation('opsz', opsz)],
    fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    letterSpacing: tracking,
    color: color,
    height: height,
    leadingDistribution: height == null ? null : TextLeadingDistribution.even,
  );
}

abstract final class Typo {
  static final title = inter(17.5, 600, opsz: 20, tracking: -0.2);
  static final greet = inter(30.5, 500, opsz: 32, tracking: -0.45, height: 1.23);
  static final pill = inter(14.6, 500, tracking: -0.05, color: Shade.soft);
  static final hint = inter(16.7, 400, opsz: 24, tracking: 0.08, color: Shade.hint);
  static final input = inter(16.7, 400, opsz: 24, tracking: 0.08, color: Shade.ink);
  static final chip = inter(13.6, 400, opsz: 18, tracking: -0.05, color: Shade.quiet);
  static final menu = inter(15.8, 400, opsz: 20, tracking: -0.12, color: Shade.soft);
  static final sheet = inter(16.8, 500, opsz: 20, tracking: -0.1);
  static final action = inter(15.8, 500, opsz: 18, tracking: -0.1);
  static final ask = inter(22.5, 500, opsz: 32, tracking: -0.15);
  static final tile = inter(12.9, 500, tracking: 0.02, color: Shade.soft);
  static final dish = inter(13.2, 400, tracking: 0.22, color: Shade.muted);
  static final big = inter(52, 400, opsz: 32, tracking: -0.6, color: Shade.ink2);
  static final meta = inter(11.4, 400, tracking: 0.28, color: Shade.muted);
  static final body = inter(17, 400, opsz: 28, tracking: -0.28, color: Shade.soft);
  static final link = inter(13.9, 500, opsz: 20, tracking: -0.1, color: Shade.soft);
  static final month = inter(28, 600, opsz: 32, tracking: -0.6);
  static final year = inter(13, 500, opsz: 24, tracking: 0, color: Shade.muted);
  static final weekday = inter(9.7, 500, tracking: 0.15, color: Shade.faint);
  static final day = inter(14, 400, tracking: 0.2);
  static final dayTiny = inter(10.5, 600, tracking: 0, color: Shade.soft);
  static final dayLabel = inter(11.1, 500, tracking: 0.12, color: Shade.muted);
  static final total = inter(42, 400, opsz: 28, tracking: 0, color: Shade.ink2);
  static final unit = inter(13.9, 400, opsz: 20, tracking: 0, color: Shade.muted);
  static final guide = inter(10.2, 400, tracking: 0.5, color: Shade.muted);
  static final kcal = inter(13.3, 600, opsz: 32, tracking: -0.2, color: Shade.soft);
  static final bubble = inter(15.5, 500, opsz: 18, tracking: 0.35, color: const Color(0xFFF7F5F0));
  static final label = inter(12.7, 500, tracking: 0.05, color: Shade.muted);
  static final answer = inter(16.4, 400, opsz: 22, tracking: -0.12, color: Shade.soft);
  static final unitBig = inter(17, 500, opsz: 24, tracking: 0, color: Shade.muted);
}

class BaseText extends StatelessWidget {
  const BaseText(this.text, {super.key, required this.style, this.align = TextAlign.left});

  final String text;
  final TextStyle style;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: align,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
    );
  }
}

class Pin extends StatelessWidget {
  const Pin({super.key, required this.baseline, required this.child, required this.size, this.left, this.right, this.center});

  final double baseline;
  final double size;
  final double? left;
  final double? right;
  final double? center;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = baseline - size * interAscent;
    if (center != null) {
      return Positioned(
        left: center! - 300,
        width: 600,
        top: top,
        child: Center(child: child),
      );
    }
    return Positioned(left: left, right: right, top: top, child: child);
  }
}
