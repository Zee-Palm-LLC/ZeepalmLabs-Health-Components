import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/palette.dart';
import '../../../widgets/stardust.dart';

Rect heroFrameRect(Size box, double blend) {
  final coverScale =
      math.max(box.width / D.frameWidth, box.height / D.frameHeight);
  final cover = Rect.fromLTWH(
    (box.width - D.frameWidth * coverScale) / 2,
    (box.height - D.frameHeight * coverScale) / 2,
    D.frameWidth * coverScale,
    D.frameHeight * coverScale,
  );
  if (blend <= 0) return cover;

  final heroH = box.height * D.heroHeightFraction;
  final heroW = heroH * D.heroAspect;
  final matchScale = heroW / D.cutWidth;
  final match = Rect.fromLTWH(
    box.width * D.heroCentreFraction - heroW / 2 - D.cutLeft * matchScale,
    box.height * D.heroTopFraction - D.cutTop * matchScale,
    D.frameWidth * matchScale,
    D.frameHeight * matchScale,
  );
  return Rect.lerp(cover, match, blend.clamp(0.0, 1.0))!;
}

class HeroStage extends StatelessWidget {
  const HeroStage({
    super.key,
    required this.entrance,
    required this.idle,
    required this.parallax,
    this.surge = 0,
    this.tint,
    this.tintStrength = 0,
  });

  final double entrance;

  final double idle;

  final Offset parallax;

  final double surge;

  final Color? tint;
  final double tintStrength;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        final plateIn = D.plateIn.transform(entrance);
        final heroIn = D.heroIn.transform(entrance);
        final flash = D.platformFlash.transform(entrance);

        final heroH = h * D.heroHeightFraction;
        final heroW = heroH * D.heroAspect;
        final heroLeft = w * D.heroCentreFraction - heroW / 2;
        final heroTop = h * D.heroTopFraction;

        final breathe = math.sin(idle * 2 * math.pi / 4.2) * 4;
        final sway = math.sin(idle * 2 * math.pi / 6.7) * 2.4;

        final groundY = heroTop + heroH * 0.80;
        final auraCentre = Offset(
          heroLeft + heroW / 2 + parallax.dx * 8,
          heroTop + heroH * 0.34 + parallax.dy * 6,
        );

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Transform.translate(
                offset: Offset(parallax.dx * 9, parallax.dy * 7),
                child: Transform.scale(
                  scale: 1.07 + (1 - plateIn) * 0.06,
                  child: Opacity(
                    opacity: plateIn.clamp(0.0, 1.0),
                    child: Image.asset(
                      'assets/hero/plate.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),

              _Aura(
                centre: auraCentre,
                radius: heroW * (0.78 + 0.03 * math.sin(idle * 1.1)),
                opacity: plateIn.clamp(0.0, 1.0) *
                    (0.55 + 0.12 * math.sin(idle * 0.8)) +
                    surge * 0.35,
                tint: tint,
                tintStrength: tintStrength,
              ),

              Stardust(
                parallax: parallax,
                intensity: plateIn.clamp(0.0, 1.0),
                surge: surge,
              ),

              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xF204050C),
                        Color(0x9904050C),
                        Color(0x1A04050C),
                        Color(0x00000000),
                        Color(0x3304050C),
                        Color(0xCC04050C),
                      ],
                      stops: <double>[0.0, 0.11, 0.22, 0.44, 0.72, 1.0],
                    ),
                  ),
                  child: SizedBox.expand(),
                ),
              ),

              Positioned(
                left: heroLeft + parallax.dx * 26 + sway,
                top: heroTop + parallax.dy * 18 + breathe + (1 - heroIn) * 64,
                width: heroW,
                height: heroH,
                child: Opacity(
                  opacity: heroIn.clamp(0.0, 1.0),
                  child: _Figure(tint: tint, tintStrength: tintStrength),
                ),
              ),

              if (flash > 0 && flash < 1)
                Positioned(
                  left: 0,
                  right: 0,
                  top: groundY - heroW * 0.5,
                  height: heroW,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _LandingFlash(t: flash, width: heroW),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.tint, required this.tintStrength});

  final Color? tint;
  final double tintStrength;

  @override
  Widget build(BuildContext context) {
    const image = Image(
      image: AssetImage('assets/hero/hero.png'),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );
    final t = tint;
    if (t == null || tintStrength <= 0) return image;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect bounds) => RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: <Color>[
          t.withValues(alpha: 0.42 * tintStrength),
          t.withValues(alpha: 0.10 * tintStrength),
        ],
      ).createShader(bounds),
      child: image,
    );
  }
}

class _Aura extends StatelessWidget {
  const _Aura({
    required this.centre,
    required this.radius,
    required this.opacity,
    required this.tint,
    required this.tintStrength,
  });

  final Offset centre;
  final double radius;
  final double opacity;
  final Color? tint;
  final double tintStrength;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(
          painter: _AuraPainter(
            centre: centre,
            radius: radius,
            opacity: opacity,
            tint: tint,
            tintStrength: tintStrength,
          ),
        ),
      );
}

class _AuraPainter extends CustomPainter {
  const _AuraPainter({
    required this.centre,
    required this.radius,
    required this.opacity,
    required this.tint,
    required this.tintStrength,
  });

  final Offset centre;
  final double radius;
  final double opacity;
  final Color? tint;
  final double tintStrength;

  @override
  void paint(Canvas canvas, Size size) {
    final o = opacity.clamp(0.0, 1.0);
    if (o <= 0) return;
    final base = tint == null
        ? Spectrum.violet
        : Color.lerp(Spectrum.violet, tint, tintStrength.clamp(0.0, 1.0))!;
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: <Color>[
            base.withValues(alpha: 0.34 * o),
            base.withValues(alpha: 0.14 * o),
            const Color(0x00000000),
          ],
          stops: const <double>[0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_AuraPainter old) =>
      old.centre != centre ||
      old.radius != radius ||
      old.opacity != opacity ||
      old.tint != tint ||
      old.tintStrength != tintStrength;
}

class _LandingFlash extends CustomPainter {
  const _LandingFlash({required this.t, required this.width});

  final double t;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final eased = Curves.easeOutCubic.transform(t);
    final fade = (1 - t).clamp(0.0, 1.0);

    final r = width * (0.25 + eased * 0.95);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 2, height: r * 0.52),
      Paint()
        ..blendMode = BlendMode.plus
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + 7 * fade
        ..color = Spectrum.violet.withValues(alpha: 0.55 * fade)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + 10 * fade),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c,
        width: width * 1.4 * (0.4 + eased * 0.6),
        height: width * 0.36 * (0.4 + eased * 0.6),
      ),
      Paint()
        ..blendMode = BlendMode.plus
        ..color = Spectrum.cyan.withValues(alpha: 0.18 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
  }

  @override
  bool shouldRepaint(_LandingFlash old) => old.t != t || old.width != width;
}
