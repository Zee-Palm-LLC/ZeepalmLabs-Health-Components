import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/aegis_theme.dart';
import '../../theme/motion.dart';
import 'aegis_logo.dart';

/// The Aegis top bar, as a real [AppBar] so it takes part in Scaffold layout,
/// safe-area insets and route transitions instead of being a row in the body.
class AegisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AegisAppBar({super.key, this.leading, this.actions});

  static const double height = 58;

  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      automaticallyImplyLeading: false,
      leading: leading,
      leadingWidth: leading == null ? null : 56,
      titleSpacing: leading == null ? 18 : 2,
      // The frost comes from flexibleSpace so the blur covers the status bar.
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: const _FrostedBar(),
      title: Row(
        children: [
          const AegisLogo(),
          const SizedBox(width: 11),
          Semantics(
            header: true,
            child: const Text('Aegis', style: AegisText.wordmark),
          ),
        ],
      ),
      actions: [
        ...?actions,
        const SizedBox(width: 8),
      ],
    );
  }
}

class _FrostedBar extends StatelessWidget {
  const _FrostedBar();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xF2040A0E), Color(0xC7040A0E)],
            ),
            border: Border(
              bottom: BorderSide(color: AegisColors.hairline),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular icon button sized for the app bar, with a press-in response so
/// taps read on a dark surface where a ripple barely shows.
class HeaderButton extends StatefulWidget {
  const HeaderButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  State<HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<HeaderButton> {
  bool _down = false;

  void _setDown(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.tooltip,
        child: GestureDetector(
          onTapDown: enabled ? (_) => _setDown(true) : null,
          onTapUp: enabled ? (_) => _setDown(false) : null,
          onTapCancel: enabled ? () => _setDown(false) : null,
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _down ? 0.88 : 1,
            duration: AegisMotion.fast,
            curve: AegisMotion.enter,
            child: AnimatedContainer(
              duration: AegisMotion.fast,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _down
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: AegisColors.hairline),
              ),
              child: Icon(
                widget.icon,
                size: 21,
                color: enabled
                    ? AegisColors.textPrimary
                    : AegisColors.textMuted.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
