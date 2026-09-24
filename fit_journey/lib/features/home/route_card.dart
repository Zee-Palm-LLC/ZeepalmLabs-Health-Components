import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/phosphor.dart';
import '../../core/type.dart';
import '../../widgets/line_arrow.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({super.key, required this.enter, required this.parallax, required this.onOpen, this.hidden = false});

  final double enter;
  final double parallax;
  final VoidCallback onOpen;
  final bool hidden;

  static const rect = Rect.fromLTWH(21.5, 444, 349.5, 295.5);
  static const image = Rect.fromLTWH(0.5, 1, 348.5, 125);

  @override
  Widget build(BuildContext context) {
    final curtain = span(enter, 0.05, 0.55, const Cubic(0.7, 0.0, 0.2, 1.0));
    final settle = span(enter, 0.05, 0.9, const Cubic(0.2, 0.7, 0.2, 1.0));
    final badge = spring(span(enter, 0.45, 0.85, Curves.linear), bounce: 0.5, freq: 2.6);
    final button = span(enter, 0.55, 1.0, const Cubic(0.2, 0.9, 0.3, 1.0));
    double item(int i) => span(enter, 0.3 + i * 0.06, 0.7 + i * 0.06, swift);
    Widget rise(int i, Widget child) {
      final t = item(i);
      return Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
      );
    }

    final meta = font(14.0, 500, color: const Color(0xFF7E8795));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: SizedBox(
        width: rect.width,
        height: rect.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Palette.card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Palette.shadow.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 5))],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fromRect(
                rect: image,
                child: Opacity(
                  opacity: hidden ? 0 : 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    clipper: _Curtain(curtain),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translateByDouble(0, parallax, 0, 1)
                        ..scaleByDouble(lerp(1.22, 1, settle) + parallax.abs() * 0.004, lerp(1.22, 1, settle) + parallax.abs() * 0.004, 1, 1),
                      child: Image.asset(Assets.riversidePark, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 281.2,
                top: 15.4,
                width: 56.6,
                height: 27,
                child: Transform.scale(
                  scale: badge,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3F5E5).withValues(alpha: 0.93),
                      borderRadius: BorderRadius.circular(13.5),
                      border: Border.all(color: const Color(0xFF2E7D62).withValues(alpha: 0.35), width: 0.8),
                    ),
                    child: Stack(
                      children: [
                        Label('Easy', x: 14.3, base: 18.3, style: font(13.6, 600, color: const Color(0xFF1C8A6F))),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(left: 0, top: 0, right: 0, height: 200, child: rise(0, Stack(clipBehavior: Clip.none, children: [Label('Riverside Park Loop', x: 13.9, base: 156, style: font(17.9, 700, color: const Color(0xFF12203A)))]))),
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      height: 200,
                      child: rise(1, Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned(left: 12.8, top: 168.2, child: Icon(PhosphorBold.path, size: 16, color: Color(0xFF8C95A2))),
                          Label('2.4 km', x: 31.6, base: 181.9, style: meta),
                          const Positioned(left: 84.9, top: 175.4, width: 3.2, height: 3.2, child: _Dot()),
                          Label('30 min', x: 101.1, base: 181.9, style: meta),
                          const Positioned(left: 160.2, top: 175.4, width: 3.2, height: 3.2, child: _Dot()),
                          Label('~180 kcal', x: 172.8, base: 181.9, style: font(13.7, 500, color: const Color(0xFF7E8795))),
                        ],
                      )),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      height: 240,
                      child: rise(2, Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 24.2 - 10,
                            top: 209.2 - 10,
                            width: 20,
                            height: 20,
                            child: Transform.rotate(
                              angle: (1 - item(2)) * -math.pi,
                              child: const Icon(PhosphorFill.star, size: 18, color: Palette.sun),
                            ),
                          ),
                          Label('4.8', x: 39.1, base: 215, style: font(14.2, 700, color: const Color(0xFF3F4E62))),
                          Label('(124)', x: 64.2, base: 215, style: font(13.3, 500, color: const Color(0xFF7E8795))),
                          const Positioned(
                            left: 251 - 8.5,
                            top: 209.2 - 8.5,
                            width: 17,
                            height: 17,
                            child: Icon(PhosphorFill.mapPin, size: 16.5, color: Color(0xFF1F7FE8)),
                          ),
                          Label('1.8 km away', x: 262.2, base: 214.9, style: font(13.7, 600, color: const Color(0xFF356673))),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 9.2 + 333.3 * (1 - button) / 2,
                top: 236,
                width: 333.3 * button + 47.3 * (1 - button),
                height: 47.3,
                child: Opacity(
                  opacity: span(enter, 0.55, 0.7).clamp(0.0, 1.0),
                  child: Pressable(
                    onTap: onOpen,
                    scale: 0.97,
                    child: _ViewButton(reveal: span(enter, 0.8, 1.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({required this.reveal});

  final double reveal;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Palette.emerald,
        borderRadius: BorderRadius.circular(23.65),
        boxShadow: [BoxShadow(color: Palette.emerald.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23.65),
        child: OverflowBox(
          alignment: Alignment.center,
          minWidth: 333.3,
          maxWidth: 333.3,
          child: SizedBox(
            width: 333.3,
            height: 47.3,
            child: Stack(
              children: [
                Opacity(
                  opacity: reveal,
                  child: Stack(
                    children: [
                      Label('View Route', x: 110.6, base: 29.4, style: font(16.4, 700, color: Colors.white)),
                      const Positioned(left: 207.4, top: 14.6, child: LineArrow(size: 18)),
                    ],
                  ),
                ),
                if (reveal > 0 && reveal < 1)
                  Positioned(
                    left: lerp(-120, 360, reveal),
                    top: -10,
                    width: 70,
                    height: 70,
                    child: Transform.rotate(
                      angle: 0.4,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0x00FFFFFF), Color(0x55FFFFFF), Color(0x00FFFFFF)]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Curtain extends CustomClipper<RRect> {
  _Curtain(this.t);

  final double t;

  @override
  RRect getClip(Size size) {
    final h = size.height * t;
    final rect = Rect.fromLTWH(0, (size.height - h) / 2, size.width, h);
    return RRect.fromRectAndRadius(rect, const Radius.circular(16));
  }

  @override
  bool shouldReclip(_Curtain old) => old.t != t;
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(decoration: BoxDecoration(color: Color(0xFF8C95A2), shape: BoxShape.circle));
  }
}
