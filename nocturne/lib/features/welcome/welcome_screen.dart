import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../core/widgets.dart';
import '../../scene/sky.dart';
import '../shell/shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final List<Twinkle> _stars;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    _stars = scatterStars(
      count: 34,
      seed: 4,
      accept: (u) {
        final x = u.dx * 393;
        final y = u.dy * 852 * 0.36 + 58;
        if (x < 112) return false;
        if ((Offset(x, y) - const Offset(197, 125)).distance < 58) return false;
        if (x > 96 && x < 318 && y > 166 && y < 250) return false;
        final ridge = 272 - (x - 250).abs() * 0.12;
        return y < ridge;
      },
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _begin() {
    Navigator.of(context).pushReplacement(
      dreamRoute(const Shell(), duration: const Duration(milliseconds: 850)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: const Color(0xFF0C0B19),
      body: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          final s = w / 393;
          final plate = _plateRect(Size(w, h));
          Offset onPlate(double x, double y) => Offset(
            plate.left + x / 393 * plate.width,
            plate.top + y / 852 * plate.height,
          );
          final ps = plate.width / 393;
          final bottom = math.max(pad.bottom, 16.0);
          final moon = onPlate(197, 125);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fromRect(
                rect: plate,
                child: Staged(
                  controller: _intro,
                  begin: 0,
                  end: 0.55,
                  scaleFrom: 1.06,
                  child: Image.asset(
                    'assets/images/welcome_night.jpg',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: Rect.fromLTWH(
                  plate.left,
                  plate.top,
                  plate.width,
                  plate.height * 0.36 + 58 * ps,
                ),
                child: Staged(
                  controller: _intro,
                  begin: 0.25,
                  end: 0.9,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SkyStars(
                        _stars,
                        top: 58 * ps,
                        height: plate.height * 0.36,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: plate,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: LanternGlowPainter(
                      const Offset(115 / 393, 368 / 852),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: h * 0.52,
                child: const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x000C0B19),
                          Color(0x590C0B19),
                          Color(0xB80C0B19),
                          Color(0xE00B0A17),
                        ],
                        stops: [0, 0.34, 0.66, 1],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: moon.dx - 34 * ps,
                top: moon.dy - 34 * ps,
                child: Staged(
                  controller: _intro,
                  begin: 0.12,
                  end: 0.6,
                  slide: 10,
                  child: Crescent(
                    radius: 34 * ps,
                    cut: const Offset(0.4, -0.3),
                    cutScale: 0.88,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: onPlate(0, 164).dy,
                child: Staged(
                  controller: _intro,
                  begin: 0.24,
                  end: 0.74,
                  slide: 14,
                  child: Column(
                    children: [
                      Text(
                        'Nocturne',
                        style: Typo.display(
                          45 * s,
                          spacing: 0.4 * s,
                          height: 1.12,
                        ),
                      ),
                      SizedBox(height: 7 * s),
                      Text(
                        'Soundscapes for a Calmer You',
                        style: Typo.ui(
                          13.8 * s,
                          color: Night.textSoft,
                          spacing: 0.25 * s,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 31 * s,
                bottom: bottom + 246 * s,
                child: Staged(
                  controller: _intro,
                  begin: 0.42,
                  end: 0.86,
                  slide: 12,
                  child: Text(
                    'Better Sleep\nBrighter Tomorrow',
                    style: Typo.serifText(
                      19.6 * s,
                      spacing: 0.45 * s,
                      height: 1.36,
                      color: const Color(0xFFEDEAF6),
                      weight: 400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: bottom + 112 * s,
                child: Staged(
                  controller: _intro,
                  begin: 0.5,
                  end: 0.94,
                  slide: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: _Feature(
                          glyph: G.leaf,
                          label: 'Calm\nYour Mind',
                          scale: s,
                        ),
                      ),
                      Expanded(
                        child: _Feature(
                          glyph: G.waveform,
                          label: 'Soothing\nSoundscapes',
                          scale: s,
                        ),
                      ),
                      Expanded(
                        child: _Feature(
                          glyph: G.moonFill,
                          label: 'Deeper\nRest',
                          scale: s,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 24 * s,
                right: 24 * s,
                bottom: bottom + 15 * s,
                child: Staged(
                  controller: _intro,
                  begin: 0.6,
                  end: 1,
                  slide: 16,
                  child: _BeginButton(onTap: _begin, scale: s),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Rect _plateRect(Size size) {
    const aspect = 1179 / 2556;
    var w = size.width;
    var h = w / aspect;
    if (h < size.height) {
      h = size.height;
      w = h * aspect;
    }
    final left = (size.width - w) / 2;
    final top = h > size.height * 1.02 ? -(h - size.height) * 0.3 : 0.0;
    return Rect.fromLTWH(left, top, w, h);
  }
}

class _SkyStars extends CustomPainter {
  _SkyStars(this.stars, {required this.top, required this.height})
    : _inner = StarsPainter(stars, opacity: 0.8);

  final List<Twinkle> stars;
  final double top;
  final double height;
  final StarsPainter _inner;

  @override
  void addListener(VoidCallback listener) => _inner.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _inner.removeListener(listener);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, top);
    _inner.paint(canvas, Size(size.width, height));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkyStars old) =>
      old.stars != stars || old.top != top || old.height != height;
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.glyph,
    required this.label,
    required this.scale,
  });

  final G glyph;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54 * s,
          height: 54 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.2, -0.4),
              radius: 1,
              colors: [Color(0x21FFFFFF), Color(0x0FFFFFFF)],
            ),
            border: Border.all(color: const Color(0x0FFFFFFF)),
          ),
          child: Glyph(
            glyph,
            size: 22 * s,
            color: const Color(0xFFE6E1FA),
            stroke: 1.6 * s,
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Typo.ui(12.6 * s, color: const Color(0xFFCBC8DA), height: 1.5),
        ),
      ],
    );
  }
}

class _BeginButton extends StatelessWidget {
  const _BeginButton({required this.onTap, required this.scale});

  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: Container(
        height: 56 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28 * s),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFB9A8FB), Color(0xFFC9BCFF), Color(0xFFB5A4F8)],
            stops: [0, 0.55, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9D86FF).withValues(alpha: 0.55),
              blurRadius: 26 * s,
              spreadRadius: -2 * s,
              offset: Offset(0, 4 * s),
            ),
            BoxShadow(
              color: const Color(0xFFB8A6FF).withValues(alpha: 0.3),
              blurRadius: 8 * s,
              spreadRadius: -1 * s,
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28 * s),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 0.8,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0, 0.55],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Begin Your Journey',
              style: Typo.ui(
                15 * s,
                color: Night.ink,
                weight: 500,
                spacing: 0.1,
              ),
            ),
            SizedBox(width: 14 * s),
            Glyph(G.arrow, size: 20 * s, color: Night.ink, stroke: 1.7 * s),
          ],
        ),
      ),
    );
  }
}
