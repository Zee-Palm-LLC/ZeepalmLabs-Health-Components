import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import 'pages/onboarding_patterns_page.dart';
import 'pages/onboarding_support_page.dart';
import 'widgets/get_started_button.dart';
import 'widgets/hero_cluster.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _page = 0;

  late final AnimationController _entrance;
  late final AnimationController _gradient;
  Timer? _startTimer;

  late final Animation<double> _phoneOpacity;
  late final Animation<Offset> _phoneOffset;
  late final Animation<double> _primaryOpacity;
  late final Animation<Offset> _primaryOffset;
  late final Animation<double> _secondaryOpacity;
  late final Animation<Offset> _secondaryOffset;
  late final Animation<double> _orbsOpacity;
  late final Animation<double> _copyOpacity;
  late final Animation<Offset> _copyOffset;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _gradient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _phoneOpacity = _interval(0.0, 0.35, Curves.easeOut);
    _phoneOffset = _slide(0.0, 0.4, const Offset(0, 0.08), Curves.easeOutCubic);

    _secondaryOpacity = _interval(0.12, 0.48, Curves.easeOut);
    _secondaryOffset =
        _slide(0.12, 0.5, const Offset(0.18, 0.12), Curves.easeOutBack);

    _primaryOpacity = _interval(0.2, 0.55, Curves.easeOut);
    _primaryOffset =
        _slide(0.2, 0.58, const Offset(-0.2, 0.1), Curves.easeOutBack);

    _orbsOpacity = _interval(0.32, 0.65, Curves.easeOut);

    _copyOpacity = _interval(0.4, 0.75, Curves.easeOut);
    _copyOffset = _slide(0.4, 0.78, const Offset(0, 0.18), Curves.easeOutCubic);

    _startTimer = Timer(const Duration(milliseconds: 80), () {
      if (mounted) _entrance.forward();
    });
  }

  Animation<double> _interval(double begin, double end, Curve curve) {
    return CurvedAnimation(
      parent: _entrance,
      curve: Interval(begin, end, curve: curve),
    );
  }

  Animation<Offset> _slide(
    double begin,
    double end,
    Offset from,
    Curve curve,
  ) {
    return Tween<Offset>(begin: from, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: Interval(begin, end, curve: curve),
      ),
    );
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _pageController.dispose();
    _entrance.dispose();
    _gradient.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final top = media.padding.top;
    final bottom = media.padding.bottom;
    final isLast = _page == 2;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _gradient,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_gradient.value);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.85 + t * 0.15, -0.95),
                radius: 1.35,
                colors: [
                  Color.lerp(AppColors.peach, const Color(0xFFF8E8D4), t)!,
                  Color.lerp(AppColors.background, AppColors.cream, t * 0.4)!,
                ],
                stops: const [0.0, 0.55],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.9 - t * 0.1, -0.7),
                        radius: 1.1,
                        colors: [
                          Color.lerp(
                            AppColors.lavender.withValues(alpha: 0.55),
                            AppColors.softLavender.withValues(alpha: 0.7),
                            t,
                          )!,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.6, 1.1),
                        radius: 0.9,
                        colors: [
                          AppColors.lavender.withValues(alpha: 0.25 + t * 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                child!,
              ],
            ),
          );
        },
        child: Column(
          children: [
            SizedBox(height: top + 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _PageDots(count: 3, index: _page),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 480),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.skip,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.skip,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                physics: const BouncingScrollPhysics(),
                children: [
                  _WelcomePage(
                    phoneOpacity: _phoneOpacity,
                    phoneOffset: _phoneOffset,
                    primaryOpacity: _primaryOpacity,
                    primaryOffset: _primaryOffset,
                    secondaryOpacity: _secondaryOpacity,
                    secondaryOffset: _secondaryOffset,
                    orbsOpacity: _orbsOpacity,
                    copyOpacity: _copyOpacity,
                    copyOffset: _copyOffset,
                  ),
                  OnboardingPatternsPage(visible: _page == 1),
                  OnboardingSupportPage(visible: _page == 2),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                28,
                8,
                28,
                math.max(bottom, 12) + 8,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: isLast
                    ? GetStartedButton(
                        key: const ValueKey('start'),
                        onPressed: () {},
                      )
                    : GetStartedButton(
                        key: const ValueKey('next'),
                        label: 'Continue',
                        onPressed: _next,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: i == index ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: i == index
                  ? AppColors.ink
                  : AppColors.ink.withValues(alpha: 0.18),
            ),
          ),
        ],
      ],
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.phoneOpacity,
    required this.phoneOffset,
    required this.primaryOpacity,
    required this.primaryOffset,
    required this.secondaryOpacity,
    required this.secondaryOffset,
    required this.orbsOpacity,
    required this.copyOpacity,
    required this.copyOffset,
  });

  final Animation<double> phoneOpacity;
  final Animation<Offset> phoneOffset;
  final Animation<double> primaryOpacity;
  final Animation<Offset> primaryOffset;
  final Animation<double> secondaryOpacity;
  final Animation<Offset> secondaryOffset;
  final Animation<double> orbsOpacity;
  final Animation<double> copyOpacity;
  final Animation<Offset> copyOffset;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: height < 700 ? 10 : 11,
            child: HeroCluster(
              phoneOpacity: phoneOpacity,
              phoneOffset: phoneOffset,
              primaryOpacity: primaryOpacity,
              primaryOffset: primaryOffset,
              secondaryOpacity: secondaryOpacity,
              secondaryOffset: secondaryOffset,
              orbsOpacity: orbsOpacity,
            ),
          ),
          Expanded(
            flex: height < 700 ? 9 : 8,
            child: FadeTransition(
              opacity: copyOpacity,
              child: SlideTransition(
                position: copyOffset,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Take a breath.\nYou're in a safe space",
                      style: GoogleFonts.libreBaskerville(
                        fontSize: height < 700 ? 28 : 30,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -0.5,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: height < 700 ? 10 : 14),
                    Text(
                      'This app helps you understand your emotions, track patterns, and feel supported along the way.',
                      style: GoogleFonts.inter(
                        fontSize: 15.2,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                        color: AppColors.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
