import 'package:flutter/material.dart';

enum Glyph {
  moon,
  bell,
  plus,
  circlePlus,
  chart,
  user,
  calendar,
  heartPulse,
  sparkles,
  zap,
  smile,
  sun,
  droplet,
  arrowRight,
  arrowLeft,
  info,
  sliders,
  check,
  chevronRight,
  close,
  flower,
  activity,
}

const _lucide = <Glyph, List<String>>{
  Glyph.moon: [
    'M20.985 12.486a9 9 0 1 1-9.473-9.472c.405-.022.617.46.402.803a6 6 0 0 0 8.268 8.268c.344-.215.825-.004.803.401',
  ],
  Glyph.bell: [
    'M10.268 21a2 2 0 0 0 3.464 0',
    'M3.262 15.326A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.673C19.41 13.956 18 12.499 18 8A6 6 0 0 0 6 8c0 4.499-1.411 5.956-2.738 7.326',
  ],
  Glyph.plus: ['M5 12h14', 'M12 5v14'],
  Glyph.circlePlus: ['M12 2a10 10 0 1 0 0 20a10 10 0 1 0 0-20', 'M8 12h8', 'M12 8v8'],
  Glyph.chart: ['M3 3v16a2 2 0 0 0 2 2h16', 'M18 17V9', 'M13 17V5', 'M8 17v-3'],
  Glyph.user: ['M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2', 'M12 3a4 4 0 1 0 0 8a4 4 0 1 0 0-8'],
  Glyph.calendar: [
    'M8 2v3',
    'M16 2v3',
    'M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z',
    'M3 9h18',
    'M8 13h.01',
    'M12 13h.01',
    'M16 13h.01',
    'M8 17h.01',
    'M12 17h.01',
    'M16 17h.01',
  ],
  Glyph.heartPulse: [
    'M2 9.5a5.5 5.5 0 0 1 9.591-3.676.56.56 0 0 0 .818 0A5.49 5.49 0 0 1 22 9.5c0 2.29-1.5 4-3 5.5l-5.492 5.313a2 2 0 0 1-3 .019L5 15c-1.5-1.5-3-3.2-3-5.5',
    'M3.22 13H9.5l.5-1 2 4.5 2-7 1.5 3.5h5.27',
  ],
  Glyph.sparkles: [
    'M11.017 2.814a1 1 0 0 1 1.966 0l1.051 5.558a2 2 0 0 0 1.594 1.594l5.558 1.051a1 1 0 0 1 0 1.966l-5.558 1.051a2 2 0 0 0-1.594 1.594l-1.051 5.558a1 1 0 0 1-1.966 0l-1.051-5.558a2 2 0 0 0-1.594-1.594l-5.558-1.051a1 1 0 0 1 0-1.966l5.558-1.051a2 2 0 0 0 1.594-1.594z',
    'M20 2v4',
    'M22 4h-4',
  ],
  Glyph.zap: [
    'M15.914 4a1.5 1.5 0 00-2.474-1.561l-9 9A1.5 1.5 0 005.5 14h4.002a.5.5 0 01.471.666L8.086 20a1.5 1.5 0 002.475 1.56l9-9A1.5 1.5 0 0018.5 10h-3.997a.5.5 0 01-.472-.667z',
  ],
  Glyph.smile: ['M15 10V9', 'M16.472 15a6 6 0 01-8.943 0', 'M9 10V9', 'M12 2a10 10 0 1 0 0 20a10 10 0 1 0 0-20'],
  Glyph.sun: [
    'M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0-8',
    'M12 2v2',
    'M12 20v2',
    'm4.93 4.93 1.41 1.41',
    'm17.66 17.66 1.41 1.41',
    'M2 12h2',
    'M20 12h2',
    'm6.34 17.66-1.41 1.41',
    'm19.07 4.93-1.41 1.41',
  ],
  Glyph.droplet: [
    'M12 22a7 7 0 0 0 7-7c0-2-1-3.9-3-5.5s-3.5-4-4-6.5c-.5 2.5-2 4.9-4 6.5C6 11.1 5 13 5 15a7 7 0 0 0 7 7z',
  ],
  Glyph.arrowRight: ['M5 12h14', 'm12 5 7 7-7 7'],
  Glyph.arrowLeft: ['m12 19-7-7 7-7', 'M19 12H5'],
  Glyph.info: ['M12 2a10 10 0 1 0 0 20a10 10 0 1 0 0-20', 'M12 16v-4', 'M12 8h.01'],
  Glyph.sliders: [
    'M10 5H3',
    'M12 19H3',
    'M14 3v4',
    'M16 17v4',
    'M21 12h-9',
    'M21 19h-5',
    'M21 5h-7',
    'M8 10v4',
    'M8 12H3',
  ],
  Glyph.check: ['M20 6 9 17l-5-5'],
  Glyph.chevronRight: ['m9 18 6-6-6-6'],
  Glyph.close: ['M18 6 6 18', 'm6 6 12 12'],
  Glyph.flower: [
    'M12 9a3 3 0 1 0 0 6a3 3 0 1 0 0-6',
    'M12 16.5A4.5 4.5 0 1 1 7.5 12 4.5 4.5 0 1 1 12 7.5a4.5 4.5 0 1 1 4.5 4.5 4.5 4.5 0 1 1-4.5 4.5',
  ],
  Glyph.activity: [
    'M22 12h-2.48a2 2 0 0 0-1.93 1.46l-2.35 8.36a.25.25 0 0 1-.48 0L9.24 2.18a.25.25 0 0 0-.48 0l-2.35 8.36A2 2 0 0 1 4.49 12H2',
  ],
};

final _cache = <Glyph, Path>{};

Path glyphPath(Glyph glyph) {
  return _cache.putIfAbsent(glyph, () {
    final path = Path();
    for (final d in _lucide[glyph]!) {
      path.addPath(parseSvgPath(d), Offset.zero);
    }
    return path;
  });
}

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(
    this.glyph, {
    super.key,
    this.size = 20,
    this.color = const Color(0xFF3A1B3D),
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
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: GlyphPainter(glyph: glyph, color: color, stroke: stroke, fill: fill),
      ),
    );
  }
}

class GlyphPainter extends CustomPainter {
  const GlyphPainter({required this.glyph, required this.color, this.stroke = 1.8, this.fill});

  final Glyph glyph;
  final Color color;
  final double stroke;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.translate((size.width - 24 * scale) / 2, (size.height - 24 * scale) / 2);
    canvas.scale(scale);
    final path = glyphPath(glyph);
    if (fill != null) canvas.drawPath(path, Paint()..color = fill!);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke / scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
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

Path parseSvgPath(String d) {
  final scanner = _Scanner(d);
  final path = Path();
  var current = Offset.zero;
  var start = Offset.zero;
  var control = Offset.zero;
  String? command;

  Offset point(bool relative) {
    final x = scanner.number();
    final y = scanner.number();
    return relative ? current + Offset(x, y) : Offset(x, y);
  }

  while (true) {
    final letter = scanner.command();
    if (letter != null) command = letter;
    if (command == null || !scanner.hasParams(command)) break;
    final relative = command.toLowerCase() == command;
    switch (command.toUpperCase()) {
      case 'M':
        current = point(relative);
        path.moveTo(current.dx, current.dy);
        start = current;
        command = relative ? 'l' : 'L';
      case 'L':
        current = point(relative);
        path.lineTo(current.dx, current.dy);
      case 'H':
        final x = scanner.number();
        current = Offset(relative ? current.dx + x : x, current.dy);
        path.lineTo(current.dx, current.dy);
      case 'V':
        final y = scanner.number();
        current = Offset(current.dx, relative ? current.dy + y : y);
        path.lineTo(current.dx, current.dy);
      case 'C':
        final c1 = point(relative);
        final c2 = point(relative);
        current = point(relative);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, current.dx, current.dy);
        control = c2;
      case 'S':
        final c2 = point(relative);
        final c1 = current * 2 - control;
        final end = point(relative);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        control = c2;
        current = end;
      case 'Q':
        final c = point(relative);
        current = point(relative);
        path.quadraticBezierTo(c.dx, c.dy, current.dx, current.dy);
        control = c;
      case 'T':
        final c = current * 2 - control;
        current = point(relative);
        path.quadraticBezierTo(c.dx, c.dy, current.dx, current.dy);
        control = c;
      case 'A':
        final rx = scanner.number();
        final ry = scanner.number();
        final rotation = scanner.number();
        final largeArc = scanner.flag();
        final sweep = scanner.flag();
        final end = point(relative);
        if (rx == 0 || ry == 0 || end == current) {
          path.lineTo(end.dx, end.dy);
        } else {
          path.arcToPoint(
            end,
            radius: Radius.elliptical(rx.abs(), ry.abs()),
            rotation: rotation,
            largeArc: largeArc,
            clockwise: sweep,
          );
        }
        current = end;
      case 'Z':
        path.close();
        current = start;
        command = null;
    }
  }
  return path;
}

class _Scanner {
  _Scanner(this.source);

  final String source;
  int index = 0;

  static final _letter = RegExp(r'[a-zA-Z]');
  static final _number = RegExp(r'[-+]?(\d*\.\d+|\d+\.?)([eE][-+]?\d+)?');

  void _skip() {
    while (index < source.length && ' ,\n\r\t'.contains(source[index])) {
      index++;
    }
  }

  String? command() {
    _skip();
    if (index < source.length && _letter.hasMatch(source[index])) {
      return source[index++];
    }
    return null;
  }

  bool hasParams(String command) {
    if (command.toUpperCase() == 'Z') return true;
    _skip();
    return index < source.length && _number.matchAsPrefix(source, index) != null;
  }

  double number() {
    _skip();
    final match = _number.matchAsPrefix(source, index);
    if (match == null) return 0;
    index = match.end;
    return double.parse(match.group(0)!);
  }

  bool flag() {
    _skip();
    if (index >= source.length) return false;
    final ch = source[index++];
    return ch == '1';
  }
}
