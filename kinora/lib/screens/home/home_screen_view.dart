import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/kinora_colors.dart';
import '../landing_page/components/floating_bottom_nav.dart';
import '../landing_page/components/math_motion.dart';
import 'components/challenge_card.dart';
import 'components/home_header.dart';
import 'components/quick_start_section.dart';
import 'components/recent_activity_section.dart';
import 'components/reveal.dart';
import 'components/week_calendar.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView>
    with TickerProviderStateMixin {
  late final AnimationController _ambience;
  late final ScrollController _scroll;

  double _scrollY = 0;

  @override
  void initState() {
    super.initState();
    _ambience = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7200),
    )..repeat();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final y = _scroll.offset.clamp(0.0, 240.0);
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
    final parallax = _scrollY / 240;

    return ColoredBox(
      color: KinoraColors.bg,
      child: Stack(
        children: [
          // Living background — drifts opposite to scroll.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambience,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0, -18 * parallax),
                  child: CustomPaint(
                    painter: _HomeAmbiencePainter(
                      phase: _ambience.value * math.pi * 2,
                      depth: 1 - parallax * 0.35,
                    ),
                  ),
                );
              },
            ),
          ),

          // Soft top glass when scrolling.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + 64,
            child: IgnorePointer(
              child: Opacity(
                opacity: MathMotion.smootherstep(parallax * 1.6),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            KinoraColors.bg.withValues(alpha: 0.82),
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
                child: const HomeHeader(),
              ),
              const SizedBox(height: 20),
              Reveal(
                delay: revealDelay(1),
                offset: const Offset(0, 24),
                scaleFrom: 0.90,
                twist: 0.02,
                duration: const Duration(milliseconds: 760),
                child: const ChallengeCard(),
              ),
              const SizedBox(height: 10),
              Reveal(
                delay: revealDelay(2),
                offset: const Offset(0, 12),
                scaleFrom: 0.98,
                twist: 0,
                child: const _SectionRule(),
              ),
              const SizedBox(height: 8),
              Reveal(
                delay: revealDelay(2, stepMs: 80),
                offset: const Offset(0, 18),
                scaleFrom: 0.95,
                twist: 0.01,
                child: const WeekCalendar(),
              ),
              const SizedBox(height: 12),
              Reveal(
                delay: revealDelay(3),
                offset: const Offset(0, 12),
                scaleFrom: 0.98,
                twist: 0,
                child: const _SectionRule(),
              ),
              const SizedBox(height: 10),
              Reveal(
                delay: revealDelay(3, stepMs: 78),
                offset: const Offset(0, 16),
                scaleFrom: 0.94,
                twist: 0.012,
                child: const QuickStartSection(),
              ),
              const SizedBox(height: 12),
              Reveal(
                delay: revealDelay(4),
                offset: const Offset(0, 12),
                scaleFrom: 0.98,
                twist: 0,
                child: const _SectionRule(),
              ),
              const SizedBox(height: 10),
              Reveal(
                delay: revealDelay(4, stepMs: 78),
                offset: const Offset(0, 20),
                scaleFrom: 0.94,
                twist: 0.01,
                child: const RecentActivitySection(),
              ),
              const SizedBox(height: 8),
              Reveal(
                delay: revealDelay(5),
                offset: const Offset(0, 10),
                scaleFrom: 0.98,
                twist: 0,
                child: const _FooterCue(),
              ),
            ],
          ),

          // Fade into bottom nav notch.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bottomClear * 0.55,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      KinoraColors.bg.withValues(alpha: 0),
                      KinoraColors.bg.withValues(alpha: 0.75),
                      KinoraColors.bg,
                    ],
                    stops: const [0, 0.45, 1],
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
                KinoraColors.lime.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.08),
                KinoraColors.lime.withValues(alpha: 0.18),
                Colors.transparent,
              ],
              stops: const [0, 0.22, 0.5, 0.78, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterCue extends StatelessWidget {
  const _FooterCue();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Center(
        child: Text(
          'Keep moving — consistency wins.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: KinoraColors.mutedSoft,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _HomeAmbiencePainter extends CustomPainter {
  _HomeAmbiencePainter({
    required this.phase,
    required this.depth,
  });

  final double phase;
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    final breath = MathMotion.breath(phase, lo: 0.88, hi: 1.14) * depth;
    final rect = Offset.zero & size;

    // Deep base wash
    canvas.drawRect(rect, Paint()..color = KinoraColors.bg);

    // Hero lime bloom (top-center, behind challenge)
    final hero = Paint()
      ..shader = ui.Gradient.radial(
        Offset(
          size.width * (0.5 + 0.03 * math.sin(phase * 0.7)),
          size.height * 0.16,
        ),
        size.width * 0.78 * breath,
        [
          KinoraColors.lime.withValues(alpha: 0.11 * depth),
          KinoraColors.lime.withValues(alpha: 0.04 * depth),
          Colors.transparent,
        ],
        const [0, 0.38, 1],
      );
    canvas.drawRect(rect, hero);

    // Left edge accent
    final left = Paint()
      ..shader = ui.Gradient.radial(
        Offset(
          size.width * -0.05,
          size.height * (0.55 + 0.03 * math.cos(phase)),
        ),
        size.width * 0.55,
        [
          KinoraColors.limeDeep.withValues(alpha: 0.05 * depth),
          Colors.transparent,
        ],
      );
    canvas.drawRect(rect, left);

    // Right drifting bloom
    final right = Paint()
      ..shader = ui.Gradient.radial(
        Offset(
          size.width * (0.95 + 0.02 * math.sin(phase * 1.1)),
          size.height * 0.4,
        ),
        size.width * 0.5 * breath,
        [
          KinoraColors.lime.withValues(alpha: 0.045 * depth),
          Colors.transparent,
        ],
      );
    canvas.drawRect(rect, right);

    // Soft vertical vignette
    final vig = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        [
          Colors.black.withValues(alpha: 0.15),
          Colors.transparent,
          Colors.transparent,
          Colors.black.withValues(alpha: 0.45),
        ],
        const [0, 0.12, 0.55, 1],
      );
    canvas.drawRect(rect, vig);

    // Floating micro sparks
    final spark = Paint()..isAntiAlias = true;
    for (var i = 0; i < 7; i++) {
      final t = (phase * 0.15 + i * 0.37) % 1.0;
      final x = size.width * (0.12 + 0.12 * i + 0.04 * math.sin(phase + i));
      final y = size.height * (0.08 + 0.7 * t);
      final a = (0.5 + 0.5 * math.sin(phase * 2 + i)).clamp(0.0, 1.0);
      spark.color = KinoraColors.lime.withValues(alpha: 0.045 * a * depth);
      canvas.drawCircle(Offset(x, y), 1.6 + (i % 3) * 0.5, spark);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeAmbiencePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.depth != depth;
}
