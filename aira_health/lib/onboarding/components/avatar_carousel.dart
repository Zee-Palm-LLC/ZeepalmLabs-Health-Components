import 'dart:async';

import 'package:aira_health/onboarding/components/fade_reveal.dart';
import 'package:aira_health/onboarding/components/onboarding_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AvatarCarousel extends StatefulWidget {
  const AvatarCarousel({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<AvatarCarousel> createState() => _AvatarCarouselState();
}

class _AvatarCarouselState extends State<AvatarCarousel> {
  late final PageController _controller;
  Timer? _introTimer;

  static const _arcStrength = 12.0;
  static const _scaleFalloff = 0.54;
  static const _minScale = 0.68;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.21,
      initialPage: widget.selectedIndex,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _playIntroHint());
  }

  void _playIntroHint() {
    _introTimer?.cancel();
    _introTimer = Timer(const Duration(milliseconds: 900), () async {
      if (!mounted || !_controller.hasClients) return;

      final page = widget.selectedIndex.toDouble();
      await _controller.animateTo(
        page + 0.22,
        duration: const Duration(milliseconds: 520),
        curve: const Cubic(0.16, 1, 0.3, 1),
      );
      if (!mounted || !_controller.hasClients) return;

      await _controller.animateTo(
        page,
        duration: const Duration(milliseconds: 620),
        curve: const Cubic(0.16, 1, 0.3, 1),
      );
    });
  }

  @override
  void didUpdateWidget(covariant AvatarCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        (_controller.page?.round() ?? widget.selectedIndex) !=
            widget.selectedIndex) {
      _controller.animateToPage(
        widget.selectedIndex,
        duration: const Duration(milliseconds: 320),
        curve: const Cubic(0.16, 1, 0.3, 1),
      );
    }
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  _ArcMetrics _metrics(double distance) {
    final abs = distance.abs();
    final scale = (1 - abs * _scaleFalloff).clamp(_minScale, 1.0);
    final bend = abs * abs * _arcStrength.h;
    return _ArcMetrics(scale: scale, translateY: bend);
  }

  @override
  Widget build(BuildContext context) {
    return FadeReveal(
      delay: const Duration(milliseconds: 230),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final page = _controller.hasClients
                ? (_controller.page ?? widget.selectedIndex.toDouble())
                : widget.selectedIndex.toDouble();

            return SizedBox(
              height: 100.h,
              child: PageView.builder(
                controller: _controller,
                itemCount: OnboardingAssets.avatars.length,
                clipBehavior: Clip.none,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  widget.onChanged(index);
                },
                itemBuilder: (context, index) {
                  final distance = page - index;
                  final metrics = _metrics(distance);
                  final focused = distance.abs() < 0.5;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: Offset(0, metrics.translateY),
                      child: Transform.scale(
                        scale: metrics.scale,
                        child: _AvatarChip(
                          asset: OnboardingAssets.avatars[index],
                          selected: focused,
                          onTap: () {
                            _controller.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 320),
                              curve: const Cubic(0.16, 1, 0.3, 1),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ArcMetrics {
  const _ArcMetrics({
    required this.scale,
    required this.translateY,
  });

  final double scale;
  final double translateY;
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: const Cubic(0.16, 1, 0.3, 1),
        padding: EdgeInsets.all(selected ? 2.4.w : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? OnboardingColors.ink : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: CircleAvatar(
          radius: 30.r,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage(asset),
        ),
      ),
    );
  }
}
