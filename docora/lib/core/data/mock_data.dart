import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.experienceYears,
    required this.fee,
    required this.hospital,
    required this.avatarColor,
    required this.initials,
    this.imageUrl,
    this.availableNow = false,
    this.successRate = 80,
    this.patients = '10k+',
  });

  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String reviews;
  final int experienceYears;
  final double fee;
  final String hospital;
  final Color avatarColor;
  final String initials;
  final String? imageUrl;
  final bool availableNow;
  final int successRate;
  final String patients;
}

class SpecialistModel {
  const SpecialistModel({
    required this.label,
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color iconColor;
}

abstract final class MockData {
  static const userName = 'Muhammad Farhan';

  static const upcoming = DoctorModel(
    id: 'eleanor',
    name: 'Dr. Eleanor Pena',
    specialty: 'Cardiologist',
    rating: 4.9,
    reviews: '20k+',
    experienceYears: 8,
    fee: 120,
    hospital: 'City Heart Hospital',
    avatarColor: Color(0xFFB8D4F0),
    initials: 'EP',
  );

  static const featured = DoctorModel(
    id: 'brooklyn',
    name: 'Dr. Brooklyn Simmons',
    specialty: 'Heart specialist',
    rating: 4.9,
    reviews: '22k+',
    experienceYears: 8,
    fee: 120,
    hospital: 'The Valley Hospital',
    avatarColor: Color(0xFFD4C4B0),
    initials: 'BS',
    successRate: 80,
    patients: '10k+',
  );

  static const specialists = [
    SpecialistModel(
      label: 'Cardiologist',
      icon: Icons.favorite_rounded,
      background: AppColors.cardio,
      iconColor: AppColors.cardioIcon,
    ),
    SpecialistModel(
      label: 'Dermatologist',
      icon: Icons.face_retouching_natural_rounded,
      background: AppColors.derma,
      iconColor: AppColors.dermaIcon,
    ),
    SpecialistModel(
      label: 'Neurologist',
      icon: Icons.psychology_alt_rounded,
      background: AppColors.neuro,
      iconColor: AppColors.neuroIcon,
    ),
  ];

  static const topRated = [
    DoctorModel(
      id: 'esther',
      name: 'Dr. Esther Howard',
      specialty: 'Heart specialist',
      rating: 4.9,
      reviews: '20k+',
      experienceYears: 8,
      fee: 120,
      hospital: 'City Heart Hospital',
      avatarColor: Color(0xFFE8C4A8),
      initials: 'EH',
      imageUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&crop=faces',
    ),
    DoctorModel(
      id: 'jacob',
      name: 'Dr. Jacob Jones',
      specialty: 'Neurologist',
      rating: 4.8,
      reviews: '19k+',
      experienceYears: 9,
      fee: 130,
      hospital: 'Brain Center',
      avatarColor: Color(0xFFD4B8E8),
      initials: 'JJ',
      imageUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f4a5b16d?w=400&auto=format&fit=crop&crop=faces',
    ),
    DoctorModel(
      id: 'bessie',
      name: 'Dr. Bessie Cooper',
      specialty: 'Ophthalmologist',
      rating: 4.8,
      reviews: '20k+',
      experienceYears: 7,
      fee: 115,
      hospital: 'Vision Care Clinic',
      avatarColor: Color(0xFFB8CCE8),
      initials: 'BC',
      imageUrl:
          'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&auto=format&fit=crop&crop=faces',
    ),
  ];

  static const nearMe = [
    DoctorModel(
      id: 'darlene',
      name: 'Dr. Darlene Robertson',
      specialty: 'Dermatologist',
      rating: 4.6,
      reviews: '22k+',
      experienceYears: 7,
      fee: 120,
      hospital: 'Skin Care Clinic',
      avatarColor: Color(0xFFE8D4C4),
      initials: 'DR',
      availableNow: true,
      imageUrl:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&crop=faces',
    ),
    DoctorModel(
      id: 'brooklyn',
      name: 'Dr. Brooklyn Simmons',
      specialty: 'Heart specialist',
      rating: 4.9,
      reviews: '22k+',
      experienceYears: 7,
      fee: 120,
      hospital: 'The Valley Hospital',
      avatarColor: Color(0xFFD4C4B0),
      initials: 'BS',
      availableNow: true,
      imageUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f4a5b16d?w=400&auto=format&fit=crop&crop=faces',
    ),
    DoctorModel(
      id: 'courtney',
      name: 'Dr. Courtney Henry',
      specialty: 'Cardiologist',
      rating: 4.8,
      reviews: '12k+',
      experienceYears: 5,
      fee: 110,
      hospital: 'Heart Care Plus',
      avatarColor: Color(0xFFE8B8C4),
      initials: 'CH',
      availableNow: true,
      imageUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&crop=faces',
    ),
  ];

  static DoctorModel? byId(String id) {
    final all = [upcoming, featured, ...topRated, ...nearMe];
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }
}
