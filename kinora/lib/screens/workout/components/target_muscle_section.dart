import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../landing_page/components/math_motion.dart';

class TargetMuscleSection extends StatefulWidget {
  const TargetMuscleSection({super.key});

  @override
  State<TargetMuscleSection> createState() => _TargetMuscleSectionState();
}

class _TargetMuscleSectionState extends State<TargetMuscleSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
        decoration: BoxDecoration(
          color: KinoraColors.cardSoft.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Muscle',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: KinoraColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      final glow =
                          0.7 + 0.3 * MathMotion.smootherstep(_pulse.value);
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: KinoraColors.lime,
                              boxShadow: [
                                BoxShadow(
                                  color: KinoraColors.lime
                                      .withValues(alpha: 0.55 * glow),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Biceps',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: KinoraColors.lime
                                  .withValues(alpha: glow),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Primary focus · isolation',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: KinoraColors.mutedSoft,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final highlight =
                    0.65 + 0.35 * MathMotion.smootherstep(_pulse.value);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: KinoraColors.lime.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomPaint(
                        size: const Size(48, 90),
                        painter: _BodySilhouettePainter(
                          front: true,
                          highlight: highlight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomPaint(
                        size: const Size(48, 90),
                        painter: _BodySilhouettePainter(
                          front: false,
                          highlight: 0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BodySilhouettePainter extends CustomPainter {
  _BodySilhouettePainter({
    required this.front,
    required this.highlight,
  });

  final bool front;
  final double highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Paint()
      ..color = const Color(0xFF4A4A50)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.addOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.09),
        width: w * 0.34,
        height: h * 0.14,
      ),
    );
    path.moveTo(w * 0.28, h * 0.18);
    path.quadraticBezierTo(w * 0.18, h * 0.35, w * 0.22, h * 0.52);
    path.lineTo(w * 0.30, h * 0.52);
    path.lineTo(w * 0.32, h * 0.92);
    path.quadraticBezierTo(w * 0.40, h * 0.98, w * 0.48, h * 0.92);
    path.lineTo(w * 0.52, h * 0.92);
    path.quadraticBezierTo(w * 0.60, h * 0.98, w * 0.68, h * 0.92);
    path.lineTo(w * 0.70, h * 0.52);
    path.lineTo(w * 0.78, h * 0.52);
    path.quadraticBezierTo(w * 0.82, h * 0.35, w * 0.72, h * 0.18);
    path.close();

    final leftArm = Path()
      ..moveTo(w * 0.26, h * 0.22)
      ..quadraticBezierTo(w * 0.02, h * 0.34, w * 0.10, h * 0.48)
      ..quadraticBezierTo(w * 0.18, h * 0.42, w * 0.28, h * 0.36)
      ..close();
    final rightArm = Path()
      ..moveTo(w * 0.74, h * 0.22)
      ..quadraticBezierTo(w * 0.98, h * 0.34, w * 0.90, h * 0.48)
      ..quadraticBezierTo(w * 0.82, h * 0.42, w * 0.72, h * 0.36)
      ..close();

    canvas.drawPath(path, body);
    canvas.drawPath(leftArm, body);
    canvas.drawPath(rightArm, body);

    if (front && highlight > 0) {
      final glow = Paint()
        ..color = KinoraColors.lime.withValues(alpha: 0.45 * highlight)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
      final solid = Paint()
        ..color = KinoraColors.lime.withValues(alpha: 0.9 * highlight);

      for (final cx in [w * 0.18, w * 0.82]) {
        final center = Offset(cx, h * 0.34);
        canvas.drawOval(
          Rect.fromCenter(center: center, width: w * 0.18, height: h * 0.11),
          glow,
        );
        canvas.drawOval(
          Rect.fromCenter(center: center, width: w * 0.12, height: h * 0.07),
          solid,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BodySilhouettePainter oldDelegate) =>
      oldDelegate.front != front || oldDelegate.highlight != highlight;
}
