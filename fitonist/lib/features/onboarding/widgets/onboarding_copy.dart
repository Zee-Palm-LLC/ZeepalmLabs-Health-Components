import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/content_width.dart';

class OnboardingCopy extends StatelessWidget {
  const OnboardingCopy({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132.h,
      child: ContentWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _CopyLine(
              delay: 0,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headline,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: _CopyLine(
                delay: 1,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyLine extends StatefulWidget {
  const _CopyLine({
    required this.delay,
    required this.child,
  });

  final int delay;
  final Widget child;

  @override
  State<_CopyLine> createState() => _CopyLineState();
}

class _CopyLineState extends State<_CopyLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        widget.delay * 0.12,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(_fade);

    if (Get.testMode) {
      _controller.value = 1;
    } else {
      Future<void>.delayed(Duration(milliseconds: widget.delay * 70), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
