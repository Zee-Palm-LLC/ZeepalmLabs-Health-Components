import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';

class DoctorsNearMeSection extends StatelessWidget {
  const DoctorsNearMeSection({
    super.key,
    this.doctors = MockData.nearMe,
    this.onViewAll,
    this.onDoctorTap,
  });

  final List<DoctorModel> doctors;
  final VoidCallback? onViewAll;
  final ValueChanged<DoctorModel>? onDoctorTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Doctors Near Me',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.body,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: doctors.length,
          separatorBuilder: (context, index) => SizedBox(height: 14.h),
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return NearMeDoctorCard(
              doctor: doctor,
              onTap: () => onDoctorTap?.call(doctor),
            );
          },
        ),
      ],
    );
  }
}

class NearMeDoctorCard extends StatefulWidget {
  const NearMeDoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
    this.onShare,
    this.onFavorite,
  });

  final DoctorModel doctor;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;

  @override
  State<NearMeDoctorCard> createState() => _NearMeDoctorCardState();
}

class _NearMeDoctorCardState extends State<NearMeDoctorCard> {
  bool _favorited = false;
  bool _pressed = false;

  DoctorModel get doctor => widget.doctor;

  @override
  Widget build(BuildContext context) {
    final accent = _specialtyAccent(doctor.specialty);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.65),
              width: 0.6.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: Offset(0, 8.h),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DoctorPhoto(
                      doctor: doctor,
                      showOnline: doctor.availableNow,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  doctor.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              const _VerifiedBadge(),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: accent.background,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _specialtyIcon(doctor.specialty),
                                  size: 12.sp,
                                  color: accent.icon,
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    doctor.specialty,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: accent.icon,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.star.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Iconsax.star,
                                      size: 12.sp,
                                      color: AppColors.star,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      doctor.rating.toStringAsFixed(1),
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  '(${doctor.reviews} reviews)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              Icon(
                                Iconsax.location,
                                size: 11.sp,
                                color: AppColors.muted,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  doctor.hospital,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.body,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      children: [
                        _ActionButton(
                          icon: Iconsax.export_3,
                          onTap: widget.onShare,
                        ),
                        SizedBox(height: 8.h),
                        _ActionButton(
                          icon: _favorited ? Icons.favorite_rounded : Iconsax.heart,
                          iconColor: _favorited ? AppColors.cardioIcon : AppColors.body,
                          filled: _favorited,
                          onTap: () {
                            setState(() => _favorited = !_favorited);
                            widget.onFavorite?.call();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _InfoFooterBar(doctor: doctor),
            ],
          ),
        ),
      ),
    );
  }

  IconData _specialtyIcon(String specialty) {
    final value = specialty.toLowerCase();
    if (value.contains('heart') || value.contains('cardio')) {
      return Iconsax.heart;
    }
    if (value.contains('neuro') || value.contains('brain')) {
      return Iconsax.health;
    }
    if (value.contains('ophthal') || value.contains('eye')) {
      return Iconsax.eye;
    }
    if (value.contains('derma') || value.contains('skin')) {
      return Iconsax.user;
    }
    return Iconsax.hospital;
  }

  _SpecialtyAccent _specialtyAccent(String specialty) {
    final value = specialty.toLowerCase();
    if (value.contains('heart') || value.contains('cardio')) {
      return const _SpecialtyAccent(
        background: AppColors.cardio,
        icon: AppColors.cardioIcon,
      );
    }
    if (value.contains('neuro') || value.contains('brain')) {
      return const _SpecialtyAccent(
        background: AppColors.neuro,
        icon: AppColors.neuroIcon,
      );
    }
    if (value.contains('derma') || value.contains('skin')) {
      return const _SpecialtyAccent(
        background: AppColors.derma,
        icon: AppColors.dermaIcon,
      );
    }
    return _SpecialtyAccent(
      background: AppColors.primaryLight,
      icon: AppColors.primary,
    );
  }
}

class _SpecialtyAccent {
  const _SpecialtyAccent({required this.background, required this.icon});

  final Color background;
  final Color icon;
}

class _DoctorPhoto extends StatelessWidget {
  const _DoctorPhoto({
    required this.doctor,
    this.showOnline = false,
  });

  final DoctorModel doctor;
  final bool showOnline;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 76.w,
              height: 76.w,
              child: doctor.imageUrl == null
                  ? ColoredBox(
                      color: doctor.avatarColor,
                      child: Center(
                        child: Text(
                          doctor.initials,
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    )
                  : Image.network(
                      doctor.imageUrl!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return ColoredBox(
                          color: doctor.avatarColor.withValues(alpha: 0.35),
                          child: Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return ColoredBox(
                          color: doctor.avatarColor,
                          child: Center(
                            child: Text(
                              doctor.initials,
                              style: GoogleFonts.poppins(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
        if (showOnline)
          Positioned(
            right: -2.w,
            bottom: -2.h,
            child: Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.45),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.onTap,
    this.iconColor,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: filled
              ? AppColors.cardioIcon.withValues(alpha: 0.10)
              : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: filled
                ? AppColors.cardioIcon.withValues(alpha: 0.25)
                : AppColors.border,
            width: 0.8.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: iconColor ?? AppColors.body,
        ),
      ),
    );
  }
}

class _InfoFooterBar extends StatelessWidget {
  const _InfoFooterBar({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.background.withValues(alpha: 0.85),
          ],
        ),
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.75)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FooterItem(
              icon: Iconsax.flash_circle,
              label: doctor.availableNow ? 'Available Now' : 'Unavailable',
              highlight: doctor.availableNow,
              showDot: doctor.availableNow,
            ),
          ),
          _FooterDivider(),
          Expanded(
            child: _FooterItem(
              icon: Iconsax.briefcase,
              label: '${doctor.experienceYears} Years',
              alignCenter: true,
              showAccent: true,
            ),
          ),
          _FooterDivider(),
          Expanded(
            child: _FooterItem(
              icon: Iconsax.dollar_circle,
              label: '\$${doctor.fee.toStringAsFixed(2)}',
              alignEnd: true,
              emphasize: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColors.border,
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({
    required this.icon,
    required this.label,
    this.highlight = false,
    this.showDot = false,
    this.showAccent = false,
    this.emphasize = false,
    this.alignCenter = false,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;
  final bool showDot;
  final bool showAccent;
  final bool emphasize;
  final bool alignCenter;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : alignCenter
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : alignCenter
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
          children: [
            if (showDot) ...[
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5.w),
            ] else ...[
              Icon(
                icon,
                size: 12.sp,
                color: emphasize
                    ? AppColors.primary
                    : highlight
                        ? AppColors.success
                        : AppColors.muted,
              ),
              SizedBox(width: 4.w),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
                  color: highlight
                      ? AppColors.success
                      : emphasize
                          ? AppColors.primary
                          : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        if (showAccent) ...[
          SizedBox(height: 5.h),
          Container(
            width: 32.w,
            height: 2.5.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 17.w,
      height: 17.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Icon(Icons.check_rounded, size: 11.sp, color: Colors.white),
    );
  }
}
