import 'package:flutter/material.dart';

import '../data/sessions.dart';
import '../theme.dart';
import 'dot_text.dart';

/// Card size in the reference, in points.
const cardSize = Size(277, 232);
const cardRadius = 24.0;

/// The card's glass background: warm wash, a soft colour blob up top and a
/// cool blue settling at the bottom.
class CardGlass extends StatelessWidget {
  const CardGlass({super.key, required this.session, required this.radius});

  final Session session;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final blob = session.blob;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(blob, const Color(0xFFF7EFE7), 0.72)!,
            const Color(0xFFF5F0EA),
            const Color(0xFFE9EEF6),
            const Color(0xFFD5E2F5),
          ],
          stops: const [0, 0.48, 0.72, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: RadialGradient(
            center: const Alignment(0.05, -0.6),
            radius: 0.8,
            colors: [blob, blob.withValues(alpha: 0.72), blob.withValues(alpha: 0.22), blob.withValues(alpha: 0)],
            stops: const [0, 0.24, 0.58, 1],
          ),
        ),
      ),
    );
  }
}

/// Everything printed on the card, laid out at [cardSize].
class CardFace extends StatelessWidget {
  const CardFace({super.key, required this.session, this.dim = 0});

  final Session session;

  /// Neighbouring cards keep only their tag and play button.
  final double dim;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: cardSize,
      child: Stack(
        children: [
          Positioned(left: 14, top: 16, child: _Tag(session: session)),
          const Positioned(right: 15, top: 14, child: PlayButton(size: 28)),
          Positioned(
            left: 0,
            right: 0,
            top: 61,
            child: Opacity(
              opacity: 1 - dim,
              child: Center(child: DotText(session.time, pitch: 2.1, dot: 0.86, glow: session.mood.deep.withValues(alpha: 0.18))),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 1 - dim,
              child: Stack(
                children: [
                  Positioned(left: 16, top: 122, child: Text(session.title, style: sans(19.8, spacing: -0.4))),
                  Positioned(
                    left: 16,
                    top: 151,
                    child: Text(session.subtitle, style: sans(11.75, color: const Color(0xFF6E6A66))),
                  ),
                  const Positioned(left: 16, right: 16, top: 176, height: 22, child: BreathRuler()),
                  Positioned(
                    left: 16,
                    top: 201,
                    child: Row(
                      children: [
                        for (final (i, cue) in session.cues.indexed) ...[
                          if (i > 0) const SizedBox(width: 16),
                          Text(cue, style: sans(11, weight: FontWeight.w500, color: const Color(0xFF3F3C39))),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.only(left: 8, right: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(session.icon, size: 12, color: Tone.text),
          const SizedBox(width: 5),
          Text(session.tag, style: sans(10.8, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Tone.night,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Icon(Icons.play_arrow_rounded, size: size * 0.55, color: Colors.white),
    );
  }
}

/// Fine tick ruler with a heavier marker at the current breath.
class BreathRuler extends StatelessWidget {
  const BreathRuler({super.key, this.marker = 0.2});

  final double marker;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _RulerPainter(marker));
}

class _RulerPainter extends CustomPainter {
  const _RulerPainter(this.marker);

  final double marker;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 4.6;
    final n = (size.width / step).floor();
    final thin = Paint()
      ..color = const Color(0xFF5E5A57).withValues(alpha: 0.55)
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i <= n; i++) {
      final x = i * step;
      final tall = i % 5 == 0;
      final h = tall ? 13.0 : 8.0;
      canvas.drawLine(Offset(x, size.height - 3 - h), Offset(x, size.height - 3), thin);
    }
    final mx = (size.width * marker / step).round() * step;
    canvas.drawLine(
      Offset(mx, 0),
      Offset(mx, size.height - 1),
      Paint()
        ..color = Tone.text
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.marker != marker;
}
