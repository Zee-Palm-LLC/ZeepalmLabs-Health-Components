import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/type.dart';

class NavItem {
  const NavItem(this.icon, this.label, this.x);

  final IconData icon;
  final String label;
  final double x;
}

const navItems = [
  NavItem(Ph.houseLight, 'Home', 48.8),
  NavItem(Ph.flowerLight, 'Pools', 125.0),
  NavItem(Ph.timerLight, 'Activity', 270.0),
  NavItem(Ph.userLight, 'Profile', 346.2),
];

class NavBar extends StatefulWidget {
  const NavBar({super.key, required this.entrance, required this.onCreate, required this.fabKey});

  static const top = 864.5;
  static const content = 58.0;

  static double topIn(Frame frame) => frame.height - frame.bottom - content;

  final Animation<double> entrance;
  final VoidCallback onCreate;
  final GlobalKey fabKey;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  int _index = 0;
  int _previous = 0;
  late final AnimationController _swap;

  @override
  void initState() {
    super.initState();
    _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 620), value: 1);
  }

  @override
  void dispose() {
    _swap.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _previous = _index;
      _index = i;
    });
    _swap.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final label = inter(11.4, 500, color: const Color(0xFF8A93A7));
    return SizedBox(
      width: Frame.width,
      height: frame.height - NavBar.topIn(frame) + 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 30,
            bottom: 0,
            child: Staged(
              animation: widget.entrance,
              begin: 0.15,
              end: 0.6,
              offset: const Offset(0, 40),
              child: CustomPaint(painter: _Bar()),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 30,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _swap,
              builder: (context, _) => CustomPaint(
                painter: _Glint(
                  from: navItems[_previous].x,
                  to: navItems[_index].x,
                  t: gentle.transform(_swap.value),
                ),
              ),
            ),
          ),
          for (final (i, item) in navItems.indexed)
            Positioned(
              left: item.x - 36,
              top: 30,
              width: 72,
              height: NavBar.content,
              child: Staged(
                animation: widget.entrance,
                begin: 0.25 + i * 0.06,
                end: 0.7 + i * 0.06,
                offset: const Offset(0, 24),
                curve: settle,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _select(i),
                  child: AnimatedBuilder(
                    animation: _swap,
                    builder: (context, _) {
                      final on = i == _index ? gentle.transform(_swap.value) : (i == _previous ? 1 - gentle.transform(_swap.value) : 0.0);
                      final pop = i == _index ? math.sin(_swap.value * math.pi) * 0.18 : 0.0;
                      return _Item(item: item, on: on, pop: pop, style: label);
                    },
                  ),
                ),
              ),
            ),
          Positioned(
            left: 197.5 - 34,
            top: 878.7 - NavBar.top + 30 - 34,
            width: 68,
            height: 68,
            child: AnimatedBuilder(
              animation: widget.entrance,
              builder: (context, child) {
                final t = span(widget.entrance.value, 0.3, 0.85, Curves.linear);
                final s = spring(t, bounce: 0.35, freq: 2.4);
                return Opacity(
                  opacity: span(widget.entrance.value, 0.3, 0.45, Curves.linear),
                  child: Transform.rotate(angle: (1 - s) * -math.pi, child: Transform.scale(scale: s, child: child)),
                );
              },
              child: _Fab(key: widget.fabKey, onTap: widget.onCreate),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.on, required this.pop, required this.style});

  final NavItem item;
  final double on;
  final double pop;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final idle = const Color(0xFF8A93A7);
    const lit = [Color(0xFFB98CFF), Color(0xFFEE8BD6)];
    Widget tint(Widget child) => ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(idle, lit[0], on)!, Color.lerp(idle, lit[1], on)!],
          ).createShader(r),
          child: child,
        );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 36 - 13,
          top: 887 - NavBar.top - 13,
          child: Transform.scale(
            scale: 1 + pop,
            child: Transform.translate(
              offset: Offset(0, -3 * pop / 0.18 * 0.6),
              child: Container(
                decoration: on > 0.01
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color.fromRGBO(170, 110, 255, 0.45 * on), blurRadius: 14)],
                      )
                    : null,
                child: tint(PhIcon(item.icon, size: 26)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 904 - NavBar.top - capInset(style),
          child: tint(Text(item.label, style: style, textAlign: TextAlign.center)),
        ),
      ],
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Tick(
        builder: (context, s, child) => CustomPaint(
          painter: _FabGlow(seconds: s),
          child: child,
        ),
        child: Center(
          child: Container(
            width: 52.4,
            height: 52.4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment(-0.9, 0.7),
                end: Alignment(0.9, -0.7),
                colors: [Color(0xFF7437F6), Color(0xFF9A48F4), Color(0xFFD86BC4), Color(0xFFF77AA3)],
                stops: [0.0, 0.35, 0.72, 1.0],
              ),
            ),
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(0, -0.85),
                radius: 0.9,
                colors: [Colors.white.withValues(alpha: 0.38), Colors.white.withValues(alpha: 0)],
              ),
            ),
            child: const Center(child: PhIcon(Ph.plus, size: 25)),
          ),
        ),
      ),
    );
  }
}

class _FabGlow extends CustomPainter {
  _FabGlow({required this.seconds});

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final b = 0.5 + 0.5 * wave(seconds, 2.6);
    canvas.drawCircle(
      c,
      27 + 2 * b,
      Paint()
        ..color = Color.fromRGBO(176, 84, 255, 0.34 + 0.16 * b)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + 4 * b),
    );
    final rect = Rect.fromCircle(center: c, radius: 29.5);
    canvas.drawCircle(
      c,
      29.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..shader = SweepGradient(
          colors: const [Color(0x00FFFFFF), Color(0x66F3B8FF), Color(0x00FFFFFF), Color(0x00FFFFFF)],
          stops: const [0.0, 0.18, 0.36, 1.0],
          transform: GradientRotation(seconds * 1.4),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_FabGlow old) => old.seconds != seconds;
}

class _Bar extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000B1A), Color(0xFF000A18)],
        ).createShader(rect),
    );
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, 0),
      Paint()
        ..strokeWidth = 1
        ..shader = const LinearGradient(
          colors: [Color(0x000B1426), Color(0xFF142038), Color(0xFF142038), Color(0x000B1426)],
          stops: [0.0, 0.2, 0.8, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_Bar old) => false;
}

class _Glint extends CustomPainter {
  _Glint({required this.from, required this.to, required this.t});

  final double from;
  final double to;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final x = lerp(from, to, t);
    final stretch = 1 + math.sin(t * math.pi) * 0.9;
    final w = 26.0 * stretch;
    final rect = Rect.fromCenter(center: Offset(x, 0.6), width: w, height: 2.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFFB98CFF), Color(0xFFEE8BD6)]).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(5)),
      Paint()
        ..color = const Color(0x66B98CFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_Glint old) => old.t != t || old.to != to || old.from != from;
}
