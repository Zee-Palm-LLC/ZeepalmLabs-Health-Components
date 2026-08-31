import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Dark mesh background — same layered radial structure as Aira-Health,
/// tuned for navy-charcoal base + magenta accent.
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
  static const Color topLeft = Color(0xFF151A28);
  static const Color topRight = Color(0xFF181428);
  static const Color topWarm = Color(0xFF1A1522);
  static const Color topWarmSoft = Color(0xFF181420);
  static const Color rightViolet = Color(0xFF1C1528);
  static const Color leftPurpleDeep = Color(0xFF1E1430);
  static const Color leftPurple = Color(0xFF221836);
  static const Color leftMist = Color(0xFF181620);
  static const Color bottomLeft = Color(0xFF1A1830);
  static const Color bottomLeftSoft = Color(0xFF1C1A32);
  static const Color bottomCenter = Color(0xFF221028);
  static const Color bottomCenterGlow = Color(0xFF2A1235);
  static const Color bottomRight = Color(0xFF281228);
  static const Color bottomRightSoft = Color(0xFF241525);
  static const Color accentGlow = Color(0x40C84FA0);
  static const Color accentGlowSoft = Color(0x18C84FA0);

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
            colors: [topLeft, base, Color(0x0012141A)],
            stops: [0.0, 0.38, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-0.92, -0.82),
            radius: 0.88,
            colors: [topWarm, topWarmSoft, Color(0x00181420)],
            stops: [0.0, 0.44, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.94, -0.84),
            radius: 0.82,
            colors: [topRight, rightViolet, Color(0x001C1528)],
            stops: [0.0, 0.42, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-1.02, 0.18),
            radius: 0.92,
            colors: [leftPurpleDeep, leftPurple, Color(0x00221836)],
            stops: [0.0, 0.48, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-0.18, 0.34),
            radius: 0.72,
            colors: [leftMist, Color(0x00181620)],
            stops: [0.0, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.0, 0.12),
            radius: 0.78,
            colors: [accentGlowSoft, Color(0x00C84FA0)],
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
            colors: [bottomCenter, bottomCenterGlow, Color(0x002A1235)],
            stops: [0.0, 0.52, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.96, 1.02),
            radius: 0.84,
            colors: [bottomRight, bottomRightSoft, Color(0x00241525)],
            stops: [0.0, 0.46, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.08, 0.55),
            radius: 0.62,
            colors: [accentGlow, Color(0x00C84FA0)],
            stops: [0.0, 1.0],
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
