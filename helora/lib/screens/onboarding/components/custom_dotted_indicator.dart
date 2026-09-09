import 'package:flutter/material.dart';
import 'package:helora/theme/app_colors.dart';

/// Vertical ticks — completed filled, active taller + accent.
class CustomDottedIndicator extends StatelessWidget {
  const CustomDottedIndicator({
    super.key,
    required this.length,
    this.index = 0,
    this.spacing = 7,
  });

  final int length;
  final int index;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          _Tick(
            state: i < index
                ? _TickState.done
                : (i == index ? _TickState.active : _TickState.idle),
          ),
        ],
      ],
    );
  }
}

enum _TickState { idle, active, done }

class _Tick extends StatelessWidget {
  const _Tick({required this.state});

  final _TickState state;

  @override
  Widget build(BuildContext context) {
    final active = state == _TickState.active;
    final done = state == _TickState.done;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: 3,
      height: active ? 22 : 14,
      decoration: BoxDecoration(
        color: (active || done) ? AppColors.accent : AppColors.tickIdle,
        borderRadius: BorderRadius.circular(10),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.45),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}
