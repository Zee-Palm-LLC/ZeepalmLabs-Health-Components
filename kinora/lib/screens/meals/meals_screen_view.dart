import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/kinora_colors.dart';
import '../home/components/reveal.dart';
import '../landing_page/components/floating_bottom_nav.dart';
import '../landing_page/components/math_motion.dart';
import 'components/cooking_community_section.dart';
import 'components/daily_nutrition_section.dart';
import 'components/meals_header.dart';

class MealsScreenView extends StatefulWidget {
  const MealsScreenView({super.key});

  @override
  State<MealsScreenView> createState() => _MealsScreenViewState();
}

class _MealsScreenViewState extends State<MealsScreenView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambience;
  late final ScrollController _scroll;
  double _scrollY = 0;

  @override
  void initState() {
    super.initState();
    _ambience = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6800),
    )..repeat();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final y = _scroll.offset.clamp(0.0, 200.0);
    if ((y - _scrollY).abs() < 0.5) return;
    setState(() => _scrollY = y);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _ambience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottomClear = FloatingBottomNav.contentClearance(context);
    final parallax = _scrollY / 200;

    return ColoredBox(
      color: KinoraColors.bg,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambience,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0, -12 * parallax),
                  child: CustomPaint(
                    painter: _MealsAmbiencePainter(
                      phase: _ambience.value * math.pi * 2,
                      depth: 1 - parallax * 0.35,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + 58,
            child: IgnorePointer(
              child: Opacity(
                opacity: MathMotion.smootherstep(parallax * 1.5),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            KinoraColors.bg.withValues(alpha: 0.78),
                            KinoraColors.bg.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(0, top + 8, 0, bottomClear),
            children: [
              Reveal(
                delay: revealDelay(0),
                offset: const Offset(0, 14),
                scaleFrom: 0.97,
                twist: 0.008,
                child: const MealsHeader(),
              ),
              const SizedBox(height: 20),
              Reveal(
                delay: revealDelay(1),
                offset: const Offset(0, 12),
                scaleFrom: 0.98,
                twist: 0,
                child: const _SectionRule(),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: revealDelay(1, stepMs: 70),
                offset: const Offset(0, 18),
                scaleFrom: 0.95,
                twist: 0.01,
                child: const DailyNutritionSection(),
              ),
              const SizedBox(height: 18),
              Reveal(
                delay: revealDelay(2),
                offset: const Offset(0, 12),
                scaleFrom: 0.98,
                twist: 0,
                child: const _SectionRule(),
              ),
              const SizedBox(height: 14),
              Reveal(
                delay: revealDelay(2, stepMs: 80),
                offset: const Offset(0, 22),
                scaleFrom: 0.93,
                twist: 0.012,
                duration: const Duration(milliseconds: 920),
                child: const CookingCommunitySection(),
              ),
              const SizedBox(height: 16),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bottomClear * 0.5,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      KinoraColors.bg.withValues(alpha: 0),
                      KinoraColors.bg.withValues(alpha: 0.78),
                      KinoraColors.bg,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionRule extends StatelessWidget {
  const _SectionRule();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: SizedBox(
        height: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                KinoraColors.lime.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.08),
                KinoraColors.lime.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealsAmbiencePainter extends CustomPainter {
  _MealsAmbiencePainter({required this.phase, required this.depth});

  final double phase;
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final breath = MathMotion.breath(phase, lo: 0.9, hi: 1.12) * depth;

    canvas.drawRect(rect, Paint()..color = KinoraColors.bg);

    final warm = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.2, size.height * 0.18),
        size.width * 0.7 * breath,
        [
          const Color(0xFFFF9A3D).withValues(alpha: 0.05 * depth),
          Colors.transparent,
        ],
      );
    canvas.drawRect(rect, warm);

    final lime = Paint()
      ..shader = ui.Gradient.radial(
        Offset(
          size.width * (0.78 + 0.03 * math.sin(phase)),
          size.height * 0.42,
        ),
        size.width * 0.55 * breath,
        [
          KinoraColors.lime.withValues(alpha: 0.07 * depth),
          Colors.transparent,
        ],
      );
    canvas.drawRect(rect, lime);

    final cool = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.55, size.height * 0.72),
        size.width * 0.5,
        [
          const Color(0xFF4DA3FF).withValues(alpha: 0.035 * depth),
          Colors.transparent,
        ],
      );
    canvas.drawRect(rect, cool);

    final vig = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        [
          Colors.black.withValues(alpha: 0.18),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.48),
        ],
        const [0, 0.4, 1],
      );
    canvas.drawRect(rect, vig);
  }

  @override
  bool shouldRepaint(covariant _MealsAmbiencePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.depth != depth;
}
