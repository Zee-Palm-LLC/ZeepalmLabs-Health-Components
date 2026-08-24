import 'package:flutter/material.dart';

import '../constants/app_images.dart';
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
  /// Local asset path, e.g. `assets/images/doctors/doctor_esther.jpg`
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

class HospitalModel {
  const HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.departments,
    required this.imagePath,
    required this.openHours,
    this.isEmergency = false,
    this.isOpen = true,
    this.phone = '+1 555 0100',
    this.about =
        'A trusted multi-specialty hospital delivering compassionate care with modern facilities and experienced specialists.',
  });

  final String id;
  final String name;
  final String address;
  final String distance;
  final double rating;
  final String reviews;
  final List<String> departments;
  final String imagePath;
  final String openHours;
  final bool isEmergency;
  final bool isOpen;
  final String phone;
  final String about;
}

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.doctor,
    required this.date,
    required this.time,
    required this.status,
    required this.visitType,
    required this.bookingId,
  });

  final String id;
  final DoctorModel doctor;
  final String date;
  final String time;
  final String status; // upcoming | completed | cancelled
  final String visitType; // Clinic | Video
  final String bookingId;
}

class ReviewModel {
  const ReviewModel({
    required this.name,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    required this.initials,
  });

  final String name;
  final double rating;
  final String comment;
  final String timeAgo;
  final String initials;
}

class PaymentCardModel {
  const PaymentCardModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.holder,
    this.isDefault = false,
  });

  final String id;
  final String brand;
  final String last4;
  final String expiry;
  final String holder;
  final bool isDefault;
}

class MedicalRecordModel {
  const MedicalRecordModel({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.date,
    required this.type,
    required this.fileLabel,
  });

  final String id;
  final String title;
  final String doctorName;
  final String date;
  final String type; // Lab | Prescription | Report
  final String fileLabel;
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
    imageUrl: AppImages.esther,
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
    imageUrl: AppImages.brooklyn,
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
      imageUrl: AppImages.esther,
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
      imageUrl: AppImages.jacob,
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
      imageUrl: AppImages.bessie,
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
      imageUrl: AppImages.darlene,
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
      imageUrl: AppImages.brooklyn,
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
      imageUrl: AppImages.courtney,
    ),
  ];

  static DoctorModel? byId(String id) {
    final all = [upcoming, featured, ...topRated, ...nearMe];
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }

  static List<DoctorModel> get allDoctors {
    final all = [upcoming, featured, ...topRated, ...nearMe];
    final seen = <String>{};
    return all.where((d) => seen.add(d.id)).toList();
  }

  static const hospitals = [
    HospitalModel(
      id: 'city-heart',
      name: 'City Heart Hospital',
      address: 'Downtown Medical Avenue',
      distance: '1.2 km',
      rating: 4.9,
      reviews: '2.4k',
      departments: ['Cardiology', 'Emergency', 'ICU'],
      imagePath: AppImages.hospital1,
      openHours: 'Open 24 Hours',
      isEmergency: true,
      phone: '+1 555 2140',
    ),
    HospitalModel(
      id: 'valley',
      name: 'The Valley Hospital',
      address: 'Green Park, Sector 12',
      distance: '2.8 km',
      rating: 4.8,
      reviews: '1.8k',
      departments: ['Neurology', 'Ortho', 'Lab'],
      imagePath: AppImages.hospital2,
      openHours: '08:00 - 22:00',
      phone: '+1 555 3321',
    ),
    HospitalModel(
      id: 'metro',
      name: 'Metro Care Clinic',
      address: 'Lake View Road',
      distance: '3.5 km',
      rating: 4.7,
      reviews: '960',
      departments: ['Dermatology', 'Dental', 'OPD'],
      imagePath: AppImages.hospital3,
      openHours: '09:00 - 20:00',
      phone: '+1 555 4488',
    ),
    HospitalModel(
      id: 'vision',
      name: 'Vision Care Hospital',
      address: 'Central Business District',
      distance: '4.1 km',
      rating: 4.6,
      reviews: '720',
      departments: ['Eye Care', 'Surgery'],
      imagePath: AppImages.hospital1,
      openHours: 'Open 24 Hours',
      isEmergency: true,
      phone: '+1 555 9012',
    ),
  ];

  static HospitalModel? hospitalById(String id) {
    for (final h in hospitals) {
      if (h.id == id) return h;
    }
    return null;
  }

  static HospitalModel? hospitalByName(String name) {
    final q = name.toLowerCase().trim();
    if (q.isEmpty) return null;

    for (final h in hospitals) {
      final hn = h.name.toLowerCase();
      if (hn == q || hn.contains(q) || q.contains(hn)) return h;
    }

    const generic = {
      'hospital',
      'clinic',
      'care',
      'center',
      'medical',
      'plus',
      'the',
    };
    final tokens = q
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length > 2 && !generic.contains(t))
        .toList();
    for (final h in hospitals) {
      final hn = h.name.toLowerCase();
      if (tokens.any((t) => hn.contains(t) || t.contains(hn))) return h;
    }

    // Doctor hospital aliases: City Heart, Valley, Skin/Metro, Vision, Brain.
    if (q.contains('heart') || q.contains('cardio')) return hospitals[0];
    if (q.contains('valley') ||
        q.contains('brain') ||
        q.contains('neuro')) {
      return hospitals[1];
    }
    if (q.contains('skin') || q.contains('derma') || q.contains('metro')) {
      return hospitals[2];
    }
    if (q.contains('vision') || q.contains('eye') || q.contains('ophthal')) {
      return hospitals[3];
    }
    return null;
  }

  static final appointments = [
    AppointmentModel(
      id: 'a1',
      doctor: upcoming,
      date: 'Sun, 23 Aug',
      time: '11:30 AM',
      status: 'upcoming',
      visitType: 'Video',
      bookingId: 'DOC-2841',
    ),
    AppointmentModel(
      id: 'a2',
      doctor: topRated[0],
      date: 'Tue, 25 Aug',
      time: '02:00 PM',
      status: 'upcoming',
      visitType: 'Clinic',
      bookingId: 'DOC-2849',
    ),
    AppointmentModel(
      id: 'a3',
      doctor: nearMe[0],
      date: 'Fri, 14 Aug',
      time: '10:00 AM',
      status: 'completed',
      visitType: 'Clinic',
      bookingId: 'DOC-2710',
    ),
    AppointmentModel(
      id: 'a4',
      doctor: topRated[1],
      date: 'Mon, 10 Aug',
      time: '04:30 PM',
      status: 'cancelled',
      visitType: 'Video',
      bookingId: 'DOC-2655',
    ),
  ];

  static const reviews = [
    ReviewModel(
      name: 'Ayesha Khan',
      rating: 5,
      comment:
          'Very attentive and explained everything clearly. Highly recommended.',
      timeAgo: '2 days ago',
      initials: 'AK',
    ),
    ReviewModel(
      name: 'Omar Ali',
      rating: 4.5,
      comment: 'Clinic was clean and wait time was short. Great experience.',
      timeAgo: '1 week ago',
      initials: 'OA',
    ),
    ReviewModel(
      name: 'Sara Ahmed',
      rating: 5,
      comment: 'Professional and kind. Follow-up plan was easy to understand.',
      timeAgo: '2 weeks ago',
      initials: 'SA',
    ),
    ReviewModel(
      name: 'Bilal Hussain',
      rating: 4,
      comment: 'Good consultation. Would book again for routine checkups.',
      timeAgo: '1 month ago',
      initials: 'BH',
    ),
  ];

  static const payments = [
    PaymentCardModel(
      id: 'p1',
      brand: 'Visa',
      last4: '4242',
      expiry: '08/28',
      holder: 'Muhammad Farhan',
      isDefault: true,
    ),
    PaymentCardModel(
      id: 'p2',
      brand: 'Mastercard',
      last4: '8891',
      expiry: '11/27',
      holder: 'Muhammad Farhan',
    ),
  ];

  static const medicalRecords = [
    MedicalRecordModel(
      id: 'r1',
      title: 'Blood Test Report',
      doctorName: 'Dr. Esther Howard',
      date: '12 Aug 2026',
      type: 'Lab',
      fileLabel: 'PDF · 1.2 MB',
    ),
    MedicalRecordModel(
      id: 'r2',
      title: 'Heart Prescription',
      doctorName: 'Dr. Eleanor Pena',
      date: '05 Aug 2026',
      type: 'Prescription',
      fileLabel: 'PDF · 420 KB',
    ),
    MedicalRecordModel(
      id: 'r3',
      title: 'ECG Summary',
      doctorName: 'Dr. Brooklyn Simmons',
      date: '28 Jul 2026',
      type: 'Report',
      fileLabel: 'PDF · 890 KB',
    ),
    MedicalRecordModel(
      id: 'r4',
      title: 'Skin Allergy Panel',
      doctorName: 'Dr. Darlene Robertson',
      date: '15 Jul 2026',
      type: 'Lab',
      fileLabel: 'PDF · 1.0 MB',
    ),
  ];
}
