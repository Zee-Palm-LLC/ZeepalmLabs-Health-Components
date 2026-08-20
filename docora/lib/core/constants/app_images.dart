import 'package:flutter/material.dart';

/// Loads a local asset image with a soft placeholder while decoding.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  final String path;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) {
        return ColoredBox(
          color: const Color(0xFFE8F1FF),
          child: Icon(
            Icons.person_rounded,
            color: const Color(0xFF1677FF).withValues(alpha: 0.45),
          ),
        );
      },
    );
  }
}

abstract final class AppImages {
  static const doctors = 'assets/images/doctors';
  static const hospitals = 'assets/images/hospitals';

  static const userAvatar = '$doctors/user_avatar.jpg';
  static const supportAvatar = '$doctors/support_avatar.jpg';
  static const bannerDoctor = '$doctors/banner_doctor.jpg';

  static const esther = '$doctors/doctor_esther.jpg';
  static const jacob = '$doctors/doctor_jacob.jpg';
  static const bessie = '$doctors/doctor_bessie.jpg';
  static const darlene = '$doctors/doctor_darlene.jpg';
  static const brooklyn = '$doctors/doctor_brooklyn.jpg';
  static const courtney = '$doctors/doctor_courtney.jpg';

  static const hospital1 = '$hospitals/hospital_1.jpg';
  static const hospital2 = '$hospitals/hospital_2.jpg';
  static const hospital3 = '$hospitals/hospital_3.jpg';
}
