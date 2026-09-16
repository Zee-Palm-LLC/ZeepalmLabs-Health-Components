import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../core/motion/ambient.dart';
import '../../../../core/motion/motion_stage.dart';
import '../../../../core/motion/reveal.dart';
import '../../../../core/painting/dashed_path_painter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/avatar_badge.dart';
import '../../../../core/widgets/dot_cluster.dart';
import '../../../../core/widgets/specialty_tile.dart';
import '../../../../core/widgets/photo_tile.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../data/showcase_data.dart';

class AppointmentsIllustration extends StatelessWidget {
  const AppointmentsIllustration({super.key, required this.active});

  final bool active;

  static Path _orbitPath(Size size) {
    return Path()
      ..addArc(
        Rect.fromCircle(center: const Offset(189, 305), radius: 176),
        -math.pi / 2,
        2 * math.pi - 0.001,
      );
  }

  @override
  Widget build(BuildContext context) {
    return MotionStage(
      active: active,
      introDuration: const Duration(milliseconds: 1600),
      builder: (context, intro, ambient) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DashedPathPainter(
                buildPath: _orbitPath,
                animation: intro,
                curve: const Interval(0, 0.6, curve: Curves.easeInOutCubic),
                color: AppColors.orbit,
              ),
            ),
          ),
          Positioned(
            left: 36,
            top: 346,
            child: Reveal(
              animation: intro,
              interval: (0.6, 0.85),
              scaleFrom: 0,
              curve: Curves.easeOutBack,
              child: Transform.rotate(
                angle: -0.6,
                child: Container(
                  width: 9,
                  height: 3,
                  decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 60.5,
            top: 366.5,
            width: 35,
            height: 35,
            child: Reveal(
              animation: intro,
              interval: (0.55, 0.85),
              scaleFrom: 0.3,
              curve: Curves.easeOutBack,
              child: Floating(
                animation: ambient,
                phase: 0.25,
                child: const DecoratedBox(
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: AppShadows.card),
                  child: PhotoTile(asset: ShowcaseAssets.pillOrb, circular: true),
                ),
              ),
            ),
          ),
          Positioned(
            left: 31,
            top: 170,
            width: 174,
            height: 157,
            child: Reveal(
              animation: intro,
              interval: (0.08, 0.5),
              from: const Offset(-28, 14),
              scaleFrom: 0.94,
              child: const _FeaturedAppointmentCard(appointment: featuredAppointment),
            ),
          ),
          Positioned(
            left: 133,
            top: 250,
            width: 207,
            height: 195,
            child: Reveal(
              animation: intro,
              interval: (0.22, 0.62),
              from: const Offset(32, 18),
              scaleFrom: 0.94,
              child: _AppointmentsCard(appointments: upcomingAppointments, animation: intro),
            ),
          ),
          Positioned(
            left: 248,
            top: 174,
            width: 32,
            height: 32,
            child: Reveal(
              animation: intro,
              interval: (0.5, 0.8),
              scaleFrom: 0.3,
              curve: Curves.easeOutBack,
              child: Floating(
                animation: ambient,
                amplitude: const Offset(0, -3),
                phase: 0.1,
                child: const AvatarBadge(
                  initials: 'AR',
                  asset: ShowcaseAssets.avatarPatient,
                  color: AppColors.avatarSand,
                  diameter: 32,
                ),
              ),
            ),
          ),
          Positioned(
            left: 257,
            top: 211,
            child: Reveal(
              animation: intro,
              interval: (0.65, 0.9),
              child: DotCluster(
                pattern: const ['##.', '.##', '#..'],
                color: AppColors.violet,
                twinkle: ambient,
              ),
            ),
          ),
          Positioned(
            left: 322,
            top: 166,
            child: Reveal(
              animation: intro,
              interval: (0.7, 0.95),
              scaleFrom: 0,
              curve: Curves.easeOutBack,
              child: Floating(
                animation: ambient,
                amplitude: const Offset(1.5, 2),
                phase: 0.6,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Container(
                    width: 10,
                    height: 6,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.violet, width: 1.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedAppointmentCard extends StatelessWidget {
  const _FeaturedAppointmentCard({required this.appointment});

  final FeaturedAppointment appointment;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 12,
            width: 44,
            height: 44,
            child: PhotoTile(asset: appointment.photoAsset),
          ),
          Positioned(left: 102, top: 19, width: 60, height: 28, child: _AppointmentMetaChip(appointment: appointment)),
          Positioned(
            left: 16,
            top: 66,
            right: 8,
            child: Text(appointment.doctor, style: AppTypography.cardTitle, maxLines: 1, softWrap: false),
          ),
          Positioned(
            left: 16,
            top: 84,
            child: Text(appointment.specialty, style: AppTypography.cardBody.copyWith(fontSize: 10)),
          ),
          Positioned(
            left: 16,
            top: 124,
            child: Text.rich(
              TextSpan(
                text: 'Fee: ',
                style: AppTypography.cardBody.copyWith(fontSize: 10),
                children: [TextSpan(text: appointment.fee, style: AppTypography.cardTitle.copyWith(fontSize: 10.5))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentMetaChip extends StatelessWidget {
  const _AppointmentMetaChip({required this.appointment});

  final FeaturedAppointment appointment;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(child: _MetaCell(value: '${appointment.durationMinutes}', label: 'Min')),
          Container(width: 1, height: 14, color: AppColors.surface.withValues(alpha: 0.35)),
          Expanded(child: _MetaCell(value: appointment.day, label: appointment.month)),
        ],
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: AppTypography.micro.copyWith(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.surface),
        ),
        Text(
          label,
          style: AppTypography.micro.copyWith(
            fontSize: 6.5,
            fontWeight: FontWeight.w500,
            color: AppColors.surface.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _AppointmentsCard extends StatelessWidget {
  const _AppointmentsCard({required this.appointments, required this.animation});

  final List<Appointment> appointments;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      elevated: true,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Column(
        children: [
          for (final (index, appointment) in appointments.indexed)
            Expanded(
              child: Reveal(
                animation: animation,
                interval: (0.38 + index * 0.08, 0.72 + index * 0.08),
                from: const Offset(14, 0),
                child: _AppointmentRow(appointment: appointment),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SpecialtyTile(icon: appointment.icon, color: appointment.color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appointment.specialty, style: AppTypography.cardTitle),
              const SizedBox(height: 2),
              Text(
                appointment.schedule,
                style: AppTypography.cardBody,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
