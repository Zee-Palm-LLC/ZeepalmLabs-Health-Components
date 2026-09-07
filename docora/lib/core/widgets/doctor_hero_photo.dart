import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_images.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';

/// Unique per list surface — IndexedStack keeps multiple tabs alive.
Object doctorPhotoHeroTag(String doctorId, String scope) =>
    'doctor-photo-$doctorId-$scope';

/// Shared photo used on list cards + detail so Hero flights match.
class DoctorHeroPhoto extends StatelessWidget {
  const DoctorHeroPhoto({
    super.key,
    required this.doctor,
    required this.scope,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
  });

  final DoctorModel doctor;
  /// Surface id, e.g. `near-me`, `top-rated`, `favorites`.
  final String scope;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;

    return Hero(
      tag: doctorPhotoHeroTag(doctor.id, scope),
      createRectTween: (begin, end) =>
          MaterialRectArcTween(begin: begin, end: end),
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: radius,
          child: doctor.imageUrl == null
              ? ColoredBox(
                  color: doctor.avatarColor,
                  child: Center(
                    child: Text(
                      doctor.initials,
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: AppImage(
                    path: doctor.imageUrl!,
                    fit: fit,
                    alignment: alignment,
                  ),
                ),
        ),
      ),
    );
  }
}
