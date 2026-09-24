import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/type.dart';

class NavItem {
  const NavItem(this.label, this.idle, this.active);

  final String label;
  final IconData idle;
  final IconData active;
}

const navItems = [
  NavItem('Home', PhosphorRegular.house, PhosphorFill.house),
  NavItem('Quests', PhosphorRegular.mapTrifold, PhosphorFill.mapTrifold),
  NavItem('Progress', PhosphorRegular.chartLineUp, PhosphorFill.chartLineUp),
  NavItem('Shop', PhosphorRegular.shoppingCart, PhosphorFill.shoppingCart),
  NavItem('Profile', PhosphorRegular.user, PhosphorFill.user),
];

class QuestNavBar extends StatefulWidget {
  const QuestNavBar({super.key, required this.entrance});

  static const top = 762.0;
  static const inset = 12.0;
  static const pillWidth = 64.0;
  static const pillTop = 6.0;
  static const pillHeight = 43.0;

  final Animation<double> entrance;

  static double centerOf(int i) {
    const slot = (393 - inset * 2) / 5;
    return inset + slot * (i + 0.5);
  }

  @override
  State<QuestNavBar> createState() => _QuestNavBarState();
}

class _QuestNavBarState extends State<QuestNavBar> with TickerProviderStateMixin {
  late final AnimationController _move;
  late final AnimationController _tap;
  int _from = 0;
  int _to = 0;

  @override
  void initState() {
    super.initState();
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 640), value: 1);
    _tap = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: 1);
  }

  @override
  void dispose() {
    _move.dispose();
    _tap.dispose();
    super.dispose();
  }

  void _select(int i) {
    HapticFeedback.selectionClick();
    _tap.forward(from: 0);
    if (i == _to) return;
    setState(() {
      _from = _to;
      _to = i;
    });
    _move.forward(from: 0);
  }

  (double, double) get _pillEdges {
    final t = _move.value;
    final forward = _to >= _from;
    final lead = const Cubic(0.3, 0.0, 0.1, 1.0).transform(t);
    final trail = const Cubic(0.6, 0.0, 0.2, 1.0).transform(t);
    const half = QuestNavBar.pillWidth / 2;
    final a = QuestNavBar.centerOf(_from);
    final b = QuestNavBar.centerOf(_to);
    final left = lerp(a - half, b - half, forward ? trail : lead);
    final right = lerp(a + half, b + half, forward ? lead : trail);
    return (left, right);
  }

  double _focus(int i) {
    if (i == _to) return span(_move.value, 0.25, 1, settle);
    if (i == _from) return 1 - span(_move.value, 0, 0.45, Curves.easeOut);
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_move, _tap, widget.entrance]),
      builder: (context, _) {
        final e = widget.entrance.value;
        final rise = span(e, 0, 0.7, const Cubic(0.2, 0.9, 0.3, 1));
        final (left, right) = _pillEdges;
        final pillIn = span(e, 0.35, 0.8, settle);
        return Transform.translate(
          offset: Offset(0, (1 - rise) * 120),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: -120,
                child: Tick(
                  builder: (context, s, _) => CustomPaint(
                    painter: _BarPainter(
                      beam: (left + right) / 2,
                      seconds: s,
                      reveal: span(e, 0.2, 0.9, Curves.easeInOut),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: left + (right - left) * (1 - pillIn) / 2,
                width: (right - left) * pillIn,
                top: QuestNavBar.pillTop,
                height: QuestNavBar.pillHeight,
                child: Opacity(
                  opacity: pillIn.clamp(0.0, 1.0),
                  child: CustomPaint(painter: _PillPainter(stretch: (right - left) / QuestNavBar.pillWidth - 1)),
                ),
              ),
              for (var i = 0; i < navItems.length; i++) _item(i, e),
            ],
          ),
        );
      },
    );
  }

  Widget _item(int i, double e) {
    final item = navItems[i];
    final focus = _focus(i);
    final appear = span(e, 0.3 + i * 0.07, 0.72 + i * 0.05, settle);
    final bounce = i == _to ? math.sin(_tap.value * math.pi) * math.exp(-2.4 * _tap.value) * 0.22 : 0.0;
    final color = Color.lerp(const Color(0xFF8FA3D6), Colors.white, focus)!;
    final label = typo(11.2, weight: focus > 0.5 ? FontWeight.w700 : FontWeight.w500, color: color, spacing: -0.1);
    final cx = QuestNavBar.centerOf(i);
    return Positioned(
      left: cx - 36,
      top: 0,
      width: 72,
      height: 60,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(i),
        child: Opacity(
          opacity: appear.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - appear) * 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 36 - 11.5,
                  top: 11 - focus * 1.5,
                  child: Transform.scale(
                    scale: 1 + bounce + 0.06 * focus,
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 1 - focus.clamp(0.0, 1.0),
                          child: PhIcon(item.idle, size: 23, color: color),
                        ),
                        Opacity(
                          opacity: focus.clamp(0.0, 1.0),
                          child: PhIcon(
                            item.active,
                            size: 23,
                            shadows: const [Shadow(color: Color(0x994FD8FF), blurRadius: 8)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextAt(
                  x: 36,
                  baseline: 43.5 - focus * 0.5,
                  anchor: 0.5,
                  width: 80,
                  style: label,
                  child: Label(item.label, label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({required this.beam, required this.seconds, required this.reveal});

  final double beam;
  final double seconds;
  final double reveal;

  static const radius = 26.0;

  Path _edge(Size size) => Path()
    ..moveTo(0, radius)
    ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
    ..lineTo(size.width - radius, 0)
    ..arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius));

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final body = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(radius),
      topRight: const Radius.circular(radius),
    );
    canvas.drawRRect(
      body.shift(const Offset(0, -6)),
      Paint()
        ..color = const Color(0xFF020A2E).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C2A74), Color(0xFF061B55), Color(0xFF031240), Color(0xFF020C30)],
          stops: [0.0, 0.25, 0.55, 1.0],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 22),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, 22), [
          Colors.white.withValues(alpha: 0.07),
          Colors.white.withValues(alpha: 0),
        ]),
    );
    canvas.drawCircle(
      Offset(beam, 0),
      70,
      Paint()
        ..shader = ui.Gradient.radial(Offset(beam, 0), 70, [
          const Color(0xFF4FA8FF).withValues(alpha: 0.22 * reveal),
          const Color(0x004FA8FF),
        ]),
    );
    canvas.restore();

    final metric = _edge(size).computeMetrics().first;
    final shown = metric.extractPath(metric.length * (0.5 - reveal / 2), metric.length * (0.5 + reveal / 2));
    final aurora = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      const [Color(0xFF34E3D2), Color(0xFF4FA8FF), Color(0xFF8F5BFF), Color(0xFFFF4FD8)],
      const [0.0, 0.35, 0.7, 1.0],
    );
    canvas.drawPath(
      shown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..shader = aurora
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      shown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..shader = aurora,
    );
    if (reveal >= 1) {
      final spot = Rect.fromCenter(center: Offset(beam, 0.6), width: 54, height: 3);
      canvas.drawRect(
        spot.inflate(3),
        Paint()
          ..shader = ui.Gradient.linear(
            spot.centerLeft,
            spot.centerRight,
            [
              const Color(0x00FFFFFF),
              Colors.white.withValues(alpha: 0.75 + 0.2 * math.sin(seconds * 3)),
              const Color(0x00FFFFFF),
            ],
            const [0.0, 0.5, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.beam != beam || old.seconds != seconds || old.reveal != reveal;
}

class _PillPainter extends CustomPainter {
  _PillPainter({required this.stretch});

  final double stretch;

  @override
  void paint(Canvas canvas, Size size) {
    final squash = (stretch * 0.08).clamp(0.0, 0.14);
    final rect = Rect.fromLTWH(0, size.height * squash / 2, size.width, size.height * (1 - squash));
    final body = RRect.fromRectAndRadius(rect, const Radius.circular(18));
    canvas.drawRRect(
      body.inflate(2),
      Paint()
        ..color = const Color(0xFF3F7BFF).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F8BFF), Color(0xFF3A5BF5), Color(0xFF7A4BF0)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.5),
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.center, [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0),
        ]),
    );
    canvas.restore();
    canvas.drawRRect(
      body.deflate(0.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          [const Color(0xFFB8E4FF), const Color(0x557FA8FF), const Color(0x99C9A8FF)],
          const [0.0, 0.5, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(_PillPainter old) => old.stretch != stretch;
}
