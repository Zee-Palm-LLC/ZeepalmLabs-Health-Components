import 'package:docora/features/home/components/custom_appointment_banner.dart';
import 'package:docora/features/home/components/custom_search_field.dart';
import 'package:docora/features/home/components/custom_shade.dart';
import 'package:docora/features/home/components/home_appbar.dart';
import 'package:docora/features/home/components/doctors_near_me_section.dart';
import 'package:docora/features/home/components/medical_specialists_section.dart';
import 'package:docora/features/home/components/top_rated_doctors_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _blurProgress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final progress = (_scrollController.offset / 40).clamp(0.0, 1.0);
    if ((progress - _blurProgress).abs() < 0.02) return;
    setState(() => _blurProgress = progress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: HomeAppBar(blurProgress: _blurProgress),
      body: Stack(
        children: [
          const CustomShade(),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              clipBehavior: Clip.none,
              padding: EdgeInsets.all(16.h),
              child: Column(
                children: [
                  const CustomSearchField(),
                  SizedBox(height: 15.h),
                  const CustomAppointmentBanner(),
                  SizedBox(height: 20.h),
                  const MedicalSpecialistsSection(),
                  SizedBox(height: 20.h),
                  const TopRatedDoctorsSection(),
                  SizedBox(height: 24.h),
                  const DoctorsNearMeSection(),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
