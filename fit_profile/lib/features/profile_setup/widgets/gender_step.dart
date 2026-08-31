import 'package:fit_profile/core/controllers/profile_setup_controller.dart';
import 'package:fit_profile/core/motion/app_motion.dart';
import 'package:fit_profile/core/motion/luxury_tap.dart';
import 'package:fit_profile/core/motion/setup_step_header.dart';
import 'package:fit_profile/core/motion/stagger_column.dart';
import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:fit_profile/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class GenderStep extends StatelessWidget {
  const GenderStep({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final GenderOption selected;
  final ValueChanged<GenderOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: StaggerColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SetupStepHeader(
            title: 'Tell Us About Yourself!',
            subtitle:
                'To give you a better experience we need\nto know your gender',
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  label: 'Male',
                  icon: Iconsax.man,
                  option: GenderOption.male,
                  selected: selected == GenderOption.male,
                  onTap: () => onChanged(GenderOption.male),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _GenderCard(
                  label: 'Female',
                  icon: Iconsax.woman,
                  option: GenderOption.female,
                  selected: selected == GenderOption.female,
                  onTap: () => onChanged(GenderOption.female),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _GenderCard(
            label: 'Others',
            icon: Iconsax.user,
            option: GenderOption.others,
            selected: selected == GenderOption.others,
            onTap: () => onChanged(GenderOption.others),
            isWide: true,
          ),
        ],
      ),
    );
  }
}

class _GenderPalette {
  const _GenderPalette({
    required this.glow,
    required this.iconBg,
    required this.iconColor,
    required this.ring,
  });

  final Color glow;
  final Color iconBg;
  final Color iconColor;
  final Color ring;

  static _GenderPalette forOption(GenderOption option) {
    return switch (option) {
      GenderOption.male => const _GenderPalette(
          glow: Color(0xFF3B82F6),
          iconBg: Color(0xFF1E3A5F),
          iconColor: Color(0xFF93C5FD),
          ring: Color(0xFF60A5FA),
        ),
      GenderOption.female => const _GenderPalette(
          glow: Color(0xFFEC4899),
          iconBg: Color(0xFF4A1D3D),
          iconColor: Color(0xFFF9A8D4),
          ring: Color(0xFFF472B6),
        ),
      GenderOption.others => const _GenderPalette(
          glow: Color(0xFF8B5CF6),
          iconBg: Color(0xFF2E2550),
          iconColor: Color(0xFFC4B5FD),
          ring: Color(0xFFA78BFA),
        ),
    };
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.icon,
    required this.option,
    required this.selected,
    required this.onTap,
    this.isWide = false,
  });

  final String label;
  final IconData icon;
  final GenderOption option;
  final bool selected;
  final VoidCallback onTap;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final palette = _GenderPalette.forOption(option);

    return LuxuryTap(
      onTap: onTap,
      scale: 0.97,
      child: AnimatedScale(
        scale: selected ? 1.02 : 1,
        duration: const Duration(milliseconds: 280),
        curve: AppMotion.curve,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: AppMotion.curve,
          height: isWide ? 88.h : 148.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD456A8),
                      Color(0xFFC84FA0),
                      Color(0xFF9E3D86),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surface,
                      AppColors.surfaceElevated,
                    ],
                  ),
            border: Border.all(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.6)
                  : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.38),
                      blurRadius: 22,
                      offset: Offset(0, 10.h),
                    ),
                    BoxShadow(
                      color: palette.glow.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: Offset(0, 6.h),
                    ),
                  ],
          ),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: isWide ? -24.w : -22.w,
                top: isWide ? -28.h : -24.h,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: isWide ? 80.w : 72.w,
                  height: isWide ? 80.w : 72.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (selected ? AppColors.white : palette.glow)
                        .withValues(alpha: selected ? 0.12 : 0.14),
                  ),
                ),
              ),
              Positioned(
                left: isWide ? null : -14.w,
                bottom: isWide ? -20.h : -16.h,
                right: isWide ? 32.w : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: isWide ? 56.w : 44.w,
                  height: isWide ? 56.w : 44.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (selected ? AppColors.accent : palette.glow)
                        .withValues(alpha: 0.1),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isWide ? 16.w : 18.w),
                child: isWide
                    ? _WideCardContent(
                        label: label,
                        icon: icon,
                        selected: selected,
                        palette: palette,
                      )
                    : _TallCardContent(
                        label: label,
                        icon: icon,
                        selected: selected,
                        palette: palette,
                      ),
              ),
              Positioned(
                top: isWide ? 10.h : 12.h,
                right: isWide ? 10.w : 12.w,
                child: AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: AppMotion.curve,
                  child: AnimatedOpacity(
                    opacity: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.tick_circle,
                        size: 22.w,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TallCardContent extends StatelessWidget {
  const _TallCardContent({
    required this.label,
    required this.icon,
    required this.selected,
    required this.palette,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final _GenderPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _IconBadge(
          icon: icon,
          selected: selected,
          palette: palette,
          size: 56.w,
          iconSize: 28.sp,
        ),
        SizedBox(height: 14.h),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.title,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 4.h),
        AnimatedOpacity(
          opacity: selected ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'Selected',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}

class _WideCardContent extends StatelessWidget {
  const _WideCardContent({
    required this.label,
    required this.icon,
    required this.selected,
    required this.palette,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final _GenderPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBadge(
          icon: icon,
          selected: selected,
          palette: palette,
          size: 52.w,
          iconSize: 24.sp,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.cardLabel.copyWith(
                  color: selected ? AppColors.white : AppColors.title,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                selected ? 'Your selection' : 'Tap to choose',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: selected
                      ? AppColors.white.withValues(alpha: 0.72)
                      : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: selected ? 1 : 0.35,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Iconsax.arrow_right_3,
            size: 18.sp,
            color: selected ? AppColors.white : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.selected,
    required this.palette,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final bool selected;
  final _GenderPalette palette;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: AppMotion.curve,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.white.withValues(alpha: 0.28),
                  AppColors.white.withValues(alpha: 0.08),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.iconBg,
                  palette.iconBg.withValues(alpha: 0.7),
                ],
              ),
        border: Border.all(
          color: selected
              ? AppColors.white.withValues(alpha: 0.35)
              : palette.ring.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (selected ? AppColors.white : palette.glow)
                .withValues(alpha: selected ? 0.15 : 0.22),
            blurRadius: 14,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: selected ? AppColors.white : palette.iconColor,
      ),
    );
  }
}
