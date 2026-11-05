import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Phosphor-style line icons, drawn from their 256-unit SVG path data so every
/// glyph shares one stroke weight and cap style.
enum Glyph {
  heart(['M128,224S24,168,24,102A54,54,0,0,1,78,48c22.59,0,41.94,12.31,50,32,8.06-19.69,27.41-32,50-32a54,54,0,0,1,54,54C232,168,128,224,128,224Z']),
  pulse(['M24,128L64,128L88,72L136,184L160,128L232,128']),
  moon(['M108.11,28.11A96.09,96.09,0,0,0,227.89,147.89,96,96,0,1,1,108.11,28.11Z']),
  steps([
    'M216,176H168v16a24,24,0,0,0,48,0Z',
    'M168,144h48c4-24,8-52,0-76-7.4-22.2-32-22.2-44-4C156,88,160,120,168,144Z',
    'M40,136H88v16a24,24,0,0,1-48,0Z',
    'M88,104H40c-4-24-8-52,0-76,7.4-22.2,32-22.2,44-4C100,48,96,80,88,104Z',
  ]),
  wind(['M184,184a32,32,0,1,0,32-32H24', 'M104,72a24,24,0,1,1,24,24H40']),
  pill(['M58.71,149.21L149.21,58.71A34,34,0,0,1,197.29,106.79L106.79,197.29A34,34,0,0,1,58.71,149.21Z', 'M104,104L152,152']),
  lock(['M48,88H208A8,8,0,0,1,216,96V208A8,8,0,0,1,208,216H48A8,8,0,0,1,40,208V96A8,8,0,0,1,48,88Z', 'M92,88V56a36,36,0,0,1,72,0V88']),
  bell(['M56,104a72,72,0,0,1,144,0c0,35.82,8.3,64.6,14.9,76A8,8,0,0,1,208,192H48a8,8,0,0,1-6.88-12C47.71,168.6,56,139.81,56,104Z', 'M96,192a32,32,0,0,0,64,0']),
  grid([
    'M48,40H104A8,8,0,0,1,112,48V104A8,8,0,0,1,104,112H48A8,8,0,0,1,40,104V48A8,8,0,0,1,48,40Z',
    'M152,40H208A8,8,0,0,1,216,48V104A8,8,0,0,1,208,112H152A8,8,0,0,1,144,104V48A8,8,0,0,1,152,40Z',
    'M48,144H104A8,8,0,0,1,112,152V208A8,8,0,0,1,104,216H48A8,8,0,0,1,40,208V152A8,8,0,0,1,48,144Z',
    'M152,144H208A8,8,0,0,1,216,152V208A8,8,0,0,1,208,216H152A8,8,0,0,1,144,208V152A8,8,0,0,1,152,144Z',
  ]),
  trend(['M224,208H32V48', 'M208,72L128,152L96,120L32,184']),
  user(['M128,40a56,56,0,1,1,0,112a56,56,0,1,1,0-112Z', 'M32,216c19.37-33.47,54.55-56,96-56s76.63,22.53,96,56']),
  sync(['M184,104H232V56', 'M188.4,192a88,88,0,1,1,1.83-126.23L232,104']),
  caret(['M96,48L176,128L96,208']),
  check(['M40,144L96,200L224,72']),
  eye(['M128,56C48,56,16,128,16,128s32,72,112,72,112-72,112-72S208,56,128,56Z', 'M128,88a40,40,0,1,1,0,80a40,40,0,1,1,0-80Z']),
  watch(['M80,64H176A16,16,0,0,1,192,80V176A16,16,0,0,1,176,192H80A16,16,0,0,1,64,176V80A16,16,0,0,1,80,64Z', 'M96,64L104,24H152L160,64', 'M96,192L104,232H152L160,192']);

  const Glyph(this.data);

  final List<String> data;

  static final _cache = <Glyph, Path>{};

  Path get path => _cache[this] ??= _build(data);
}

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(this.glyph, {super.key, this.size = 20, this.color = const Color(0xFF16181D), this.weight = 14});

  final Glyph glyph;
  final double size;
  final Color color;
  final double weight;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: size, child: CustomPaint(painter: _GlyphPainter(glyph, color, weight)));
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.color, this.weight);

  final Glyph glyph;
  final Color color;
  final double weight;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 256;
    canvas.scale(s);
    canvas.drawPath(
      glyph.path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = weight
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.glyph != glyph || old.color != color || old.weight != weight;
}

final _token = RegExp(r'[A-Za-z]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');

Path _build(List<String> parts) {
  final out = Path();
  for (final d in parts) {
    out.addPath(_parse(d), Offset.zero);
  }
  return out;
}

Path _parse(String d) {
  final tokens = _token.allMatches(d).map((m) => m.group(0)!).toList();
  final path = Path();
  var i = 0;
  var cmd = 'M';
  var cur = Offset.zero;
  var start = Offset.zero;
  var ctrl = Offset.zero;
  bool isCmd(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);
  double n() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    if (isCmd(tokens[i])) cmd = tokens[i++];
    final rel = cmd == cmd.toLowerCase();
    final base = rel ? cur : Offset.zero;
    switch (cmd.toUpperCase()) {
      case 'M':
        cur = base + Offset(n(), n());
        start = cur;
        path.moveTo(cur.dx, cur.dy);
        cmd = rel ? 'l' : 'L';
      case 'L':
        cur = base + Offset(n(), n());
        path.lineTo(cur.dx, cur.dy);
      case 'H':
        cur = Offset((rel ? cur.dx : 0) + n(), cur.dy);
        path.lineTo(cur.dx, cur.dy);
      case 'V':
        cur = Offset(cur.dx, (rel ? cur.dy : 0) + n());
        path.lineTo(cur.dx, cur.dy);
      case 'C':
        final c1 = base + Offset(n(), n());
        ctrl = base + Offset(n(), n());
        cur = base + Offset(n(), n());
        path.cubicTo(c1.dx, c1.dy, ctrl.dx, ctrl.dy, cur.dx, cur.dy);
      case 'S':
        final c1 = cur * 2 - ctrl;
        ctrl = base + Offset(n(), n());
        cur = base + Offset(n(), n());
        path.cubicTo(c1.dx, c1.dy, ctrl.dx, ctrl.dy, cur.dx, cur.dy);
      case 'A':
        final rx = n(), ry = n(), rot = n(), large = n() != 0, sweep = n() != 0;
        cur = base + Offset(n(), n());
        path.arcToPoint(cur, radius: Radius.elliptical(rx, ry), rotation: rot * math.pi / 180, largeArc: large, clockwise: sweep);
      case 'Z':
        path.close();
        cur = start;
      default:
        i++;
    }
  }
  return path;
}
