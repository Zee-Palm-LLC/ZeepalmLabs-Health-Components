import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../landing_page/components/math_motion.dart';
import 'reveal.dart';

class QuickStartItem {
  const QuickStartItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class QuickStartSection extends StatelessWidget {
  const QuickStartSection({super.key});

  static const items = <QuickStartItem>[
    QuickStartItem(icon: LucideIcons.person_standing, label: 'Warm Up'),
    QuickStartItem(icon: LucideIcons.heart_pulse, label: 'Cardio'),
    QuickStartItem(icon: LucideIcons.dumbbell, label: 'Strength'),
    QuickStartItem(icon: LucideIcons.accessibility, label: 'Stretching'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Quick Start',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: KinoraColors.text,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Text(
                'View all',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KinoraColors.lime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Reveal(
                    delay: revealDelay(i, stepMs: 55),
                    offset: const Offset(0, 16),
                    scaleFrom: 0.88,
                    twist: 0.025,
                    child: _QuickCard(item: items[i], index: i),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatefulWidget {
  const _QuickCard({required this.item, required this.index});

  final QuickStartItem item;
  final int index;

  @override
  State<_QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<_QuickCard>
    with TickerProviderStateMixin {
  late final AnimationController _press;
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _idle = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2600 + widget.index * 180),
    )..repeat();
  }

  @override
  void dispose() {
    _press.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_press, _idle]),
        builder: (context, _) {
          final p = MathMotion.smootherstep(_press.value);
          final phase = _idle.value * math.pi * 2 + widget.index;
          final breath = MathMotion.breath(phase, lo: 0.985, hi: 1.015);
          final glow = 0.08 + 0.1 * (0.5 + 0.5 * math.sin(phase));

          return Transform.scale(
            scale: (1 - 0.07 * p) * breath,
            child: AspectRatio(
              aspectRatio: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        KinoraColors.cardSoft,
                        KinoraColors.limeDim,
                        0.18 + 0.12 * p,
                      )!,
                      KinoraColors.cardSoft,
                    ],
                  ),
                  border: Border.all(
                    color: KinoraColors.lime.withValues(
                      alpha: 0.08 + 0.2 * p + glow * 0.4,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: KinoraColors.lime.withValues(
                        alpha: (0.06 + 0.16 * p) * glow * 4,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: KinoraColors.lime.withValues(alpha: 0.10),
                        boxShadow: [
                          BoxShadow(
                            color: KinoraColors.lime
                                .withValues(alpha: 0.18 * glow * 3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.item.icon,
                        size: 22,
                        color: KinoraColors.lime,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.item.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KinoraColors.lime,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
