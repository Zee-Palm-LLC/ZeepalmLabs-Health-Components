import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app/theme/palette.dart';
import '../app/theme/typography.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrandPainter()),
    );
  }
}

class _BrandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final left = Path()
      ..moveTo(w * 0.50, h * 0.06)
      ..lineTo(w * 0.05, h * 0.94)
      ..lineTo(w * 0.33, h * 0.94)
      ..lineTo(w * 0.50, h * 0.52)
      ..close();

    final right = Path()
      ..moveTo(w * 0.56, h * 0.18)
      ..lineTo(w * 0.95, h * 0.94)
      ..lineTo(w * 0.45, h * 0.94)
      ..lineTo(w * 0.62, h * 0.60)
      ..lineTo(w * 0.47, h * 0.60)
      ..close();

    canvas.drawPath(
      left,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(w * 0.1, h),
          Offset(w * 0.5, 0),
          const <Color>[Spectrum.deep, Spectrum.blue],
          const <double>[0.0, 1.0],
        ),
    );
    canvas.drawPath(
      right,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(w * 0.45, h),
          Offset(w, h * 0.2),
          const <Color>[Spectrum.cyan, Spectrum.teal, Spectrum.amber],
          const <double>[0.0, 0.45, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(_BrandPainter oldDelegate) => false;
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.tagline});

  final String? tagline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const BrandMark(size: 25),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Trailglow',
                style: Typo.wordmark,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (tagline != null) ...<Widget>[
                const SizedBox(height: 3),
                Text(
                  tagline!.toUpperCase(),
                  style: Typo.label(8, letterSpacing: 2.0, color: Tone.faint),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
