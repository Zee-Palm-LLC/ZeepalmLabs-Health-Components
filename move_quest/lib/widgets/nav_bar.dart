import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/type.dart';

class NavItem {
  const NavItem(this.label, this.glyph, this.x, this.iconTop, this.iconSize);

  final String label;
  final Glyph glyph;
  final double x;
  final double iconTop;
  final double iconSize;
}

const navItems = [
  NavItem('Home', Glyph.home, 48.8, 780, 34),
  NavItem('Quests', Glyph.map, 131, 787.5, 26),
  NavItem('Progress', Glyph.progress, 204, 787.5, 26),
  NavItem('Shop', Glyph.cart, 278, 787.5, 28),
  NavItem('Profile', Glyph.profile, 350.5, 787.5, 26),
];

class QuestNavBar extends StatefulWidget {
  const QuestNavBar({super.key, required this.entrance});

  final Animation<double> entrance;

  @override
  State<QuestNavBar> createState() => _QuestNavBarState();
}

class _QuestNavBarState extends State<QuestNavBar> with SingleTickerProviderStateMixin {
  late final AnimationController _move;
  int _from = 0;
  int _to = 0;

  @override
  void initState() {
    super.initState();
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 620), value: 1);
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i == _to) return;
    HapticFeedback.selectionClick();
    setState(() {
      _from = _to;
      _to = i;
    });
    _move.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_move, widget.entrance]),
      builder: (context, _) {
        final e = widget.entrance.value;
        final rise = span(e, 0, 0.7, const Cubic(0.2, 0.9, 0.3, 1));
        return Transform.translate(
          offset: Offset(0, (1 - rise) * 110),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                left: 0,
                top: 775.3 - 764,
                right: 0,
                bottom: -80,
                child: CustomPaint(painter: _BarPainter()),
              ),
              _bubble(e),
              for (var i = 0; i < navItems.length; i++) _item(i, e),
            ],
          ),
        );
      },
    );
  }

  double get _bubbleX {
    final t = _move.value;
    final a = navItems[_from].x;
    final b = navItems[_to].x;
    return lerp(a, b, const Cubic(0.5, 0, 0.1, 1).transform(t));
  }

  Widget _bubble(double e) {
    final t = _move.value;
    final stretch = math.sin(t * math.pi) * 0.34;
    final pop = spring(span(e, 0.35, 1, Curves.linear), bounce: 0.5);
    final x = _bubbleX;
    return Positioned(
      left: x - 35 - 10,
      top: 799.5 - 764 - 35 - 10,
      width: 90,
      height: 90,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scaleByDouble(pop * (1 + stretch), pop * (1 - stretch * 0.45), 1, 1),
        child: const CustomPaint(painter: _BubblePainter()),
      ),
    );
  }

  Widget _item(int i, double e) {
    final item = navItems[i];
    final active = i == _to;
    final focus = active
        ? span(_move.value, 0.35, 1, settle)
        : (i == _from ? 1 - span(_move.value, 0, 0.4, Curves.easeOut) : 0.0);
    final appear = span(e, 0.3 + i * 0.08, 0.75 + i * 0.05, settle);
    final color = Color.lerp(const Color(0xFFC9D6F4), Colors.white, focus)!;
    final isHomeShape = i == 0;
    final labelStyle = isHomeShape
        ? typo(14.8, weight: FontWeight.w700, color: color)
        : typo(lerp(12.9, 13.6, focus), weight: focus > 0.5 ? FontWeight.w700 : FontWeight.w500, color: color);
    final baseline = isHomeShape ? 833.0 : 837.7;
    return Positioned(
      left: item.x - 36,
      top: 0,
      width: 72,
      height: 90,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(i),
        child: Opacity(
          opacity: appear.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - appear) * 18 - focus * (isHomeShape ? 0 : 3)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 36 - item.iconSize / 2,
                  top: item.iconTop - 764,
                  child: Transform.scale(
                    scale: 1 + 0.12 * focus * (isHomeShape ? 0 : 1),
                    child: GlyphIcon(
                      item.glyph,
                      size: item.iconSize,
                      stroke: 2.1,
                      color: isHomeShape ? Colors.white : color,
                    ),
                  ),
                ),
                TextAt(
                  x: 36,
                  baseline: baseline - 764,
                  anchor: 0.5,
                  width: 90,
                  style: labelStyle,
                  child: Label(item.label, labelStyle),
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
  const _BarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: const Radius.circular(26),
      topRight: const Radius.circular(26),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF024794), Color(0xFF013F86), Color(0xFF002150), Color(0xFF001E46), Color(0xFF001940), Color(0xFF021334)],
          stops: [0.0, 0.03, 0.22, 0.41, 0.6, 1.0],
        ).createShader(Offset.zero & size),
    );
    final top = Path()
      ..moveTo(0, 26)
      ..arcToPoint(const Offset(26, 0), radius: const Radius.circular(26))
      ..lineTo(size.width - 26, 0)
      ..arcToPoint(Offset(size.width, 26), radius: const Radius.circular(26));
    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF2FC8FF).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF7FE6FF),
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => false;
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = 35.0;
    canvas.drawCircle(
      c,
      r + 2,
      Paint()
        ..color = const Color(0xFF2E8BFF).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.3),
          colors: const [Color(0xFF2877F2), Color(0xFF1558E0), Color(0xFF0B45C8)],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r - 0.8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF5CC8FF),
    );
    final tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8FE0FF);
    canvas.drawLine(c + const Offset(-r - 1.5, 0), c + const Offset(-r + 2.5, 0), tick);
    canvas.drawLine(c + const Offset(r - 2.5, 0), c + const Offset(r + 3.5, 0), tick);
    canvas.drawLine(c + const Offset(0, -r - 1.5), c + const Offset(0, -r + 2), tick);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;
}
