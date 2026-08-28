import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Soft floating ambient blobs behind dashboard content.
class DashboardAmbientGlow extends StatefulWidget {
  const DashboardAmbientGlow({super.key});

  @override
  State<DashboardAmbientGlow> createState() => _DashboardAmbientGlowState();
}

class _DashboardAmbientGlowState extends State<DashboardAmbientGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return IgnorePointer(
          child: Stack(
            children: [
              _blob(
                top: 80.h + t * 12,
                left: -40.w,
                size: 140.w,
                color: const Color(0x33C9B8FF),
              ),
              _blob(
                top: 280.h - t * 16,
                right: -30.w,
                size: 120.w,
                color: const Color(0x33FFB8D9),
              ),
              _blob(
                bottom: 180.h + math.sin(t * math.pi) * 10,
                left: 60.w,
                size: 100.w,
                color: const Color(0x289ED8FF),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
