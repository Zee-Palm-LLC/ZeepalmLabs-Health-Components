import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../core/widgets.dart';
import '../../scene/clock.dart';
import '../../scene/orb.dart';
import '../../scene/streams.dart';
import '../../scene/vessel.dart';
import '../../sound/mixer.dart';
import '../../sound/sounds.dart';
import '../home/home_screen.dart';
import '../sleep/sleep_screen.dart';
import 'sheets.dart';

Route<T> mixRoute<T>(Widget page) =>
    dreamRoute<T>(page, duration: const Duration(milliseconds: 700));

class MixScreen extends StatefulWidget {
  const MixScreen({super.key});

  @override
  State<MixScreen> createState() => MixScreenState();
}

class MixScreenState extends State<MixScreen> with TickerProviderStateMixin {
  late final AnimationController intro;
  late final AnimationController pour;
  late final NebulaDriver nebula;
  late Mixer _mixer;
  Sound? _focus;
  int _generation = 0;
  bool _timerTouched = false;

  @override
  void initState() {
    super.initState();
    intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    pour = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _mixer = MixerScope.read(context);
    nebula = NebulaDriver(
      NebulaMix.of(_mixer.sounds, _mixer.volume),
      fill: 0,
      energy: _energyFor(_mixer),
    );
    nebula.fillRate = 0.42;
    _generation = _mixer.pourGeneration;
    _mixer.addListener(_onMixer);
    pour.addListener(_onPour);
    Future.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      pour.forward(from: 0);
      _mixer.play();
    });
  }

  double _energyFor(Mixer m) => 0.55 + 0.6 * m.master;

  void _onPour() {
    if (pour.value > 0.3) {
      nebula.retarget(NebulaMix.of(_mixer.sounds, _mixer.volume), fill: 1);
    }
  }

  void _onMixer() {
    if (!mounted) return;
    if (_mixer.pourGeneration != _generation) {
      _generation = _mixer.pourGeneration;
      nebula.retarget(NebulaMix.of(_mixer.sounds, _mixer.volume), fill: 0.2);
      pour.forward(from: 0);
    } else {
      nebula.retarget(
        NebulaMix.of(_mixer.sounds, _mixer.volume),
        energy: _energyFor(_mixer),
      );
    }
    if (_focus != null && !_mixer.contains(_focus!)) _focus = null;
    setState(() {});
  }

  @override
  void dispose() {
    _mixer.removeListener(_onMixer);
    intro.dispose();
    pour.dispose();
    nebula.dispose();
    super.dispose();
  }

  void _tapOrb(Sound s) {
    setState(() => _focus = _focus == s ? null : s);
  }

  Future<void> _add() async {
    setState(() => _focus = null);
    final picked = await showSoundPicker(context);
    if (picked != null && mounted) {
      _mixer.toggle(picked);
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _timer() async {
    final d = await showTimerSheet(context, _mixer.timer);
    if (d != null && mounted) {
      _mixer.setTimer(d);
      setState(() => _timerTouched = true);
      if (!mounted) return;
      Toast.show(
        context,
        'Sleep timer set for ${d.inMinutes} minutes',
        glyph: G.timer,
      );
    }
  }

  void _save() {
    _mixer.toggleLike();
    Toast.show(
      context,
      _mixer.liked ? 'Saved to your Library' : 'Removed from your Library',
      glyph: _mixer.liked ? G.heartFill : G.heart,
    );
  }

  bool _leaving = false;

  Future<void> _ambient() async {
    if (_leaving) return;
    _leaving = true;
    Toast.dismiss();
    await Navigator.of(context).push(sleepRoute(const SleepScreen()));
    _leaving = false;
  }

  @override
  Widget build(BuildContext context) {
    final mixer = MixerScope.of(context);
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Night.base,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_focus != null) setState(() => _focus = null);
        },
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            final s = w / 393;
            final top = mq.padding.top;
            final bottom = math.max(mq.padding.bottom, 12.0);
            final layout = MixLayout.compute(
              Size(w, h),
              top,
              bottom,
              mixer.sounds.length,
            );
            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(child: _MixBackdrop()),
                Positioned.fill(
                  child: Staged(
                    controller: intro,
                    begin: 0.05,
                    end: 0.7,
                    scaleFrom: 0.94,
                    child: Vessel(driver: nebula, geometry: layout.vessel),
                  ),
                ),
                Positioned.fromRect(
                  rect: Rect.fromCircle(
                    center: layout.vessel.center,
                    radius: layout.vessel.radius * 0.8,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_focus != null) {
                        setState(() => _focus = null);
                      } else if (mixer.sounds.isNotEmpty) {
                        HapticFeedback.lightImpact();
                        _ambient();
                      }
                    },
                    child: Hero(
                      tag: 'nebula',
                      flightShuttleBuilder: nebulaFlight(nebula, 16 * s),
                      createRectTween: arcTween,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: pour,
                      builder: (context, _) => CustomPaint(
                        painter: StreamsPainter(_streams(layout, mixer)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: layout.headerY - 25 * s,
                  height: 50 * s,
                  child: Staged(
                    controller: intro,
                    end: 0.5,
                    slide: -8,
                    child: _header(s, mixer),
                  ),
                ),
                for (var i = 0; i < mixer.sounds.length; i++)
                  _orbSlot(i, mixer.sounds[i], layout, s),
                if (mixer.sounds.length < Mixer.maxSounds)
                  _addSlot(layout, s, mixer.sounds.length),
                Positioned(
                  left: 0,
                  right: 0,
                  top: layout.blendY - 12 * s,
                  height: 24 * s,
                  child: Staged(
                    controller: intro,
                    begin: 0.3,
                    end: 0.8,
                    child: Center(child: _blendLabel(s, mixer)),
                  ),
                ),
                Positioned(
                  left: 22 * s,
                  right: 22 * s,
                  top: layout.sliderY - 18 * s,
                  height: 36 * s,
                  child: Staged(
                    controller: intro,
                    begin: 0.35,
                    end: 0.85,
                    slide: 8,
                    child: _slider(s, mixer),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: layout.actionsY - 13 * s,
                  child: Staged(
                    controller: intro,
                    begin: 0.42,
                    end: 0.95,
                    slide: 10,
                    child: _actions(s, mixer),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<StreamLine> _streams(MixLayout layout, Mixer mixer) {
    final out = <StreamLine>[];
    final n = mixer.sounds.length;
    final slots = n < Mixer.maxSounds ? n + 1 : n;
    for (var i = 0; i < n; i++) {
      final sound = mixer.sounds[i];
      final start = 0.08 * i;
      final p = ((pour.value - start) / 0.5).clamp(0.0, 1.0);
      final focusDim = _focus == null || _focus == sound ? 1.0 : 0.45;
      out.add(
        StreamLine(
          from: layout.streamStart(i, slots),
          to: layout.streamEnd(i, n),
          color: sound.glow,
          level: mixer.volume(sound) * focusDim * (0.6 + 0.6 * mixer.master),
          progress: Ease.inOut.transform(p),
        ),
      );
    }
    return out;
  }

  Widget _header(double s, Mixer mixer) {
    return Stack(
      children: [
        Positioned(
          left: 20 * s,
          top: 7 * s,
          child: Pressable(
            onTap: () => Navigator.of(context).maybePop(),
            child: GlassCircle(
              size: 36 * s,
              fill: const Color(0x0FFFFFFF),
              border: const Color(0x24FFFFFF),
              child: Glyph(
                G.back,
                size: 17 * s,
                color: Night.text,
                stroke: 1.7 * s,
              ),
            ),
          ),
        ),
        Positioned(
          left: 80 * s,
          right: 80 * s,
          top: 0,
          child: Column(
            children: [
              Text(
                'Your Mix',
                style: Typo.ui(
                  15 * s,
                  color: const Color(0xFFC3C2D6),
                  weight: 380,
                ),
              ),
              SizedBox(height: 2 * s),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(a),
                    child: child,
                  ),
                ),
                child: Text(
                  mixer.poem,
                  key: ValueKey(mixer.poem),
                  style: Typo.serifText(
                    19.5 * s,
                    color: Night.text,
                    weight: 430,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 20 * s,
          top: 8 * s,
          child: Pressable(
            onTap: () {
              setState(() => _focus = null);
              mixer.reset();
            },
            child: Container(
              width: 70 * s,
              height: 34 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17 * s),
                color: const Color(0x0DFFFFFF),
                border: Border.all(color: const Color(0x24FFFFFF)),
              ),
              child: Text(
                'Reset',
                style: Typo.ui(13 * s, color: Night.text, weight: 450),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _orbSlot(int i, Sound sound, MixLayout layout, double s) {
    final n = MixerScope.read(context).sounds.length;
    final c = layout.orbCenter(i, n < Mixer.maxSounds ? n + 1 : n);
    final d = layout.orbSize;
    final focused = _focus == sound;
    final dimmed = _focus != null && !focused;
    final delay = 0.12 + i * 0.06;
    return AnimatedPositioned(
      key: ValueKey('slot-${sound.name}'),
      duration: const Duration(milliseconds: 620),
      curve: Ease.out,
      left: c.dx - 50 * s,
      top: c.dy - d / 2,
      width: 100 * s,
      height: d + 60 * s,
      child: Staged(
        controller: intro,
        begin: delay,
        end: delay + 0.5,
        slide: 12,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 360),
          opacity: dimmed ? 0.55 : 1,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Pressable(
                onTap: () => _tapOrb(sound),
                onLongPress: () => MixerScope.read(context).remove(sound),
                child: Column(
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.easeOutBack,
                      scale: focused ? 1.1 : 1,
                      child: Hero(
                        tag: 'orb-${sound.name}',
                        flightShuttleBuilder: orbFlight(sound),
                        createRectTween: arcTween,
                        child: Orb(
                          sound: sound,
                          diameter: d,
                          glow: focused ? 1.3 : 1.05,
                          life: 1.05,
                        ),
                      ),
                    ),
                    SizedBox(height: 14 * s),
                    Text(
                      sound.label,
                      style: Typo.ui(
                        13.6 * s,
                        color: Night.text,
                        weight: focused ? 600 : 500,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 6 * s,
                top: -4 * s,
                child: IgnorePointer(
                  ignoring: !focused,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutBack,
                    scale: focused ? 1 : 0,
                    child: Pressable(
                      onTap: () {
                        MixerScope.read(context).remove(sound);
                        HapticFeedback.mediumImpact();
                      },
                      child: Container(
                        width: 24 * s,
                        height: 24 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E1C3A),
                          border: Border.all(color: const Color(0x40FFFFFF)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x80000000), blurRadius: 8),
                          ],
                        ),
                        child: Glyph(
                          G.close,
                          size: 12 * s,
                          color: Night.text,
                          stroke: 1.8 * s,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addSlot(MixLayout layout, double s, int n) {
    final c = layout.orbCenter(n, n + 1);
    final d = layout.orbSize;
    return AnimatedPositioned(
      key: const ValueKey('slot-add'),
      duration: const Duration(milliseconds: 620),
      curve: Ease.out,
      left: c.dx - 50 * s,
      top: c.dy - d / 2,
      width: 100 * s,
      height: d + 60 * s,
      child: Staged(
        controller: intro,
        begin: 0.35,
        end: 0.85,
        child: Pressable(
          onTap: _add,
          child: Column(
            children: [
              SizedBox.square(
                dimension: d,
                child: CustomPaint(
                  painter: _DashedRing(),
                  child: Center(
                    child: Glyph(
                      G.plus,
                      size: 22 * s,
                      color: Night.lavenderSoft,
                      stroke: 1.6 * s,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 11 * s),
              Text(
                'Add',
                style: Typo.ui(13.6 * s, color: Night.textDim, weight: 500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blendLabel(double s, Mixer mixer) {
    final focus = _focus;
    final text = focus == null
        ? (mixer.sounds.isEmpty
              ? 'Add a sound to begin'
              : 'Blending Your Peace')
        : '${focus.label}  ·  ${(mixer.volume(focus) * 100).round()}%';
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(focus?.name ?? text),
        style: Typo.ui(14 * s, color: const Color(0xFFE1E0EE), weight: 430),
      ),
    );
  }

  Widget _slider(double s, Mixer mixer) {
    final focus = _focus;
    final value = focus == null ? mixer.master : mixer.volume(focus);
    final colors = focus == null
        ? const [Color(0xFF3E5FE6), Color(0xFFA7B4FF)]
        : [
            Color.lerp(focus.mid, focus.glow, 0.3)!,
            Color.lerp(focus.glow, Colors.white, 0.45)!,
          ];
    return Row(
      children: [
        Pressable(
          onTap: () => focus == null
              ? mixer.setMaster(mixer.master > 0 ? 0 : 0.62)
              : mixer.setVolume(focus, value > 0 ? 0 : 0.64),
          child: SizedBox(
            width: 36 * s,
            height: 36 * s,
            child: Center(
              child: Glyph(
                G.speaker,
                size: 24 * s,
                color: Night.text,
                stroke: 1.6 * s,
              ),
            ),
          ),
        ),
        SizedBox(width: 6 * s),
        Expanded(
          child: NightSlider(
            value: value,
            colors: colors,
            onChanged: (v) =>
                focus == null ? mixer.setMaster(v) : mixer.setVolume(focus, v),
          ),
        ),
      ],
    );
  }

  Widget _actions(double s, Mixer mixer) {
    return Row(
      children: [
        Expanded(
          child: IconLabel(
            glyph: G.timer,
            label: _timerTouched ? '${mixer.timer.inMinutes} min' : 'Timer',
            onTap: _timer,
          ),
        ),
        Expanded(
          child: IconLabel(
            glyph: mixer.liked ? G.heartFill : G.heart,
            label: 'Save Mix',
            onTap: _save,
            active: mixer.liked,
          ),
        ),
        Expanded(
          child: IconLabel(
            glyph: G.waveform,
            label: 'Ambient',
            onTap: _ambient,
          ),
        ),
      ],
    );
  }
}

class MixLayout {
  MixLayout._(
    this.size,
    this.scale,
    this.headerY,
    this.orbY,
    this.orbSize,
    this.vessel,
    this.blendY,
    this.sliderY,
    this.actionsY,
  );

  final Size size;
  final double scale;
  final double headerY;
  final double orbY;
  final double orbSize;
  final VesselGeometry vessel;
  final double blendY;
  final double sliderY;
  final double actionsY;

  static MixLayout compute(Size size, double top, double bottom, int count) {
    final s = size.width / 393;
    final h = size.height;
    final headerY = top + 39 * s;
    final orbY = top + 146 * s;
    final actionsY = h - bottom - 35 * s;
    final sliderY = h - bottom - 97 * s;
    final blendY = h - bottom - 136 * s;
    final vesselBottom = h - bottom - 171 * s;
    final lipLimit = orbY + 152 * s;
    final radius = math.min(151.5 * s, (vesselBottom - lipLimit) / 1.885);
    final center = Offset(size.width / 2, vesselBottom - radius);
    return MixLayout._(
      size,
      s,
      headerY,
      orbY,
      72 * s,
      VesselGeometry(center, radius),
      blendY,
      sliderY,
      actionsY,
    );
  }

  Offset orbCenter(int i, int n) {
    final pitch = 98.7 * scale;
    final span = (n - 1) * pitch;
    return Offset(size.width / 2 - span / 2 + i * pitch, orbY);
  }

  Offset streamStart(int i, int n) => orbCenter(i, n) + Offset(0, 72 * scale);

  Offset streamEnd(int i, int n) {
    final spread = n <= 1 ? 0.0 : (i / (n - 1) - 0.5);
    return vessel.mouth +
        Offset(
          spread * vessel.mouthHalf * 0.55 + 4 * scale,
          vessel.radius * 0.1,
        );
  }
}

class _MixBackdrop extends StatelessWidget {
  const _MixBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1124), Color(0xFF0B0F20), Color(0xFF0D1123)],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0.15),
            radius: 0.75,
            colors: [Color(0x1A4B45B8), Color(0x004B45B8)],
          ),
        ),
      ),
    );
  }
}

class _DashedRing extends CustomPainter {
  _DashedRing() : super(repaint: SceneClock.instance);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 1;
    final t = SceneClock.instance.value;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x66B9A9FF);
    const n = 28;
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2 + t * 0.15;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        a,
        math.pi * 2 / n * 0.5,
        false,
        paint,
      );
    }
    canvas.drawCircle(
      c,
      r * 0.9,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x1A9C88F2), Color(0x009C88F2)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_DashedRing old) => false;
}
