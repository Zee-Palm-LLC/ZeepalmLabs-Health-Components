import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicify/theme/app_colors.dart';

class MascotBubble extends StatefulWidget {
  const MascotBubble({
    super.key,
    required this.message,
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  State<MascotBubble> createState() => _MascotBubbleState();
}

class _MascotBubbleState extends State<MascotBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bearH = widget.compact ? 76.0 : 118.0;

    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final t = _float.value;
        final dy = math.sin(t * math.pi) * 5;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: bearH * 0.92,
            height: bearH,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: bearH * 0.7,
                    height: bearH * 0.28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.22),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/bear.png',
                  height: bearH,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: widget.compact ? 16 : 28,
                right: 2,
              ),
              child: CustomPaint(
                painter: const _SpeechBubblePainter(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 15, 18, 17),
                  child: Text(
                    widget.message,
                    style: GoogleFonts.inter(
                      fontSize: widget.compact ? 13 : 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: -0.1,
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One continuous path — rounded bubble + left tail.
class _SpeechBubblePainter extends CustomPainter {
  const _SpeechBubblePainter();

  static Path _bubblePath(Size size) {
    const r = 20.0;
    const left = 12.0;
    final right = size.width;
    const top = 0.0;
    final bottom = size.height - 6;
    final tip = Offset(0, size.height - 2);
    final tailTop = bottom - 22;
    final tailBottom = bottom - 5;

    return Path()
      ..moveTo(left + r, top)
      ..lineTo(right - r, top)
      ..quadraticBezierTo(right, top, right, top + r)
      ..lineTo(right, bottom - r)
      ..quadraticBezierTo(right, bottom, right - r, bottom)
      ..lineTo(left + r, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - r)
      ..lineTo(left, tailBottom)
      ..quadraticBezierTo(left * 0.28, tip.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(left * 0.42, tip.dy - 9, left, tailTop)
      ..lineTo(left, top + r)
      ..quadraticBezierTo(left, top, left + r, top)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _bubblePath(size);

    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = AppColors.purple.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawPath(path, Paint()..color = AppColors.white);

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purple.withValues(alpha: 0.18),
            AppColors.border.withValues(alpha: 0.7),
          ],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SpeechBubblePainter oldDelegate) => false;
}
