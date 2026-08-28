import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Lightweight robot mascot with a gentle idle float.
class RobotMascot extends StatefulWidget {
  const RobotMascot({super.key});

  @override
  State<RobotMascot> createState() => _RobotMascotState();
}

class _RobotMascotState extends State<RobotMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatY = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatY,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatY.value.h),
          child: child,
        );
      },
      child: SizedBox(
        width: 108.w,
        height: 118.h,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              right: 2.w,
              bottom: 0,
              child: _Limb(width: 18.w, height: 34.h),
            ),
            Positioned(
              left: 8.w,
              bottom: 0,
              child: _Limb(width: 18.w, height: 34.h),
            ),
            Positioned(
              bottom: 28.h,
              child: Container(
                width: 74.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8E7FA8).withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 46.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3A8),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFFE8D98A),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ':)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5A4D78),
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (_) => Container(
                          width: 5.w,
                          height: 5.w,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFB9AED4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: 10.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4C8F0),
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD766),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Limb extends StatelessWidget {
  const _Limb({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0F8),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
    );
  }
}
