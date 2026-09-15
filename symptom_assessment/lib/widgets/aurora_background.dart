import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../core/palette.dart';
import '../core/shaders.dart';

/// The page wash, with three slow colour drifts in it.
///
/// Ticks at a low rate on purpose: the drift is minutes-scale, so a frame
/// every 50 ms is indistinguishable from every 8 and costs a sixth as much.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, this.drift = 1});

  /// 0 keeps the flat gradient; 1 is the full drift.
  final double drift;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  ui.FragmentShader? _shader;
  double _time = 0;
  Duration _lastPaint = Duration.zero;

  @override
  void initState() {
    super.initState();
    _shader = Shaders.aurora();
    if (_shader != null) _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    if (elapsed - _lastPaint < const Duration(milliseconds: 50)) return;
    _lastPaint = elapsed;
    setState(() => _time = elapsed.inMicroseconds / 1e6);
  }

  @override
  void dispose() {
    if (_shader != null) _ticker.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    if (shader == null) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Paper.washTop, Paper.washMid, Paper.white],
            stops: <double>[0, 0.42, 0.95],
          ),
        ),
        child: SizedBox.expand(),
      );
    }
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AuroraPainter(shader, _time, widget.drift),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.shader, this.time, this.mix);

  final ui.FragmentShader shader;
  final double time;
  final double mix;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, mix);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.time != time || old.mix != mix;
}
