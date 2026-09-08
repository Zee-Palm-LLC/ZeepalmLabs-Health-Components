import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../home/components/reveal.dart';
import '../../landing_page/components/math_motion.dart';

class _Nutrient {
  const _Nutrient({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    required this.sub,
    required this.progress,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;
  final String sub;
  final double progress;
}

class DailyNutritionSection extends StatelessWidget {
  const DailyNutritionSection({super.key});

  static const _items = <_Nutrient>[
    _Nutrient(
      icon: LucideIcons.flame,
      color: Color(0xFFFF4D4D),
      label: 'Calories',
      value: '1120',
      unit: 'Kcal',
      sub: '/ 2300 burned',
      progress: 1120 / 2300,
    ),
    _Nutrient(
      icon: LucideIcons.dna,
      color: Color(0xFF4DA3FF),
      label: 'Proteins',
      value: '98',
      unit: 'g',
      sub: '/ 392 kcal',
      progress: 0.72,
    ),
    _Nutrient(
      icon: LucideIcons.wheat,
      color: Color(0xFFFF9A3D),
      label: 'Carbs',
      value: '120',
      unit: 'g',
      sub: '/ 480 kcal',
      progress: 0.58,
    ),
    _Nutrient(
      icon: LucideIcons.droplet,
      color: Color(0xFFB07CFF),
      label: 'Fats',
      value: '32',
      unit: 'g',
      sub: '/ 288 kcal',
      progress: 0.4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Your Daily Nutrition',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: KinoraColors.text,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => HapticFeedback.selectionClick(),
                child: Text(
                  'Edit Goals',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KinoraColors.lime,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _items.length,
            separatorBuilder: (_, index) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              return Reveal(
                delay: revealDelay(i, stepMs: 55),
                offset: const Offset(0, 16),
                scaleFrom: 0.9,
                twist: 0.02,
                child: _NutritionCard(item: _items[i], index: i),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NutritionCard extends StatefulWidget {
  const _NutritionCard({required this.item, required this.index});

  final _Nutrient item;
  final int index;

  @override
  State<_NutritionCard> createState() => _NutritionCardState();
}

class _NutritionCardState extends State<_NutritionCard>
    with TickerProviderStateMixin {
  late final AnimationController _press;
  late final AnimationController _enter;
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _idle = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2800 + widget.index * 160),
    )..repeat();
  }

  @override
  void dispose() {
    _press.dispose();
    _enter.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_press, _enter, _idle]),
        builder: (context, _) {
          final press = MathMotion.smootherstep(_press.value);
          final enter = MathMotion.settle(_enter.value, alpha: 5.5, omega: 10);
          final phase = _idle.value * math.pi * 2 + widget.index;
          final glow = 0.1 + 0.08 * (0.5 + 0.5 * math.sin(phase));
          final bar = item.progress * enter;

          return Transform.scale(
            scale: 1 - 0.05 * press,
            child: Container(
              width: 138,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(KinoraColors.cardSoft, item.color, 0.08)!,
                    KinoraColors.cardSoft,
                  ],
                ),
                border: Border.all(
                  color: item.color.withValues(alpha: 0.14 + glow),
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.16 * glow * 4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(item.icon, size: 18, color: item.color),
                      ),
                      const Spacer(),
                      Text(
                        '${(bar * 100).round()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: item.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: KinoraColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: item.value,
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: KinoraColors.text,
                            height: 1.1,
                          ),
                        ),
                        TextSpan(
                          text: ' ${item.unit}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: KinoraColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: SizedBox(
                      height: 4,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(
                            color: item.color.withValues(alpha: 0.15),
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: bar.clamp(0.0, 1.0),
                            child: ColoredBox(color: item.color),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.sub,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: KinoraColors.mutedSoft,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
