import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:physio_motion/components/fade_slide_in.dart';
import 'package:physio_motion/components/welcome_headline.dart';
import 'package:physio_motion/components/welcome_login_link.dart';
import 'package:physio_motion/components/welcome_start_button.dart';
import 'package:physio_motion/components/welcome_top_bar.dart';
import 'package:physio_motion/screens/home/home_screen.dart';
import 'package:physio_motion/theme/app_colors.dart';
import 'package:physio_motion/widgets/premium_page_route.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enter.forward();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Living background — soft float + breathe
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, child) {
              final t = _ambient.value;
              final dy = math.sin(t * math.pi * 2) * 10;
              final dx = math.cos(t * math.pi) * 6;
              final scale = 1.02 + (t * 0.03);
              return Align(
                alignment: Alignment.bottomRight,
                child: Transform.translate(
                  offset: Offset(70 + dx, dy),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.bottomRight,
                    child: child,
                  ),
                ),
              );
            },
            child: Image.asset('assets/welcome_bg.png'),
          ),
          // Soft lime wash that gently pulses behind content
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) {
              final opacity = 0.04 + (_ambient.value * 0.06);
              return IgnorePointer(
                child: Align(
                  alignment: const Alignment(0.85, 0.55),
                  child: Container(
                    width: 220,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.lime.withValues(alpha: opacity),
                          AppColors.lime.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0,
                    end: 0.22,
                    offset: const Offset(0, -12),
                    child: const WelcomeTopBar(),
                  ),
                  const SizedBox(height: 30),
                  WelcomeHeadline(animation: _enter),
                  const SizedBox(height: 110),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.52,
                    end: 0.78,
                    offset: const Offset(0, 28),
                    curve: Curves.easeOutBack,
                    child: WelcomeStartButton(
                      ambient: _ambient,
                      onTap: () {
                        Navigator.push(
                          context,
                          PremiumPageRoute(page: const HomeScreen()),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.72,
                    end: 1,
                    offset: const Offset(0, 16),
                    child: const WelcomeLoginLink(),
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
