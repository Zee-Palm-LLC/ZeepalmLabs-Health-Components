import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core/assets.dart';
import 'core/canvas.dart';
import 'core/motion.dart';
import 'core/palette.dart';
import 'features/home/home_screen.dart';
import 'features/home/nav_bar.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/route/route_screen.dart';
import 'features/splash/splash_screen.dart';

enum Stage { splash, onboarding, home }

class FitJourneyApp extends StatelessWidget {
  const FitJourneyApp({super.key, this.start = Stage.splash});

  final Stage start;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitJourney',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Figtree',
        scaffoldBackgroundColor: Palette.page,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(body: DesignCanvas(child: Shell(start: start))),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key, this.start = Stage.splash});

  final Stage start;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> with TickerProviderStateMixin {
  late final AnimationController _portal;
  late final AnimationController _bloom;
  late final AnimationController _route;
  final _home = GlobalKey<HomeScreenState>();
  late Stage _stage;
  Offset _pin = SplashScreen.pinCenter;
  Rect _button = OnboardingScreen.buttonRect;
  Rect _origin = Rect.zero;
  bool _routeShown = false;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _stage = widget.start;
    _portal = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250));
    _bloom = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _route = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
    if (_stage != Stage.splash) _portal.value = 1;
    if (_stage == Stage.home) _bloom.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final asset in Assets.all) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  void dispose() {
    _portal.dispose();
    _bloom.dispose();
    _route.dispose();
    super.dispose();
  }

  void _toOnboarding(Offset pin) {
    setState(() {
      _pin = pin;
      _stage = Stage.onboarding;
    });
    _portal.forward(from: 0);
  }

  void _toHome(Rect button) {
    setState(() {
      _button = button;
      _stage = Stage.home;
    });
    _bloom.forward(from: 0);
  }

  void _openRoute(Rect origin) {
    if (_routeShown && _route.status == AnimationStatus.forward) return;
    setState(() {
      _origin = origin;
      _routeShown = true;
    });
    _route.forward(from: 0);
  }

  Future<void> _closeRoute() async {
    await _route.animateBack(0, duration: const Duration(milliseconds: 780), curve: Curves.linear);
    if (!mounted) return;
    setState(() => _routeShown = false);
    _home.currentState?.resetSection();
  }

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([_portal, _bloom, _route]),
      builder: (context, _) {
        final portal = _portal.value;
        final bloom = _bloom.value;
        final route = _route.value;
        final showSplash = _stage == Stage.splash || (_stage == Stage.onboarding && portal < 1);
        final showOnboarding = _stage == Stage.onboarding || (_stage == Stage.home && bloom < 0.5);
        final showHome = _stage == Stage.home;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (showHome)
              Positioned.fill(
                child: _Recede(
                  t: _routeShown ? route : 0,
                  child: HomeScreen(
                    key: _home,
                    entrance: _bloom,
                    routeOpen: _routeShown,
                    onOpenRoute: _openRoute,
                  ),
                ),
              ),
            if (showSplash)
              Positioned.fill(
                child: _ZoomInto(
                  t: _stage == Stage.onboarding ? portal : 0,
                  focus: _pin,
                  child: SplashScreen(onFinish: _toOnboarding),
                ),
              ),
            if (showOnboarding)
              Positioned.fill(
                child: ClipPath(
                  clipper: _PinPortal(center: _pin, t: _stage == Stage.onboarding ? Curves.easeInCubic.transform(portal) : 1),
                  child: _Settle(
                    t: _stage == Stage.onboarding ? portal : 1,
                    focus: _pin,
                    child: IgnorePointer(
                      ignoring: _stage != Stage.onboarding,
                      child: OnboardingScreen(entrance: _portal, onFinish: _toHome),
                    ),
                  ),
                ),
              ),
            if (_stage == Stage.home && bloom < 1)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BloomPainter(
                      t: bloom,
                      from: _button,
                      to: Rect.fromCircle(center: NavBar.fabCenter(scope), radius: NavFab.radius),
                      size: Size(CanvasScope.width, scope.height),
                    ),
                  ),
                ),
              ),
            if (_routeShown)
              Positioned.fill(
                child: RouteScreen(arrive: _route, origin: _origin, onBack: _closeRoute),
              ),
          ],
        );
      },
    );
  }
}

class _ZoomInto extends StatelessWidget {
  const _ZoomInto({required this.t, required this.focus, required this.child});

  final double t;
  final Offset focus;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final e = Curves.easeInCubic.transform(t);
    final scale = 1 + e * 1.8;
    return Transform(
      transform: Matrix4.identity()
        ..translateByDouble(focus.dx, focus.dy, 0, 1)
        ..scaleByDouble(scale, scale, 1, 1)
        ..translateByDouble(-focus.dx, -focus.dy, 0, 1),
      child: child,
    );
  }
}

class _Settle extends StatelessWidget {
  const _Settle({required this.t, required this.focus, required this.child});

  final double t;
  final Offset focus;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scale = lerp(1.18, 1.0, Curves.easeOutCubic.transform(t));
    return Transform(
      transform: Matrix4.identity()
        ..translateByDouble(focus.dx, focus.dy, 0, 1)
        ..scaleByDouble(scale, scale, 1, 1)
        ..translateByDouble(-focus.dx, -focus.dy, 0, 1),
      child: child,
    );
  }
}

class _Recede extends StatelessWidget {
  const _Recede({required this.t, required this.child});

  final double t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final e = Curves.easeInOutCubic.transform(t);
    return Transform.scale(
      scale: 1 - 0.06 * e,
      alignment: const Alignment(0, 0.2),
      child: child,
    );
  }
}

class _PinPortal extends CustomClipper<Path> {
  _PinPortal({required this.center, required this.t});

  final Offset center;
  final double t;

  @override
  Path getClip(Size size) {
    if (t >= 1) return Path()..addRect(Offset.zero & size);
    final reach = math.sqrt(size.width * size.width + size.height * size.height) * 1.25;
    final r = 4 + reach * t;
    final c = center.translate(0, -r * 0.35 + 6);
    final tip = Offset(c.dx, c.dy + r * 1.62);
    final phi = math.acos(r / (tip.dy - c.dy));
    final start = math.pi / 2 + phi;
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(c.dx + math.cos(start) * r, c.dy + math.sin(start) * r)
      ..arcTo(Rect.fromCircle(center: c, radius: r), start, 2 * math.pi - 2 * phi, false)
      ..close();
  }

  @override
  bool shouldReclip(_PinPortal old) => old.t != t || old.center != center;
}

class _BloomPainter extends CustomPainter {
  _BloomPainter({required this.t, required this.from, required this.to, required this.size});

  final double t;
  final Rect from;
  final Rect to;
  final Size size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final full = Offset.zero & size;
    Rect rect;
    double radius;
    Color color;
    double alpha = 1;
    if (t < 0.46) {
      final e = Curves.easeInOutCubic.transform(t / 0.46);
      rect = Rect.lerp(from, full.inflate(40), e)!;
      radius = lerp(from.height / 2, 80, e);
      color = Palette.deepTeal;
    } else {
      final e = Curves.easeInOutCubic.transform(((t - 0.46) / 0.46).clamp(0.0, 1.0));
      rect = Rect.lerp(full.inflate(40), to, e)!;
      radius = lerp(80, to.width / 2, e);
      color = Color.lerp(Palette.deepTeal, const Color(0xFF05A682), e)!;
      alpha = 1 - span(t, 0.9, 1.0, Curves.linear);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = color.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_BloomPainter old) => old.t != t;
}
