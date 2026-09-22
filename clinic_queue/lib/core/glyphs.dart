import 'package:flutter/widgets.dart';

enum Glyph {
  pin,
  car,
  heart,
  star,
  arrow,
  home,
  queue,
  map,
  user,
  back,
  info,
  shield,
  timer,
  calendar,
  door,
  check,
  bell,
  plus,
}

const Map<Glyph, List<String>> _paths = {
  Glyph.pin: [
    'M20 10c0 4.993-5.539 10.193-7.399 11.799a1 1 0 0 1-1.202 0C9.539 20.193 4 14.993 4 10a8 8 0 0 1 16 0',
    'M15 10a3 3 0 1 1-6 0a3 3 0 1 1 6 0',
  ],
  Glyph.car: [
    'm21 8-2 2-1.5-3.7A2 2 0 0 0 15.646 5H8.4a2 2 0 0 0-1.903 1.257L5 10 3 8',
    'M7 14h.01',
    'M17 14h.01',
    'M5 10h14a2 2 0 0 1 2 2v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4a2 2 0 0 1 2-2z',
    'M5 18v2',
    'M19 18v2',
  ],
  Glyph.heart: [
    'M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z',
  ],
  Glyph.star: [
    'M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z',
  ],
  Glyph.arrow: ['M5 12h14', 'm12 5 7 7-7 7'],
  Glyph.home: [
    'M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8',
    'M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z',
  ],
  Glyph.queue: ['M4 6.5h16', 'M4 12h11', 'M4 17.5h7'],
  Glyph.map: [
    'M14.106 5.553a2 2 0 0 0 1.788 0l3.659-1.83A1 1 0 0 1 21 4.619v12.764a1 1 0 0 1-.553.894l-4.553 2.277a2 2 0 0 1-1.788 0l-4.212-2.106a2 2 0 0 0-1.788 0l-3.659 1.83A1 1 0 0 1 3 19.381V6.618a1 1 0 0 1 .553-.894l4.553-2.277a2 2 0 0 1 1.788 0z',
    'M15 5.764v15',
    'M9 3.236v15',
  ],
  Glyph.user: ['M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2', 'M16 7a4 4 0 1 1-8 0a4 4 0 1 1 8 0'],
  Glyph.back: ['m15 18-6-6 6-6'],
  Glyph.info: ['M22 12a10 10 0 1 1-20 0a10 10 0 1 1 20 0', 'M12 16v-4', 'M12 8h.01'],
  Glyph.shield: [
    'M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z',
    'm9 12 2 2 4-4',
  ],
  Glyph.timer: ['M10 2h4', 'M12 14l3-3', 'M20 14a8 8 0 1 1-16 0a8 8 0 1 1 16 0'],
  Glyph.calendar: [
    'M8 2v4',
    'M16 2v4',
    'M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z',
    'M3 10h18',
  ],
  Glyph.door: ['M18 20V6a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v14', 'M2 20h20', 'M14 12v.01'],
  Glyph.check: ['M20 6 9 17l-5-5'],
  Glyph.bell: ['M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9', 'M10.3 21a1.94 1.94 0 0 0 3.4 0'],
  Glyph.plus: ['M5 12h14', 'M12 5v14'],
};

final Map<Glyph, List<Path>> _cache = {};

List<Path> glyphPaths(Glyph glyph) {
  return _cache.putIfAbsent(glyph, () => [for (final d in _paths[glyph]!) parseSvgPath(d)]);
}

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(
    this.glyph, {
    super.key,
    this.size = 20,
    this.color = const Color(0xFF0F3B3A),
    this.stroke = 1.8,
    this.fill,
  });

  final Glyph glyph;
  final double size;
  final Color color;
  final double stroke;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: GlyphPainter(glyph, color, stroke, fill)),
    );
  }
}

class GlyphPainter extends CustomPainter {
  const GlyphPainter(this.glyph, this.color, this.stroke, this.fill);

  final Glyph glyph;
  final Color color;
  final double stroke;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.save();
    canvas.scale(k);
    final paths = glyphPaths(glyph);
    final fill = this.fill;
    if (fill != null) {
      final paint = Paint()..color = fill;
      for (final path in paths) {
        canvas.drawPath(path, paint);
      }
    }
    if (stroke > 0) {
      final line = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke / k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (final path in paths) {
        canvas.drawPath(path, line);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(GlyphPainter oldDelegate) {
    return oldDelegate.glyph != glyph ||
        oldDelegate.color != color ||
        oldDelegate.stroke != stroke ||
        oldDelegate.fill != fill;
  }
}

Path parseSvgPath(String data) {
  final tokens = RegExp(
    r'[MmLlHhVvCcSsQqAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:e-?\d+)?',
  ).allMatches(data).map((m) => m.group(0)!).toList();
  final path = Path();
  var i = 0;
  var command = '';
  var x = 0.0;
  var y = 0.0;
  var startX = 0.0;
  var startY = 0.0;
  var lastCx = 0.0;
  var lastCy = 0.0;
  var lastWasCubic = false;

  bool isCommand(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);
  double next() => double.parse(tokens[i++]);

  while (i < tokens.length) {
    if (isCommand(tokens[i])) {
      command = tokens[i++];
    }
    final relative = command == command.toLowerCase();
    final dx = relative ? x : 0.0;
    final dy = relative ? y : 0.0;
    var cubic = false;
    switch (command.toUpperCase()) {
      case 'M':
        x = next() + dx;
        y = next() + dy;
        path.moveTo(x, y);
        startX = x;
        startY = y;
        command = relative ? 'l' : 'L';
      case 'L':
        x = next() + dx;
        y = next() + dy;
        path.lineTo(x, y);
      case 'H':
        x = next() + (relative ? x : 0.0);
        path.lineTo(x, y);
      case 'V':
        y = next() + (relative ? y : 0.0);
        path.lineTo(x, y);
      case 'C':
        final x1 = next() + dx;
        final y1 = next() + dy;
        final x2 = next() + dx;
        final y2 = next() + dy;
        x = next() + dx;
        y = next() + dy;
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastCx = x2;
        lastCy = y2;
        cubic = true;
      case 'S':
        final x1 = lastWasCubic ? 2 * x - lastCx : x;
        final y1 = lastWasCubic ? 2 * y - lastCy : y;
        final x2 = next() + dx;
        final y2 = next() + dy;
        x = next() + dx;
        y = next() + dy;
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastCx = x2;
        lastCy = y2;
        cubic = true;
      case 'Q':
        final x1 = next() + dx;
        final y1 = next() + dy;
        x = next() + dx;
        y = next() + dy;
        path.quadraticBezierTo(x1, y1, x, y);
      case 'A':
        final rx = next();
        final ry = next();
        final rotation = next();
        final large = next() != 0;
        final sweep = next() != 0;
        x = next() + dx;
        y = next() + dy;
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: large,
          clockwise: sweep,
        );
      case 'Z':
        path.close();
        x = startX;
        y = startY;
    }
    lastWasCubic = cubic;
  }
  return path;
}
