import 'package:aira_health/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlideToStart extends StatefulWidget {
  const SlideToStart({
    super.key,
    required this.label,
    required this.onComplete,
    this.leading = Icons.chevron_right_rounded,
  });

  final String label;
  final VoidCallback onComplete;
  final IconData leading;

  @override
  State<SlideToStart> createState() => _SlideToStartState();
}

class _SlideToStartState extends State<SlideToStart> {
  double _dx = 0;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final max = constraints.maxWidth - 64;
        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9B7BA8).withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - (_dx / max)).clamp(0.15, 1),
                child: Text(widget.label, style: AiraType.body(size: 14)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Icon(
                    Icons.keyboard_double_arrow_right_rounded,
                    color: AiraColors.muted.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Positioned(
                left: 8 + _dx,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    if (_done) return;
                    setState(() {
                      _dx = (_dx + d.delta.dx).clamp(0, max);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_dx > max * 0.72) {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _dx = max;
                        _done = true;
                      });
                      widget.onComplete();
                    } else {
                      setState(() => _dx = 0);
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.leading, color: AiraColors.ink),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
