import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/theme/app_colors.dart';

class BookingStepBar extends StatelessWidget {
  const BookingStepBar({super.key, required this.step});

  /// 1 = doctor, 2 = schedule, 3 = done
  final int step;

  @override
  Widget build(BuildContext context) {
    final labels = ['Doctor', 'Schedule', 'Confirm'];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 4.h),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    height: 2.5.h,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.r),
                      gradient: step > i
                          ? const LinearGradient(
                              colors: [
                                AppColors.primary,
                                Color(0xFF4A9AFF),
                              ],
                            )
                          : null,
                      color: step > i
                          ? null
                          : AppColors.border.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            _StepDot(
              index: i + 1,
              label: labels[i],
              active: step >= i + 1,
              current: step == i + 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.active,
    required this.current,
  });

  final int index;
  final String label;
  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          width: current ? 30.w : 26.w,
          height: current ? 30.w : 26.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A9AFF), AppColors.primary],
                  )
                : null,
            color: active ? null : Colors.white,
            border: Border.all(
              color: active
                  ? Colors.transparent
                  : AppColors.border.withValues(alpha: 0.9),
              width: 1.2,
            ),
            boxShadow: current
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: active && !current
                ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
                : Text(
                    '$index',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.muted,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            fontWeight: current ? FontWeight.w600 : FontWeight.w500,
            color: current ? AppColors.primary : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class BookingFadeSlide extends StatelessWidget {
  const BookingFadeSlide({
    super.key,
    required this.animation,
    required this.child,
    this.begin = 0,
    this.end = 1,
    this.dy = 16,
  });

  final AnimationController animation;
  final Widget child;
  final double begin;
  final double end;
  final double dy;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - curved.value) * dy),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class BookingPrimaryButton extends StatefulWidget {
  const BookingPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final IconData? icon;

  @override
  State<BookingPrimaryButton> createState() => _BookingPrimaryButtonState();
}

class _BookingPrimaryButtonState extends State<BookingPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled && widget.onTap != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.enabled && widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1 : 0.45,
          duration: const Duration(milliseconds: 180),
          child: Container(
            height: 52.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4A9AFF),
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              boxShadow: widget.enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.38),
                        blurRadius: 18,
                        offset: Offset(0, 8.h),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 18.sp),
                  SizedBox(width: 8.w),
                ],
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData specialtyIcon(String label) {
  final l = label.toLowerCase();
  if (l.contains('cardio') || l.contains('heart')) return Iconsax.heart;
  if (l.contains('derma') || l.contains('skin')) return Iconsax.brush_1;
  if (l.contains('neuro')) return Iconsax.cpu;
  if (l.contains('ophthal') || l.contains('eye')) return Iconsax.eye;
  return Iconsax.hospital;
}
