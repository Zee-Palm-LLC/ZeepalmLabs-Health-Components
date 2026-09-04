import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:medicify/theme/app_colors.dart';

class ContinueButton extends StatefulWidget {
  const ContinueButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => _press.forward() : null,
      onTapCancel: () => _press.reverse(),
      onTapUp: enabled
          ? (_) async {
              await _press.reverse();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          final t = Curves.easeOut.transform(_press.value);
          final scale = 1 - 0.035 * t;
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: enabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.purple, AppColors.purpleDeep],
                  )
                : null,
            color: enabled ? null : AppColors.white.withValues(alpha: 0.72),
            border: enabled
                ? null
                : Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: enabled
                    ? AppColors.purple.withValues(alpha: 0.38)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: enabled ? 22 : 10,
                offset: const Offset(0, 10),
              ),
              if (enabled)
                BoxShadow(
                  color: AppColors.purpleDeep.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: enabled
                      ? AppColors.white
                      : AppColors.textSecondary.withValues(alpha: 0.4),
                ),
                child: Text(widget.label),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: enabled ? 26 : 0,
                child: enabled
                    ? const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Iconsax.arrow_right_3,
                          size: 18,
                          color: AppColors.white,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
