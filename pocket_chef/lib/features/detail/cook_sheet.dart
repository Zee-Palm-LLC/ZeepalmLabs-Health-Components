import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';

const _steps = [
  ('Boil the pasta', 'Cook 200 g pasta in salted water until al dente.', 9),
  ('Warm the garlic', 'Soften 2 cloves of garlic in olive oil over low heat.', 2),
  ('Make it creamy', 'Stir in the cream and parmesan until silky.', 4),
  ('Toss and serve', 'Fold the pasta through the sauce and plate it up.', 1),
];

Future<void> showCookSheet(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x66160A10),
    transitionDuration: const Duration(milliseconds: 620),
    pageBuilder: (context, a, b) => const _CookSheet(),
    transitionBuilder: (context, a, b, child) {
      final t = CurvedAnimation(parent: a, curve: const Cubic(0.2, 1.15, 0.3, 1), reverseCurve: Curves.easeInCubic);
      return AnimatedBuilder(
        animation: t,
        builder: (context, child) => Transform.translate(offset: Offset(0, 520 * (1 - t.value)), child: child),
        child: child,
      );
    },
  );
}

class _CookSheet extends StatefulWidget {
  const _CookSheet();

  @override
  State<_CookSheet> createState() => _CookSheetState();
}

class _CookSheetState extends State<_CookSheet> with SingleTickerProviderStateMixin {
  int _step = 0;
  late final AnimationController _ring;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_step == _steps.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step++);
    _ring.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final (title, body, minutes) = _steps[_step];
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: Frame.width,
          padding: EdgeInsets.fromLTRB(24, 14, 24, frame.bottom + 18),
          decoration: const BoxDecoration(
            color: Palette.paper,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(0, -6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(color: const Color(0xFFE4DDD7), borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: AnimatedBuilder(
                      animation: _ring,
                      builder: (context, _) => CustomPaint(
                        painter: _RingPainter((_step + Curves.easeOutCubic.transform(_ring.value)) / _steps.length),
                        child: Center(
                          child: Text('${_step + 1}/${_steps.length}', style: inter(17, 700, color: Palette.ink)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                          position: Tween(begin: const Offset(0.2, 0), end: Offset.zero).animate(a),
                          child: child,
                        ),
                      ),
                      child: Column(
                        key: ValueKey(_step),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: inter(20, 700, color: Palette.ink)),
                          const SizedBox(height: 6),
                          Text(body, style: inter(14, 400, color: Palette.mute, height: 1.35)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const PhIcon(Ph.timer, size: 16, color: Palette.tomato),
                              const SizedBox(width: 6),
                              Text('$minutes min', style: inter(13, 600, color: Palette.tomato)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Tick(
                      builder: (context, s, child) => Transform.translate(offset: Offset(0, 3 * wave(s, 1.4)), child: child),
                      child: ClipOval(child: Image.asset(Art.homeAvatar.asset, fit: BoxFit.cover)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Pressable(
                      onTap: _next,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(27),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFD2F4C), Color(0xFFF7162F)],
                          ),
                          boxShadow: [BoxShadow(color: Palette.tomato.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
                        ),
                        child: Center(
                          child: Text(
                            _step == _steps.length - 1 ? 'Enjoy your meal!' : 'Next step',
                            style: inter(16.5, 700, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(5);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = const Color(0xFFF3E9E4),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [Color(0xFFFF6A7E), Palette.tomato, Color(0xFFFF6A7E)],
          stops: [0.0, 0.5, 1.0],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
