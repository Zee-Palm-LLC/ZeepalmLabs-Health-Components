import 'package:flutter/material.dart';

import '../core/style.dart';

class ChunkyText extends StatelessWidget {
  const ChunkyText(this.text, {super.key, required this.size});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final base = baloo(size, weight: 800, tracking: -0.5, height: 1.0);
    Widget layer(Paint p, Offset o) => Transform.translate(
      offset: o,
      child: Label(text, style: base.copyWith(foreground: p, color: null)),
    );
    return Stack(
      children: [
        layer(
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9
            ..strokeJoin = StrokeJoin.round
            ..color = const Color(0xFF3A1E6E)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          const Offset(0, 8),
        ),
        for (var d = 7.0; d > 0; d -= 1)
          layer(
            Paint()
              ..style = PaintingStyle.fill
              ..color = Color.lerp(
                const Color(0xFFB4470C),
                const Color(0xFFE07A16),
                1 - d / 7,
              )!,
            Offset(0, d),
          ),
        layer(
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..strokeJoin = StrokeJoin.round
            ..color = const Color(0xFFFFF0B0),
          Offset.zero,
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE680), Color(0xFFFFC93A), Color(0xFFFF9A22)],
            stops: [0, 0.5, 1],
          ).createShader(r),
          child: Label(text, style: base),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.7),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0.15, 0.45],
          ).createShader(r),
          child: Label(text, style: base),
        ),
      ],
    );
  }
}
