import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomIconBtn extends StatefulWidget {
  const CustomIconBtn({
    super.key,
    this.icon,
    this.onTap,
    this.size = 37,
    this.iconSize = 20,
    this.iconColor,
  });

  final IconData? icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? iconColor;

  @override
  State<CustomIconBtn> createState() => _CustomIconBtnState();
}

class _CustomIconBtnState extends State<CustomIconBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dimension = widget.size.w;
    final iconColor = widget.iconColor ?? const Color(0xFF4B5563);

    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            },
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        height: dimension,
        width: dimension,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          gradient: _pressed
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF3F4F6), Color(0xFFFFFFFF)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF5F7FA)],
                ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.95),
            width: 1.2,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: const Color(0xFFD1D5DB).withValues(alpha: 0.35),
                    offset: Offset(1.5.w, 1.5.h),
                    blurRadius: 4.r,
                    spreadRadius: -1,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    offset: Offset(-1.w, -1.h),
                    blurRadius: 3.r,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF).withValues(alpha: 0.28),
                    offset: Offset(4.w, 5.h),
                    blurRadius: 10.r,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.95),
                    offset: Offset(-3.w, -3.h),
                    blurRadius: 8.r,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: const Color(0xFFE5E7EB).withValues(alpha: 0.6),
                    offset: Offset(0, 2.h),
                    blurRadius: 4.r,
                  ),
                ],
        ),
        child: widget.icon == null
            ? null
            : Icon(
                widget.icon,
                size: widget.iconSize.sp,
                color: iconColor,
              ),
      ),
    );
  }
}
