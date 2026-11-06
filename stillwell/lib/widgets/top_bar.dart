import 'package:flutter/material.dart';

import '../theme.dart';

/// Menu on the left, bell and avatar on the right, all on one centre line
/// 74 pt from the top of the reference screen, inset 18 pt from each edge.
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 56, 18, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Pressable(
              child: _RoundButton(
                child: CustomPaint(size: Size(16, 11), painter: _MenuGlyph()),
              ),
            ),
            const Spacer(),
            Pressable(
              child: _RoundButton(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_rounded, size: 18, color: Tone.night),
                    Positioned(
                      right: -1.5,
                      top: -1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Tone.alert,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 7),
            const Pressable(child: Avatar(size: 36)),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: softShadow),
      child: child,
    );
  }
}

/// Two soft lines, the lower one shorter: a calmer take on the hamburger.
class _MenuGlyph extends CustomPainter {
  const _MenuGlyph();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Tone.night
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(1, size.height * 0.22), Offset(size.width - 1, size.height * 0.22), p);
    canvas.drawLine(Offset(1, size.height * 0.78), Offset(size.width * 0.62, size.height * 0.78), p);
  }

  @override
  bool shouldRepaint(_MenuGlyph old) => false;
}

/// Sinks slightly under the finger and springs back on release.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.9});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: Duration(milliseconds: _down ? 90 : 420),
        curve: _down ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}

/// Lilac disc with a small orange fluffy creature peeking up.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ClipOval(child: CustomPaint(painter: _CreaturePainter())),
    );
  }
}

class _CreaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final bg = Offset.zero & size;
    canvas.drawRect(
      bg,
      Paint()
        ..shader = const RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFFDCCBFA), Color(0xFFB79CF0)]).createShader(bg),
    );
    final body = Rect.fromCenter(center: Offset(w * 0.5, w * 0.68), width: w * 0.78, height: w * 0.86);
    canvas.drawOval(
      body,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.45),
          colors: [Color(0xFFFFB067), Color(0xFFF27A2A), Color(0xFFD45A16)],
          stops: [0, 0.6, 1],
        ).createShader(body),
    );
    // Ear tufts.
    for (final sx in [-1.0, 1.0]) {
      final ear = Path()
        ..moveTo(w * (0.5 + sx * 0.2), w * 0.34)
        ..lineTo(w * (0.5 + sx * 0.33), w * 0.18)
        ..lineTo(w * (0.5 + sx * 0.34), w * 0.4)
        ..close();
      canvas.drawPath(ear, Paint()..color = const Color(0xFFF07A2C));
    }
    // Eyes.
    for (final sx in [-1.0, 1.0]) {
      final c = Offset(w * (0.5 + sx * 0.14), w * 0.5);
      canvas.drawCircle(c, w * 0.105, Paint()..color = Colors.white);
      canvas.drawCircle(c + Offset(sx * w * 0.012, w * 0.01), w * 0.06, Paint()..color = const Color(0xFF231A14));
      canvas.drawCircle(c + Offset(-w * 0.02, -w * 0.03), w * 0.018, Paint()..color = Colors.white);
    }
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, w * 0.66), width: w * 0.12, height: w * 0.06),
      Paint()..color = const Color(0xFFB4470F),
    );
  }

  @override
  bool shouldRepaint(_CreaturePainter old) => false;
}
