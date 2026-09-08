import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import 'math_motion.dart';

class NavDest {
  const NavDest({
    required this.icon,
    required this.label,
    this.tilt = 0,
  });

  final IconData icon;
  final String label;
  final double tilt;
}

/// Edge-to-edge notched dock + living center orb.
/// Motion driven by springs + [MathMotion].
class FloatingBottomNav extends StatefulWidget {
  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const double barHeight = 72;
  static const double fabSize = 64;
  /// Air gap between FAB edge and dock notch.
  static const double fabGap = 8;

  static const double _orbPad = 10;
  static double get _orbBox => fabSize + _orbPad * 2;
  static double get fabRadius => fabSize / 2;
  static double get notchRadius => fabRadius + fabGap;
  static double get fabRise => _orbBox / 2;

  static const items = <NavDest>[
    NavDest(icon: LucideIcons.house, label: 'Home'),
    NavDest(icon: LucideIcons.dumbbell, label: 'Workout', tilt: -0.35),
    NavDest(icon: LucideIcons.chart_column, label: 'Stats'),
    NavDest(icon: LucideIcons.soup, label: 'Meals'),
    NavDest(icon: LucideIcons.circle_user, label: 'Profile'),
  ];

  static double contentClearance(BuildContext context) {
    return barHeight +
        fabRise +
        MediaQuery.paddingOf(context).bottom +
        12;
  }

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _fabPop;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _fabPop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    if (widget.currentIndex == 2) _fabPop.value = 1;
  }

  @override
  void didUpdateWidget(FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;

    if (widget.currentIndex == 2) {
      _fabPop.forward(from: 0);
    } else if (oldWidget.currentIndex == 2) {
      _fabPop.reverse();
    }
  }

  bool get _centerActive => widget.currentIndex == 2;

  void _select(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.selectionClick();
    widget.onChanged(index);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _fabPop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: FloatingBottomNav.barHeight +
          FloatingBottomNav.fabRise +
          bottom,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: FloatingBottomNav.barHeight + bottom,
              width: double.infinity,
              child: CustomPaint(
                painter: _DockPainter(pulse: _pulse),
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: bottom),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final gap =
                          FloatingBottomNav.notchRadius * 2 + 20;
                      final sideW = (constraints.maxWidth - gap) / 2;

                      return Row(
                        children: [
                          SizedBox(
                            width: sideW,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _NavIcon(
                                    dest: FloatingBottomNav.items[0],
                                    selected: widget.currentIndex == 0,
                                    onTap: () => _select(0),
                                  ),
                                ),
                                Expanded(
                                  child: _NavIcon(
                                    dest: FloatingBottomNav.items[1],
                                    selected: widget.currentIndex == 1,
                                    onTap: () => _select(1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: gap),
                          SizedBox(
                            width: sideW,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _NavIcon(
                                    dest: FloatingBottomNav.items[3],
                                    selected: widget.currentIndex == 3,
                                    onTap: () => _select(3),
                                  ),
                                ),
                                Expanded(
                                  child: _NavIcon(
                                    dest: FloatingBottomNav.items[4],
                                    selected: widget.currentIndex == 4,
                                    onTap: () => _select(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: _CenterOrb(
              pulse: _pulse,
              pop: _fabPop,
              selected: _centerActive,
              onTap: () => _select(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatefulWidget {
  const _NavIcon({
    required this.dest,
    required this.selected,
    required this.onTap,
  });

  final NavDest dest;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> with TickerProviderStateMixin {
  static const _iconSpring = SpringDescription(
    mass: 0.65,
    stiffness: 280,
    damping: 12,
  );

  late final AnimationController _scale;
  late final AnimationController _select;
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController.unbounded(vsync: this)
      ..value = widget.selected ? 1.14 : 1.0;
    _select = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      value: widget.selected ? 1 : 0,
    );
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
  }

  @override
  void didUpdateWidget(_NavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;

    _scale.animateWith(
      SpringSimulation(
        _iconSpring,
        _scale.value,
        widget.selected ? 1.14 : 1.0,
        widget.selected ? 7.2 : _scale.velocity,
      ),
    );
    if (widget.selected) {
      _select.forward(from: 0);
    } else {
      _select.reverse();
    }
  }

  @override
  void dispose() {
    _scale.dispose();
    _select.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scale, _select, _press]),
        builder: (context, _) {
          final t = MathMotion.spiralBlend(_select.value);
          final press = MathMotion.smootherstep(_press.value);
          final color = Color.lerp(
            KinoraColors.muted,
            KinoraColors.lime,
            t,
          )!;
          final settleY = widget.selected
              ? -2.5 * MathMotion.settle(_select.value, alpha: 8, omega: 14)
              : 0.0;
          final wobble = widget.selected
              ? MathMotion.wobble(_select.value, amp: 0.14, freq: 2.2)
              : 0.0;
          final scale = _scale.value * (1 - 0.08 * press);
          final pip = MathMotion.softBounce(_select.value);

          Widget icon = Icon(
            widget.dest.icon,
            size: 22,
            color: color,
          );
          final angle = widget.dest.tilt + wobble;
          if (angle != 0) {
            icon = Transform.rotate(angle: angle, child: icon);
          }

          return Transform.translate(
            offset: Offset(0, settleY),
            child: Transform.scale(
              scale: scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(height: 5),
                  Text(
                    widget.dest.label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight:
                          t > 0.5 ? FontWeight.w600 : FontWeight.w500,
                      color: color,
                      height: 1,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Slim active pip — not a background container.
                  Opacity(
                    opacity: pip.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scaleX: 0.35 + 0.65 * pip,
                      scaleY: pip,
                      child: Container(
                        width: 14,
                        height: 3,
                        decoration: BoxDecoration(
                          color: KinoraColors.lime,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: KinoraColors.lime
                                  .withValues(alpha: 0.45 * pip),
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
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

class _CenterOrb extends StatefulWidget {
  const _CenterOrb({
    required this.pulse,
    required this.pop,
    required this.selected,
    required this.onTap,
  });

  final Animation<double> pulse;
  final Animation<double> pop;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CenterOrb> createState() => _CenterOrbState();
}

class _CenterOrbState extends State<_CenterOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.pulse, widget.pop, _press]),
      builder: (context, child) {
        final phase = widget.pulse.value * math.pi * 2;
        final breath = MathMotion.breath(phase, lo: 0.97, hi: 1.04);
        final popT = MathMotion.softBounce(widget.pop.value);
        final press = MathMotion.smootherstep(_press.value);
        final scale = (0.88 + 0.12 * popT) * breath * (1 - 0.06 * press);
        final glowBase = 0.5 + 0.5 * math.sin(phase);
        final glow = (0.16 + 0.28 * glowBase) *
            (widget.selected ? 1.25 : 0.8);
        final ringA = MathMotion.breath(phase + 0.7, lo: 1.02, hi: 1.10);
        final ringB = MathMotion.breath(phase + 2.1, lo: 1.10, hi: 1.20);
        final iconTilt = widget.selected
            ? 0.1 * math.sin(phase) * MathMotion.tanh(popT * 2.2)
            : 0.0;
        final orbit = phase;

        return SizedBox(
          width: FloatingBottomNav._orbBox,
          height: FloatingBottomNav._orbBox,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse halo
              Transform.scale(
                scale: ringB,
                child: Container(
                  width: FloatingBottomNav.fabSize + 16,
                  height: FloatingBottomNav.fabSize + 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: KinoraColors.lime.withValues(
                        alpha: widget.selected ? 0.18 : 0.06,
                      ),
                      width: 1,
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: ringA,
                child: Container(
                  width: FloatingBottomNav.fabSize + 8,
                  height: FloatingBottomNav.fabSize + 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: KinoraColors.lime.withValues(
                        alpha: widget.selected ? 0.42 : 0.14,
                      ),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Tiny orbiting accents
              if (widget.selected)
                ...List.generate(3, (i) {
                  final a = orbit + i * (math.pi * 2 / 3);
                  final r = FloatingBottomNav.fabRadius + 11;
                  return Transform.translate(
                    offset: Offset(math.cos(a) * r, math.sin(a) * r),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: KinoraColors.lime.withValues(alpha: 0.7),
                        boxShadow: [
                          BoxShadow(
                            color:
                                KinoraColors.lime.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onTapDown: (_) => _press.forward(),
                  onTapUp: (_) {
                    _press.reverse();
                    widget.onTap();
                  },
                  onTapCancel: () => _press.reverse(),
                  child: Container(
                    width: FloatingBottomNav.fabSize,
                    height: FloatingBottomNav.fabSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                            KinoraColors.lime,
                            Colors.white,
                            0.18,
                          )!,
                          KinoraColors.lime,
                          KinoraColors.limeDeep,
                        ],
                        stops: const [0, 0.45, 1],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: KinoraColors.lime.withValues(alpha: glow),
                          blurRadius: 20 + 14 * glow,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Specular sheen
                        Positioned(
                          top: 10,
                          left: 14,
                          child: Container(
                            width: 22,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.45),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: iconTilt,
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: const Icon(
        LucideIcons.chart_column,
        size: 26,
        color: KinoraColors.ink,
      ),
    );
  }
}

class _DockPainter extends CustomPainter {
  _DockPainter({required this.pulse}) : super(repaint: pulse);

  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final host = Offset.zero & size;
    final cx = size.width / 2;
    final guest = Rect.fromCircle(
      center: Offset(cx, 0),
      radius: FloatingBottomNav.notchRadius,
    );

    final hostPath = Path()..addRect(host);
    final guestPath = Path()..addOval(guest);
    final path = Path.combine(PathOperation.difference, hostPath, guestPath);

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.45),
      14,
      false,
    );

    final fill = Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        const [
          Color(0xFF1E222B),
          KinoraColors.bar,
          Color(0xFF12141A),
        ],
        const [0, 0.45, 1],
      );
    canvas.drawPath(path, fill);

    // Top edge highlight (skips the notch with a path stroke).
    final topGlow = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, 0),
        [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0),
        ],
        const [0, 0.18, 0.82, 1],
      );
    canvas.drawPath(path, topGlow);

    // Lime rim along the sharp circular notch — breathes with pulse.
    final phase = pulse.value * math.pi * 2;
    final rimA = 0.22 + 0.14 * (0.5 + 0.5 * math.sin(phase));
    final rim = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = KinoraColors.lime.withValues(alpha: rimA);
    canvas.drawArc(
      guest.inflate(0.6),
      0.12,
      math.pi - 0.24,
      false,
      rim,
    );

    // Soft radial shade under the FAB for depth inside the notch.
    final well = Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.radial(
        Offset(cx, FloatingBottomNav.notchRadius * 0.35),
        FloatingBottomNav.notchRadius * 1.15,
        [
          Colors.black.withValues(alpha: 0.28),
          Colors.transparent,
        ],
      );
    canvas.save();
    canvas.clipPath(path);
    canvas.drawCircle(
      Offset(cx, FloatingBottomNav.notchRadius * 0.2),
      FloatingBottomNav.notchRadius,
      well,
    );
    canvas.restore();

    final edge = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = KinoraColors.barEdge.withValues(alpha: 0.8);
    canvas.drawPath(path, edge);
  }

  @override
  bool shouldRepaint(covariant _DockPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}
