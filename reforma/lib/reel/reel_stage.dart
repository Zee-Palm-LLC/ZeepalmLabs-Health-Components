import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../icons.dart';
import '../theme.dart';
import '../widgets/art.dart';

/// Showcase stage with kinetic captions, the real app in a phone, and a
/// scripted finger on top. Everything here is a pure function of
/// [ReelState.t], so frames rendered at a fixed 1/60 s step are perfectly even.
class ReelState extends ChangeNotifier {
  double t = 0;
  double length = 30;
  Offset finger = const Offset(1700, 1500); // base (unzoomed) stage coordinates
  double fingerOpacity = 0;
  double press = 0; // 0..1 squash while pressed
  final ripples = <(Offset, double)>[]; // base position, start time

  /// Camera: stage point kept at the centre, and zoom (identity when null/1).
  Offset? camFocus;
  double camZoom = 1;

  /// Gesture label shown beside the cursor (Lull-style): text, icon, start, end.
  ({String text, IconData icon, double start, double end})? label;

  Offset center(Size stage) => stage.center(Offset.zero);
  Offset toScreen(Offset base, Size stage) => center(stage) + (base - (camFocus ?? center(stage))) * camZoom;
  Offset toBase(Offset screen, Size stage) => (camFocus ?? center(stage)) + (screen - center(stage)) / camZoom;

  void tick(double time) {
    t = time;
    notifyListeners();
  }
}

/// Output format: landscape 4:3 (ZeepalmLabs showcase, captions left of the
/// phone), portrait 4:5 (Instagram feed, captions above the phone), or a
/// bare 4:5 cut: just the phone, sized to fill the frame, no text.
class ReelFormat {
  const ReelFormat._(this.name, this.size, this.phoneScale, this.isPortrait, [this.bare = false]);

  static const landscape = ReelFormat._('4x3', Size(1920, 1440), 1.45, false);
  static const portrait = ReelFormat._('4x5', Size(1080, 1350), 1.1, true);
  static const phoneOnly = ReelFormat._('4x5-phone', Size(1080, 1350), 1.5, true, true);

  final String name;
  final Size size;
  final double phoneScale;
  final bool isPortrait;
  final bool bare; // phone only: no intro, captions or outro

  // PhoneFrame is 416 × 870 including its 2-pt rim.
  double get phoneW => 416 * phoneScale;
  double get phoneH => 870 * phoneScale;
  double get phoneLeft => bare
      ? (size.width - phoneW) / 2
      : isPortrait ? (size.width - phoneW) / 2 : size.width - 150 - phoneW;
  double get phoneTop => bare
      ? (size.height - phoneH) / 2
      : isPortrait ? size.height - phoneH - 34 : (size.height - phoneH) / 2;

  /// Type / effect scale relative to the landscape master.
  double get u => isPortrait ? 0.6 : 1;
}

class Caption {
  const Caption(this.start, this.end, this.eyebrow, this.title, this.body);

  final double start, end;
  final String eyebrow, title, body;
}

const reelCaptions = [
  Caption(2.5, 5.9, '01  ·  HOME', 'Recovery,\nat a glance.',
      'A live recovery score that springs into place — pain, mobility and stiffness one tap away.'),
  Caption(6.2, 10.5, '02  ·  BODY CHECK-IN', 'Tap where\nit hurts.',
      'Hotspots morph across the body and follow every turn.'),
  Caption(10.7, 14.9, '03  ·  REAL-TIME 3D', 'Spin it with\nyour finger.',
      'Procedural anatomy with physics inertia — no model files, nothing to load.'),
  Caption(15.2, 17.9, '04  ·  LIVE SYNC', 'Check-ins update\nyour day.',
      'Pain level and recovery score respond the moment you save.'),
  Caption(18.3, 25.9, '05  ·  GUIDED SESSION', 'A 3D coach\nshows the move.',
      'Shared-element transitions, a parallax hero and spring-filled progress.'),
];

double _spring(double t, {double k = 120, double zeta = 0.72}) {
  if (t <= 0) return 0;
  final s = SpringSimulation(SpringDescription.withDampingRatio(mass: 1, stiffness: k, ratio: zeta), 0, 1, 0);
  return s.x(t);
}

double _clamp01(double v) => v.clamp(0.0, 1.0);
double _ease(double v) => Curves.easeOutCubic.transform(_clamp01(v));

class ReelStage extends StatelessWidget {
  const ReelStage({super.key, required this.state, required this.phoneChild, this.format = ReelFormat.landscape});

  final ReelState state;
  final Widget phoneChild;
  final ReelFormat format;

  @override
  Widget build(BuildContext context) {
    final f = format;
    return SizedBox(
      width: f.size.width,
      height: f.size.height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: f.bare ? const _GreyStage() : _Backdrop(state))),
          ),
          if (!f.bare) ...[
            Positioned.fill(child: _Intro(state: state, f: f)),
            if (f.isPortrait)
              Positioned(left: 60, right: 60, top: 0, height: f.phoneTop - 4, child: _Captions(state: state, f: f))
            else
              Positioned(left: 150, top: 0, bottom: 0, width: 900, child: _Captions(state: state, f: f)),
            if (f.isPortrait)
              Positioned(left: 0, right: 0, top: 0, height: f.phoneTop - 4, child: _Outro(state: state, f: f))
            else
              Positioned.fill(child: _Outro(state: state, f: f)),
          ],
          // Camera (push-ins in the phone-only cut) around the phone.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: state,
              builder: (context, child) {
                final c = f.size.center(Offset.zero), focus = state.camFocus ?? c, z = state.camZoom;
                return Transform(
                  transform: Matrix4.identity()
                    ..translateByDouble(c.dx, c.dy, 0, 1)
                    ..scaleByDouble(z, z, 1, 1)
                    ..translateByDouble(-focus.dx, -focus.dy, 0, 1),
                  child: child,
                );
              },
              child: Stack(clipBehavior: Clip.none, children: [
          // The phone rises in on a spring and glides slightly for the outro.
          AnimatedBuilder(
            animation: state,
            builder: (context, child) {
              final t = state.t;
              final rise = f.bare ? 1.0 : _spring(t - 1.85, k: 70, zeta: 0.74);
              final out = _ease((t - 26.0) / 1.2);
              final dy = (1 - rise) * f.size.height;
              final dx = f.isPortrait ? 0.0 : out * 40; // landscape outro glide
              return Positioned(
                left: f.phoneLeft + dx,
                top: f.phoneTop + dy,
                width: f.phoneW,
                height: f.phoneH,
                child: Opacity(opacity: _clamp01(rise * 3), child: child),
              );
            },
            // The phone-only cut has no drop shadow — just the device on the backdrop.
            child: f.bare
                ? FittedBox(child: SizedBox(width: 416, height: 870, child: phoneChild))
                : _PhoneShadow(
                    f: f,
                    child: FittedBox(child: SizedBox(width: 416, height: 870, child: phoneChild)),
                  ),
          ),
              ]),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _Finger(state, f, f.isPortrait && !f.bare ? 0.72 : 1))),
          ),
          if (f.bare) Positioned.fill(child: IgnorePointer(child: _GestureLabel(state: state, f: f))),
          // Fade in/out to the backdrop colour.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: state,
                builder: (context, _) {
                  final t = state.t;
                  final end = state.length - 0.7;
                  final a = t < 0.5 ? 1 - t / 0.5 : (t > end ? _clamp01((t - end) / 0.7) : 0.0);
                  final bg = f.bare ? const Color(0xFFEDEEF0) : const Color(0xFFF3EEF6);
                  return ColoredBox(color: bg.withValues(alpha: a.toDouble()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneShadow extends StatelessWidget {
  const _PhoneShadow({required this.child, required this.f});

  final Widget child;
  final ReelFormat f;

  @override
  Widget build(BuildContext context) {
    final k = f.phoneScale / 1.45;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(64 * f.phoneScale),
        boxShadow: [
          BoxShadow(color: const Color(0x1F503C78), blurRadius: 140 * k, spreadRadius: -30 * k, offset: Offset(0, 46 * k)),
          BoxShadow(color: const Color(0x14000000), blurRadius: 24 * k, offset: Offset(0, 8 * k)),
        ],
      ),
      child: child,
    );
  }
}

/// Soft lavender studio backdrop with slow drifting light orbs.
class _Backdrop extends CustomPainter {
  _Backdrop(this.s) : super(repaint: s);

  final ReelState s;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.35, -0.2),
          radius: 1.15,
          colors: [Color(0xFFFBF8FC), Color(0xFFF1E9F6), Color(0xFFE6DCEF)],
          stops: [0, 0.55, 1],
        ).createShader(r),
    );
    final t = s.t, w = size.width / 1920, h = size.height / 1440, m = math.min(w, h);
    void orb(Offset c, double rad, Color col) => canvas.drawCircle(
          c,
          rad,
          Paint()
            ..shader = RadialGradient(colors: [col, col.withValues(alpha: 0)])
                .createShader(Rect.fromCircle(center: c, radius: rad)),
        );
    orb(Offset((1450 + 60 * math.sin(t * 0.21)) * w, (380 + 40 * math.cos(t * 0.17)) * h), 700 * m, const Color(0x55C9B6F2));
    orb(Offset((300 + 80 * math.cos(t * 0.13)) * w, (1250 + 50 * math.sin(t * 0.19)) * h), 650 * m, const Color(0x40B9D8CC));
    orb(Offset((900 + 90 * math.sin(t * 0.11 + 1)) * w, (120 + 30 * math.cos(t * 0.23)) * h), 520 * m, const Color(0x38F3C9DD));
  }

  @override
  bool shouldRepaint(_Backdrop old) => false;
}

/// Opening lockup: the sprout grows, the word mark rises letter by letter,
/// then the lockup glides out of the way (up-left / up) as the phone arrives.
class _Intro extends StatelessWidget {
  const _Intro({required this.state, required this.f});

  final ReelState state;
  final ReelFormat f;

  @override
  Widget build(BuildContext context) {
    final u = f.isPortrait ? 0.7 : 1.0;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final t = state.t;
        if (t > 3.2) return const SizedBox();
        final grow = _spring(t - 0.15, k: 90, zeta: 0.55);
        final leave = _ease((t - 1.95) / 0.9);
        final fade = 1 - _clamp01((t - 2.2) / 0.7);
        const word = 'Reforma';
        final away = f.isPortrait ? Offset(0, -420 * leave) : Offset(-260 * leave, -120 * leave);
        return Opacity(
          opacity: fade,
          child: Transform.translate(
            offset: away,
            child: Center(
              child: Transform.scale(
                scale: 1 - 0.25 * leave,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: (1 - grow) * -0.6,
                      child: Transform.scale(scale: grow, child: LeafLogo(size: 150 * u)),
                    ),
                    SizedBox(width: 34 * u),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < word.length; i++)
                              Builder(builder: (context) {
                                final v = _spring(t - 0.45 - i * 0.055, k: 140, zeta: 0.62);
                                return Opacity(
                                  opacity: _clamp01(v * 1.5),
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - v) * 60 * u),
                                    child: Text(word[i], style: inter(150 * u, FontWeight.w400, C.ink, ls: -4 * u, height: 1)),
                                  ),
                                );
                              }),
                          ],
                        ),
                        SizedBox(height: 18 * u),
                        Opacity(
                          opacity: _ease((t - 1.0) / 0.6),
                          child: Transform.translate(
                            offset: Offset(0, 20 * u * (1 - _ease((t - 1.0) / 0.6))),
                            child: Text('Better Movement. Brighter Days.', style: inter(44 * u, FontWeight.w400, C.ink2)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Kinetic captions: eyebrow slides in, title lines rise on springs with a
/// stagger, body fades up; the whole block lifts away on exit.
class _Captions extends StatelessWidget {
  const _Captions({required this.state, required this.f});

  final ReelState state;
  final ReelFormat f;

  @override
  Widget build(BuildContext context) {
    final u = f.u, center = f.isPortrait;
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = center ? TextAlign.center : TextAlign.start;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final t = state.t;
        Caption? c;
        for (final x in reelCaptions) {
          if (t >= x.start - 0.05 && t < x.end + 0.6) c = x;
        }
        if (c == null) return const SizedBox();
        final local = t - c.start;
        final exit = _ease((t - c.end) / 0.5);
        final lines = c.title.split('\n');
        // Portrait: a single title line where it fits keeps the block compact.
        final shown = center ? [lines.join(' ')] : lines;
        return Opacity(
          opacity: 1 - exit,
          child: Transform.translate(
            offset: Offset(0, -40 * u * exit),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: align,
              children: [
                Builder(builder: (context) {
                  final v = _spring(local, k: 160, zeta: 0.8);
                  return Opacity(
                    opacity: _clamp01(v),
                    child: Transform.translate(
                      offset: center ? Offset(0, 16 * (1 - v)) : Offset(-40 * (1 - v), 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 46 * u * _clamp01(v),
                            height: 4 * u + 1,
                            margin: EdgeInsets.only(right: 18 * u),
                            decoration: BoxDecoration(color: C.teal, borderRadius: BorderRadius.circular(2)),
                          ),
                          Text(c!.eyebrow, style: inter(28 * u + 4, FontWeight.w600, C.teal, ls: 3 * u)),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 34 * u),
                for (final (i, line) in shown.indexed)
                  Builder(builder: (context) {
                    final v = _spring(local - 0.12 - i * 0.1, k: 120, zeta: 0.7);
                    return ClipRect(
                      child: Opacity(
                        opacity: _clamp01(v * 1.4),
                        child: Transform.translate(
                          offset: Offset(0, (1 - v) * 110 * u),
                          child: Text(line,
                              textAlign: textAlign,
                              style: inter(center ? 58 : 104, FontWeight.w500, C.ink, ls: -3 * u, height: 1.12)),
                        ),
                      ),
                    );
                  }),
                SizedBox(height: center ? 18 : 36),
                Builder(builder: (context) {
                  final v = _ease((local - 0.45) / 0.6);
                  return Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 24 * u * (1 - v)),
                      child: SizedBox(
                        width: center ? 860 : 760,
                        child: Text(c!.body,
                            textAlign: textAlign, style: inter(center ? 26 : 36, FontWeight.w400, C.ink2, height: 1.45)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Closing lockup (left of the phone, or above it in portrait).
class _Outro extends StatelessWidget {
  const _Outro({required this.state, required this.f});

  final ReelState state;
  final ReelFormat f;

  @override
  Widget build(BuildContext context) {
    final p = f.isPortrait;
    final u = p ? 0.62 : 1.0;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final t = state.t - 26.3;
        if (t < 0) return const SizedBox();
        final logo = _spring(t, k: 100, zeta: 0.6);
        double line(double d) => _ease((t - d) / 0.6);
        Widget rise(double v, Widget w) =>
            Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 30 * u * (1 - v)), child: w));
        return Padding(
          padding: EdgeInsets.only(left: p ? 0 : 150),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: p ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: p ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  Transform.scale(scale: logo, child: LeafLogo(size: 110 * u)),
                  SizedBox(width: 26 * u),
                  rise(line(0.15), Text('Reforma', style: inter(120 * u, FontWeight.w400, C.ink, ls: -3 * u, height: 1))),
                ],
              ),
              SizedBox(height: 30 * u),
              rise(line(0.4), Text('Better Movement. Brighter Days.', style: inter(46 * u, FontWeight.w400, C.ink2))),
              SizedBox(height: 60 * u),
              rise(
                line(0.7),
                Row(
                  mainAxisSize: p ? MainAxisSize.min : MainAxisSize.max,
                  children: [
                    for (final chip in ['3D body check-in', 'Physics motion', 'Built in Flutter'])
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: p ? 6 : 0).copyWith(right: p ? 6 : 16),
                        padding: EdgeInsets.symmetric(horizontal: 26 * u, vertical: 14 * u),
                        decoration: BoxDecoration(
                          color: const Color(0xCCFFFFFF),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: const Color(0x14000000)),
                        ),
                        child: Text(chip, style: inter(28 * u + 2, FontWeight.w500, C.ink)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// iOS-style touch indicator: soft disc that squashes on press and leaves a
/// ripple ring.
class _Finger extends CustomPainter {
  _Finger(this.s, this.f, this.k) : super(repaint: s);

  final ReelState s;
  final ReelFormat f;
  final double k; // size scale

  @override
  void paint(Canvas canvas, Size size) {
    if (f.bare) return _paintHand(canvas, size);
    for (final (p, start) in s.ripples) {
      final q = (s.t - start) / 0.55;
      if (q < 0 || q > 1) continue;
      final e = Curves.easeOutCubic.transform(q);
      canvas.drawCircle(
        p,
        (30 + 60 * e) * k,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 * k
          ..color = Colors.white.withValues(alpha: (1 - q) * 0.85),
      );
    }
    if (s.fingerOpacity <= 0.01) return;
    final a = s.fingerOpacity;
    final r = 38 * k * (1 - 0.18 * s.press);
    canvas.drawCircle(
      s.finger + Offset(0, 6 * k),
      r + 4 * k,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16 * a)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * k),
    );
    canvas.drawCircle(s.finger, r, Paint()..color = Colors.white.withValues(alpha: 0.62 * a));
    canvas.drawCircle(
      s.finger,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * k
        ..color = Colors.white.withValues(alpha: 0.95 * a),
    );
  }

  /// macOS-style pointing hand (as in the Lull reel), tip at the cursor, with
  /// click ripples; sized with the camera zoom like an on-phone pointer.
  void _paintHand(Canvas canvas, Size size) {
    for (final (p, start) in s.ripples) {
      final q = ((s.t - start) / 0.6).clamp(0.0, 1.0);
      if (q >= 1) continue;
      final e = Curves.easeOutCubic.transform(q);
      final r = (14 + e * 34) * s.camZoom;
      final c = s.toScreen(p, size);
      canvas.drawCircle(c, r, Paint()..color = Colors.white.withValues(alpha: 0.45 * (1 - q)));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black.withValues(alpha: 0.18 * (1 - q)),
      );
    }
    if (s.fingerOpacity <= 0.01) return;
    final tip = s.toScreen(s.finger, size);
    final scale = 1.45 * s.camZoom * (1 - 0.12 * s.press);
    canvas.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: s.fingerOpacity));
    canvas.translate(tip.dx, tip.dy);
    canvas.scale(scale);
    canvas.translate(0, -0.4);
    canvas.drawPath(
      _hand.shift(const Offset(0.6, 1.4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
    );
    canvas.drawPath(_hand, Paint()..color = Colors.white);
    canvas.drawPath(
      _hand,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.black,
    );
    final line = Paint()
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = Colors.black;
    canvas.drawLine(const Offset(1.9, 11), const Offset(1.9, 14.5), line);
    canvas.drawLine(const Offset(5.3, 11.5), const Offset(5.3, 15), line);
    canvas.drawLine(const Offset(8.6, 12.5), const Offset(8.6, 15.5), line);
    canvas.restore();
  }

  static final Path _hand = () {
    RRect r(double l, double t, double r, double b, double rad) => RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));
    Path p(RRect rr) => Path()..addRRect(rr);
    var hand = p(r(-2.3, 0, 2.3, 13, 2.3));
    for (final part in [
      p(r(1.6, 6.5, 6.0, 14, 2.2)),
      p(r(5.0, 7.5, 9.2, 15, 2.1)),
      p(r(8.4, 9.0, 11.8, 15.5, 1.7)),
      Path()
        ..addRRect(RRect.fromLTRBAndCorners(
          -4.8,
          10.5,
          11.8,
          23,
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
          bottomLeft: const Radius.circular(6),
          bottomRight: const Radius.circular(5),
        )),
      p(r(-9.8, 11.2, -2.5, 15.2, 2.0)).transform((Matrix4.identity()
            ..translateByDouble(-3.0, 13.0, 0, 1)
            ..rotateZ(-0.55)
            ..translateByDouble(3.0, -13.0, 0, 1))
          .storage),
    ]) {
      hand = Path.combine(PathOperation.union, hand, part);
    }
    return hand;
  }();

  @override
  bool shouldRepaint(_Finger old) => false;
}

/// Lull's light grey studio stage with a soft vignette.
class _GreyStage extends CustomPainter {
  const _GreyStage();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFFEDEEF0));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(radius: 0.85, colors: [Color(0x00FFFFFF), Color(0x14000000)]).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GreyStage old) => false;
}

/// Dark pill naming the gesture ("Tap", "Spin"…) that follows the cursor and
/// pops in with an overshoot, as in the Lull reel.
class _GestureLabel extends StatelessWidget {
  const _GestureLabel({required this.state, required this.f});

  final ReelState state;
  final ReelFormat f;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final l = state.label, t = state.t;
        if (l == null || t < l.start || t > l.end) return const SizedBox();
        double win(double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
        final inP = Curves.easeOutBack.transform(win(l.start, l.start + 0.3));
        final opacity = (win(l.start, l.start + 0.2) * (1 - win(l.end - 0.2, l.end))).clamp(0.0, 1.0);
        final anchor = state.toScreen(state.finger, f.size);
        return Stack(children: [
          Positioned(
            left: anchor.dx + 44,
            top: anchor.dy + 52,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                alignment: Alignment.topLeft,
                scale: 0.7 + 0.3 * inP,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 12, 24, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xE6141518),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(l.icon, size: 30, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(l.text, style: inter(30, FontWeight.w600, Colors.white, ls: -0.2)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}

/// Gesture label icons.
abstract final class ReelIcons {
  static const tap = PhFill.handTap;
  static const grab = PhFill.handGrabbing;
  static const swipe = PhFill.handSwipeRight;
  static const pull = PhFill.arrowsDownUp;
}
