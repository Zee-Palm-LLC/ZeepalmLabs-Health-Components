import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/art.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/fx.dart';

class Racer {
  const Racer(this.name, this.score, this.fill, this.color, this.rankColor);

  final String name;
  final int score;
  final double fill;
  final Color color;
  final Color rankColor;
}

class Friend {
  const Friend(
    this.name,
    this.sprite,
    this.avatar,
    this.pill,
    this.text,
    this.tail,
  );

  final String name;
  final Sprite sprite;
  final Box avatar;
  final Box pill;
  final Offset text;
  final Offset tail;
}

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<RaceScreen> createState() => RaceScreenState();
}

class RaceScreenState extends State<RaceScreen> with TickerProviderStateMixin {
  static const racers = [
    Racer('You', 2480, 0.75, Color(0xFFFFD34A), Color(0xFFFFD34A)),
    Racer('Luna', 2120, 0.62, Color(0xFFC07CFF), Color(0xFFC9A2FF)),
    Racer('Zane', 1960, 0.56, Color(0xFF5BCB6E), Color(0xFFC9A2FF)),
    Racer('Maya', 1740, 0.44, Color(0xFFFF9C74), Color(0xFFFFD991)),
  ];

  static const friends = [
    Friend(
      'Luna',
      Art.luna,
      Box.circle(52, 95.7, 16.5),
      Box(35, 80, 121.7, 111.7),
      Offset(76.6, 98.2),
      Offset(93, 112),
    ),
    Friend(
      'Zane',
      Art.zane,
      Box.circle(296.7, 133, 16.5),
      Box(280, 117, 365, 149),
      Offset(320.8, 134.3),
      Offset(330, 149),
    ),
    Friend(
      'Kai',
      Art.kai,
      Box.circle(46, 441, 16.5),
      Box(29, 425, 105, 457),
      Offset(70, 442.6),
      Offset(80, 457),
    ),
    Friend(
      'Maya',
      Art.maya,
      Box.circle(320, 415, 15.5),
      Box(304, 399, 383, 431),
      Offset(342.2, 419.5),
      Offset(352, 431),
    ),
  ];

  late final AnimationController _intro;
  late final AnimationController _rocket;
  late final AnimationController _gear;
  int _target = 0;
  int _sent = -1;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
    _rocket = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _gear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _rocket.dispose();
    _gear.dispose();
    super.dispose();
  }

  Future<void> challenge() async {
    if (_rocket.isAnimating) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _target = (_target + 1) % friends.length;
      _sent = -1;
    });
    await _rocket.forward(from: 0).orCancel.catchError((_) {});
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() => _sent = _target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tone.space,
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _rocket, _gear]),
        builder: (context, _) {
          final i = _intro.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Plate('race'),
              const Sparkles(
                area: Rect.fromLTRB(8, 50, 394, 860),
                count: 40,
                seed: 12,
                opacity: 0.9,
                big: 0.3,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Tick(
                    builder: (context, t, _) =>
                        CustomPaint(painter: _Comets(t)),
                  ),
                ),
              ),
              for (final (k, f) in friends.indexed)
                _planet(f.sprite, i, 0.05 + k * 0.08, k),
              _planet(Art.you, i, 0.0, 9, hero: true),
              for (final (k, f) in friends.indexed)
                _tag(f, i, 0.35 + k * 0.06, k),
              _you(i),
              _rocketLayer(),
              _board(i),
              Positioned(
                left: 351,
                top: 56,
                child: Pressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _gear.forward(from: 0);
                  },
                  child: Opacity(
                    opacity: span(i, 0.2, 0.5),
                    child: Transform.rotate(
                      angle:
                          Curves.easeOutBack.transform(_gear.value) *
                          math.pi /
                          3,
                      child: const PhIcon(
                        Ph.gear,
                        size: 30,
                        shadows: [
                          Shadow(color: Color(0x88A79BFF), blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 50,
                child: Pressable(
                  onTap: widget.onBack,
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(child: PhIcon(Ph.caretLeft, size: 18)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _planet(
    Sprite sprite,
    double i,
    double delay,
    int k, {
    bool hero = false,
  }) {
    final t = span(i, delay, delay + 0.45, Curves.linear);
    final s = spring(t, bounce: 0.35, freq: 1.8);
    final hit = _sent >= 0 && !hero && friends[_sent].sprite == sprite;
    return Place(
      sprite,
      child: Opacity(
        opacity: span(t, 0, 0.3, Curves.linear),
        child: Transform.scale(
          scale: lerp(0.3, 1, s) * (hit ? 1.06 : 1),
          child: Float(
            dy: hero ? 5 : 4,
            dx: hero ? 0 : 2,
            period: 3 + k * 0.37,
            phase: k * 0.11,
            tilt: hero ? 0.0 : 0.03,
            child: sprite.image(),
          ),
        ),
      ),
    );
  }

  Widget _tag(Friend f, double i, double delay, int k) {
    final t = span(i, delay, delay + 0.35, Curves.linear);
    final s = spring(t, bounce: 0.45, freq: 2.2);
    final hit = _sent == k;
    final p = f.pill;
    return Positioned(
      left: f.avatar.l - 4,
      top: p.t - 8,
      width: p.r - f.avatar.l + 8,
      height: f.tail.dy - p.t + 16,
      child: Opacity(
        opacity: span(t, 0, 0.3, Curves.linear),
        child: Transform.scale(
          scale: lerp(0.4, 1, s),
          alignment: Alignment.bottomCenter,
          child: Float(
            dy: 2.5,
            period: 2.6 + k * 0.3,
            phase: k * 0.2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: p.l - f.avatar.l + 4,
                  top: 8,
                  width: p.w,
                  height: p.h + (f.tail.dy - p.b) + 6,
                  child: CustomPaint(
                    painter: _NamePainter(
                      f.tail.dx - p.l,
                      p.h,
                      hit ? const Color(0xFFFFD86A) : const Color(0x80D9D2FF),
                    ),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: f.avatar.t - p.t + 8,
                  width: f.avatar.w,
                  height: f.avatar.h,
                  child: Image.asset(
                    'assets/art/${Art.tagAvatars[f.name]}.webp',
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                Positioned(
                  left: f.text.dx - f.avatar.l + 4,
                  top: f.text.dy - p.t + 8 - 14.9 * balooAscent,
                  child: Label(f.name, style: baloo(14.9)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _you(double i) {
    final t = span(i, 0.3, 0.65, Curves.linear);
    final s = spring(t, bounce: 0.5, freq: 2.4);
    return Stack(
      children: [
        Place(
          Art.crown,
          child: Opacity(
            opacity: span(t, 0.2, 0.5, Curves.linear),
            child: Transform.translate(
              offset: Offset(0, -30 * (1 - s)),
              child: Tick(
                builder: (context, sec, child) => Transform.rotate(
                  angle: 0.08 * wave(sec, 1.9),
                  child: child,
                ),
                child: Art.crown.image(),
              ),
            ),
          ),
        ),
        Positioned(
          left: 161.7,
          top: 225,
          width: 70,
          height: 44,
          child: Opacity(
            opacity: span(t, 0, 0.3, Curves.linear),
            child: Transform.scale(
              scale: lerp(0.4, 1, s),
              child: Tick(
                builder: (context, sec, _) => CustomPaint(
                  painter: _NamePainter(
                    34.5,
                    35,
                    Color.lerp(
                      const Color(0xFFFFB84A),
                      const Color(0xFFFFE08A),
                      0.5 + 0.5 * wave(sec, 1.6),
                    )!,
                    glow: true,
                  ),
                  child: Align(
                    alignment: const Alignment(0, -0.62),
                    child: Label(
                      'You',
                      style: baloo(20.7, color: const Color(0xFFFFF2D6)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rocketLayer() {
    final r = _rocket.value;
    if (r <= 0 || r >= 1) {
      if (_sent < 0) return const SizedBox.shrink();
    }
    final from = Art.you.box.center + const Offset(0, -10);
    final to = friends[_target].sprite.box.center;
    final e = Curves.easeInOutCubic.transform(r);
    final ctrl = Offset((from.dx + to.dx) / 2, math.min(from.dy, to.dy) - 120);
    Offset bez(double u) => Offset(
      (1 - u) * (1 - u) * from.dx + 2 * (1 - u) * u * ctrl.dx + u * u * to.dx,
      (1 - u) * (1 - u) * from.dy + 2 * (1 - u) * u * ctrl.dy + u * u * to.dy,
    );
    final p = bez(e);
    final ahead = bez(math.min(1, e + 0.02));
    final angle = math.atan2(ahead.dy - p.dy, ahead.dx - p.dx) + math.pi / 4;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _Trail(bez, e, r))),
        ),
        if (r > 0 && r < 1)
          Positioned(
            left: p.dx - 20,
            top: p.dy - 20,
            width: 40,
            height: 40,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: angle - math.pi / 4 + 0.6,
                child: ClipOval(
                  child: Image.asset(Art.rocket.asset, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        Burst(
          t: span(r, 0.85, 1, Curves.linear) < 1
              ? span(r, 0.85, 1, Curves.linear)
              : 0,
          center: to,
          color: const Color(0xFFFFD86A),
          radius: 70,
          count: 22,
          seed: 7,
        ),
        if (_sent >= 0) _sentToast(),
      ],
    );
  }

  Widget _sentToast() {
    return Positioned(
      left: 0,
      right: 0,
      top: 520,
      child: IgnorePointer(
        child: Entrance(
          key: ValueKey(_sent),
          duration: const Duration(milliseconds: 2400),
          builder: (context, a) => AnimatedBuilder(
            animation: a,
            builder: (context, _) {
              final v = a.value;
              return Opacity(
                opacity:
                    span(v, 0, 0.1, Curves.linear) *
                    (1 - span(v, 0.8, 1, Curves.linear)),
                child: Transform.translate(
                  offset: Offset(
                    0,
                    12 * (1 - spring(span(v, 0, 0.3, Curves.linear))),
                  ),
                  child: Center(
                    child: GlassPill(
                      width: 230,
                      height: 40,
                      rim: const Color(0xCCFFD06A),
                      child: Center(
                        child: Label(
                          'Challenge sent to ${friends[_sent].name}!',
                          style: baloo(15, color: const Color(0xFFFFE7A6)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _board(double i) {
    final t = span(i, 0.2, 0.6, Curves.linear);
    final s = spring(t, bounce: 0.22, freq: 1.7);
    return Positioned.fill(
      child: Opacity(
        opacity: span(t, 0, 0.3, Curves.linear),
        child: Transform.translate(
          offset: Offset(0, 260 * (1 - s)),
          child: Stack(
            children: [
              const Positioned(
                left: 15,
                top: 567,
                width: 375,
                height: 256,
                child: CustomPaint(painter: _PanelPainter()),
              ),
              const Place(Art.trophy),
              At(
                baseline: 597,
                size: 19.5,
                left: 134.8,
                child: Label('Weekly Orbit Race', style: baloo(19.5)),
              ),
              Positioned(
                left: 23,
                right: 32,
                top: 616.2,
                height: 1,
                child: ColoredBox(color: Colors.white.withValues(alpha: 0.12)),
              ),
              for (final (k, r) in racers.indexed)
                ..._row(
                  k,
                  r,
                  span(i, 0.4 + k * 0.08, 0.8 + k * 0.05, Curves.linear),
                ),
              Positioned(
                left: 65,
                top: 792.3,
                child: GoldButton(
                  width: 277,
                  height: 47,
                  size: 17.9,
                  label: 'Challenge a friend',
                  onTap: challenge,
                  leading: const PhIcon(
                    Ph.users,
                    size: 25,
                    color: Color(0xFF6E5FD8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _row(int k, Racer r, double t) {
    final cy = 640.0 + 39.4 * k;
    final nameBase = 635.7 + 39.6 * k;
    final scoreBase = 649.1 + 39.7 * k;
    final barY = nameBase + 9.3;
    final fill = Curves.easeOutCubic.transform(t);
    final rank = '${k + 1}';
    return [
      At(
        baseline: cy + 8.5,
        size: 25,
        center: 46.7,
        child: Opacity(
          opacity: span(t, 0, 0.3, Curves.linear),
          child: Label(
            rank,
            style: baloo(
              25,
              weight: 800,
              color: r.rankColor,
              shadows: [
                Shadow(
                  color: r.rankColor.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        left: 87 - 16.5,
        top: cy - 16.5,
        width: 33,
        height: 33,
        child: Opacity(
          opacity: span(t, 0, 0.3, Curves.linear),
          child: Transform.scale(
            scale: spring(t, bounce: 0.4, freq: 2),
            child: Image.asset(
              'assets/art/${Art.avatars[r.name]}.webp',
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
      At(
        baseline: nameBase,
        size: 13.9,
        left: 120.2,
        child: Opacity(
          opacity: span(t, 0.1, 0.4, Curves.linear),
          child: Label(r.name, style: baloo(13.9)),
        ),
      ),
      Positioned(
        left: 119,
        top: barY,
        width: 186,
        height: 10,
        child: CustomPaint(painter: _BarPainter(r.fill * fill, r.color)),
      ),
      At(
        baseline: scoreBase,
        size: 14,
        right: 349.3,
        child: CountUp(value: r.score, t: t, style: baloo(14)),
      ),
      Positioned(
        left: 352,
        top: scoreBase - 15.5,
        width: 23,
        height: 23,
        child: Transform.scale(
          scale: spring(span(t, 0.5, 1, Curves.linear), bounce: 0.5, freq: 2.4),
          child: Art.star.image(),
        ),
      ),
    ];
  }
}

class _PanelPainter extends CustomPainter {
  const _PanelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const tabL = 62.0;
    const tabR = 305.0;
    const tabTop = 0.0;
    const body = 33.0;
    const r = 28.0;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, body + r)
      ..quadraticBezierTo(0, body, r, body)
      ..lineTo(tabL - 18, body)
      ..quadraticBezierTo(tabL, body, tabL + 2, body - 14)
      ..quadraticBezierTo(tabL + 4, tabTop, tabL + 24, tabTop)
      ..lineTo(tabR - 24, tabTop)
      ..quadraticBezierTo(tabR - 4, tabTop, tabR - 2, body - 14)
      ..quadraticBezierTo(tabR, body, tabR + 18, body)
      ..lineTo(w - r, body)
      ..quadraticBezierTo(w, body, w, body + r)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..close();
    canvas.drawPath(
      path.shift(const Offset(0, 8)),
      Paint()
        ..color = const Color(0x660C0830)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF2433A9E), Color(0xF22E2780), Color(0xF2272170)],
          stops: [0, 0.4, 1],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFE2D6FF).withValues(alpha: 0.85),
            const Color(0xFFB7A6FF).withValues(alpha: 0.35),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_PanelPainter old) => false;
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.fill, this.color);

  final double fill;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, r),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    final w = size.width * fill;
    if (w <= 0) return;
    final bar = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, size.height), r);
    canvas.drawRRect(
      bar,
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(
      bar,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, Colors.white, 0.35)!, color],
        ).createShader(Rect.fromLTWH(0, 0, w, size.height)),
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.fill != fill || old.color != color;
}

class _NamePainter extends CustomPainter {
  _NamePainter(this.tailX, this.bodyH, this.rim, {this.glow = false});

  final double tailX;
  final double bodyH;
  final Color rim;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, bodyH),
      Radius.circular(bodyH / 2),
    );
    final tail = Path()
      ..moveTo(tailX - 6, bodyH - 1)
      ..lineTo(tailX, bodyH + 7)
      ..lineTo(tailX + 6, bodyH - 1)
      ..close();
    final path = Path()
      ..addRRect(body)
      ..addPath(tail, Offset.zero);
    if (glow) {
      canvas.drawRRect(
        body,
        Paint()
          ..color = rim.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawPath(path, Paint()..color = const Color(0xE6221C5E));
    canvas.drawRRect(
      body.deflate(0.8),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = glow ? 2.2 : 1.3
        ..color = rim,
    );
  }

  @override
  bool shouldRepaint(_NamePainter old) => old.rim != rim;
}

class _Trail extends CustomPainter {
  _Trail(this.bez, this.e, this.r);

  final Offset Function(double) bez;
  final double e;
  final double r;

  @override
  void paint(Canvas canvas, Size size) {
    if (r <= 0 || r >= 1) return;
    for (var k = 0; k < 24; k++) {
      final u = e - k * 0.012;
      if (u <= 0) break;
      final p = bez(u);
      final a = (1 - k / 24) * (1 - span(r, 0.85, 1, Curves.linear));
      canvas.drawCircle(
        p,
        6 * (1 - k / 24) + 1,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFFFE08A),
            const Color(0xFFFF6FCF),
            k / 24,
          )!.withValues(alpha: a * 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_Trail old) => old.e != e || old.r != r;
}

class _Comets extends CustomPainter {
  _Comets(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const comets = [
      (Offset(-40, 330), Offset(140, 210), 5.5, 0.0),
      (Offset(420, 270), Offset(250, 380), 7.0, 0.4),
      (Offset(300, 40), Offset(130, 140), 6.2, 0.7),
    ];
    for (final (from, to, period, phase) in comets) {
      final life = ((t / period + phase) % 1.0) / 0.22;
      if (life > 1) continue;
      final head = Offset.lerp(from, to, life)!;
      final tail = Offset.lerp(from, to, math.max(0, life - 0.35))!;
      final a = math.sin(life * math.pi);
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            colors: [
              const Color(0x00FFE7B0),
              const Color(0xFFFFE7B0).withValues(alpha: a),
            ],
          ).createShader(Rect.fromPoints(tail, head)),
      );
      canvas.drawCircle(
        head,
        3.2,
        Paint()
          ..color = Colors.white.withValues(alpha: a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_Comets old) => old.t != t;
}
