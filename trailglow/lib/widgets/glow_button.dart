import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/motion.dart';
import '../app/theme/palette.dart';
import '../app/theme/typography.dart';
import 'press_scale.dart';

class GlowButton extends StatefulWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.play_arrow_rounded,
    this.colors = const <Color>[Spectrum.deep, Spectrum.blue, Spectrum.cyan],
    this.height = 64,
    this.breathing = true,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final List<Color> colors;
  final double height;
  final bool breathing;

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.breathing) _breath.repeat();
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.height / 2);
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        final wave = 0.5 + 0.5 * math.sin(_breath.value * math.pi * 2);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.colors.last.withValues(alpha: 0.22 + wave * 0.12),
                blurRadius: 36 + wave * 12,
                spreadRadius: -4,
                offset: const Offset(0, 10),
              ),
              const BoxShadow(
                color: Color(0xAA000000),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: child,
        );
      },
      child: PressScale(
        onTap: widget.onTap,
        scale: 0.965,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: widget.colors,
              stops: List<double>.generate(
                widget.colors.length,
                (i) => i / math.max(1, widget.colors.length - 1),
              ),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.18),
                      ],
                      stops: const <double>[0.0, 0.48, 1.0],
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.32),
                        ),
                      ),
                      child: Icon(widget.icon, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Text(widget.label, style: Typo.button),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleAction extends StatelessWidget {
  const CircleAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 54,
    this.color = Tone.primary,
    this.background = Night.panel,
    this.border = Night.hairline,
    this.glow,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final Color background;
  final Color border;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      scale: 0.9,
      child: AnimatedContainer(
        duration: Motion.quick,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background,
          border: Border.all(color: border),
          boxShadow: glow == null
              ? null
              : <BoxShadow>[
                  BoxShadow(
                    color: glow!.withValues(alpha: 0.30),
                    blurRadius: 26,
                    spreadRadius: -4,
                  ),
                ],
        ),
        child: Icon(icon, size: size * 0.40, color: color),
      ),
    );
  }
}
