import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';

class NavSpec {
  const NavSpec(this.idle, this.active, this.label, this.x);

  final IconData idle;
  final IconData? active;
  final String label;
  final double x;
}

const navSpecs = [
  NavSpec(Ph.house, Ph.houseFill, 'Home', 53.0),
  NavSpec(Ph.barbell, Ph.barbellFill, 'Workouts', 148.7),
  NavSpec(Ph.chartBar, null, 'Progress', 246.0),
  NavSpec(Ph.user, Ph.userFill, 'Profile', 341.2),
];

class NavBar extends StatefulWidget {
  const NavBar({super.key, required this.index, required this.onSelect, required this.entrance});

  static const refIcon = 65.4;
  static const refBase = 34.7;
  static const refTop = 91.4;

  static double lift(Frame frame) => math.max(0, frame.bottom - refBase);

  static double height(Frame frame) => refTop + lift(frame);

  final int index;
  final ValueChanged<int> onSelect;
  final Animation<double> entrance;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  late final AnimationController _slide;
  late double _from;
  late double _to;

  @override
  void initState() {
    super.initState();
    _from = navSpecs[widget.index].x;
    _to = _from;
    _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 720), value: 1);
  }

  @override
  void didUpdateWidget(NavBar old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _from = _position;
      _to = navSpecs[widget.index].x;
      _slide.forward(from: 0);
    }
  }

  double get _position => lerp(_from, _to, spring(_slide.value, bounce: 0.3, freq: 2.2));

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = NavBar.lift(frame);
    final h = NavBar.height(frame);
    final iconY = NavBar.refIcon + lift;
    final baseY = NavBar.refBase + lift;
    return AnimatedBuilder(
      animation: widget.entrance,
      builder: (context, child) {
        final t = span(widget.entrance.value, 0.0, 1.0, gentle);
        return Transform.translate(offset: Offset(0, (1 - t) * h), child: child);
      },
      child: SizedBox(
        width: Frame.width,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xF2F8F4EE), Color(0xFAF9F6EE)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -14,
              height: 14,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [const Color(0xFFE9E2D6).withValues(alpha: 0.35), const Color(0x00E9E2D6)],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _slide,
              builder: (context, _) {
                final v = _slide.value;
                final stretch = math.sin(math.min(v * 1.6, 1.0) * math.pi) * (_to - _from).abs() * 0.22;
                final x = _position;
                return Positioned(
                  left: x - 30 - stretch / 2,
                  top: h - iconY - 25,
                  width: 60 + stretch,
                  height: 50,
                  child: IgnorePointer(
                    child: CustomPaint(painter: _Goo(progress: v)),
                  ),
                );
              },
            ),
            for (var i = 0; i < navSpecs.length; i++)
              Positioned(
                left: navSpecs[i].x - 40,
                top: 0,
                width: 80,
                height: h,
                child: _Item(
                  spec: navSpecs[i],
                  active: i == widget.index,
                  iconFromBottom: iconY,
                  baseFromBottom: baseY,
                  height: h,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onSelect(i);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Goo extends CustomPainter {
  _Goo({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    final glow = Paint()
      ..shader = ui.Gradient.radial(
        r.center,
        size.width * 0.55,
        [const Color(0xCCFFFFFF), const Color(0x66FFFFFF), const Color(0x00FFFFFF)],
        [0, 0.55, 1],
      );
    canvas.drawOval(r.deflate(1), glow);
    final ring = math.sin(progress * math.pi);
    if (ring > 0.01) {
      final p = Paint()
        ..color = Palette.violet.withValues(alpha: 0.10 * ring)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawOval(r.deflate(6), p);
    }
  }

  @override
  bool shouldRepaint(_Goo old) => old.progress != progress;
}

class _Item extends StatefulWidget {
  const _Item({
    required this.spec,
    required this.active,
    required this.iconFromBottom,
    required this.baseFromBottom,
    required this.height,
    required this.onTap,
  });

  final NavSpec spec;
  final bool active;
  final double iconFromBottom;
  final double baseFromBottom;
  final double height;
  final VoidCallback onTap;

  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 640), value: widget.active ? 1 : 0);
  }

  @override
  void didUpdateWidget(_Item old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) {
      widget.active ? _c.forward(from: 0) : _c.animateBack(0, duration: const Duration(milliseconds: 260));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const idle = Color(0xFF6E6D6C);
    const idleLabel = Color(0xFF8C8A88);
    return Pressable(
      onTap: widget.onTap,
      haptic: false,
      scale: 0.9,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final v = _c.value;
          final pop = widget.active ? spring(v, bounce: 0.6, freq: 2.8) : v;
          final s = 1 + 0.16 * math.sin(math.min(v, 1.0) * math.pi) * (widget.active ? 1 : 0);
          final label = inter(
            11.9,
            lerp(500, 600, v),
            color: Color.lerp(idleLabel, Palette.violet, v)!,
            track: -0.01,
          );
          final iconTop = widget.height - widget.iconFromBottom - 14;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 26,
                top: iconTop - s * 0 - 6 * math.sin(math.min(v, 1.0) * math.pi) * (widget.active ? 1 : 0),
                child: Transform.scale(
                  scale: s,
                  child: SizedBox.square(
                    dimension: 28,
                    child: Stack(
                      children: [
                        Opacity(opacity: 1 - v, child: PhIcon(widget.spec.idle, size: 28, color: idle)),
                        Opacity(
                          opacity: v,
                          child: Transform.scale(
                            scale: lerp(0.6, 1, pop.clamp(0.0, 1.2)),
                            child: widget.spec.active != null
                                ? PhIcon(
                                    widget.spec.active!,
                                    size: 28,
                                    foreground: Paint()
                                      ..shader = ui.Gradient.linear(
                                        const Offset(0, 0),
                                        const Offset(0, 28),
                                        const [Color(0xFF8446FF), Color(0xFF6424EE)],
                                      ),
                                  )
                                : const CustomPaint(size: Size(28, 28), painter: _ChartTile()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: widget.height - widget.baseFromBottom - 8.67,
                child: Center(child: Cap(widget.spec.label, label, align: TextAlign.center)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChartTile extends CustomPainter {
  const _ChartTile();

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(const Rect.fromLTWH(2.5, 2.5, 23, 23), const Radius.circular(5.5));
    canvas.drawRRect(
      r,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, 2), const Offset(0, 26), const [Color(0xFF8B4DFF), Color(0xFF6424EE)]),
    );
    final bar = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRRect(RRect.fromLTRBR(7.5, 15.5, 10.5, 21, const Radius.circular(1.2)), bar);
    canvas.drawRRect(RRect.fromLTRBR(12.5, 12, 15.5, 21, const Radius.circular(1.2)), bar);
    canvas.drawRRect(RRect.fromLTRBR(17.5, 9, 20.5, 21, const Radius.circular(1.2)), bar);
    final spark = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(18.5, 5.8), const Offset(22.5, 5.8), spark);
  }

  @override
  bool shouldRepaint(_ChartTile old) => false;
}
