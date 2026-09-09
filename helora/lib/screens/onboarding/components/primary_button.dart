import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helora/theme/app_colors.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    this.label = 'Continue',
    this.onPressed,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTapDown: (_) {
          _setPressed(true);
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          _setPressed(false);
          widget.onPressed?.call();
        },
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            height: widget.height,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text.withValues(alpha: _pressed ? 0.06 : 0.14),
                  blurRadius: _pressed ? 10 : 22,
                  offset: Offset(0, _pressed ? 3 : 8),
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.bg,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
