import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatefulWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.showDot = false,
    this.pulse = false,
  });

  final String label;
  final Color color;
  final bool showDot;
  final bool pulse;

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: widget.color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showDot) ...[
            BadgeDot(color: widget.color, controller: _controller),
            SizedBox(width: 6.w),
          ],
          Text(
            widget.label,
            style: GoogleFonts.poppins(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeDot extends StatelessWidget {
  const BadgeDot({super.key, required this.color, this.controller});

  final Color color;
  final AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    final core = Container(
      width: 5.w,
      height: 5.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    if (controller == null) return core;

    return SizedBox(
      width: 5.w,
      height: 5.w,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: controller!,
            builder: (_, _) {
              final t = controller!.value;
              return Container(
                width: 5.w + 10.w * t,
                height: 5.w + 10.w * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.35 * (1 - t)),
                ),
              );
            },
          ),
          core,
        ],
      ),
    );
  }
}
