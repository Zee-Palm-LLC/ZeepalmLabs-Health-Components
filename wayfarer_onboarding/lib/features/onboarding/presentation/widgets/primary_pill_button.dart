import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PrimaryPillButton extends StatefulWidget {
  const PrimaryPillButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<PrimaryPillButton> createState() => _PrimaryPillButtonState();
}

class _PrimaryPillButtonState extends State<PrimaryPillButton> {
  static const _pressDuration = Duration(milliseconds: 140);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: _pressDuration,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: _pressDuration,
            curve: Curves.easeOut,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pressed ? AppColors.orangePressed : AppColors.orange,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: _pressed ? 0.22 : 0.34),
                  blurRadius: _pressed ? 12 : 22,
                  offset: Offset(0, _pressed ? 4 : 10),
                ),
              ],
            ),
            child: Text(widget.label, style: AppTypography.button),
          ),
        ),
      ),
    );
  }
}
