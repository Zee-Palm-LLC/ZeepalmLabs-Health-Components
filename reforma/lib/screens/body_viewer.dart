import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../icons.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../widgets/motion.dart';
import '../three/face.dart';
import '../three/figure.dart';
import '../three/figures.dart';
import '../three/renderer.dart';
import '../three/vec.dart';

/// A pain marker pinned to the body surface.
class _Marker {
  _Marker(this.label, this.region, this.p, this.n, {required this.pillLeft, required this.gap});

  final String label;
  final int region;
  V3 p, n;
  final bool pillLeft; // pill sits left of the hotspot
  final double gap;
  Offset pill = Offset.zero; // smoothed pill anchor (screen)
  bool placed = false;
}

class _Frame extends ChangeNotifier {
  void tick() => notifyListeners();
}

/// Damped spring integrated per frame (semi-implicit Euler).
class _Spring {
  _Spring(this.x, {this.k = 140, this.zeta = 0.7});

  double x, v = 0, target = 0;
  final double k, zeta;

  void step(double dt) {
    final c = 2 * math.sqrt(k) * zeta;
    v += (-k * (x - target) - c * v) * dt;
    x += v * dt;
  }
}

class BodyViewer extends StatefulWidget {
  const BodyViewer({super.key});

  static const size = Size(390, 424);

  @override
  State<BodyViewer> createState() => _BodyViewerState();
}

class _BodyViewerState extends State<BodyViewer> with SingleTickerProviderStateMixin {
  final view = BodyView(Figures.body);
  final frame = _Frame();
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;

  // Rotation state.
  double time = 0, yaw = 0, yawVel = 0, idle = 0;
  final pitch = _Spring(0, k: 90, zeta: 0.8);
  final enter = _Spring(stillMode ? 1 : 0, k: 46, zeta: 0.58)..target = 1;
  bool dragging = false;

  // Selection state.
  int selRegion = Region.of(Region.shoulder, 1);
  V3 selP = const V3(17.6, 137.2, 3.6), selN = const V3(0.55, 0.45, 0.7);
  V3 prevP = const V3(17.6, 137.2, 3.6), prevN = const V3(0.55, 0.45, 0.7);
  final morph = _Spring(1, k: 150, zeta: 0.62)..target = 1;
  final tint = _Spring(1, k: 60, zeta: 1)..target = 1;
  String selName = 'Shoulder', prevName = 'Shoulder';
  Offset? card;
  Offset? ripple;
  double rippleT = 1;
  bool snapped = false;

  final markers = [
    _Marker('Neck', Region.of(Region.neck, 0), const V3(-5.6, 145.5, 3.2), const V3(-0.5, 0.3, 0.8),
        pillLeft: true, gap: 56),
    _Marker('Knee', Region.of(Region.knee, 1), const V3(7.4, 47.5, 6.0), const V3(0.1, 0, 1), pillLeft: false, gap: 57),
  ];

  static const origin = Offset(195, 213);
  static const pivot = V3(0, 85, 0);
  static const scale = 2.36;

  @override
  void initState() {
    super.initState();
    _render();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    frame.dispose();
    super.dispose();
  }

  double get _sway {
    final a = ((idle - 1.5) / 2.5).clamp(0.0, 1.0);
    return a * a * (3 - 2 * a) * 0.13 * math.sin(time * 0.55);
  }

  double get _yawShown => yaw + _sway - (1 - enter.x) * 1.25;

  void _render() {
    final e = enter.x;
    view.update(
      yaw: _yawShown,
      pitch: pitch.x + 0.03,
      scale: scale * (0.9 + 0.1 * e),
      origin: origin + Offset(0, (1 - e) * 10),
      pivot: pivot,
      breath: math.sin(time * math.pi * 2 / 4.6),
      spot: V3.lerp(prevP, selP, morph.x),
      spotAmt: tint.x.clamp(0.0, 1.0),
    );
    if (!snapped) {
      // Snap the authored anchors onto the actual surface.
      snapped = true;
      for (final m in markers) {
        final h = view.hitTest(view.project(m.p).$1);
        if (h != null) {
          m.p = h.point;
          m.n = h.normal;
        }
      }
      final h = view.hitTest(view.project(selP).$1);
      if (h != null) {
        selP = prevP = h.point;
        selN = prevN = h.normal;
      }
    }
  }

  void _tick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = now;
    time += dt;
    if (!dragging) {
      idle += dt;
      yaw += yawVel * dt;
      yawVel *= math.exp(-dt * 2.4); // friction
      if (yawVel.abs() > 0.05) idle = 0;
    }
    pitch.step(dt);
    enter.step(dt);
    morph.step(dt);
    tint.step(dt);
    if (rippleT < 1) rippleT = math.min(1, rippleT + dt / 0.65);
    _render();
    frame.tick();
  }

  void _onPanStart(DragStartDetails d) {
    yaw += _sway;
    idle = 0;
    dragging = true;
    yawVel = 0;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    yaw += d.delta.dx * 0.0125;
    pitch.x = (pitch.x + d.delta.dy * 0.004).clamp(-0.28, 0.28);
    pitch.v = 0;
  }

  void _onPanEnd(DragEndDetails d) {
    dragging = false;
    yawVel = (d.velocity.pixelsPerSecond.dx * 0.0125).clamp(-14.0, 14.0);
    pitch.v = d.velocity.pixelsPerSecond.dy * 0.002;
  }

  void _onTap(TapUpDetails d) {
    final h = view.hitTest(d.localPosition);
    ripple = d.localPosition;
    rippleT = 0;
    if (h == null) return;
    HapticFeedback.selectionClick();
    final t = morph.x.clamp(0.0, 1.0);
    prevP = V3.lerp(prevP, selP, t);
    prevN = V3.lerp(prevN, selN, t).norm;
    selP = h.point;
    selN = h.normal;
    prevName = selName;
    selName = Region.name(h.region);
    tint.x = 0.35;
    selRegion = h.region;
    morph
      ..x = 0
      ..v = 0;
    idle = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTapUp: _onTap,
      child: RepaintBoundary(
        child: CustomPaint(size: BodyViewer.size, painter: _BodyPainter(this)),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter(this.s) : super(repaint: s.frame);

  final _BodyViewerState s;

  static final _texts = <String, TextPainter>{};
  static TextPainter _t(String text, TextStyle style) => _texts.putIfAbsent(
        '$text|${style.fontSize}|${style.fontWeight}|${style.color}',
        () => TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout(),
      );
  static final _icon = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(PhFill.personArmsSpread.codePoint),
      style: TextStyle(
        fontFamily: PhFill.personArmsSpread.fontFamily,
        package: PhFill.personArmsSpread.fontPackage,
        fontSize: 13,
        color: Colors.white,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  static final _shadow = Paint()
    ..color = const Color(0x1A3B2A55)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

  @override
  void paint(Canvas canvas, Size size) {
    final e = s.enter.x.clamp(0.0, 1.2);
    final v = s.view;

    // Halo disc behind the figure.
    const hc = Offset(195, 236);
    final hr = 172.0 * (0.85 + 0.15 * e.clamp(0, 1));
    canvas.drawCircle(
      hc,
      hr,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFEDE5FA).withValues(alpha: 0.95 * e.clamp(0, 1)),
            const Color(0xFFF1EAF8).withValues(alpha: 0.7 * e.clamp(0, 1)),
            const Color(0x00F4EEF6),
          ],
          stops: const [0, 0.82, 1],
        ).createShader(Rect.fromCircle(center: hc, radius: hr)),
    );

    // Contact shadow.
    final (foot, _) = v.project(const V3(0, 0, 2));
    canvas.drawOval(
      Rect.fromCenter(center: foot + const Offset(0, 2), width: 92, height: 14),
      Paint()
        ..color = const Color(0x2E2A2140)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    v.draw(canvas);
    drawFace(canvas, v, Pose.standing);

    // Pain markers (orange) with pills that trail the hotspot.
    for (final m in s.markers) {
      if (m.region == s.selRegion) continue;
      final (hp, facing) = v.project(m.p, m.n);
      final a = ((facing + 0.25) / 0.45).clamp(0.0, 1.0) * e.clamp(0, 1);
      if (a <= 0.01) continue;
      final pulse = 0.5 + 0.5 * math.sin(s.time * 3.2 + m.gap);
      canvas.drawCircle(
        hp,
        13 + 3 * pulse,
        Paint()
          ..shader = RadialGradient(colors: [
            C.orange.withValues(alpha: 0.55 * a),
            C.orange.withValues(alpha: 0.0),
          ]).createShader(Rect.fromCircle(center: hp, radius: 16 + 3 * pulse)),
      );
      canvas.drawCircle(hp, 3.2, Paint()..color = C.orange.withValues(alpha: a));

      final label = _t(m.label, inter(12.5, FontWeight.w500, C.ink));
      final pw = label.width + 30;
      final target = m.pillLeft ? hp + Offset(-m.gap - pw, -1) : hp + Offset(m.gap, -1);
      if (!m.placed) {
        m.pill = target;
        m.placed = true;
      } else {
        m.pill = Offset.lerp(m.pill, target, 0.16)!;
      }
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(m.pill.dx, m.pill.dy - 14, pw, 28), const Radius.circular(14));
      final dot = m.pillLeft ? Offset(r.right - 9, m.pill.dy) : Offset(r.left - 0.5, m.pill.dy);
      canvas.drawLine(
        m.pillLeft ? Offset(r.right, m.pill.dy) : Offset(r.left, m.pill.dy),
        hp,
        Paint()
          ..color = C.orange.withValues(alpha: 0.45 * a)
          ..strokeWidth = 1,
      );
      canvas.saveLayer(r.outerRect.inflate(16), Paint()..color = Color.fromRGBO(0, 0, 0, a));
      canvas.drawRRect(r.shift(const Offset(0, 3)), _shadow);
      canvas.drawRRect(r, Paint()..color = Colors.white);
      label.paint(canvas, Offset(r.left + (m.pillLeft ? 12 : 16), m.pill.dy - label.height / 2));
      canvas.drawCircle(dot, 3, Paint()..color = C.orange);
      canvas.restore();
    }

    // Selected hotspot: morphs along the surface toward the new pick.
    final t = s.morph.x;
    final sp = V3.lerp(s.prevP, s.selP, t);
    final sn = V3.lerp(s.prevN, s.selN, t.clamp(0, 1)).norm;
    final (hp, facing) = v.project(sp, sn);
    final a = ((facing + 0.3) / 0.45).clamp(0.0, 1.0) * e.clamp(0, 1);
    if (a > 0.01) {
      final breathe = 0.5 + 0.5 * math.sin(s.time * 2.2);
      final gr = 36 + 6 * breathe;
      canvas.drawCircle(
        hp,
        gr,
        Paint()
          ..shader = RadialGradient(colors: [
            C.lav.withValues(alpha: 0.55 * a),
            C.lav.withValues(alpha: 0.18 * a),
            C.lav.withValues(alpha: 0),
          ], stops: const [0, 0.55, 1])
              .createShader(Rect.fromCircle(center: hp, radius: gr)),
      );
      // expanding pulse ring
      final pr = (s.time % 1.8) / 1.8;
      canvas.drawCircle(
        hp,
        6 + 22 * Curves.easeOut.transform(pr),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = C.lavDeep.withValues(alpha: (1 - pr) * 0.6 * a),
      );
      canvas.drawCircle(hp, 5.5, Paint()..color = Colors.white.withValues(alpha: a));
      canvas.drawCircle(hp, 3.8, Paint()..color = C.lavDeep.withValues(alpha: a));

      // Callout card.
      final title = _t(s.selName, inter(12.5, FontWeight.w600, C.ink));
      final old = _t(s.prevName, inter(12.5, FontWeight.w600, C.ink));
      final sub = _t('Selected', inter(10, FontWeight.w400, C.muted));
      final double cw = math.max(106.0, 46 + math.max(title.width, sub.width) + 14);
      const ch = 50.0;
      final right = hp.dx >= 195;
      var target = right ? Offset(hp.dx + 28, hp.dy - 69) : Offset(hp.dx - 28 - cw, hp.dy - 69);
      if (target.dy < 4) target = Offset(target.dx, hp.dy + 30);
      target = Offset(target.dx.clamp(6.0, size.width - cw - 6), target.dy.clamp(4.0, size.height - ch - 4));
      s.card = s.card == null ? target : Offset.lerp(s.card, target, 0.14);
      final c = s.card!;
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(c.dx, c.dy, cw, ch), const Radius.circular(14));
      final anchor = Offset(c.dx < hp.dx ? r.left + 6 : r.right - 6, r.bottom - 4);
      canvas.drawLine(
        anchor,
        hp,
        Paint()
          ..color = C.lavDeep.withValues(alpha: 0.55 * a)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(anchor, 2.2, Paint()..color = C.lavDeep.withValues(alpha: 0.8 * a));
      canvas.saveLayer(r.outerRect.inflate(18), Paint()..color = Color.fromRGBO(0, 0, 0, a));
      canvas.drawRRect(r.shift(const Offset(0, 4)), _shadow);
      canvas.drawRRect(r, Paint()..color = const Color(0xF7FFFFFF));
      final ic = Offset(r.left + 22, r.top + 25);
      canvas.drawCircle(
        ic,
        11,
        Paint()
          ..shader = const LinearGradient(colors: [Color(0xFFC1AEF5), C.lavDeep])
              .createShader(Rect.fromCircle(center: ic, radius: 11)),
      );
      _icon.paint(canvas, ic - Offset(_icon.width / 2, _icon.height / 2));
      // Name cross-fades + slides as the selection morphs.
      final m = t.clamp(0.0, 1.0);
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(r.left + 38, r.top + 6, cw - 40, 20));
      if (m < 1 && s.prevName != s.selName) {
        canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, 1 - m));
        old.paint(canvas, Offset(r.left + 40, r.top + 9 - 12 * m));
        canvas.restore();
      }
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, s.prevName == s.selName ? 1 : m));
      title.paint(canvas, Offset(r.left + 40, r.top + 9 + (s.prevName == s.selName ? 0 : 12 * (1 - m))));
      canvas.restore();
      canvas.restore();
      sub.paint(canvas, Offset(r.left + 40, r.top + 27));
      canvas.restore();
    }

    // Tap ripple.
    if (s.ripple != null && s.rippleT < 1) {
      final rt = Curves.easeOutCubic.transform(s.rippleT);
      canvas.drawCircle(
        s.ripple!,
        4 + 26 * rt,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = C.lavDeep.withValues(alpha: (1 - rt) * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) => false;
}
