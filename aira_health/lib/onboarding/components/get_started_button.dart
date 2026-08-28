import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStartedButton extends StatefulWidget {
  const GetStartedButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  State<GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<GetStartedButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: const Cubic(0.16, 1, 0.3, 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: const Cubic(0.16, 1, 0.3, 1),
          height: 50.h,
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFF1A1A1A) : Colors.black,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _pressed ? 0.14 : 0.24),
                blurRadius: _pressed ? 10 : 18,
                offset: Offset(0, _pressed ? 2.h : 6.h),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'Get Started',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
