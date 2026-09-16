import 'package:flutter/material.dart';

abstract final class ShowcaseAssets {
  static const doctorFeatured = 'assets/images/doctor_featured.jpg';
  static const pillOrb = 'assets/images/pill_orb.jpg';
  static const consultLeft = 'assets/images/consult_left.jpg';
  static const consultCenter = 'assets/images/consult_center.jpg';
  static const consultRight = 'assets/images/consult_right.jpg';
  static const clinicHeartCare = 'assets/images/clinic_heart_care.jpg';
  static const clinicCentralMedical = 'assets/images/clinic_central_medical.jpg';
  static const clinicBrightSmile = 'assets/images/clinic_bright_smile.jpg';
  static const avatarPatient = 'assets/images/avatar_patient.png';
  static const avatarDoctor1 = 'assets/images/avatar_doctor_1.png';
  static const avatarDoctor2 = 'assets/images/avatar_doctor_2.png';
  static const avatarDoctor3 = 'assets/images/avatar_doctor_3.png';
}

class FeaturedAppointment {
  const FeaturedAppointment({
    required this.doctor,
    required this.specialty,
    required this.fee,
    required this.photoAsset,
    required this.durationMinutes,
    required this.day,
    required this.month,
  });

  final String doctor;
  final String specialty;
  final String fee;
  final String photoAsset;
  final int durationMinutes;
  final String day;
  final String month;
}

class Appointment {
  const Appointment({
    required this.specialty,
    required this.schedule,
    required this.icon,
    required this.color,
  });

  final String specialty;
  final String schedule;
  final IconData icon;
  final Color color;
}

class Consultation {
  const Consultation({
    required this.initials,
    required this.avatarAsset,
    required this.photoAsset,
    this.doctorName,
    this.status,
  });

  final String initials;
  final String avatarAsset;
  final String photoAsset;
  final String? doctorName;
  final String? status;
}

class Clinic {
  const Clinic({
    required this.name,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.photoAsset,
  });

  final String name;
  final String description;
  final double rating;
  final int reviewCount;
  final String photoAsset;

  String get ratingLabel => '${rating.toStringAsFixed(1)} ($reviewCount)';
}

const featuredAppointment = FeaturedAppointment(
  doctor: 'Dr. Arjun Mehta',
  specialty: 'Cardiologist',
  fee: r'$120',
  photoAsset: ShowcaseAssets.doctorFeatured,
  durationMinutes: 30,
  day: '24',
  month: 'Sep',
);

const upcomingAppointments = [
  Appointment(
    specialty: 'Cardiology',
    schedule: 'Check-up, 24 Sep 2026',
    icon: Icons.monitor_heart_rounded,
    color: Color(0xFFE5402B),
  ),
  Appointment(
    specialty: 'Blood Test',
    schedule: 'Lab visit, 2 Oct 2026',
    icon: Icons.bloodtype_rounded,
    color: Color(0xFFD6336C),
  ),
  Appointment(
    specialty: 'Eye Exam',
    schedule: 'Vision test, 15 Oct 2026',
    icon: Icons.visibility_rounded,
    color: Color(0xFF3B7BE0),
  ),
  Appointment(
    specialty: 'Vaccination',
    schedule: 'Flu shot, 4 Nov 2026',
    icon: Icons.vaccines_rounded,
    color: Color(0xFF2F9E6B),
  ),
];

const worldwideConsultations = [
  Consultation(initials: 'DK', avatarAsset: ShowcaseAssets.avatarDoctor1, photoAsset: ShowcaseAssets.consultLeft),
  Consultation(initials: 'SM', avatarAsset: ShowcaseAssets.avatarDoctor2, photoAsset: ShowcaseAssets.consultCenter),
  Consultation(
    initials: 'RL',
    avatarAsset: ShowcaseAssets.avatarDoctor3,
    photoAsset: ShowcaseAssets.consultRight,
    doctorName: 'Dr. Lee',
    status: 'online now',
  ),
];

const topClinics = [
  Clinic(
    name: 'Heart Care Institute',
    description: 'Advanced cardiac screening with same-week appointments',
    rating: 4.9,
    reviewCount: 120,
    photoAsset: ShowcaseAssets.clinicHeartCare,
  ),
  Clinic(
    name: 'Central Medical Centre',
    description: 'A leading multi-specialty hospital, open around the clock',
    rating: 4.7,
    reviewCount: 312,
    photoAsset: ShowcaseAssets.clinicCentralMedical,
  ),
  Clinic(
    name: 'Bright Smile Dental',
    description: 'Gentle cleanings, whitening and family dental care',
    rating: 4.8,
    reviewCount: 96,
    photoAsset: ShowcaseAssets.clinicBrightSmile,
  ),
];
