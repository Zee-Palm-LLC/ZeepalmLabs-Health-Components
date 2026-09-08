import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../landing_page/components/math_motion.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final phase = _pulse.value * math.pi * 2;
              final breath = MathMotion.breath(phase, lo: 0.96, hi: 1.04);
              final glow = 0.18 + 0.16 * (0.5 + 0.5 * math.sin(phase));
              return Transform.scale(
                scale: breath,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: KinoraColors.lime, width: 2.2),
                    boxShadow: [
                      BoxShadow(
                        color: KinoraColors.lime.withValues(alpha: glow),
                        blurRadius: 14,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: child,
                ),
              );
            },
            child: const CircleAvatar(
              backgroundColor: KinoraColors.limeDim,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=faces',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello Emma 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: KinoraColors.text,
                    height: 1.15,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Get ready to crush your goals today!',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: KinoraColors.muted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const _RoundAction(icon: LucideIcons.bell, badge: true),
          const SizedBox(width: 10),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final phase = _pulse.value * math.pi * 2;
              final hot = 0.5 + 0.5 * math.sin(phase * 1.3);
              return _RoundAction(
                icon: LucideIcons.flame,
                glow: Color.lerp(
                  Colors.transparent,
                  KinoraColors.orange.withValues(alpha: 0.35),
                  hot,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatefulWidget {
  const _RoundAction({
    required this.icon,
    this.badge = false,
    this.glow,
  });

  final IconData icon;
  final bool badge;
  final Color? glow;

  @override
  State<_RoundAction> createState() => _RoundActionState();
}

class _RoundActionState extends State<_RoundAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        HapticFeedback.selectionClick();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          final t = MathMotion.smootherstep(_press.value);
          return Transform.scale(scale: 1 - 0.1 * t, child: child);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: KinoraColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  if (widget.glow != null)
                    BoxShadow(
                      color: widget.glow!,
                      blurRadius: 12,
                    ),
                ],
              ),
              child: Icon(widget.icon, size: 20, color: KinoraColors.text),
            ),
            if (widget.badge)
              Positioned(
                top: 7,
                right: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: KinoraColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: KinoraColors.surface,
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: KinoraColors.danger.withValues(alpha: 0.55),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
