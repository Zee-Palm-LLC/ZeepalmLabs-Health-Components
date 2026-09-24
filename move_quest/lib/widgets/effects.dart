import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/sprites.dart';

class Motes extends StatelessWidget {
  const Motes({
    super.key,
    required this.area,
    this.count = 26,
    this.colors = const [Color(0xFF9FE8FF), Color(0xFFFFE9A8), Color(0xFFD6B8FF)],
    this.seed = 7,
    this.size = 2.2,
    this.opacity = 1,
  });

  final Rect area;
  final int count;
  final List<Color> colors;
  final int seed;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: area,
      child: IgnorePointer(
        child: Tick(
          builder: (context, s, _) => CustomPaint(painter: _MotesPainter(s, count, colors, seed, size, opacity)),
        ),
      ),
    );
  }
}

class _MotesPainter extends CustomPainter {
  _MotesPainter(this.s, this.count, this.colors, this.seed, this.dot, this.opacity);

  final double s;
  final int count;
  final List<Color> colors;
  final int seed;
  final double dot;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    for (var i = 0; i < count; i++) {
      final x0 = rnd.nextDouble();
      final period = 5 + rnd.nextDouble() * 6;
      final phase = rnd.nextDouble();
      final r = dot * (0.45 + rnd.nextDouble() * 0.8);
      final c = colors[i % colors.length];
      final t = (s / period + phase) % 1.0;
      final y = size.height * (1 - t);
      final x = size.width * x0 + math.sin((s + i) * 0.9 + phase * 6) * 6;
      final life = math.sin(t * math.pi);
      final twinkle = 0.55 + 0.45 * math.sin(s * 3.1 + i * 1.7);
      final a = (life * twinkle * opacity).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        r * 2.6,
        Paint()
          ..color = c.withValues(alpha: 0.28 * a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 2),
      );
      canvas.drawCircle(Offset(x, y), r, Paint()..color = Color.lerp(c, Colors.white, 0.5)!.withValues(alpha: a));
    }
  }

  @override
  bool shouldRepaint(_MotesPainter old) => old.s != s || old.opacity != opacity;
}

class GlyphReveal extends StatefulWidget {
  const GlyphReveal({
    super.key,
    required this.text,
    required this.style,
    required this.progress,
    this.stagger = 0.55,
    this.lift = 14,
    this.flip = 0.0,
  });

  final String text;
  final TextStyle style;
  final Animation<double> progress;
  final double stagger;
  final double lift;
  final double flip;

  @override
  State<GlyphReveal> createState() => _GlyphRevealState();
}

class _GlyphRevealState extends State<GlyphReveal> {
  late TextPainter _painter;
  late List<Rect> _boxes;

  @override
  void initState() {
    super.initState();
    _layout();
  }

  @override
  void didUpdateWidget(GlyphReveal old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text || old.style != widget.style) _layout();
  }

  void _layout() {
    _painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _boxes = [
      for (var i = 0; i < widget.text.length; i++)
        _painter
            .getBoxesForSelection(TextSelection(baseOffset: i, extentOffset: i + 1))
            .fold<Rect>(Rect.zero, (acc, b) => acc == Rect.zero ? b.toRect() : acc.expandToInclude(b.toRect())),
    ];
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _painter.width,
      height: _painter.height,
      child: CustomPaint(
        painter: _GlyphPainter(
          painter: _painter,
          boxes: _boxes,
          progress: widget.progress,
          stagger: widget.stagger,
          lift: widget.lift,
          flip: widget.flip,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter({
    required this.painter,
    required this.boxes,
    required this.progress,
    required this.stagger,
    required this.lift,
    required this.flip,
  }) : super(repaint: progress);

  final TextPainter painter;
  final List<Rect> boxes;
  final Animation<double> progress;
  final double stagger;
  final double lift;
  final double flip;

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.value;
    if (p >= 1) {
      painter.paint(canvas, Offset.zero);
      return;
    }
    if (p <= 0) return;
    final n = boxes.length;
    final window = 1 - stagger;
    for (var i = 0; i < n; i++) {
      final box = boxes[i];
      if (box.isEmpty) continue;
      final start = n <= 1 ? 0.0 : stagger * i / (n - 1);
      final t = ((p - start) / window).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final k = spring(t, bounce: 0.5, freq: 2.6);
      final alpha = span(t, 0, 0.4, Curves.linear);
      final c = box.center;
      canvas.save();
      canvas.translate(c.dx, c.dy + lift * (1 - k));
      if (flip != 0) {
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.004)
          ..rotateX(flip * (1 - k));
        canvas.transform(m.storage);
      }
      final sc = lerp(0.4, 1, k);
      canvas.scale(sc, sc);
      canvas.translate(-c.dx, -c.dy);
      canvas.clipRect(box.inflate(box.height * 0.35));
      canvas.saveLayer(box.inflate(box.height), Paint()..color = Colors.white.withValues(alpha: alpha));
      painter.paint(canvas, Offset.zero);
      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.painter != painter;
}

class SpriteImage extends StatefulWidget {
  const SpriteImage({super.key, required this.sprite, required this.builder});

  final Sprite sprite;
  final Widget Function(BuildContext context, ui.Image? image) builder;

  @override
  State<SpriteImage> createState() => _SpriteImageState();
}

class _SpriteImageState extends State<SpriteImage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  void _resolve() {
    final stream = AssetImage(widget.sprite.asset).resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    if (_listener != null) _stream?.removeListener(_listener!);
    _listener = ImageStreamListener((info, _) {
      if (mounted) setState(() => _image = info.image);
    });
    _stream = stream..addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) _stream?.removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _image);
}

class WavingFlag extends StatelessWidget {
  const WavingFlag({super.key, required this.sprite, required this.unfurl});

  final Sprite sprite;
  final Animation<double> unfurl;

  @override
  Widget build(BuildContext context) {
    return SpriteImage(
      sprite: sprite,
      builder: (context, image) {
        if (image == null) return sprite.image();
        return Tick(
          builder: (context, s, _) =>
              CustomPaint(size: Size(sprite.width, sprite.height), painter: _FlagPainter(image, s, unfurl.value)),
        );
      },
    );
  }
}

class _FlagPainter extends CustomPainter {
  _FlagPainter(this.image, this.s, this.unfurl);

  final ui.Image image;
  final double s;
  final double unfurl;

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 14;
    const rows = 6;
    final iw = image.width.toDouble();
    final ih = image.height.toDouble();
    final positions = Float32List((cols + 1) * (rows + 1) * 2);
    final coords = Float32List((cols + 1) * (rows + 1) * 2);
    const pole = 0.16;
    var k = 0;
    for (var r = 0; r <= rows; r++) {
      for (var c = 0; c <= cols; c++) {
        final u = c / cols;
        final v = r / rows;
        final reach = ((u - pole) / (1 - pole)).clamp(0.0, 1.0);
        final open = span(unfurl, 0, 1, settle);
        final phase = s * 5.2 - u * 5.4;
        final dy = math.sin(phase) * size.height * 0.11 * reach;
        final squeeze = 1 - reach * (1 - open) * 0.92;
        final dx = math.cos(phase * 0.5) * size.width * 0.018 * reach;
        final x = pole * size.width + (u - pole) * size.width * squeeze + dx;
        final xx = u < pole ? u * size.width : x;
        positions[k] = xx;
        positions[k + 1] = v * size.height + dy;
        coords[k] = u * iw;
        coords[k + 1] = v * ih;
        k += 2;
      }
    }
    final indices = <int>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final a = r * (cols + 1) + c;
        final b = a + 1;
        final d = a + cols + 1;
        final e = d + 1;
        indices.addAll([a, b, d, b, e, d]);
      }
    }
    final vertices = ui.Vertices.raw(
      VertexMode.triangles,
      positions,
      textureCoordinates: coords,
      indices: Uint16List.fromList(indices),
    );
    final shader = ImageShader(
      image,
      TileMode.clamp,
      TileMode.clamp,
      Matrix4.identity().storage,
      filterQuality: FilterQuality.medium,
    );
    canvas.drawVertices(vertices, BlendMode.srcOver, Paint()..shader = shader);
    vertices.dispose();
  }

  @override
  bool shouldRepaint(_FlagPainter old) => old.s != s || old.unfurl != unfurl || old.image != image;
}

ColorFilter _flat(Color c, [double alpha = 1]) =>
    ColorFilter.matrix([0, 0, 0, 0, c.r * 255, 0, 0, 0, 0, c.g * 255, 0, 0, 0, 0, c.b * 255, 0, 0, 0, alpha, 0]);

class Energize extends StatelessWidget {
  const Energize({
    super.key,
    required this.progress,
    required this.child,
    this.edge = const Color(0xFFB8F6FF),
    this.body = const Color(0xFF2A6CF0),
  });

  final Animation<double> progress;
  final Widget child;
  final Color edge;
  final Color body;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final p = progress.value;
        final front = p >= 1 ? -0.5 : lerp(1.06, -0.06, Curves.easeInOut.transform(p));
        const soft = 0.035;
        LinearGradient band(List<Color> colors, List<double> stops) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: [for (final v in stops) v.clamp(0.0, 1.0)],
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => band(
                const [Colors.transparent, Colors.transparent, Colors.white, Colors.white],
                [0, front - soft, front + soft, 1],
              ).createShader(rect),
              child: child,
            ),
            ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => band(
                const [Colors.white, Colors.white, Colors.transparent, Colors.transparent],
                [0, front - soft, front + soft, 1],
              ).createShader(rect),
              child: ColorFiltered(colorFilter: _flat(body), child: child),
            ),
            ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => band(
                const [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                [front - 0.06, front - 0.008, front + 0.01, front + 0.05],
              ).createShader(rect),
              child: ColorFiltered(colorFilter: _flat(edge), child: child),
            ),
          ],
        );
      },
    );
  }
}

class Sheen extends StatelessWidget {
  const Sheen({
    super.key,
    required this.child,
    this.period = 4.2,
    this.delay = 0,
    this.width = 0.22,
    this.strength = 0.75,
  });

  final Widget child;
  final double period;
  final double delay;
  final double width;
  final double strength;

  @override
  Widget build(BuildContext context) {
    return Tick(
      child: child,
      builder: (context, s, child) {
        final t = ((s - delay) % period) / period;
        final idle = s < delay || t > 0.45;
        final pos = idle ? -2.0 : lerp(-0.4, 1.4, span(t, 0, 0.42, Curves.easeInOut));
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: const Alignment(-1, -0.6),
            end: const Alignment(1, 0.6),
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: strength),
              Colors.white.withValues(alpha: 0),
            ],
            stops: [(pos - width).clamp(0.0, 1.0), pos.clamp(0.0, 1.0), (pos + width).clamp(0.0, 1.0)],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}

class Odometer extends StatelessWidget {
  const Odometer({super.key, required this.text, required this.style, required this.progress});

  final String text;
  final TextStyle style;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final digits = text.split('');
    final n = digits.length;
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final p = progress.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [for (var i = 0; i < n; i++) _digit(digits[i], i, n, p)],
        );
      },
    );
  }

  Widget _digit(String ch, int i, int n, double p) {
    final value = int.tryParse(ch);
    if (value == null) return Text(ch, style: style);
    final start = 0.08 * (n - 1 - i);
    final t = span(p, start, math.min(1.0, start + 0.62), const Cubic(0.2, 0.7, 0.2, 1.0));
    final spins = 1 + (n - i);
    final pos = (value + 10 * spins) * t;
    final whole = pos.floor();
    final frac = pos - whole;
    final a = whole % 10;
    final b = (whole + 1) % 10;
    final h = (style.fontSize ?? 14) * (style.height ?? 1.0) * 1.2;
    return ClipRect(
      child: SizedBox(
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(opacity: 0, child: Text('$value', style: style)),
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, -frac * h),
                child: Text('$a', style: style, textAlign: TextAlign.center),
              ),
            ),
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, (1 - frac) * h),
                child: Text('$b', style: style, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
