import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../home.dart';
import '../layout.dart';
import '../mood.dart';
import '../widgets/phone_frame.dart';
import 'reel.dart';

/// A 4:5 (1080 × 1350) cut in the style of the original X post: the phone on
/// a light grey stage, a hand cursor driving the UI, and a camera that pushes
/// in on each interaction and eases back out.
const xReelLength = 24.0;

const _stage = Size(1080, 1350);
const _center = Offset(540, 675);

/// Base phone placement: the 412 × 866 framed device scaled 1.5×, centred.
const _k = 1.5;
const _phoneW = 412 * _k;
const _phoneH = 866 * _k;
const _phoneLeft = (1080 - _phoneW) / 2;
const _phoneTop = (1350 - _phoneH) / 2;

/// Design point on the phone screen → unzoomed stage coordinates.
Offset _base(Offset p) => Offset(_phoneLeft + (11 + p.dx) * _k, _phoneTop + (11 + p.dy) * _k);

/// Camera keyframes: (time, focus x, focus y, zoom). Focus is in phone design points.
const _camera = <(double, double, double, double)>[
  (0, 195, 422, 1),
  (4.4, 195, 422, 1),
  (5.2, 195, 545, 1.55),
  (7.6, 195, 565, 1.64),
  (8.5, 195, 422, 1),
  (9.2, 195, 422, 1),
  (9.9, 195, 500, 1.8),
  (11.8, 195, 515, 1.84),
  (12.6, 195, 600, 1.3),
  (13.8, 195, 600, 1.33),
  (14.5, 195, 422, 1),
  (16.6, 195, 422, 1),
  (17.25, 195, 690, 1.75),
  (18.7, 195, 690, 1.8),
  (19.5, 195, 190, 1.62),
  (21.0, 195, 190, 1.68),
  (21.7, 195, 422, 1),
  (24, 195, 422, 1),
];

/// Cursor keyframes: (time, x, y, pressed) in phone design points.
const _cursor = <(double, double, double, bool)>[
  (0, 420, 930, false),
  (1.1, 45, 140, false),
  (1.8, 120, 140, false),
  (2.5, 195, 140, false),
  (3.2, 270, 140, false),
  (3.9, 345, 140, false),
  (4.6, 231, 476, false),
  (5.25, 231, 476, false),
  (5.3, 231, 476, true),
  (5.45, 231, 476, false),
  (6.75, 213, 476, false),
  (6.82, 213, 476, true),
  (6.97, 213, 476, false),
  (8.2, 232, 560, false),
  (9.6, 195, 476, false),
  (9.75, 195, 476, true),
  (10.0, 195, 476, true),
  (11.5, 159, 476, true),
  (11.6, 159, 476, false),
  (12.6, 255, 640, false),
  (14.6, 110, 640, false),
  (14.75, 110, 640, true),
  (15.15, 290, 640, true),
  (15.2, 290, 640, false),
  (15.8, 110, 640, false),
  (15.95, 110, 640, true),
  (16.35, 290, 640, true),
  (16.4, 290, 640, false),
  (17.3, 195, 702, false),
  (17.4, 195, 702, true),
  (17.55, 195, 702, false),
  (17.85, 195, 702, true),
  (18.0, 195, 702, false),
  (18.7, 232, 760, false),
  (19.6, 120, 140, false),
  (20.3, 270, 140, false),
  (20.9, 345, 140, false),
  (21.0, 345, 140, true),
  (21.15, 345, 140, false),
  (21.9, 195, 476, false),
  (22.0, 195, 476, true),
  (22.15, 195, 476, false),
  (23.2, 300, 620, false),
];

typedef _Label = ({double start, double end, IconData icon, String text});

const _labels = <_Label>[
  (start: 1.0, end: 4.3, icon: Icons.mouse_outlined, text: 'Hover'),
  (start: 5.1, end: 7.3, icon: Icons.ads_click_rounded, text: 'Tap'),
  (start: 9.6, end: 11.9, icon: Icons.pan_tool_alt_rounded, text: 'Drag'),
  (start: 14.6, end: 16.6, icon: Icons.swipe_rounded, text: 'Swipe'),
  (start: 17.2, end: 18.4, icon: Icons.touch_app_rounded, text: 'Poke'),
  (start: 21.85, end: 22.9, icon: Icons.ads_click_rounded, text: 'Tap'),
];

double _ease(double x) => Curves.easeInOutCubic.transform(x.clamp(0.0, 1.0));
double _win(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

class XReel extends StatefulWidget {
  const XReel({super.key, required this.controller, required this.hooks});
  final ReelController controller;
  final ReelHooks hooks;

  @override
  State<XReel> createState() => _XReelState();
}

class _XReelState extends State<XReel> with SingleTickerProviderStateMixin {
  final _home = GlobalKey<LullHomeState>();
  late final Widget _phone = FittedBox(child: PhoneFrame(homeKey: _home));
  late final Ticker _ticker = createTicker(_tick);

  Duration? _origin;
  double _t = 0;
  int _next = 0;
  Mood? _dragMood;
  bool _done = false;
  bool _wasDown = false;
  final _clicks = <(double, Offset)>[];

  LullHomeState get _app => _home.currentState!;
  void _sfx(String kind) => widget.hooks.sfx(kind);

  late final List<(double, void Function())> _events = [
    (5.32, () {
      _sfx('tap');
      _app.tapSwitch();
    }),
    (6.85, () {
      _sfx('tap');
      _app.tapSwitch();
    }),
    (9.78, () {
      _sfx('tap');
      _dragMood = _app.mood;
    }),
    (11.6, () {
      _app.endDrag(0);
      _dragMood = null;
    }),
    (14.8, () => _sfx('whoosh')),
    (15.05, () => _app.step(1)),
    (16.0, () => _sfx('whoosh')),
    (16.25, () => _app.step(1)),
    (17.42, _poke),
    (17.87, _poke),
    (21.02, () => _sfx('tab')),
    (22.03, () {
      _sfx('tap');
      _app.goTo(Mood.radiant);
    }),
  ];

  void _poke() {
    _sfx('pop');
    _app.pokeOrb();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.onStart = () => _ticker.start();
    if (widget.controller.started) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    _origin ??= elapsed;
    final t = (elapsed - _origin!).inMicroseconds / 1e6;

    while (_next < _events.length && _events[_next].$1 <= t) {
      _events[_next].$2();
      _next++;
    }
    if (_dragMood != null && t >= 10.0 && t <= 11.5) {
      _app.dragSwitch(0.5 * (1 - _ease(_win(t, 10.0, 11.5))));
      if (_app.mood != _dragMood) {
        _dragMood = _app.mood;
        _sfx('tick');
      }
    }

    final c = _cursorAt(t);
    _app.hoverChip(_chipUnder(c.pos));
    if (c.down && !_wasDown) _clicks.add((t, c.pos));
    _wasDown = c.down;
    _clicks.removeWhere((e) => t - e.$1 > 0.6);

    if (t >= xReelLength + 0.15 && !_done) {
      _done = true;
      widget.hooks.onDone();
    }
    setState(() => _t = t);
  }

  static int? _chipUnder(Offset p) {
    if ((p.dy - 136).abs() > 30) return null;
    for (var i = 0; i < 5; i++) {
      if ((p.dx - (45 + 75 * i)).abs() < 30) return i;
    }
    return null;
  }

  static ({Offset pos, bool down}) _cursorAt(double t) {
    for (var i = 0; i < _cursor.length - 1; i++) {
      final a = _cursor[i], b = _cursor[i + 1];
      if (t >= a.$1 && t < b.$1) {
        final e = _ease(_win(t, a.$1, b.$1));
        return (pos: Offset.lerp(Offset(a.$2, a.$3), Offset(b.$2, b.$3), e)!, down: a.$4);
      }
    }
    final l = _cursor.last;
    return (pos: Offset(l.$2, l.$3), down: false);
  }

  static ({Offset focus, double zoom}) _cameraAt(double t) {
    for (var i = 0; i < _camera.length - 1; i++) {
      final a = _camera[i], b = _camera[i + 1];
      if (t >= a.$1 && t < b.$1) {
        final e = _ease(_win(t, a.$1, b.$1));
        return (
          focus: Offset.lerp(Offset(a.$2, a.$3), Offset(b.$2, b.$3), e)!,
          zoom: a.$4 + (b.$4 - a.$4) * e,
        );
      }
    }
    final l = _camera.last;
    return (focus: Offset(l.$2, l.$3), zoom: l.$4);
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final cam = _cameraAt(t);
    final f = _base(cam.focus);
    final camera = Matrix4.identity()
      ..translateByDouble(_center.dx, _center.dy, 0, 1)
      ..scaleByDouble(cam.zoom, cam.zoom, 1, 1)
      ..translateByDouble(-f.dx, -f.dy, 0, 1);

    final cursor = _cursorAt(t);
    final cursorBase = _base(cursor.pos);
    final cursorScreen = _center + (cursorBase - f) * cam.zoom;

    return SizedBox.fromSize(
      size: _stage,
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _Stage())),
          Positioned.fill(
            child: Transform(
              transform: camera,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(left: _phoneLeft, top: _phoneTop, width: _phoneW, height: _phoneH, child: _phone),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CursorPainter(
                          t: t,
                          tip: cursorBase,
                          down: cursor.down,
                          clicks: [for (final (s, p) in _clicks) (s, _base(p))],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final l in _labels)
            if (t >= l.start && t <= l.end) _label(t, l, cursorScreen),
        ],
      ),
    );
  }

  Widget _label(double t, _Label l, Offset anchor) {
    final inP = Curves.easeOutBack.transform(_win(t, l.start, l.start + 0.3));
    final outP = _win(t, l.end - 0.2, l.end);
    final opacity = (_win(t, l.start, l.start + 0.2) * (1 - outP)).clamp(0.0, 1.0);
    return Positioned(
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
    );
  }
}

class _Stage extends CustomPainter {
  const _Stage();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFFEDEEF0));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 0.85,
          colors: [Color(0x00FFFFFF), Color(0x14000000)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_Stage old) => false;
}

/// macOS-style pointing hand, tip at [tip], with click ripples.
class _CursorPainter extends CustomPainter {
  _CursorPainter({required this.t, required this.tip, required this.down, required this.clicks});

  final double t;
  final Offset tip;
  final bool down;
  final List<(double, Offset)> clicks;

  static final Path _hand = () {
    RRect r(double l, double t, double r, double b, double rad) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));
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
  void paint(Canvas canvas, Size size) {
    for (final (start, p) in clicks) {
      final k = ((t - start) / 0.6).clamp(0.0, 1.0);
      final e = Curves.easeOutCubic.transform(k);
      final r = 14 + e * 34;
      canvas.drawCircle(p, r, Paint()..color = Colors.white.withValues(alpha: 0.45 * (1 - k)));
      canvas.drawCircle(
        p,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black.withValues(alpha: 0.18 * (1 - k)),
      );
    }

    const unit = 1.45;
    final scale = unit * (down ? 0.88 : 1.0);
    canvas.save();
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

  @override
  bool shouldRepaint(_CursorPainter old) => true;
}

