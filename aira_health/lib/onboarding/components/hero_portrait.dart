import 'package:aira_health/onboarding/components/fade_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeroPortrait extends StatefulWidget {
  const HeroPortrait({
    super.key,
    required this.asset,
  });

  final String asset;

  @override
  State<HeroPortrait> createState() => _HeroPortraitState();
}

class _HeroPortraitState extends State<HeroPortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);
    _floatY = Tween<double>(begin: 0, end: -7).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (MediaQuery.sizeOf(context).width * 2.5).round();

    return FadeReveal(
      delay: const Duration(milliseconds: 60),
      duration: const Duration(milliseconds: 560),
      offsetY: 14,
      scaleBegin: 0.94,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _floatY,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatY.value.h),
              child: child,
            );
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 480),
            switchInCurve: const Cubic(0.16, 1, 0.3, 1),
            switchOutCurve: const Cubic(0.4, 0, 0.2, 1),
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Cubic(0.16, 1, 0.3, 1),
                ),
              );

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: slide,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
                    child: child,
                  ),
                ),
              );
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ...previousChildren,
                  ?currentChild,
                ],
              );
            },
            child: _PortraitFrame(
              key: ValueKey(widget.asset),
              asset: widget.asset,
              cacheWidth: cacheWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _PortraitFrame extends StatelessWidget {
  const _PortraitFrame({
    super.key,
    required this.asset,
    required this.cacheWidth,
  });

  final String asset;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.62, 0.82, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Image.asset(
          asset,
          width: 360.w,
          height: double.infinity,
          fit: BoxFit.fitHeight,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.medium,
          cacheWidth: cacheWidth,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
