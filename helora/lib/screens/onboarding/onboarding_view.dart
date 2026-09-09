import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helora/screens/onboarding/components/custom_dotted_indicator.dart';
import 'package:helora/screens/onboarding/components/onboarding_page_one.dart';
import 'package:helora/screens/onboarding/components/onboarding_page_three.dart';
import 'package:helora/screens/onboarding/components/onboarding_page_two.dart';
import 'package:helora/screens/onboarding/components/primary_button.dart';

import '../../theme/app_colors.dart';

abstract final class _ShellMotion {
  static double clamp01(double t) => t.clamp(0.0, 1.0);

  static double magnetic(double t, {double sharpness = 2.7}) {
    t = clamp01(t);
    final e2 = math.exp(2 * sharpness * (2 * t - 1).clamp(-20.0, 20.0));
    final th = (e2 - 1) / (e2 + 1);
    final e2s = math.exp(2 * sharpness);
    final ths = (e2s - 1) / (e2s + 1);
    return 0.5 * (1 + th / ths);
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  static const _pageCount = 3;

  late final PageController _pages;
  late final AnimationController _brand;
  late final AnimationController _ambient;
  late final AnimationController _pagePulse;

  int _index = 0;
  bool _transitioning = false;

  static const _glows = [
    AppColors.glowTeal,
    AppColors.glowPurple,
    AppColors.glowBlue,
  ];

  static const _glowCenters = [
    Alignment(-0.75, -0.2),
    Alignment(0.15, -0.25),
    Alignment(0.0, -0.05),
  ];

  @override
  void initState() {
    super.initState();
    _pages = PageController();

    _brand = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat();
    _pagePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _brand.forward();
        _pagePulse.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _brand.dispose();
    _ambient.dispose();
    _pagePulse.dispose();
    _pages.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_transitioning) return;
    HapticFeedback.selectionClick();

    if (_index >= _pageCount - 1) {
      HapticFeedback.mediumImpact();
      return;
    }

    _transitioning = true;
    try {
      await _pages.nextPage(
        duration: const Duration(milliseconds: 560),
        curve: Curves.easeOutCubic,
      );
    } finally {
      if (mounted) _transitioning = false;
    }
  }

  void _onPageChanged(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Ambient layers only — never rebuilds the CTA
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_ambient, _brand, _pagePulse]),
              builder: (context, _) {
                final breath =
                    0.5 + 0.5 * math.sin(_ambient.value * math.pi * 2);
                final drift = math.sin(_ambient.value * math.pi * 2) * 0.04;
                final brandT =
                    _ShellMotion.magnetic(_brand.value, sharpness: 2.9);
                final pulseT = Curves.easeOut.transform(_pagePulse.value);
                final glowAlpha = (0.42 + 0.18 * breath) *
                    (0.9 + 0.1 * pulseT) *
                    (0.92 + 0.08 * brandT);

                return Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(
                              _glowCenters[_index].x + drift,
                              _glowCenters[_index].y - drift * 0.6,
                            ),
                            radius: 1.05 + 0.12 * breath,
                            colors: [
                              _glows[_index].withValues(alpha: glowAlpha),
                              AppColors.bg.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(
                                -_glowCenters[_index].x * 0.55,
                                0.75,
                              ),
                              radius: 0.85,
                              colors: [
                                _glows[(_index + 1) % _glows.length]
                                    .withValues(
                                      alpha: 0.12 + 0.08 * breath,
                                    ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.2,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(
                                  alpha: 0.18 + 0.06 * (1 - breath),
                                ),
                              ],
                              stops: const [0.55, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: Listenable.merge([_brand, _ambient, _pagePulse]),
                  builder: (context, _) {
                    final brandT =
                        _ShellMotion.magnetic(_brand.value, sharpness: 2.9);
                    final pulseT =
                        Curves.easeOut.transform(_pagePulse.value);
                    return Transform.translate(
                      offset: Offset(0, (1 - brandT) * -16),
                      child: Opacity(
                        opacity: brandT.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.92 + 0.08 * brandT,
                          child: _BrandMark(
                            phase: _ambient.value * math.pi * 2,
                            emphasize: pulseT,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: _onPageChanged,
                    children: [
                      const OnboardingPageOne(key: ValueKey('onb-1')),
                      OnboardingPageTwo(
                        key: const ValueKey('onb-2'),
                        isActive: _index == 1,
                      ),
                      OnboardingPageThree(
                        key: const ValueKey('onb-3'),
                        isActive: _index == 2,
                        // Start intro on previous page so arrival isn't blank→fade blink.
                        prepare: _index >= 1,
                      ),
                    ],
                  ),
                ),

                // Footer stays fully opaque — no fade/reverse blink
                const SizedBox(height: 18),
                CustomDottedIndicator(
                  length: _pageCount,
                  index: _index,
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: _index >= _pageCount - 1 ? 'Get Started' : 'Continue',
                  onPressed: _next,
                  height: 52,
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.phase, required this.emphasize});

  final double phase;
  final double emphasize;

  @override
  Widget build(BuildContext context) {
    final beat =
        1.0 + 0.05 * math.sin(phase * 2.2) * (0.55 + 0.45 * emphasize);
    final glow = 0.2 + 0.25 * (0.5 + 0.5 * math.sin(phase * 2.2));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: beat,
          child: Icon(
            LucideIcons.heart_pulse,
            size: 20,
            color: AppColors.text.withValues(alpha: 0.95),
            shadows: [
              Shadow(
                color: AppColors.accent.withValues(alpha: glow),
                blurRadius: 12 + 6 * emphasize,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Helora',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
            letterSpacing: -0.35,
          ),
        ),
      ],
    );
  }
}
