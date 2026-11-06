import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LED dot-matrix lettering: the text is set in Geist Mono, rasterised once,
/// then resampled onto a fine grid of round dots.
class DotText extends StatefulWidget {
  const DotText(
    this.text, {
    super.key,
    this.size = 50,
    this.spacing = -4,
    this.pitch = 2.3,
    this.dot = 0.74,
    this.color = Colors.white,
    this.glow,
  });

  final String text;
  final double size;
  final double spacing;

  /// Distance between dot centres, in points.
  final double pitch;

  /// Dot radius, in points.
  final double dot;
  final Color color;
  final Color? glow;

  @override
  State<DotText> createState() => _DotTextState();
}

class _DotTextState extends State<DotText> {
  static final _cache = <String, Future<_Grid>>{};
  _Grid? _grid;

  String get _key => '${widget.text}|${widget.size}|${widget.spacing}|${widget.pitch}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(DotText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text || old.size != widget.size || old.pitch != widget.pitch) _load();
  }

  void _load() {
    final future = _cache[_key] ??= _Grid.build(widget.text, widget.size, widget.spacing, widget.pitch);
    future.then((g) {
      if (mounted) setState(() => _grid = g);
    });
  }

  @override
  Widget build(BuildContext context) {
    final g = _grid;
    if (g == null) return SizedBox(height: widget.size * 1.2);
    return CustomPaint(size: g.size, painter: _DotPainter(g, widget.dot, widget.color, widget.glow));
  }
}

class _Grid {
  _Grid(this.size, this.dots);

  final Size size;
  final List<Offset> dots;

  static Future<_Grid> build(String text, double size, double spacing, double pitch) async {
    final style = GoogleFonts.geistMono(fontSize: size, fontWeight: FontWeight.w500, letterSpacing: spacing, height: 1);
    await GoogleFonts.pendingFonts();
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const k = 3.0;
    final w = (tp.width * k).ceil();
    final h = (tp.height * k).ceil();
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec)..scale(k);
    tp.paint(canvas, Offset.zero);
    final img = await rec.endRecording().toImage(w, h);
    final data = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    img.dispose();

    double alphaAt(double x, double y) {
      var sum = 0.0;
      var n = 0;
      for (var dy = -1; dy <= 1; dy++) {
        for (var dx = -1; dx <= 1; dx++) {
          final px = (x * k).round() + dx;
          final py = (y * k).round() + dy;
          if (px < 0 || py < 0 || px >= w || py >= h) continue;
          sum += data.getUint8((py * w + px) * 4 + 3);
          n++;
        }
      }
      return n == 0 ? 0 : sum / n / 255;
    }

    final dots = <Offset>[];
    for (var y = pitch / 2; y < tp.height; y += pitch) {
      for (var x = pitch / 2; x < tp.width; x += pitch) {
        if (alphaAt(x, y) > 0.42) dots.add(Offset(x, y));
      }
    }
    return _Grid(Size(tp.width, tp.height), dots);
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.grid, this.radius, this.color, this.glow);

  final _Grid grid;
  final double radius;
  final Color color;
  final Color? glow;

  @override
  void paint(Canvas canvas, Size size) {
    final g = glow;
    if (g != null) {
      final soft = Paint()
        ..color = g
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      for (final d in grid.dots) {
        canvas.drawCircle(d, radius * 1.6, soft);
      }
    }
    final p = Paint()..color = color;
    for (final d in grid.dots) {
      canvas.drawCircle(d, radius, p);
    }
  }

  @override
  bool shouldRepaint(_DotPainter old) => old.grid != grid || old.color != color || old.radius != radius || old.glow != glow;
}
