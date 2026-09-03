import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:physio_motion/components/fade_slide_in.dart';
import 'package:physio_motion/components/home_app_bar.dart';
import 'package:physio_motion/components/home_focus_area_card.dart';
import 'package:physio_motion/components/home_greeting.dart';
import 'package:physio_motion/components/home_quick_actions.dart';
import 'package:physio_motion/components/home_recovery_card.dart';
import 'package:physio_motion/components/home_streak_strip.dart';
import 'package:physio_motion/components/home_todays_plan.dart';
import 'package:physio_motion/screens/community_screen/community_screen.dart';
import 'package:physio_motion/theme/app_colors.dart';
import 'package:physio_motion/utils/community_images.dart';
import 'package:physio_motion/widgets/bottom_nav.dart';
import 'package:physio_motion/widgets/premium_page_route.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  double _scrollProgress = 0;
  int _navIndex = 0;

  late final AnimationController _enter;
  late final AnimationController _ambient;
  late final AnimationController _navEnter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    )..repeat(reverse: true);
    _navEnter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CommunityImages.preload(context);
      _enter.forward();
      Future.delayed(const Duration(milliseconds: 420), () {
        if (mounted) _navEnter.forward();
      });
    });
  }

  void _onScroll() {
    final next = (_scrollController.offset / 48).clamp(0.0, 1.0);
    if ((next - _scrollProgress).abs() > 0.01) {
      setState(() => _scrollProgress = next);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _enter.dispose();
    _ambient.dispose();
    _navEnter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: HomeAppBar(scrollProgress: _scrollProgress),
      bottomNavigationBar: Material(
        type: MaterialType.transparency,
        child: FadeSlideIn(
          animation: _navEnter,
          begin: 0,
          end: 1,
          offset: const Offset(0, 28),
          curve: Curves.easeOutCubic,
          child: PhysioBottomNav(
            index: _navIndex,
            onChanged: (i) {
              if (i == 1) {
                Navigator.of(context).pushReplacement(
                  PremiumPageRoute(page: const CommunityScreen()),
                );
                return;
              }
              setState(() => _navIndex = i);
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          // Soft ambient washes — living luxury backdrop
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) {
              final t = _ambient.value;
              return IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      top: -40 + math.sin(t * math.pi) * 12,
                      right: -60 + math.cos(t * math.pi) * 10,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.lime.withValues(alpha: 0.07 + t * 0.04),
                              AppColors.lime.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 280 + math.cos(t * math.pi) * 16,
                      left: -80,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF5E5CE6)
                                  .withValues(alpha: 0.05 + (1 - t) * 0.03),
                              const Color(0xFF5E5CE6).withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + kToolbarHeight + 4,
              16,
              PhysioBottomNav.contentClearance(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(
                  animation: _enter,
                  begin: 0,
                  end: 0.22,
                  offset: const Offset(0, 16),
                  child: const HomeGreeting(),
                ),
                const SizedBox(height: 18),
                FadeSlideIn(
                  animation: _enter,
                  begin: 0.08,
                  end: 0.36,
                  offset: const Offset(0, 24),
                  curve: Curves.easeOutCubic,
                  child: const HomeRecoveryCard(),
                ),
                const SizedBox(height: 14),
                FadeSlideIn(
                  animation: _enter,
                  begin: 0.2,
                  end: 0.48,
                  offset: const Offset(0, 18),
                  child: const HomeStreakStrip(),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  animation: _enter,
                  begin: 0.32,
                  end: 0.58,
                  offset: const Offset(0, 18),
                  child: const HomeTodaysPlan(),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  animation: _enter,
                  begin: 0.44,
                  end: 0.7,
                  offset: const Offset(0, 18),
                  child: const HomeFocusAreaCard(),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  animation: _enter,
                  begin: 0.56,
                  end: 0.86,
                  offset: const Offset(0, 18),
                  child: const HomeQuickActions(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
