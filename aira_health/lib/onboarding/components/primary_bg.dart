import 'package:flutter/material.dart';

/// Pixel-matched mesh background sampled from the Aira onboarding reference.
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

  static const Color base = Color(0xFFF8F0F5);
  static const Color topLeft = Color(0xFFFAF2F7);
  static const Color topRight = Color(0xFFF7F2FA);
  static const Color topPeach = Color(0xFFFCEAEA);
  static const Color topPeachSoft = Color(0xFFFBECF0);
  static const Color rightLilac = Color(0xFFF8F0FB);
  static const Color leftLavender = Color(0xFFE8E4FF);
  static const Color leftLavenderDeep = Color(0xFFE6E2FF);
  static const Color leftMist = Color(0xFFF2E8F5);
  static const Color bottomLeft = Color(0xFFF3EEFB);
  static const Color bottomLeftSoft = Color(0xFFF5F0FC);
  static const Color bottomCenter = Color(0xFFF9E9FA);
  static const Color bottomCenterGlow = Color(0xFFFAE5FD);
  static const Color bottomRight = Color(0xFFFDE8FA);
  static const Color bottomRightSoft = Color(0xFFFCE6F9);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: base,
      child: Stack(
        fit: StackFit.expand,
        children: const [
          _RadialWash(
            alignment: Alignment(0.02, -0.92),
            radius: 1.05,
            colors: [topLeft, base, Color(0x00F8F0F5)],
            stops: [0.0, 0.38, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-0.92, -0.82),
            radius: 0.88,
            colors: [topPeach, topPeachSoft, Color(0x00FBECF0)],
            stops: [0.0, 0.44, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.94, -0.84),
            radius: 0.82,
            colors: [topRight, rightLilac, Color(0x00F8F0FB)],
            stops: [0.0, 0.42, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-1.02, 0.18),
            radius: 0.92,
            colors: [leftLavenderDeep, leftLavender, Color(0x00E8E4FF)],
            stops: [0.0, 0.48, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-0.18, 0.34),
            radius: 0.72,
            colors: [leftMist, Color(0x00F2E8F5)],
            stops: [0.0, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(-0.88, 1.02),
            radius: 0.86,
            colors: [bottomLeft, bottomLeftSoft, Color(0x00F5F0FC)],
            stops: [0.0, 0.5, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.04, 1.04),
            radius: 0.9,
            colors: [bottomCenter, bottomCenterGlow, Color(0x00FAE5FD)],
            stops: [0.0, 0.52, 1.0],
          ),
          _RadialWash(
            alignment: Alignment(0.96, 1.02),
            radius: 0.84,
            colors: [bottomRight, bottomRightSoft, Color(0x00FCE6F9)],
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

/// Shared onboarding background colors for other widgets.
abstract final class PrimaryBgColors {
  static const Color base = _MeshBackground.base;
  static const Color title = Color(0xFF2B2433);
  static const Color subtitle = Color(0xFF8B8194);
}
