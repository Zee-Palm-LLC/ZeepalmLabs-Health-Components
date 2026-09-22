import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../core/widgets.dart';
import '../../scene/sky.dart';
import '../../scene/vessel.dart';
import '../../sound/mixer.dart';
import '../mix/sheets.dart';

Route<T> sleepRoute<T>(Widget page) =>
    dreamRoute<T>(page, duration: const Duration(milliseconds: 750));

String clockText(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _dim;
  late final NebulaDriver _nebula;
  late final Mixer _mixer;
  late final List<Twinkle> _stars;
  late final AnimationController _pull;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _dim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pull = AnimationController.unbounded(vsync: this);
    _mixer = MixerScope.read(context);
    _nebula = NebulaDriver(
      NebulaMix.of(_mixer.sounds, _mixer.volume),
      fill: 1,
      energy: 1.05,
    );
    _mixer.addListener(_onMixer);
    _stars = scatterStars(
      count: 46,
      seed: 9,
      accept: (u) {
        final x = u.dx * 393;
        final y = u.dy * 240 + 40;
        if ((Offset(x, y) - const Offset(253, 128)).distance < 50) return false;
        if (x > 345) return false;
        final ridge = x < 170 ? 150 + x * 0.35 : 215 + (x - 170) * 0.1;
        return y < ridge;
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mixer.play();
    });
  }

  void _onMixer() {
    _nebula.retarget(NebulaMix.of(_mixer.sounds, _mixer.volume));
  }

  void _dragUpdate(DragUpdateDetails d) {
    final next = _pull.value + d.delta.dy;
    _pull.value = next < 0 ? next * 0.2 : next;
  }

  void _dragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (_pull.value > 110 || v > 800) {
      HapticFeedback.lightImpact();
      Navigator.of(context).maybePop();
      return;
    }
    _pull.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 320, damping: 30),
        _pull.value,
        0,
        v,
      ),
    );
  }

  @override
  void dispose() {
    _mixer.removeListener(_onMixer);
    _intro.dispose();
    _dim.dispose();
    _pull.dispose();
    _nebula.dispose();
    super.dispose();
  }

  void _lightsOut() {
    HapticFeedback.lightImpact();
    _dim.forward();
  }

  void _wake() {
    if (_dim.value > 0) _dim.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final mixer = MixerScope.of(context);
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Night.deep,
      body: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          final s = w / 393;
          final plateH = w * 1560 / 1179;
          final cardTop = math.max(h - 427 * s, mq.padding.top + 300 * s);
          final textShift = cardTop - 425 * s;
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _wake,
            onVerticalDragStart: (_) => _pull.stop(),
            onVerticalDragUpdate: _dragUpdate,
            onVerticalDragEnd: _dragEnd,
            child: AnimatedBuilder(
              animation: Listenable.merge([_dim, _pull]),
              builder: (context, child) {
                final t = Ease.inOut.transform(_dim.value);
                final pull = _pull.value;
                return Transform.translate(
                  offset: Offset(0, pull * 0.55),
                  child: Stack(
                    children: [
                      child!,
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: t < 0.5,
                          child: Opacity(
                            opacity: t,
                            child: _LightsOut(
                              onWake: _wake,
                              mixer: mixer,
                              scale: s,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: math.min(0.0, textShift * 0.6),
                    height: plateH,
                    child: Staged(
                      controller: _intro,
                      end: 0.6,
                      scaleFrom: 1.05,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/sleep_lake.jpg',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                          IgnorePointer(
                            child: CustomPaint(painter: _Sky(_stars, s)),
                          ),
                          IgnorePointer(
                            child: CustomPaint(
                              painter: ShimmerPainter(
                                const Offset(258 / 393, 318 / 520),
                                const Size(0.2, 0.2),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 253 * s - 30 * s,
                            top: 128 * s - 30 * s,
                            child: Crescent(
                              radius: 30 * s,
                              cut: const Offset(0.36, -0.3),
                              cutScale: 0.9,
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x66070914),
                                  Color(0x00070914),
                                  Color(0x00070914),
                                  Color(0xFF0B0E1D),
                                ],
                                stops: [0, 0.14, 0.72, 1],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16 * s,
                    top: mq.padding.top + 6 * s,
                    child: Staged(
                      controller: _intro,
                      begin: 0.3,
                      end: 0.8,
                      child: Pressable(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: GlassCircle(
                          size: 38 * s,
                          fill: const Color(0x1A0B0E1D),
                          border: const Color(0x2EFFFFFF),
                          child: Glyph(
                            G.chevronDown,
                            size: 18 * s,
                            color: Night.text,
                            stroke: 1.8 * s,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 25 * s,
                    right: 25 * s,
                    top: 211 * s + textShift,
                    child: Staged(
                      controller: _intro,
                      begin: 0.2,
                      end: 0.75,
                      slide: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sleep Well',
                            style: Typo.ui(
                              16 * s,
                              color: const Color(0xFFE6E5F2),
                              weight: 430,
                            ),
                          ),
                          SizedBox(height: 12 * s),
                          Text(
                            'You’re Almost\nThere',
                            style: Typo.serifText(
                              27.5 * s,
                              height: 1.35,
                              spacing: -0.2 * s,
                              weight: 430,
                            ),
                          ),
                          SizedBox(height: 6 * s),
                          Text(
                            'Let the sounds guide you into\na deeper, calmer sleep.',
                            style: Typo.ui(
                              14.5 * s,
                              color: const Color(0xFFD3D1E2),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4 * s,
                    right: 4 * s,
                    top: cardTop,
                    bottom: 0,
                    child: Staged(
                      controller: _intro,
                      begin: 0.3,
                      end: 0.95,
                      slide: 40,
                      child: _Card(
                        nebula: _nebula,
                        mixer: mixer,
                        scale: s,
                        onLightsOut: _lightsOut,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Sky extends CustomPainter {
  _Sky(this.stars, this.scale) : _inner = StarsPainter(stars, opacity: 0.9);

  final List<Twinkle> stars;
  final double scale;
  final StarsPainter _inner;

  @override
  void addListener(VoidCallback listener) => _inner.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _inner.removeListener(listener);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, 40 * scale);
    _inner.paint(canvas, Size(size.width, 240 * scale));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Sky old) => old.stars != stars || old.scale != scale;
}

class _Card extends StatelessWidget {
  const _Card({
    required this.nebula,
    required this.mixer,
    required this.scale,
    required this.onLightsOut,
  });

  final NebulaDriver nebula;
  final Mixer mixer;
  final double scale;
  final VoidCallback onLightsOut;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.vertical(
      top: Radius.circular(34 * s),
      bottom: Radius.circular(44 * s),
    );
    return Blurred(
      radius: radius,
      sigma: 24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xE61D1B38), Color(0xF2121429), Color(0xFA0C0F21)],
            stops: [0, 0.25, 1],
          ),
          border: Border.all(color: const Color(0x24C9C0FF)),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0, 0.12],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 22 * s,
              top: 21 * s,
              width: 84 * s,
              height: 84 * s,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16 * s),
                  border: Border.all(color: const Color(0x2EFFFFFF)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B4BD8).withValues(alpha: 0.35),
                      blurRadius: 22 * s,
                      spreadRadius: -4 * s,
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'nebula',
                  child: NebulaArt(driver: nebula, radius: 16 * s),
                ),
              ),
            ),
            Positioned(
              left: 127 * s,
              right: 60 * s,
              top: 33 * s,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topLeft,
                  children: [...previous, ?current],
                ),
                child: Column(
                  key: ValueKey(mixer.name + mixer.subtitle),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mixer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Typo.serifText(16 * s, weight: 470, height: 1.3),
                    ),
                    SizedBox(height: 5 * s),
                    Text(
                      mixer.sounds.isEmpty ? 'Silence' : mixer.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Typo.ui(12.2 * s, color: const Color(0xFFB2AFCA)),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 24 * s,
              top: 34 * s,
              child: Pressable(
                onTap: mixer.toggleLike,
                child: Padding(
                  padding: EdgeInsets.all(4 * s),
                  child: Glyph(
                    mixer.liked ? G.heartFill : G.heart,
                    size: 22 * s,
                    color: mixer.liked ? Night.lavenderSoft : Night.text,
                    stroke: 1.5 * s,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28 * s,
              right: 23 * s,
              top: 126 * s,
              height: 20 * s,
              child: CustomPaint(painter: _Progress(mixer.progress)),
            ),
            Positioned(
              left: 23 * s,
              top: 151 * s,
              child: Text(
                clockText(mixer.elapsed),
                style: Typo.ui(
                  12 * s,
                  color: const Color(0xFFABA8C2),
                  spacing: 0.2,
                ),
              ),
            ),
            Positioned(
              right: 23 * s,
              top: 151 * s,
              child: Text(
                '-${clockText(mixer.remaining)}',
                style: Typo.ui(
                  12 * s,
                  color: const Color(0xFFABA8C2),
                  spacing: 0.2,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 224 * s - 37 * s,
              height: 74 * s,
              child: _Controls(
                mixer: mixer,
                scale: s,
                onLightsOut: onLightsOut,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 312 * s,
              child: Text(
                '“A calmer mind\nleads to a brighter tomorrow.”',
                textAlign: TextAlign.center,
                style: Typo.serifText(
                  14 * s,
                  color: const Color(0xFFC9C6DA),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends CustomPainter {
  _Progress(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final x0 = 5.0;
    final x1 = size.width;
    canvas.drawLine(
      Offset(x0, y),
      Offset(x1, y),
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x809C92D6),
    );
    final x = x0 + (x1 - x0) * value;
    final lead = math.max(x, x0 + (x1 - x0) * 0.14);
    canvas.drawLine(
      Offset(x0, y),
      Offset(lead, y),
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFA79CE6),
    );
    canvas.drawCircle(
      Offset(x, y),
      9,
      Paint()
        ..color = const Color(0xFFBDB3FF).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset(x, y),
      5.5,
      Paint()..color = const Color(0xFFF5F3FF),
    );
  }

  @override
  bool shouldRepaint(_Progress old) => old.value != value;
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.mixer,
    required this.scale,
    required this.onLightsOut,
  });

  final Mixer mixer;
  final double scale;
  final VoidCallback onLightsOut;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const soft = Color(0xFFA7A1DE);
    Widget at(double x, Widget child) => Positioned(
      left: x * s - 37 * s,
      top: 0,
      width: 74 * s,
      height: 74 * s,
      child: Center(child: child),
    );
    return Stack(
      children: [
        at(
          46,
          Pressable(
            onTap: () => showLevelsSheet(context),
            child: Padding(
              padding: EdgeInsets.all(8 * s),
              child: Glyph(
                G.sliders,
                size: 24 * s,
                color: Night.text,
                stroke: 1.6 * s,
              ),
            ),
          ),
        ),
        at(
          112,
          Pressable(
            onTap: () => mixer.step(-1),
            child: Padding(
              padding: EdgeInsets.all(8 * s),
              child: Glyph(G.prev, size: 22 * s, color: soft),
            ),
          ),
        ),
        at(
          193,
          Pressable(
            onTap: mixer.togglePlay,
            child: Container(
              width: 74 * s,
              height: 74 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.2, -0.5),
                  radius: 1,
                  colors: [Color(0x2EFFFFFF), Color(0x14FFFFFF)],
                ),
                border: Border.all(color: const Color(0x14FFFFFF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (c, a) => ScaleTransition(
                  scale: a,
                  child: FadeTransition(opacity: a, child: c),
                ),
                child: Glyph(
                  mixer.playing ? G.pause : G.play,
                  key: ValueKey(mixer.playing),
                  size: 30 * s,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        at(
          274,
          Pressable(
            onTap: () => mixer.step(1),
            child: Padding(
              padding: EdgeInsets.all(8 * s),
              child: Glyph(G.next, size: 22 * s, color: soft),
            ),
          ),
        ),
        at(
          341,
          Pressable(
            onTap: onLightsOut,
            child: GlassCircle(
              size: 42 * s,
              fill: const Color(0x12FFFFFF),
              border: const Color(0x0FFFFFFF),
              child: Glyph(G.moonFill, size: 22 * s, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _LightsOut extends StatelessWidget {
  const _LightsOut({
    required this.onWake,
    required this.mixer,
    required this.scale,
  });

  final VoidCallback onWake;
  final Mixer mixer;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onWake,
      child: Container(
        color: const Color(0xF7030409),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Crescent(radius: 26 * s, glow: 0.6),
            SizedBox(height: 28 * s),
            Text(
              'Sleep well',
              style: Typo.serifText(22 * s, color: const Color(0x99E8E4FF)),
            ),
            SizedBox(height: 8 * s),
            Text(
              '${clockText(mixer.remaining)} remaining',
              style: Typo.ui(
                12.5 * s,
                color: const Color(0x668E8BA8),
                spacing: 1.2,
              ),
            ),
            SizedBox(height: 40 * s),
            Text(
              'Tap to wake',
              style: Typo.ui(
                11 * s,
                color: const Color(0x408E8BA8),
                spacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
