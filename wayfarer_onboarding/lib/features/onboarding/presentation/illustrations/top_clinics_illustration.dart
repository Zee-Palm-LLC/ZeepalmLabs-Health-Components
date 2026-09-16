import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/brand.dart';
import '../../../../core/motion/motion_stage.dart';
import '../../../../core/motion/reveal.dart';
import '../../../../core/painting/dashed_path_painter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/photo_tile.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../data/showcase_data.dart';

class TopClinicsIllustration extends StatelessWidget {
  const TopClinicsIllustration({super.key, required this.active});

  final bool active;

  static Path _loopPath(Size size) => Path()..addOval(const Rect.fromLTWH(-6, 128, 390, 330));

  @override
  Widget build(BuildContext context) {
    final [heartCare, centralMedical, brightSmile] = topClinics;

    return MotionStage(
      active: active,
      introDuration: const Duration(milliseconds: 1700),
      ambientPeriod: const Duration(milliseconds: 2400),
      builder: (context, intro, ambient) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DashedPathPainter(
                buildPath: _loopPath,
                animation: intro,
                curve: const Interval(0.1, 0.7, curve: Curves.easeInOutCubic),
                color: AppColors.orbit,
              ),
            ),
          ),
          Positioned(
            left: 29,
            top: 163,
            width: 311,
            height: 78,
            child: Reveal(
              animation: intro,
              interval: (0.1, 0.5),
              from: const Offset(-36, 0),
              child: _ClinicCard(clinic: heartCare, imageInset: 15, imageVertical: 6, imageWidth: 79),
            ),
          ),
          Positioned(
            left: 29,
            top: 357,
            width: 311,
            height: 85,
            child: Reveal(
              animation: intro,
              interval: (0.3, 0.7),
              from: const Offset(-36, 0),
              child: _ClinicCard(clinic: brightSmile, imageInset: 15, imageVertical: 7, imageWidth: 79),
            ),
          ),
          Positioned(
            left: 23,
            top: 259,
            width: 332,
            height: 93,
            child: Reveal(
              animation: intro,
              interval: (0.2, 0.62),
              from: const Offset(40, 0),
              scaleFrom: 0.92,
              curve: Curves.easeOutBack,
              child: _ClinicCard(
                clinic: centralMedical,
                imageInset: 6,
                imageVertical: 8,
                imageWidth: 87,
                featured: true,
                heartbeat: ambient,
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 156,
            child: Reveal(
              animation: intro,
              interval: (0.55, 0.85),
              scaleFrom: 0.3,
              curve: Curves.easeOutBack,
              child: Transform.rotate(angle: -0.2, child: const _CategoryTag(label: 'Cardiology')),
            ),
          ),
          Positioned(
            left: 310,
            top: 150,
            child: Reveal(
              animation: intro,
              interval: (0.62, 0.9),
              scaleFrom: 0.3,
              curve: Curves.easeOutBack,
              child: Transform.rotate(angle: 0.08, child: _FeeTag(fee: featuredAppointment.fee)),
            ),
          ),
          Positioned(
            left: 10,
            top: 436,
            child: Reveal(
              animation: intro,
              interval: (0.7, 0.98),
              scaleFrom: 0.3,
              curve: Curves.easeOutBack,
              child: Transform.rotate(angle: -0.1, child: const _VerifiedTag()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({
    required this.clinic,
    required this.imageInset,
    required this.imageVertical,
    required this.imageWidth,
    this.featured = false,
    this.heartbeat,
  });

  final Clinic clinic;
  final double imageInset;
  final double imageVertical;
  final double imageWidth;
  final bool featured;
  final Animation<double>? heartbeat;

  @override
  Widget build(BuildContext context) {
    final actionSize = featured ? 24.0 : 22.0;

    return SurfaceCard(
      elevated: featured,
      padding: EdgeInsets.fromLTRB(imageInset, imageVertical, featured ? 9 : 8, imageVertical),
      child: Row(
        children: [
          SizedBox(width: imageWidth, child: PhotoTile(asset: clinic.photoAsset)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic.name,
                  style: AppTypography.cardTitle.copyWith(fontSize: featured ? 13 : 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(clinic.description, style: AppTypography.cardBody, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 11, color: AppColors.star),
                    const SizedBox(width: 2),
                    Text(clinic.ratingLabel, style: AppTypography.micro.copyWith(color: AppColors.ink, fontSize: 8.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _Heartbeat(
            animation: heartbeat,
            child: _CircleAction(
              size: actionSize,
              icon: featured ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              iconColor: featured ? AppColors.heart : AppColors.inkMuted,
            ),
          ),
          const SizedBox(width: 5),
          _CircleAction(
            size: actionSize,
            icon: Icons.north_east_rounded,
            iconColor: featured ? AppColors.surface : AppColors.inkMuted,
            fill: featured ? AppColors.orange : null,
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.size, required this.icon, required this.iconColor, this.fill});

  final double size;
  final IconData icon;
  final Color iconColor;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill ?? AppColors.surface,
        border: fill == null ? Border.all(color: AppColors.hairline) : null,
      ),
      child: Icon(icon, size: size * 0.5, color: iconColor),
    );
  }
}

class _Heartbeat extends StatelessWidget {
  const _Heartbeat({required this.animation, required this.child});

  final Animation<double>? animation;
  final Widget child;

  // Two quick beats at the start of each loop, then rest.
  static double _scaleAt(double t) {
    if (t > 0.25) return 1;
    return 1 + 0.18 * math.max(0, math.sin(t * math.pi * 8));
  }

  @override
  Widget build(BuildContext context) {
    final animation = this.animation;
    if (animation == null) return child;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Transform.scale(scale: _scaleAt(animation.value), child: child),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: AppColors.orangeSoft, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: AppTypography.micro.copyWith(color: AppColors.orange, fontSize: 7.5)),
    );
  }
}

class _FeeTag extends StatelessWidget {
  const _FeeTag({required this.fee});

  final String fee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Fee', style: AppTypography.micro.copyWith(fontSize: 6, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(fee, style: AppTypography.cardTitle.copyWith(fontSize: 7.5)),
        ],
      ),
    );
  }
}

class _VerifiedTag extends StatelessWidget {
  const _VerifiedTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Verified by', style: AppTypography.micro.copyWith(fontSize: 6, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
          ),
          const SizedBox(width: 2),
          Text(AppBrand.name, style: AppTypography.micro.copyWith(fontSize: 6, color: AppColors.ink)),
        ],
      ),
    );
  }
}
