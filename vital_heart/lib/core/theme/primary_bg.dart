import 'package:vital_heart/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PrimaryBg extends StatelessWidget {
  const PrimaryBg({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _MeshBackground(),
          ?child,
        ],
      ),
    );
  }
}

class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  static const Color base = AppColors.bg;
  static const Color topLeft = Color(0xFF141828);
  static const Color topRight = Color(0xFF181228);
  static const Color topWarm = Color(0xFF1A1420);
  static const Color topWarmSoft = Color(0xFF18121C);
  static const Color rightViolet = Color(0xFF1C1428);
  static const Color leftPurpleDeep = Color(0xFF221430);
  static const Color leftPurple = Color(0xFF281838);
  static const Color bottomLeft = Color(0xFF1A1830);
  static const Color bottomLeftSoft = Color(0xFF1C1A32);
  static const Color bottomCenter = Color(0xFF281028);
  static const Color bottomCenterGlow = Color(0xFF321235);
  static const Color bottomRight = Color(0xFF301228);
  static const Color bottomRightSoft = Color(0xFF2A1425);
  static const Color accentGlow = Color(0x45E84A8A);
  static const Color accentGlowSoft = Color(0x1AE84A8A);

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: base,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _RadialWash(
            alignment: Alignment(0.02, -0.92),
            radius: 1.05,
            colors: [topLeft, base, Color(0x000E1018)],
            stops: [0.0, 0.38, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-0.92, -0.82),
            radius: 0.88,
            colors: [topWarm, topWarmSoft, Color(0x0018121C)],
            stops: [0.0, 0.44, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.94, -0.84),
            radius: 0.82,
            colors: [topRight, rightViolet, Color(0x001C1428)],
            stops: [0.0, 0.42, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.0, 0.08),
            radius: 0.82,
            colors: [accentGlowSoft, Color(0x00E84A8A)],
            stops: [0.0, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-1.02, 0.18),
            radius: 0.92,
            colors: [leftPurpleDeep, leftPurple, Color(0x00281838)],
            stops: [0.0, 0.48, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.08, 0.52),
            radius: 0.68,
            colors: [accentGlow, Color(0x00E84A8A)],
            stops: [0.0, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-0.88, 1.02),
            radius: 0.86,
            colors: [bottomLeft, bottomLeftSoft, Color(0x001C1A32)],
            stops: [0.0, 0.5, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.04, 1.04),
            radius: 0.9,
            colors: [bottomCenter, bottomCenterGlow, Color(0x00321235)],
            stops: [0.0, 0.52, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.96, 1.02),
            radius: 0.84,
            colors: [bottomRight, bottomRightSoft, Color(0x002A1425)],
            stops: [0.0, 0.46, 1.0],
          ),
        ],
      ),
    );
  }
}

class _RadialWash extends StatelessWidget {
  const _RadialWash({
    required this.alignment,
    required this.radius,
    required this.colors,
    required this.stops,
  });

  final Alignment alignment;
  final double radius;
  final List<Color> colors;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: alignment,
          radius: radius,
          colors: colors,
          stops: stops,
        ),
      ),
    );
  }
}
