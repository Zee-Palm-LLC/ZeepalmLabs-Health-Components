import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Solid black (#000000) image slot — empty, no icons/text/gradients.
class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.border,
    this.clipper,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final CustomClipper<Path>? clipper;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: clipper == null ? borderRadius : null,
        border: border,
      ),
    );

    if (clipper != null) {
      return ClipPath(clipper: clipper, child: child);
    }
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}

/// Solid black circular avatar / story slot.
class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({
    super.key,
    this.size = 48,
    this.borderColor,
    this.borderWidth = 2.5,
  });

  final double size;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.imagePlaceholder,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
    );
  }
}

/// Organic / editorial crop for hero athlete slot.
class OrganicHeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.12, size.height * 0.08);
    path.cubicTo(
      size.width * 0.02,
      size.height * 0.22,
      size.width * -0.02,
      size.height * 0.45,
      size.width * 0.08,
      size.height * 0.72,
    );
    path.cubicTo(
      size.width * 0.18,
      size.height * 0.95,
      size.width * 0.55,
      size.height * 1.02,
      size.width * 0.88,
      size.height * 0.82,
    );
    path.cubicTo(
      size.width * 1.05,
      size.height * 0.68,
      size.width * 1.02,
      size.height * 0.35,
      size.width * 0.92,
      size.height * 0.12,
    );
    path.cubicTo(
      size.width * 0.78,
      size.height * -0.02,
      size.width * 0.35,
      size.height * -0.02,
      size.width * 0.12,
      size.height * 0.08,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class SoftBlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.1);
    path.quadraticBezierTo(
      0,
      size.height * 0.4,
      size.width * 0.2,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 1.05,
      size.width * 0.95,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 1.05,
      size.height * 0.25,
      size.width * 0.7,
      size.height * 0.05,
    );
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * -0.05,
      size.width * 0.15,
      size.height * 0.1,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
