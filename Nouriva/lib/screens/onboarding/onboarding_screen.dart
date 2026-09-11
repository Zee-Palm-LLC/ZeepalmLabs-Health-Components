import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_text.dart';
import '../../services/onboarding_video_cache.dart';
import '../../widgets/motion.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _page = PageController();
  late final AnimationController _enter;
  late final AnimationController _chrome;

  double _pageValue = 0;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: AppMotion.enter);
    _chrome = AnimationController(vsync: this, duration: AppMotion.enter);
    _page.addListener(_onScroll);
    _playEnter();
    _chrome.forward();
  }

  void _onScroll() {
    final v = _page.page ?? _index.toDouble();
    if ((v - _pageValue).abs() < 0.001) return;
    setState(() => _pageValue = v);
  }

  Future<void> _playEnter() async {
    _enter.value = 0;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    _enter.forward(from: 0);
  }

  void _go(int i) {
    _page.animateToPage(
      i,
      duration: AppMotion.page,
      curve: AppMotion.elasticPage,
    );
  }

  void _next() {
    if (_index >= kOnboardingPages.length - 1) return;
    _go(_index + 1);
  }

  void _skip() => _go(kOnboardingPages.length - 1);

  @override
  void dispose() {
    _page.removeListener(_onScroll);
    _page.dispose();
    _enter.dispose();
    _chrome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _VideoStack(pageValue: _pageValue),
          _ReadableVeil(pageValue: _pageValue),
          PageView.builder(
            controller: _page,
            physics: const ElasticPagePhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: kOnboardingPages.length,
            onPageChanged: (i) {
              setState(() => _index = i);
              _playEnter();
            },
            itemBuilder: (_, _) => const SizedBox.expand(),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: SpringEnter(
                      animation: _chrome,
                      dy: 10,
                      child: _SkipChip(onTap: _skip),
                    ),
                  ),
                  Expanded(
                    child: _PageOverlay(
                      pageValue: _pageValue,
                      enter: _enter,
                    ),
                  ),
                  SpringEnter(
                    animation: _chrome,
                    dy: 18,
                    interval: const Interval(0.18, 1, curve: AppMotion.soft),
                    child: Row(
                      children: [
                        Expanded(
                          child: _PageDots(
                            count: kOnboardingPages.length,
                            value: _pageValue,
                          ),
                        ),
                        _NextFab(onTap: _next),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoStack extends StatefulWidget {
  const _VideoStack({required this.pageValue});

  final double pageValue;

  @override
  State<_VideoStack> createState() => _VideoStackState();
}

class _VideoStackState extends State<_VideoStack> {
  final _cache = OnboardingVideoCache.instance;

  @override
  void initState() {
    super.initState();
    // Controllers are already initialized by [OnboardingVideoCache.preload].
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPlayback());
  }

  @override
  void didUpdateWidget(covariant _VideoStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageValue != widget.pageValue) {
      _syncPlayback();
    }
  }

  void _syncPlayback() {
    final active =
        widget.pageValue.round().clamp(0, kOnboardingPages.length - 1);
    final activeAsset = kOnboardingPages[active].video;
    final settled = (widget.pageValue - active).abs() < 0.02;

    for (final asset in kOnboardingVideoAssets) {
      final c = _cache.controllerFor(asset);
      if (c == null || !c.value.isInitialized) continue;
      if (asset == activeAsset) {
        if (!c.value.isPlaying) {
          c.play();
        }
      } else if (c.value.isPlaying) {
        c.pause();
        if (settled) {
          c.seekTo(Duration.zero);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.cream),
        for (var i = 0; i < kOnboardingPages.length; i++) _videoLayer(i),
      ],
    );
  }

  Widget _videoLayer(int i) {
    final asset = kOnboardingPages[i].video;
    final c = _cache.controllerFor(asset);
    if (c == null || !c.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final raw = (1.0 - (widget.pageValue - i).abs()).clamp(0.0, 1.0);
    final opacity = AppMotion.soft.transform(raw);
    if (opacity <= 0.01) return const SizedBox.shrink();

    final scale = 1.0 + (0.035 * (1 - opacity));

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: ClipRect(
          child: Transform.translate(
            offset: const Offset(0, 1),
            child: Transform.scale(
              scale: 1.02,
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: c.value.size.width,
                  height: c.value.size.height,
                  child: VideoPlayer(c),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadableVeil extends StatelessWidget {
  const _ReadableVeil({required this.pageValue});

  final double pageValue;

  @override
  Widget build(BuildContext context) {
    // Blend page-1 bottom veil with page-2 top veil while swiping.
    final topWeight = _weightFor(OnboardingLayout.topCenter);
    final bottomWeight = _weightFor(OnboardingLayout.bottomStart);

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: bottomWeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.cream.withValues(alpha: 0),
                    AppColors.cream.withValues(alpha: 0.55),
                    AppColors.cream.withValues(alpha: 0.96),
                  ],
                  stops: const [0.42, 0.68, 1],
                ),
              ),
            ),
          ),
          Opacity(
            opacity: topWeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.cream.withValues(alpha: 0.92),
                    AppColors.cream.withValues(alpha: 0.55),
                    AppColors.cream.withValues(alpha: 0),
                    AppColors.cream.withValues(alpha: 0.35),
                    AppColors.cream.withValues(alpha: 0.9),
                  ],
                  stops: const [0.0, 0.18, 0.42, 0.78, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _weightFor(OnboardingLayout layout) {
    var w = 0.0;
    for (var i = 0; i < kOnboardingPages.length; i++) {
      if (kOnboardingPages[i].layout != layout) continue;
      w = math.max(w, (1.0 - (pageValue - i).abs()).clamp(0.0, 1.0));
    }
    return w;
  }
}

class _PageOverlay extends StatelessWidget {
  const _PageOverlay({
    required this.pageValue,
    required this.enter,
  });

  final double pageValue;
  final Animation<double> enter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var i = 0; i < kOnboardingPages.length; i++)
          _fadePage(i),
      ],
    );
  }

  Widget _fadePage(int i) {
    final raw = (1.0 - (pageValue - i).abs()).clamp(0.0, 1.0);
    if (raw <= 0.01) return const SizedBox.shrink();

    // Elastic visual blend — soft scale + slide while paging.
    final t = AppMotion.soft.transform(raw);
    final page = kOnboardingPages[i];
    final delta = pageValue - i;
    final drift = delta * 36.w;
    final scale = 0.94 + (0.06 * t);
    final lift = (1 - t) * 10.h;

    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(-drift, lift),
        child: Transform.scale(
          scale: scale,
          alignment: page.layout == OnboardingLayout.topCenter
              ? Alignment.topCenter
              : Alignment.bottomLeft,
          child: switch (page.layout) {
            OnboardingLayout.bottomStart => Align(
                alignment: Alignment.bottomLeft,
                child: _BottomStartCopy(
                  page: page,
                  enter: enter,
                  active: raw > 0.85,
                ),
              ),
            OnboardingLayout.topCenter => Align(
                alignment: Alignment.topCenter,
                child: _TopCenterCopy(
                  page: page,
                  enter: enter,
                  active: raw > 0.85,
                ),
              ),
          },
        ),
      ),
    );
  }
}

class _BottomStartCopy extends StatelessWidget {
  const _BottomStartCopy({
    required this.page,
    required this.enter,
    required this.active,
  });

  final OnboardingPage page;
  final Animation<double> enter;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpringEnter(
            animation: enter,
            dy: 26,
            child: _LeafTitle(title: page.title),
          ),
          SizedBox(height: 14.h),
          SpringEnter(
            animation: enter,
            dy: 20,
            interval: const Interval(0.16, 1, curve: AppMotion.soft),
            child: Text(page.body, style: AppText.body()),
          ),
        ],
      ),
    );
  }
}

class _TopCenterCopy extends StatelessWidget {
  const _TopCenterCopy({
    required this.page,
    required this.enter,
    required this.active,
  });

  final OnboardingPage page;
  final Animation<double> enter;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpringEnter(
            animation: enter,
            dy: 18,
            child: _UnderlinedTitle(title: page.title, animate: active),
          ),
          SizedBox(height: 14.h),
          SpringEnter(
            animation: enter,
            dy: 16,
            interval: const Interval(0.18, 1, curve: AppMotion.soft),
            child: Text(
              page.body,
              textAlign: TextAlign.center,
              style: AppText.bodyCenter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnderlinedTitle extends StatelessWidget {
  const _UnderlinedTitle({required this.title, required this.animate});

  final String title;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final lines = title.split('\n');
    final top = lines.first;
    final bottom = lines.length > 1 ? lines.sublist(1).join(' ') : '';

    return Column(
      children: [
        Text(
          top,
          textAlign: TextAlign.center,
          style: AppText.displayCenter(),
        ),
        if (bottom.isNotEmpty) ...[
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Text(
                  bottom,
                  textAlign: TextAlign.center,
                  style: AppText.displayCenter(),
                ),
              ),
              Positioned(
                bottom: 0,
                child: _BrushStroke(animate: animate),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BrushStroke extends StatefulWidget {
  const _BrushStroke({required this.animate});

  final bool animate;

  @override
  State<_BrushStroke> createState() => _BrushStrokeState();
}

class _BrushStrokeState extends State<_BrushStroke>
    with SingleTickerProviderStateMixin {
  late final AnimationController _draw;

  @override
  void initState() {
    super.initState();
    _draw = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.animate) _draw.forward();
  }

  @override
  void didUpdateWidget(covariant _BrushStroke oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _draw.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _draw,
      builder: (_, _) {
        return CustomPaint(
          size: Size(132.w, 10.h),
          painter: _BrushPainter(
            progress: AppMotion.soft.transform(_draw.value),
          ),
        );
      },
    );
  }
}

class _BrushPainter extends CustomPainter {
  _BrushPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.05,
        size.width * 0.55,
        size.height * 1.05,
        size.width,
        size.height * 0.35,
      );

    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(
      drawn,
      Paint()
        ..color = AppColors.sage
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BrushPainter old) => old.progress != progress;
}

class _SkipChip extends StatelessWidget {
  const _SkipChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.skipFill,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: AppColors.skipBorder, width: 1),
        ),
        child: Text('Skip', style: AppText.skip(color: AppColors.forest)),
      ),
    );
  }
}

class _LeafTitle extends StatelessWidget {
  const _LeafTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final lines = title.split('\n');
    final last = lines.isEmpty ? '' : lines.last;
    final head = lines.length <= 1
        ? ''
        : '${lines.sublist(0, lines.length - 1).join('\n')}\n';

    return Text.rich(
      TextSpan(
        children: [
          if (head.isNotEmpty) TextSpan(text: head, style: AppText.display()),
          TextSpan(text: last, style: AppText.display()),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
              child: CustomPaint(
                size: Size(22.w, 18.w),
                painter: const _TwinLeafPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TwinLeafPainter extends CustomPainter {
  const _TwinLeafPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.leaf
      ..style = PaintingStyle.fill;

    void leaf(Offset c, double rot, double sx, double sy) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot);
      canvas.scale(sx, sy);
      final path = Path()
        ..moveTo(0, -size.height * 0.42)
        ..cubicTo(
          size.width * 0.42,
          -size.height * 0.18,
          size.width * 0.38,
          size.height * 0.28,
          0,
          size.height * 0.42,
        )
        ..cubicTo(
          -size.width * 0.38,
          size.height * 0.28,
          -size.width * 0.42,
          -size.height * 0.18,
          0,
          -size.height * 0.42,
        )
        ..close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    leaf(Offset(size.width * 0.38, size.height * 0.55), -0.55, 0.72, 0.9);
    leaf(Offset(size.width * 0.62, size.height * 0.42), 0.35, 0.78, 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.value});

  final int count;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final dist = (value - i).abs().clamp(0.0, 1.0);
        final active = 1 - dist;
        final w = 7.w + 10.w * active;
        final color = Color.lerp(AppColors.mute, AppColors.forest, active)!;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: AppMotion.softTight,
          margin: EdgeInsets.only(right: i == count - 1 ? 0 : 7.w),
          width: w,
          height: 7.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100.r),
          ),
        );
      }),
    );
  }
}

class _NextFab extends StatelessWidget {
  const _NextFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 58.w;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.forest,
          boxShadow: [
            BoxShadow(
              color: AppColors.forestDeep.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Iconsax.arrow_right_3,
          color: Colors.white,
          size: 22.sp,
        ),
      ),
    );
  }
}
