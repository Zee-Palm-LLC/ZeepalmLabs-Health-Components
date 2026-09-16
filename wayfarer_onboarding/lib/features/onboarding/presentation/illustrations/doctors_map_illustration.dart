import 'package:flutter/material.dart';

import '../../../../core/motion/ambient.dart';
import '../../../../core/motion/motion_stage.dart';
import '../../../../core/motion/reveal.dart';
import '../../../../core/painting/world_dot_map.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/avatar_badge.dart';
import '../../../../core/widgets/dot_cluster.dart';
import '../../../../core/widgets/photo_tile.dart';
import '../../data/showcase_data.dart';

typedef _Hotspot = ({double left, double top, List<String> pattern, Color color});

const List<_Hotspot> _hotspots = [
  (left: 316, top: 244, pattern: ['.##', '##.'], color: AppColors.orange),
  (left: 300, top: 306, pattern: ['##.', '.##', '..#'], color: AppColors.violet),
  (left: 4, top: 283, pattern: ['##', '#.'], color: AppColors.orange),
  (left: 64, top: 408, pattern: ['.##', '###'], color: AppColors.violet),
  (left: 354, top: 418, pattern: ['##.', '.##'], color: AppColors.orange),
];

class DoctorsMapIllustration extends StatelessWidget {
  const DoctorsMapIllustration({super.key, required this.active});

  final bool active;

  static const _centerCard = Rect.fromLTWH(148, 139, 79, 107);
  static const _leftCard = Rect.fromLTWH(85, 163, 53, 67);
  static const _rightCard = Rect.fromLTWH(236, 160, 56, 67);

  @override
  Widget build(BuildContext context) {
    final [leftDoctor, centerDoctor, rightDoctor] = worldwideConsultations;

    return MotionStage(
      active: active,
      introDuration: const Duration(milliseconds: 1800),
      builder: (context, intro, ambient) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 199,
            width: 375,
            height: 264,
            child: CustomPaint(
              painter: WorldDotMapPainter(
                animation: intro,
                curve: const Interval(0, 0.7, curve: Curves.easeOut),
                color: AppColors.mapDot,
              ),
            ),
          ),
          for (final spot in _hotspots)
            Positioned(
              left: spot.left,
              top: spot.top,
              child: Reveal(
                animation: intro,
                interval: (0.45, 0.75),
                scaleFrom: 0.4,
                child: DotCluster(pattern: spot.pattern, color: spot.color, twinkle: ambient),
              ),
            ),
          Positioned(
            left: 322,
            top: 386,
            child: Reveal(
              animation: intro,
              interval: (0.6, 0.9),
              child: PulseRing(animation: ambient, color: AppColors.orange, diameter: 36),
            ),
          ),
          Positioned(
            left: 43,
            top: 364,
            child: Reveal(
              animation: intro,
              interval: (0.6, 0.9),
              child: PulseRing(animation: ambient, color: AppColors.violet, diameter: 48, cycles: 2),
            ),
          ),
          Positioned(
            left: 51,
            top: 372,
            width: 32,
            height: 32,
            child: Reveal(
              animation: intro,
              interval: (0.5, 0.8),
              scaleFrom: 0.3,
              curve: Curves.easeOutBack,
              child: Floating(animation: ambient, phase: 0.4, child: const _CareBubble()),
            ),
          ),
          _fanOutCard(intro, ambient, rect: _rightCard, consultation: rightDoctor, phase: 0.7),
          _fanOutCard(intro, ambient, rect: _leftCard, consultation: leftDoctor, phase: 0.2),
          Positioned.fromRect(
            rect: _centerCard,
            child: Reveal(
              animation: intro,
              interval: (0.15, 0.55),
              from: const Offset(0, 18),
              scaleFrom: 0.55,
              curve: Curves.easeOutBack,
              child: Floating(
                animation: ambient,
                amplitude: const Offset(0, -2.5),
                child: _ConsultationCard(consultation: centerDoctor, highlighted: true, avatarReveal: intro),
              ),
            ),
          ),
          Positioned(
            left: 220,
            top: 346,
            height: 29,
            child: Reveal(
              animation: intro,
              interval: (0.62, 0.95),
              from: const Offset(24, 0),
              child: _AvailabilityChip(consultation: rightDoctor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fanOutCard(
    Animation<double> intro,
    Animation<double> ambient, {
    required Rect rect,
    required Consultation consultation,
    required double phase,
  }) {
    final towardCenter = _centerCard.center - rect.center;
    return Positioned.fromRect(
      rect: rect,
      child: Reveal(
        animation: intro,
        interval: (0.35, 0.8),
        from: towardCenter,
        scaleFrom: 0.7,
        rotateFrom: towardCenter.dx.sign * -0.25,
        child: Floating(
          animation: ambient,
          amplitude: const Offset(0, 2),
          phase: phase,
          child: _ConsultationCard(consultation: consultation, avatarReveal: intro),
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({required this.consultation, required this.avatarReveal, this.highlighted = false});

  final Consultation consultation;
  final Animation<double> avatarReveal;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final radius = highlighted ? 12.0 : 10.0;
    final avatarSize = highlighted ? 22.0 : 18.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(radius),
              border: highlighted ? Border.all(color: AppColors.orangeBorder, width: 1.5) : null,
              boxShadow: highlighted ? AppShadows.raised : AppShadows.card,
            ),
            child: Padding(
              padding: EdgeInsets.all(highlighted ? 3 : 2.5),
              child: PhotoTile(
                asset: consultation.photoAsset,
                borderRadius: BorderRadius.circular(radius - 3),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -avatarSize / 2 + 2,
          child: Center(
            child: Reveal(
              animation: avatarReveal,
              interval: (0.6, 0.88),
              scaleFrom: 0,
              curve: Curves.easeOutBack,
              child: AvatarBadge(
                initials: consultation.initials,
                asset: consultation.avatarAsset,
                color: highlighted ? AppColors.avatarSand : AppColors.avatarClay,
                diameter: avatarSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.consultation});

  final Consultation consultation;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.cardBody.copyWith(fontSize: 9.5, color: AppColors.ink);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppShadows.raised,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4.5, 4.5, 10, 4.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarBadge(
              initials: consultation.initials,
              asset: consultation.avatarAsset,
              color: AppColors.avatarRose,
              diameter: 20,
              ringWidth: 0,
            ),
            const SizedBox(width: 6),
            Text.rich(
              TextSpan(
                text: '${consultation.doctorName} is ',
                style: style,
                children: [
                  TextSpan(
                    text: consultation.status,
                    style: AppTypography.cardTitle.copyWith(fontSize: 9.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareBubble extends StatelessWidget {
  const _CareBubble();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: AppShadows.raised,
      ),
      child: Center(child: Icon(Icons.local_hospital_rounded, size: 17, color: AppColors.heart)),
    );
  }
}
