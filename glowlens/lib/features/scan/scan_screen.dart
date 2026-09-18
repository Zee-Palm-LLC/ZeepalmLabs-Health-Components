import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import 'face_stage.dart';

enum ScanPhase { idle, scanning, done }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, this.autoStart = false});

  final bool autoStart;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _intro;
  late final AnimationController _mesh;
  late final AnimationController _scan;
  late final AnimationController _zones;
  late final AnimationController _swap;
  final ValueNotifier<(Offset, double)?> _ripple = ValueNotifier(null);
  final ValueNotifier<Offset> _tilt = ValueNotifier(Offset.zero);
  Offset _tiltTarget = Offset.zero;
  Offset? _rippleOrigin;
  double _rippleStart = 0;
  ScanPhase _phase = ScanPhase.idle;
  late final MeshState _meshState;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
    _mesh = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    _scan = AnimationController(vsync: this, duration: const Duration(milliseconds: 3800));
    _zones = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100), value: 1);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_mesh.isAnimating && _mesh.value == 0) _mesh.forward();
    });
    startClock();
    clock.addListener(_tick);
    _meshState = MeshState(intro: _mesh, scan: _scan, zones: _zones, clock: clock, ripple: _ripple, tilt: _tilt);
    if (widget.autoStart) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _startScan();
      });
    }
  }

  @override
  void dispose() {
    clock.removeListener(_tick);
    _intro.dispose();
    _mesh.dispose();
    _scan.dispose();
    _zones.dispose();
    _swap.dispose();
    _ripple.dispose();
    _tilt.dispose();
    disposeClock();
    super.dispose();
  }

  void _tick() {
    final next = Offset.lerp(_tilt.value, _tiltTarget, 0.07)!;
    if ((next - _tilt.value).distanceSquared > 0.00001) _tilt.value = next;
    final origin = _rippleOrigin;
    if (origin != null) {
      final age = (clock.value - _rippleStart) / 1.2;
      if (age >= 1) {
        _rippleOrigin = null;
        _ripple.value = null;
      } else {
        _ripple.value = (origin, age);
      }
    }
  }

  Future<void> _startScan() async {
    if (_phase == ScanPhase.scanning) return;
    HapticFeedback.mediumImpact();
    if (_mesh.value < 1) {
      _mesh.stop();
      await _mesh.animateTo(1, duration: const Duration(milliseconds: 900));
    }
    _zones.value = 0;
    setState(() => _phase = ScanPhase.scanning);
    await _scan.forward(from: 0);
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() => _phase = ScanPhase.done);
    ScanResults.instance.publish();
    _zones.forward(from: 0);
  }

  Future<void> _upload() async {
    final choice = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Upload',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, _) => _UploadSheet(animation: animation),
    );
    if (choice == null || !mounted) return;
    _scan.value = 0;
    _zones.value = 0;
    setState(() => _phase = ScanPhase.idle);
    await _swap.reverse(from: 1);
    _mesh.value = 0;
    await _swap.forward();
    await _mesh.forward();
    if (mounted) _startScan();
  }

  void _touch(Offset local) {
    _rippleOrigin = local;
    _rippleStart = clock.value;
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final top = media.padding.top;
    final uploadTop = height - math.max(media.padding.bottom, 12) - 26 - 56;
    final buttonsTop = uploadTop - 72;
    final headTop = top + 150;
    final chin = buttonsTop - 21;
    final photoHeight = math.min((chin - headTop) / 0.596, width * 1.18 * 1.401);
    final photoWidth = photoHeight / 1.401;
    final photoLeft = width / 2 - meshCentre.dx * photoWidth;
    final photoTop = headTop - 0.107 * photoHeight;

    final faceCentre = Offset(width / 2, photoTop + 0.42 * photoHeight);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: Backdrop()),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _AuraPainter(clock: clock, scan: _scan, intro: _intro, centre: faceCentre),
              ),
            ),
          ),
          Positioned(
            left: photoLeft,
            top: photoTop,
            width: photoWidth,
            height: photoHeight,
            child: _photo(Size(photoWidth, photoHeight)),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SparklePainter(clock: clock, intro: _intro, centre: faceCentre, width: width),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: buttonsTop - 12,
            bottom: 0,
            child: IgnorePointer(
              child: Entrance(
                animation: stage(_intro, 0.3, 0.8),
                offset: const Offset(0, 40),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white.withValues(alpha: 0.42), Colors.white.withValues(alpha: 0.72)],
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(left: 18, right: 18, top: top + 11, child: _header()),
          Positioned(left: 19, right: 19, top: top + 72, child: _title()),
          Positioned(
            left: 22,
            right: 22,
            top: buttonsTop,
            child: Entrance(
              animation: stage(_intro, 0.35, 0.8, curve: const Cubic(0.2, 0.9, 0.25, 1.1)),
              offset: const Offset(0, 50),
              child: _scanButton(),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            top: uploadTop,
            child: Entrance(
              animation: stage(_intro, 0.45, 0.9, curve: const Cubic(0.2, 0.9, 0.25, 1.1)),
              offset: const Offset(0, 50),
              child: _uploadButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Entrance(
      animation: stage(_intro, 0, 0.4),
      offset: const Offset(0, -16),
      blur: 6,
      child: Row(
        children: [
          RoundButton(glyph: Glyph.back, onTap: () => Navigator.of(context).maybePop()),
          Expanded(
            child: Center(child: Text('Face Scan', style: inter(20, 600, spacing: -0.4))),
          ),
          RoundButton(glyph: Glyph.gallery, onTap: _upload),
        ],
      ),
    );
  }

  Widget _title() {
    final subtitle = switch (_phase) {
      ScanPhase.idle => 'Identify facial and get personalized care.',
      ScanPhase.scanning => 'Hold still, mapping 65 facial points…',
      ScanPhase.done => '3 areas detected. Your skin score is ${Analysis.score}.',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Entrance(
          animation: stage(_intro, 0.08, 0.45),
          offset: const Offset(0, 20),
          blur: 8,
          child: Text('Wrinkle Detection', style: inter(24, 700, spacing: -0.5)),
        ),
        const SizedBox(height: 6),
        Entrance(
          animation: stage(_intro, 0.14, 0.5),
          offset: const Offset(0, 14),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            layoutBuilder: (current, previous) =>
                Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              subtitle,
              key: ValueKey(_phase),
              style: inter(12.5, 400, color: Palette.muted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _photo(Size box) {
    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _swap, _tilt]),
      builder: (context, child) {
        final appear = Curves.easeOutCubic.transform(window(_intro.value, 0.05, 0.6));
        final swap = Curves.easeInOutCubic.transform(_swap.value);
        final tilt = _tilt.value;
        final blur = (1 - swap) * 14 + (1 - appear) * 10;
        Widget result = Transform(
          alignment: Alignment(meshCentre.dx * 2 - 1, meshCentre.dy * 2 - 1),
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(tilt.dx * 0.12)
            ..rotateX(-tilt.dy * 0.08)
            ..scaleByDouble(
              lerp(1.08, 1, appear) * lerp(0.92, 1, swap),
              lerp(1.08, 1, appear) * lerp(0.92, 1, swap),
              1,
              1,
            ),
          child: child,
        );
        if (blur > 0.2) {
          result = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: result,
          );
        }
        return Opacity(opacity: (appear * swap).clamp(0.0, 1.0), child: result);
      },
      child: GestureDetector(
        onTapUp: (d) => _touch(d.localPosition),
        onPanUpdate: (d) {
          _tiltTarget = Offset(
            (d.localPosition.dx / box.width * 2 - 1).clamp(-1.0, 1.0),
            (d.localPosition.dy / box.height * 2 - 1).clamp(-1.0, 1.0),
          );
        },
        onPanEnd: (_) => _tiltTarget = Offset.zero,
        child: MouseRegion(
          onHover: (e) => _tiltTarget =
              Offset(e.localPosition.dx / box.width * 2 - 1, e.localPosition.dy / box.height * 2 - 1) * 0.6,
          onExit: (_) => _tiltTarget = Offset.zero,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const RadialGradient(
                    center: Alignment(0.11, -0.2),
                    radius: 0.82,
                    colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
                    stops: [0, 0.7, 1],
                  ).createShader(rect),
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
                      stops: [0, 0.74, 0.97],
                    ).createShader(rect),
                    child: Image.asset(
                      'assets/images/face.webp',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: FaceMeshPainter(_meshState, scanning: _phase == ScanPhase.scanning)),
                ),
              ),
              ..._zoneChips(box),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _zoneChips(Size box) {
    const anchors = [Offset(0.555, 0.205), Offset(0.79, 0.345), Offset(0.36, 0.49)];
    return [
      for (var i = 0; i < 3; i++)
        Positioned(
          left: anchors[i].dx * box.width,
          top: anchors[i].dy * box.height,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: AnimatedBuilder(
              animation: _zones,
              builder: (context, child) {
                final t = window(_zones.value, 0.12 + i * 0.18, 0.62 + i * 0.18);
                if (t <= 0) return const SizedBox.shrink();
                return Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.scale(scale: Curves.elasticOut.transform(t), child: child),
                );
              },
              child: _ZoneChip(area: Analysis.areas[i]),
            ),
          ),
        ),
    ];
  }

  Widget _scanButton() {
    return AnimatedBuilder(
      animation: _scan,
      builder: (context, _) {
        final (label, glyph) = switch (_phase) {
          ScanPhase.idle => ('Scan Your Face', Glyph.camera),
          ScanPhase.scanning => ('Scanning ${(_scan.value * 100).round()}%', null),
          ScanPhase.done => ('View Analysis', Glyph.arrowRight),
        };
        return GradientPill(
          label: label,
          glyph: glyph,
          labelKey: _phase,
          progress: _phase == ScanPhase.scanning ? _scan.value : null,
          shimmer: _phase != ScanPhase.scanning,
          onTap: switch (_phase) {
            ScanPhase.idle => _startScan,
            ScanPhase.scanning => null,
            ScanPhase.done => () => Navigator.of(context).pop('analytic'),
          },
        );
      },
    );
  }

  Widget _uploadButton() {
    final again = _phase == ScanPhase.done;
    return Pressable(
      onTap: again ? _startScan : _upload,
      scale: 0.96,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Color(0x147A4FA0), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Row(
            key: ValueKey(again),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlyphIcon(again ? Glyph.camera : Glyph.upload, size: 19, stroke: 1.7),
              const SizedBox(width: 9),
              Text(again ? 'Scan Again' : 'Upload Photo', style: inter(15, 600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  const _ZoneChip({required this.area});

  final Area area;

  @override
  Widget build(BuildContext context) {
    final mild = area.severity == Severity.mild;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 11, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x26A14FB0), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: mild ? const LinearGradient(colors: [Color(0xFF9DB0F2), Palette.periwinkle]) : Palette.brand,
            ),
          ),
          const SizedBox(width: 6),
          Text(area.name, style: inter(11, 600)),
          const SizedBox(width: 4),
          Text('· ${area.severityLabel}', style: inter(11, 500, color: mild ? Palette.periwinkle : Palette.orchid)),
        ],
      ),
    );
  }
}

class _UploadSheet extends StatelessWidget {
  const _UploadSheet({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final rise = animation.status == AnimationStatus.reverse
            ? Curves.easeInCubic.transform(t)
            : const Cubic(0.16, 1, 0.3, 1).transform(t);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10 * t, sigmaY: 10 * t),
                  child: ColoredBox(color: const Color(0xFF2A1640).withValues(alpha: 0.18 * t)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FractionalTranslation(translation: Offset(0, 1 - rise), child: child),
            ),
          ],
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Palette.hairline, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Add a photo', style: inter(19, 700)),
            const SizedBox(height: 4),
            Text('Face the light, no makeup, hair off the forehead.', style: inter(12.5, 400, color: Palette.muted)),
            const SizedBox(height: 18),
            Row(
              children: [
                for (final (i, glyph, label, value) in [
                  (0, Glyph.camera, 'Take a selfie', 'camera'),
                  (1, Glyph.gallery, 'From gallery', 'gallery'),
                ]) ...[
                  if (i == 1) const SizedBox(width: 12),
                  Expanded(
                    child: Entrance(
                      animation: stage(animation, 0.3 + i * 0.12, 0.8 + i * 0.1, curve: Curves.easeOutBack),
                      offset: const Offset(0, 40),
                      child: Pressable(
                        onTap: () => Navigator.of(context).pop(value),
                        child: SizedBox(
                          height: 120,
                          child: HoloSurface(
                            tone: i == 0 ? HoloTone.upload : HoloTone.area,
                            radius: 20,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: Center(child: GlyphIcon(glyph, size: 22, gradient: Palette.brand)),
                                ),
                                const SizedBox(height: 10),
                                Text(label, style: inter(13.5, 600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuraPainter extends CustomPainter {
  _AuraPainter({required this.clock, required this.scan, required this.intro, required this.centre})
    : super(repaint: Listenable.merge([clock, scan, intro]));

  final ValueNotifier<double> clock;
  final Animation<double> scan;
  final Animation<double> intro;
  final Offset centre;

  @override
  void paint(Canvas canvas, Size size) {
    final s = clock.value;
    final show = window(intro.value, 0, 0.6, Curves.easeOut);
    final boost = scan.value > 0 && scan.value < 1 ? math.sin(scan.value * math.pi) : 0.0;
    final breathe = 1 + 0.06 * math.sin(s * 1.3);
    const blobs = [(Color(0x80D7B6F7), 0.0, 175.0), (Color(0x70FBC3D6), 2.1, 160.0), (Color(0x60BFD6F8), 4.2, 150.0)];
    for (final (color, phase, radius) in blobs) {
      final a = s * 0.35 + phase;
      final c = centre + Offset(math.cos(a) * 46, math.sin(a) * 30);
      final r = radius * breathe * show * (1 + boost * 0.25);
      if (r <= 0) continue;
      final alpha = (color.a * (0.8 + boost * 0.6)).clamp(0.0, 1.0);
      canvas.drawCircle(
        c,
        r,
        Paint()..shader = ui.Gradient.radial(c, r, [color.withValues(alpha: alpha), color.withValues(alpha: 0)]),
      );
    }
  }

  @override
  bool shouldRepaint(_AuraPainter oldDelegate) => oldDelegate.centre != centre;
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.clock, required this.intro, required this.centre, required this.width})
    : super(repaint: Listenable.merge([clock, intro]));

  final ValueNotifier<double> clock;
  final Animation<double> intro;
  final Offset centre;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final s = clock.value;
    final show = window(intro.value, 0.5, 1);
    if (show <= 0) return;
    for (var i = 0; i < 11; i++) {
      final seed = math.sin(i * 78.233) * 43758.5453;
      final r = seed - seed.floorToDouble();
      final angle = i / 11 * math.pi * 2 + r;
      final rise = (s * (0.05 + r * 0.05) + r) % 1;
      final base = centre + Offset(math.cos(angle) * width * 0.44, math.sin(angle) * width * 0.52);
      final p = base + Offset(math.sin(s * 0.8 + i) * 8, -rise * 60);
      final twinkle = math.pow(math.max(0.0, math.sin((s * (0.6 + r) + r * 7) * math.pi)), 2).toDouble();
      final fade = math.sin(rise * math.pi) * twinkle * show;
      if (fade < 0.02) continue;
      final size = 3 + r * 4;
      canvas.drawCircle(
        p,
        size * 1.6,
        Paint()
          ..color = const Color(0xFFF7B7D6).withValues(alpha: 0.45 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      final star = Path()
        ..moveTo(p.dx, p.dy - size)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + size, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + size)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - size, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - size)
        ..close();
      canvas.drawPath(star, Paint()..color = Colors.white.withValues(alpha: fade));
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.centre != centre;
}
