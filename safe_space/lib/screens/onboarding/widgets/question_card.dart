import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.background,
    required this.question,
    required this.meta,
    required this.leading,
    this.width = 188,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 14),
  });

  final Color background;
  final String question;
  final String meta;
  final Widget leading;
  final double width;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(height: 10),
          Text(
            question,
            style: GoogleFonts.libreBaskerville(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            meta,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class SoftAvatar extends StatelessWidget {
  const SoftAvatar({
    super.key,
    required this.child,
    this.size = 28,
    this.background = AppColors.softLavender,
  });

  final Widget child;
  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Simple stylized face matching the lavender character icon in the design.
class CharacterFace extends StatelessWidget {
  const CharacterFace({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SoftAvatar(
      size: size,
      background: const Color(0xFFB8AED9),
      child: CustomPaint(
        size: Size.square(size),
        painter: _FacePainter(),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2 + size.height * 0.04;

    // Head blob
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - size.height * 0.02),
        width: size.width * 0.62,
        height: size.height * 0.58,
      ),
      paint,
    );

    // Eyes
    final eye = Paint()..color = const Color(0xFF5C5278);
    canvas.drawCircle(
      Offset(cx - size.width * 0.12, cy - size.height * 0.05),
      size.width * 0.045,
      eye,
    );
    canvas.drawCircle(
      Offset(cx + size.width * 0.12, cy - size.height * 0.05),
      size.width * 0.045,
      eye,
    );

    // Soft smile
    final smile = Paint()
      ..color = const Color(0xFF5C5278)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(cx - size.width * 0.1, cy + size.height * 0.08)
      ..quadraticBezierTo(
        cx,
        cy + size.height * 0.16,
        cx + size.width * 0.1,
        cy + size.height * 0.08,
      );
    canvas.drawPath(smilePath, smile);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PhotoAvatar extends StatelessWidget {
  const PhotoAvatar({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SoftAvatar(
      size: size,
      background: const Color(0xFFD4C4B0),
      child: CustomPaint(
        size: Size.square(size),
        painter: _PersonPainter(),
      ),
    );
  }
}

class _PersonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skin = Paint()..color = const Color(0xFFE8C4A8);
    final hair = Paint()..color = const Color(0xFF4A3728);
    final shirt = Paint()..color = const Color(0xFF7A9BB8);

    // Shoulders
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.92),
        width: size.width * 0.78,
        height: size.height * 0.42,
      ),
      shirt,
    );

    // Head
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.42),
      size.width * 0.28,
      skin,
    );

    // Hair
    final hairPath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.12,
        size.width * 0.5,
        size.height * 0.12,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.12,
        size.width * 0.78,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.28,
        size.width * 0.5,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.28,
        size.width * 0.22,
        size.height * 0.38,
      );
    canvas.drawPath(hairPath, hair);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
