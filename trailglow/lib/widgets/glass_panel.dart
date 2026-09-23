import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app/theme/palette.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 26,
    this.padding = const EdgeInsets.all(18),
    this.blur = 22,
    this.tint = Night.panel,
    this.borderColor = Night.hairline,
    this.highlight = true,
    this.shadow = true,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final double blur;
  final Color tint;
  final Color borderColor;
  final bool highlight;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: shadow
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x99000000),
                  blurRadius: 34,
                  spreadRadius: -6,
                  offset: Offset(0, 16),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: shape,
              border: Border.all(color: borderColor, width: 1),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  highlight
                      ? Color.alphaBlend(const Color(0x0DFFFFFF), tint)
                      : tint,
                  tint,
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class HairlineDivider extends StatelessWidget {
  const HairlineDivider({super.key, this.inset = 0});

  final double inset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: inset),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0x00FFFFFF), Night.hairline, Color(0x00FFFFFF)],
          stops: <double>[0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
