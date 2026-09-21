import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum Glyph {
  heart,
  bell,
  bellRing,
  back,
  forward,
  down,
  more,
  pill,
  leaf,
  calendar,
  clock,
  chat,
  user,
  users,
  home,
  plus,
  drop,
  steps,
  moon,
  sun,
  sunSoft,
  walk,
  phone,
  check,
  thumb,
  send,
  arrow,
  coffee,
  alert,
  close,
  sparkle,
}

const Map<Glyph, List<String>> _paths = {
  Glyph.heart: [
    'M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z',
  ],
  Glyph.bell: ['M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9', 'M10.3 21a1.94 1.94 0 0 0 3.4 0'],
  Glyph.bellRing: [
    'M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9',
    'M10.3 21a1.94 1.94 0 0 0 3.4 0',
    'M22 8c0-2.3-.8-4.3-2-6',
    'M4 2C2.8 3.7 2 5.7 2 8',
  ],
  Glyph.back: ['m15 18-6-6 6-6'],
  Glyph.forward: ['m9 18 6-6-6-6'],
  Glyph.down: ['m6 9 6 6 6-6'],
  Glyph.pill: ['m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z', 'm8.5 8.5 7 7'],
  Glyph.leaf: [
    'M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z',
    'M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12',
  ],
  Glyph.calendar: [
    'M8 2v4',
    'M16 2v4',
    'M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z',
    'M3 10h18',
  ],
  Glyph.clock: ['M22 12a10 10 0 1 1-20 0a10 10 0 1 1 20 0', 'M12 6v6l4 2'],
  Glyph.chat: [
    'M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z',
    'M8 10h.01',
    'M12 10h.01',
    'M16 10h.01',
  ],
  Glyph.user: ['M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2', 'M16 7a4 4 0 1 1-8 0a4 4 0 1 1 8 0'],
  Glyph.users: [
    'M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2',
    'M13 7a4 4 0 1 1-8 0a4 4 0 1 1 8 0',
    'M22 21v-2a4 4 0 0 0-3-3.87',
    'M16 3.13a4 4 0 0 1 0 7.75',
  ],
  Glyph.home: [
    'M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8',
    'M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z',
  ],
  Glyph.plus: ['M5 12h14', 'M12 5v14'],
  Glyph.drop: [
    'M12 22a7 7 0 0 0 7-7c0-2-1-3.9-3-5.5s-3.5-4-4-6.5c-.5 2.5-2 4.9-4 6.5C6 11.1 5 13 5 15a7 7 0 0 0 7 7z',
    'M9.2 15.4a2.9 2.9 0 0 0 2.4 2.6',
  ],
  Glyph.steps: [
    'M4 16v-2.38C4 11.5 2.97 10.5 3 8c.03-2.72 1.49-6 4.5-6C9.37 2 10 3.8 10 5.5c0 3.11-2 5.66-2 8.68V16a2 2 0 1 1-4 0Z',
    'M20 20v-2.38c0-2.12 1.03-3.12 1-5.62-.03-2.72-1.49-6-4.5-6C14.63 6 14 7.8 14 9.5c0 3.11 2 5.66 2 8.68V20a2 2 0 1 0 4 0Z',
    'M16 17h4',
    'M4 13h4',
  ],
  Glyph.moon: ['M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z'],
  Glyph.sun: [
    'M16 12a4 4 0 1 1-8 0a4 4 0 1 1 8 0',
    'M12 2v2',
    'M12 20v2',
    'm4.93 4.93 1.41 1.41',
    'm17.66 17.66 1.41 1.41',
    'M2 12h2',
    'M20 12h2',
    'm6.34 17.66-1.41 1.41',
    'm19.07 4.93-1.41 1.41',
  ],
  Glyph.sunSoft: [
    'M15 12a3 3 0 1 1-6 0a3 3 0 1 1 6 0',
    'M12 3v1',
    'M12 20v1',
    'M3 12h1',
    'M20 12h1',
    'm18.364 5.636-.707.707',
    'm6.343 17.657-.707.707',
    'm5.636 5.636.707.707',
    'm17.657 17.657.707.707',
  ],
  Glyph.walk: [
    'M15.3 4.6a1.8 1.8 0 1 1-3.6 0a1.8 1.8 0 1 1 3.6 0',
    'M8.2 11.2l3.3-3 2.6 2.4 2.9 1.2',
    'M11.5 8.2l-1.4 5.4 3 2.6.8 5.3',
    'M10.1 13.6l-2 3.2-2.8 4.7',
  ],
  Glyph.phone: [
    'M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z',
  ],
  Glyph.check: ['M20 6 9 17l-5-5'],
  Glyph.thumb: [
    'M7 10v12',
    'M15 5.88 14 10h5.83a2 2 0 0 1 1.92 2.56l-2.33 8A2 2 0 0 1 17.5 22H4a2 2 0 0 1-2-2v-8a2 2 0 0 1 2-2h2.76a2 2 0 0 0 1.79-1.11L12 2a3.13 3.13 0 0 1 3 3.88Z',
  ],
  Glyph.send: [
    'M14.536 21.686a.5.5 0 0 0 .937-.024l6.5-19a.496.496 0 0 0-.635-.635l-19 6.5a.5.5 0 0 0-.024.937l7.93 3.18a2 2 0 0 1 1.112 1.11z',
    'm21.854 2.147-10.94 10.939',
  ],
  Glyph.arrow: ['M5 12h14', 'm12 5 7 7-7 7'],
  Glyph.coffee: [
    'M10 2v2',
    'M14 2v2',
    'M16 8a1 1 0 0 1 1 1v8a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V9a1 1 0 0 1 1-1h14a4 4 0 1 1-1 7.93',
    'M6 2v2',
  ],
  Glyph.alert: ['M12 7v6', 'M12 17h.01'],
  Glyph.close: ['M18 6 6 18', 'm6 6 12 12'],
  Glyph.more: ['M5 12h.01', 'M12 12h.01', 'M19 12h.01'],
  Glyph.sparkle: [
    'M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z',
  ],
};

final Map<Glyph, List<Path>> _cache = {};

List<Path> glyphPaths(Glyph glyph) {
  return _cache.putIfAbsent(glyph, () => [for (final d in _paths[glyph]!) parseSvgPath(d)]);
}

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(
    this.glyph, {
    super.key,
    this.size = 22,
    this.color = const Color(0xFF2A2230),
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
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke / k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final path in paths) {
      canvas.drawPath(path, line);
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
  final tokens = RegExp(r'[MmLlHhVvCcSsQqAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:e-?\d+)?').allMatches(data).map((m) => m.group(0)!).toList();
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

class CareLogo extends StatelessWidget {
  const CareLogo({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: size, child: const CustomPaint(painter: _LogoPainter()));
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k);
    final heart = glyphPaths(Glyph.heart).first;
    final bounds = heart.getBounds();
    canvas.drawPath(
      heart,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          colors: [Color(0xFFA487FF), Color(0xFF6B48EC)],
        ).createShader(bounds),
    );
    canvas.drawCircle(const Offset(15.4, 9.2), 2.2, Paint()..color = const Color(0xFFF58DB4));
    final arc = Path()..addArc(Rect.fromCircle(center: const Offset(12, 13.4), radius: 3.4), math.pi * 0.15, math.pi * 0.7);
    canvas.drawPath(
      arc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF7B5CF5),
    );
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
