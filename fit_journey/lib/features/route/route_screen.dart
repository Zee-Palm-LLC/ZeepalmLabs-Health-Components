import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/assets.dart';
import '../../core/canvas.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import 'journey_button.dart';
import 'route_geometry.dart';
import 'route_layer.dart';
import 'route_sheet.dart';
import '../../core/phosphor.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key, required this.arrive, required this.origin, required this.onBack});

  final Animation<double> arrive;
  final Rect origin;
  final VoidCallback onBack;

  static const mapSize = Size(393, 367);

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _journey;
  late final AnimationController _follow;
  late final AnimationController _recenter;
  late final AnimationController _bookmark;
  late final AnimationController _locate;
  late final Clock _clock;
  bool _saved = false;
  double _userZoom = 1;
  Offset _userPan = Offset.zero;
  double _zoomFrom = 1;
  Offset _panFrom = Offset.zero;
  double _gestureZoom = 1;
  Offset _gestureFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2900))..forward();
    _journey = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          HapticFeedback.heavyImpact();
          _follow.animateBack(0, duration: const Duration(milliseconds: 1100), curve: glide);
          setState(() {});
        }
      });
    _follow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _recenter = AnimationController(vsync: this, duration: const Duration(milliseconds: 760))
      ..addListener(() {
        final t = Curves.easeInOutCubic.transform(_recenter.value);
        setState(() {
          _userZoom = lerp(_zoomFrom, 1, t);
          _userPan = Offset.lerp(_panFrom, Offset.zero, t)!;
        });
      });
    _bookmark = AnimationController(vsync: this, duration: const Duration(milliseconds: 760));
    _locate = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _clock = Clock(this);
  }

  @override
  void dispose() {
    _intro.dispose();
    _journey.dispose();
    _follow.dispose();
    _recenter.dispose();
    _bookmark.dispose();
    _locate.dispose();
    _clock.dispose();
    super.dispose();
  }

  bool get _running => _journey.isAnimating;

  void _toggleJourney() {
    if (_journey.isCompleted) {
      HapticFeedback.mediumImpact();
      _journey.value = 0;
      _journey.forward();
      _follow.forward();
    } else if (_running) {
      HapticFeedback.selectionClick();
      _journey.stop();
    } else {
      HapticFeedback.mediumImpact();
      _journey.forward();
      _follow.forward();
    }
    setState(() {});
  }

  void _toggleSave() {
    HapticFeedback.lightImpact();
    setState(() => _saved = !_saved);
    if (_saved) _bookmark.forward(from: 0);
  }

  void _locateMe() {
    HapticFeedback.selectionClick();
    _zoomFrom = _userZoom;
    _panFrom = _userPan;
    _recenter.forward(from: 0);
    if (!_running) _follow.animateBack(0, duration: const Duration(milliseconds: 700), curve: glide);
    _locate.forward(from: 0);
  }

  void _scaleStart(ScaleStartDetails d) {
    _recenter.stop();
    _gestureZoom = _userZoom;
    _gestureFocal = d.localFocalPoint;
  }

  void _scaleUpdate(ScaleUpdateDetails d, double viewportHeight) {
    setState(() {
      final zoom = (_gestureZoom * d.scale).clamp(1.0, 2.6);
      final focalShift = d.localFocalPoint - _gestureFocal;
      _gestureFocal = d.localFocalPoint;
      final ratio = zoom / _userZoom;
      final pan = (_userPan - d.localFocalPoint) * ratio + d.localFocalPoint + focalShift;
      _userZoom = zoom;
      _userPan = _clampPan(pan, zoom, viewportHeight);
    });
  }

  Offset _clampPan(Offset pan, double zoom, double viewportHeight) {
    final minX = RouteScreen.mapSize.width * (1 - zoom);
    final minY = math.min(0.0, viewportHeight - RouteScreen.mapSize.height * zoom);
    return Offset(pan.dx.clamp(minX, 0.0), pan.dy.clamp(minY, 0.0));
  }

  (double, Offset) _camera(double viewportHeight) {
    final f = Curves.easeInOutCubic.transform(_follow.value);
    if (f == 0) return (_userZoom, _userPan);
    final runner = RouteGeometry.instance.loopAt(_journey.value).position;
    const followZoom = 1.55;
    final target = Offset(RouteScreen.mapSize.width / 2, viewportHeight * 0.52);
    final follow = _clampPan(target - runner * followZoom, followZoom, viewportHeight);
    return (lerp(_userZoom, followZoom, f), Offset.lerp(_userPan, follow, f)!);
  }

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    final lift = scope.lift;
    final drop = scope.drop;
    final mapTop = math.min(lift, 0.0);
    final mapRect = Rect.fromLTWH(0, mapTop, 393, RouteScreen.mapSize.height + math.max(lift, 0.0));
    final squeeze = ((335.3 + lift) - (331.3 + drop)).clamp(0.0, 110.0);
    final sheetLift = lift - squeeze;
    final sheetTop = 335.3 + sheetLift;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) widget.onBack();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.arrive, _intro, _journey, _follow, _bookmark, _locate, _clock]),
          builder: (context, _) {
            final a = widget.arrive.value;
            final morph = Curves.easeInOutCubic.transform(a);
            final rise = spring(span(a, 0.28, 1.0, Curves.linear), bounce: 0.14, freq: 1.7);
            final slide = (1 - rise) * (scope.height - sheetTop + 40);
            final intro = _intro.value;
            final seconds = _clock.seconds;
            final frame = Rect.lerp(widget.origin, mapRect, morph)!;
            final (zoom, camera) = _camera(sheetTop - mapTop + 24);
            final pan = camera.translate(0, -squeeze * 0.5);
            final chrome = spring(span(intro, 0.2, 0.5, Curves.linear), bounce: 0.45, freq: 2.4) * span(a, 0.6, 1.0);
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(child: IgnorePointer(child: ColoredBox(color: Colors.white.withValues(alpha: span(a, 0.55, 1.0))))),
                Positioned.fromRect(
                  rect: frame,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(lerp(16, 0, morph)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _MapView(
                          zoom: zoom,
                          pan: pan,
                          draw: span(intro, 0.34, 0.86, const Cubic(0.45, 0.05, 0.25, 1.0)),
                          startPin: spring(span(intro, 0.26, 0.5, Curves.linear), bounce: 0.5, freq: 2.6),
                          label: span(intro, 0.32, 0.56, swift),
                          finish: span(intro, 0.8, 1.0, Curves.linear),
                          ripple: span(intro, 0.9, 1.0, Curves.linear),
                          journey: _journey.value,
                          seconds: seconds,
                          locate: _locate.isAnimating ? _locate.value : 0,
                          onScaleStart: _scaleStart,
                          onScaleUpdate: (d) => _scaleUpdate(d, sheetTop - mapTop + 24),
                          opacity: span(a, 0.2, 0.7, Curves.easeInOut),
                        ),
                        IgnorePointer(
                          child: Opacity(
                            opacity: 1 - span(a, 0.25, 0.75, Curves.easeInOut),
                            child: Image.asset(Assets.riversidePark, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _RoundButton(
                  center: Offset(41.5, 76.5 + lift),
                  radius: 22.8,
                  pop: chrome,
                  onTap: widget.onBack,
                  child: const Center(child: Icon(PhosphorBold.caretLeft, size: 21, color: Color(0xFF0E2440))),
                ),
                _RoundButton(
                  center: Offset(353.5, 76.5 + lift),
                  radius: 22.8,
                  pop: chrome,
                  onTap: _toggleSave,
                  child: CustomPaint(
                    foregroundPainter: _Burst(saved: _saved, burst: _bookmark.value),
                    child: Center(
                      child: Transform.scale(
                        scale: _saved && _bookmark.value > 0 && _bookmark.value < 1 ? 1 + math.sin(_bookmark.value * math.pi) * 0.25 : 1.0,
                        child: Icon(
                          _saved ? PhosphorFill.bookmarkSimple : PhosphorBold.bookmarkSimple,
                          size: 22,
                          color: _saved ? Palette.mint : const Color(0xFF0E2440),
                        ),
                      ),
                    ),
                  ),
                ),
                _RoundButton(
                  center: Offset(352.2, 300.6 + sheetLift + slide * 0.2),
                  radius: 23.6,
                  pop: chrome,
                  onTap: _locateMe,
                  child: Center(
                    child: Transform.rotate(
                      angle: Curves.easeInOutBack.transform(_locate.value) * math.pi / 2,
                      child: const Icon(PhosphorBold.crosshair, size: 24, color: Color(0xFF4A5568)),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: sheetTop + slide,
                  height: scope.height - sheetTop + 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Palette.card,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [BoxShadow(color: Palette.shadow.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, -6))],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: sheetTop + slide,
                  bottom: math.max(0.0, scope.height - (756 + drop) + 6),
                  child: ClipRect(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        height: 752 + sheetLift - sheetTop,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              top: -sheetTop,
                              height: 780 + sheetLift,
                              child: RouteSheet(enter: span(intro, 0.1, 0.8, Curves.linear), lift: sheetLift, seconds: seconds),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                JourneyButton(
                  rect: Rect.fromLTWH(18.5, 756 + drop + slide, 357, 54.5),
                  enter: span(intro, 0.45, 0.8, Curves.linear),
                  progress: _journey.value,
                  running: _running,
                  onTap: _toggleJourney,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({
    required this.zoom,
    required this.pan,
    required this.draw,
    required this.startPin,
    required this.label,
    required this.finish,
    required this.ripple,
    required this.journey,
    required this.seconds,
    required this.locate,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.opacity,
  });

  final double zoom;
  final Offset pan;
  final double draw;
  final double startPin;
  final double label;
  final double finish;
  final double ripple;
  final double journey;
  final double seconds;
  final double locate;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      child: Opacity(
        opacity: opacity,
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.hardEdge,
          child: SizedBox.fromSize(
            size: RouteScreen.mapSize,
            child: Transform(
              transform: Matrix4.identity()
                ..translateByDouble(pan.dx, pan.dy, 0, 1)
                ..scaleByDouble(zoom, zoom, 1, 1),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: Image.asset(Assets.routeMap, fit: BoxFit.fill, filterQuality: FilterQuality.medium)),
                  Positioned.fill(child: CustomPaint(painter: RouteLayer(draw: draw, journey: journey, seconds: seconds, zoom: math.sqrt(zoom)))),
                  if (locate > 0)
                    Positioned.fill(child: CustomPaint(painter: _Pulse(locate))),
                  Positioned.fill(child: CustomPaint(painter: FinishPinPainter(drop: finish, ripple: ripple))),
                  Positioned.fill(child: CustomPaint(painter: StartPinPainter(pop: startPin))),
                  _StartTag(reveal: label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartTag extends StatelessWidget {
  const _StartTag({required this.reveal});

  final double reveal;

  @override
  Widget build(BuildContext context) {
    const rect = Rect.fromLTWH(107.5, 54.9, 61.3, 26.9);
    final w = lerp(26.9, rect.width, reveal);
    return Positioned(
      left: rect.center.dx - w / 2,
      top: rect.top + (1 - reveal) * 14,
      width: w,
      height: rect.height,
      child: Opacity(
        opacity: span(reveal, 0.0, 0.3).clamp(0.0, 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.45),
            gradient: const LinearGradient(colors: [Color(0xFF11B98A), Color(0xFF03AB7E)]),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13.45),
            child: OverflowBox(
              minWidth: rect.width,
              maxWidth: rect.width,
              child: Stack(
                children: [
                  Label('Start', x: 12.0, base: 19.7, style: font(15.8, 700, color: const Color(0xFFEFFFF9).withValues(alpha: span(reveal, 0.4, 1.0)))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.center, required this.radius, required this.pop, required this.onTap, required this.child});

  final Offset center;
  final double radius;
  final double pop;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - radius,
      top: center.dy - radius,
      width: radius * 2,
      height: radius * 2,
      child: Transform.scale(
        scale: pop,
        child: Pressable(
          onTap: onTap,
          scale: 0.88,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFF),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Palette.shadow.withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Burst extends CustomPainter {
  _Burst({required this.saved, required this.burst});

  final bool saved;
  final double burst;

  @override
  void paint(Canvas canvas, Size size) {
    if (!saved || burst <= 0 || burst >= 1) return;
    final c = size.center(Offset.zero);
    final e = Curves.easeOut.transform(burst);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + 0.3;
      final p = c + Offset(math.cos(a), math.sin(a)) * (12 + 16 * e);
      canvas.drawCircle(p, 2.2 * (1 - e), Paint()..color = (i.isEven ? Palette.mint : Palette.sun));
    }
  }

  @override
  bool shouldRepaint(_Burst old) => old.saved != saved || old.burst != burst;
}

class _Pulse extends CustomPainter {
  _Pulse(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const c = Offset(112.9, 100.85);
    for (var k = 0; k < 2; k++) {
      final local = ((t - k * 0.25) / 0.75).clamp(0.0, 1.0);
      if (local <= 0 || local >= 1) continue;
      canvas.drawCircle(
        c,
        16 + 46 * Curves.easeOut.transform(local),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * (1 - local) + 0.5
          ..color = Palette.mint.withValues(alpha: 0.8 * (1 - local)),
      );
    }
  }

  @override
  bool shouldRepaint(_Pulse old) => old.t != t;
}
