import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';
import '../../widgets/rolling_number.dart';
import '../../widgets/surface.dart';

const stakes = [5, 10, 20, 50, 100];
const stops = [47.0, 131.3, 206.0, 278.7, 350.3];
const ticks = [47.0, 88.0, 131.3, 168.0, 206.0, 242.0, 278.7, 315.0, 350.3];

class AmountCard extends StatefulWidget {
  const AmountCard({super.key, required this.entrance});

  static const rect = Rect.fromLTRB(17.2, 435.0, 377.8, 603.0);

  final Animation<double> entrance;

  @override
  State<AmountCard> createState() => _AmountCardState();
}

class _AmountCardState extends State<AmountCard> with TickerProviderStateMixin {
  int _index = 1;
  int _was = 1;
  double _x = stops[1];
  late final AnimationController _snap;
  late final AnimationController _roll;
  late final AnimationController _jiggle;
  double _snapFrom = stops[1];

  @override
  void initState() {
    super.initState();
    _snap = AnimationController(vsync: this, duration: const Duration(milliseconds: 520))
      ..addListener(() => setState(() => _x = lerp(_snapFrom, stops[_index], settle.transform(_snap.value))));
    _roll = AnimationController(vsync: this, duration: const Duration(milliseconds: 700), value: 1);
    _jiggle = AnimationController(vsync: this, duration: const Duration(milliseconds: 650), value: 1);
  }

  @override
  void dispose() {
    _snap.dispose();
    _roll.dispose();
    _jiggle.dispose();
    super.dispose();
  }

  void _choose(int i, {bool animate = true}) {
    i = i.clamp(0, stakes.length - 1);
    if (i != _index) {
      HapticFeedback.selectionClick();
      _was = _index;
      _index = i;
      _roll.forward(from: 0);
      _jiggle.forward(from: 0);
    }
    if (animate) {
      _snapFrom = _x;
      _snap.forward(from: 0);
    }
    setState(() {});
  }

  int _nearest(double x) {
    var best = 0;
    for (var i = 1; i < stops.length; i++) {
      if ((stops[i] - x).abs() < (stops[best] - x).abs()) best = i;
    }
    return best;
  }

  void _drag(double localX) {
    _snap.stop();
    final x = (localX + AmountCard.rect.left).clamp(stops.first, stops.last);
    setState(() => _x = x);
    final n = _nearest(x);
    if (n != _index) _choose(n, animate: false);
  }

  @override
  Widget build(BuildContext context) {
    const r = AmountCard.rect;
    final e = widget.entrance;
    final title = inter(13.44, 600, color: const Color(0xFFE0E4EC));
    final note = inter(11.44, 400, color: const Color(0xFF808BA6));
    final money = inter(22.05, 700, color: const Color(0xFFF1F3F7));
    final tick = inter(11.68, 500, color: const Color(0xFF69738B));
    final lit = inter(11.68, 600, color: const Color(0xFFE2E5EF));

    return SizedBox(
      width: r.width,
      height: r.height,
      child: Surface(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 29.5 - r.left,
              top: 444.7 - r.top,
              child: const Tile(
                width: 53,
                height: 52.6,
                fill: [Color(0xFF4A2F2C), Color(0xFF3A2A30)],
                edge: Color(0xFF5E4847),
                glow: Color(0x22FF9F43),
              ),
            ),
            Positioned(
              left: Art.cCoins.left - r.left,
              top: Art.cCoins.top - r.top,
              width: Art.cCoins.width,
              height: Art.cCoins.height,
              child: AnimatedBuilder(
                animation: _jiggle,
                builder: (context, child) {
                  final j = _jiggle.value < 1 ? math.sin(_jiggle.value * math.pi * 4) * (1 - _jiggle.value) : 0.0;
                  return Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..translateByDouble(0, -5 * j.abs(), 0, 1)
                      ..rotateZ(0.2 * j),
                    child: child,
                  );
                },
                child: Art.cCoins.image(),
              ),
            ),
            Positioned(left: 105 - r.left - bearing('A', title), top: 447.3 - r.top - capInset(title), child: Text('Amount', style: title)),
            Positioned(left: 105 - r.left - bearing('H', note), top: 467.9 - r.top - capInset(note), child: Text('How much to stake?', style: note)),
            Positioned(
              left: 123.2 - 18.2 - r.left,
              top: 510.3 - 18.2 - r.top,
              child: _Step(icon: Ph.minusRegular, onTap: () => _choose(_index - 1), enabled: _index > 0),
            ),
            Positioned(
              left: 323.5 - 18.2 - r.left,
              top: 510.3 - 18.2 - r.top,
              child: _Step(icon: Ph.plusRegular, onTap: () => _choose(_index + 1), enabled: _index < stakes.length - 1),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 501.3 - r.top - capInset(money),
              child: Center(
                child: Transform.translate(
                  offset: Offset(218.3 - (r.left + r.width / 2), 0),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_roll, e]),
                    builder: (context, _) {
                      final intro = span(e.value, 0.45, 0.85, Curves.linear);
                      final bump = _roll.value < 1 ? math.sin(_roll.value * math.pi) * 0.08 : 0.0;
                      return Transform.scale(
                        scale: 1 + bump,
                        child: RollingNumber(
                          key: ValueKey(_index),
                          text: '\$${stakes[_index]}',
                          from: intro < 1 ? null : '\$${stakes[_was]}',
                          style: money,
                          progress: intro < 1 ? intro : _roll.value,
                          stagger: 0.12,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 530 - r.top,
              width: r.width,
              height: 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (d) => _drag(d.localPosition.dx),
                onHorizontalDragUpdate: (d) => _drag(d.localPosition.dx),
                onHorizontalDragEnd: (_) => _choose(_nearest(_x)),
                onTapUp: (d) => _choose(_nearest(d.localPosition.dx + r.left)),
                child: AnimatedBuilder(
                  animation: e,
                  builder: (context, _) => CustomPaint(
                    painter: _Track(x: _x - r.left, fill: span(e.value, 0.5, 0.95, gentle), top: 530 - r.top, left: r.left),
                  ),
                ),
              ),
            ),
            Positioned(
              left: _x - r.left - 16,
              top: 550.25 - r.top - 16,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: e,
                  builder: (context, child) {
                    final s = spring(span(e.value, 0.62, 0.95, Curves.linear), bounce: 0.4);
                    return Transform.scale(scale: s, child: child);
                  },
                  child: const _Thumb(),
                ),
              ),
            ),
            for (final x in ticks)
              Positioned(
                left: x - r.left - 0.5,
                top: 560 - r.top,
                child: Container(width: 1, height: 4.7, color: x <= _x + 0.5 ? const Color(0xFF6A4BD6) : const Color(0xFF2B3656)),
              ),
            for (final (i, x) in stops.indexed)
              Positioned(
                left: x - r.left - 20,
                width: 40,
                top: 574.0 - r.top - capInset(tick),
                child: GestureDetector(
                  onTap: () => _choose(i),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 260),
                    style: i == _index ? lit : tick,
                    child: Text('${stakes[i]}', textAlign: TextAlign.center),
                  ),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 520),
              curve: settle,
              left: stops[_index] - r.left - 7.7,
              top: 590.67 - r.top,
              child: Container(
                width: 15.4,
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  gradient: const LinearGradient(colors: [Color(0xFF7B5CF5), Color(0xFFB07BFF)]),
                  boxShadow: const [BoxShadow(color: Color(0x887B5CF5), blurRadius: 6)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.onTap, required this.enabled});

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.86,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: 36.4,
          height: 36.4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF13234A), Color(0xFF0E1C3E)],
            ),
            border: Border.all(color: const Color(0xFF26335A), width: 1.1),
          ),
          child: Center(child: PhIcon(icon, size: 15, color: const Color(0xFFE8ECF4))),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb();

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, s, child) {
        final g = 0.5 + 0.5 * wave(s, 2.2);
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color.fromRGBO(140, 90, 255, 0.35 + 0.2 * g), blurRadius: 12 + 4 * g)],
          ),
          child: child,
        );
      },
      child: Center(
        child: Container(
          width: 23.6,
          height: 23.6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB88BFF), Color(0xFF8A52F6)],
            ),
          ),
          child: Center(
            child: Container(
              width: 17.8,
              height: 17.8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0xFFFFFFFF), Color(0xFFEBDDFF)], stops: [0.5, 1.0]),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 5.2,
                    height: 5.2,
                    decoration: BoxDecoration(color: const Color(0xFFA46BF8), borderRadius: BorderRadius.circular(0.8)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Track extends CustomPainter {
  _Track({required this.x, required this.fill, required this.top, required this.left});

  final double x;
  final double fill;
  final double top;
  final double left;

  @override
  void paint(Canvas canvas, Size size) {
    final y = 550.25 - 435.0 - top;
    final a = 44.7 - left;
    final b = 352.6 - left;
    final track = RRect.fromLTRBR(a, y - 3.25, b, y + 3.25, const Radius.circular(3.25));
    canvas.drawRRect(track, Paint()..color = const Color(0xFF162649));
    final end = lerp(a, x, fill);
    if (end > a + 1) {
      final rect = Rect.fromLTRB(a, y - 3.25, end, y + 3.25);
      final paint = Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF5747FB), Color(0xFF7F43F9), Color(0xFFA46BF8)]).createShader(rect);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3.25)), paint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(5)),
        Paint()
          ..color = const Color(0x557F43F9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }

  @override
  bool shouldRepaint(_Track old) => old.x != x || old.fill != fill;
}
