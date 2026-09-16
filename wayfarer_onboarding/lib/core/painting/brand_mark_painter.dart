import 'package:flutter/rendering.dart';

import '../theme/app_colors.dart';

/// The mark that perches on the wordmark: an ink stethoscope tube rising into
/// a rounded orange medical cross.
class BrandMarkPainter extends CustomPainter {
  const BrandMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cross = Offset(w * 0.60, h * 0.34);

    final tube = Path()
      ..moveTo(w * 0.24, h * 0.94)
      ..quadraticBezierTo(w * 0.30, h * 0.52, cross.dx, cross.dy);
    canvas.drawPath(
      tube,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.1
        ..strokeCap = StrokeCap.round,
    );

    final arm = w * 0.2;
    final span = w * 0.62;
    final radius = Radius.circular(arm * 0.32);
    final orange = Paint()..color = AppColors.orange;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: cross, width: span, height: arm), radius), orange);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: cross, width: arm, height: span), radius), orange);
  }

  @override
  bool shouldRepaint(BrandMarkPainter oldDelegate) => false;
}
