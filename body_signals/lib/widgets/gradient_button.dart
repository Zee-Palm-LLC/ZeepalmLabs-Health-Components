import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/app_motion.dart';

class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon = Iconsax.arrow_right_1,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final double height;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  static const _lit = Color(0xFF6D8CFF);
  static const _mid = Color(0xFF5B6FE8);
  static const _shade = Color(0xFF4A55C8);
  static const _deep = Color(0xFF343A8E);
  static const _edge = Color(0xFF2A306E);

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height.h;
    final radius = BorderRadius.circular(height / 2);
    final depth = 5.h;
    final pressOffset = _pressed ? depth : 0.0;

    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) {
        _setPressed(true);
        HapticFeedback.lightImpact();
      },
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              _setPressed(false);
              widget.onPressed?.call();
            },
      onTapCancel: () => _setPressed(false),
      child: SizedBox(
        height: height + depth,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: depth,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: _edge,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
              ),
            ),

            AnimatedPositioned(
              duration: AppMotion.fast,
              curve: AppMotion.enter,
              left: 0,
              right: 0,
              top: pressOffset,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_lit, _mid, _shade, _deep],
                    stops: [0.0, 0.35, 0.78, 1.0],
                  ),
                  border: Border.all(color: _edge, width: 1.5),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.45,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(height / 2),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.16),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(height / 2),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.28),
                                Colors.black.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(2.5.w),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(height / 2),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.18),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.label,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.15,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        if (widget.trailingIcon != null) ...[
                          SizedBox(width: 10.w),
                          Icon(
                            widget.trailingIcon,
                            size: 17.sp,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
