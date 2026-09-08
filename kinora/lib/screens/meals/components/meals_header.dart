import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../landing_page/components/math_motion.dart';

class MealsHeader extends StatefulWidget {
  const MealsHeader({super.key});

  @override
  State<MealsHeader> createState() => _MealsHeaderState();
}

class _MealsHeaderState extends State<MealsHeader>
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
              final phase = _pulse.value * 3.14159 * 2;
              final glow = 0.16 + 0.14 * (0.5 + 0.5 * MathMotion.breath(phase, lo: 0, hi: 1));
              return Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: KinoraColors.lime, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: KinoraColors.lime.withValues(alpha: glow),
                      blurRadius: 12,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: child,
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
                const SizedBox(height: 2),
                Text(
                  'Get ready',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KinoraColors.lime,
                  ),
                ),
              ],
            ),
          ),
          const _RoundAction(icon: LucideIcons.bell, badge: true),
          const SizedBox(width: 10),
          const _RoundAction(icon: LucideIcons.flame),
        ],
      ),
    );
  }
}

class _RoundAction extends StatefulWidget {
  const _RoundAction({required this.icon, this.badge = false});

  final IconData icon;
  final bool badge;

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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
