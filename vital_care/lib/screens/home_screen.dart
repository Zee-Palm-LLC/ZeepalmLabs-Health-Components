import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vital_care/screens/components/chat_launcher.dart';
import 'package:vital_care/screens/components/overview_card.dart';
import 'package:vital_care/screens/components/patient_card.dart';
import 'package:vital_care/screens/components/vitals_row.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,

        title: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Dr. John Smith',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Iconsax.search_normal_1,
              size: 20.sp,
              color: const Color(0xFF2563EB),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.all(6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Iconsax.notification,
              size: 20.sp,
              color: const Color(0xFF2563EB),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFE3EDFF),
                  Color(0xFFF2F6FF),
                  Color(0xFFFAFCFF),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.0, 0.25, 0.6, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: GoogleFonts.poppins(fontSize: 24.sp)),
                  Text(
                    'Neuromuscular Diagnostic Focus',
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                  SizedBox(height: 16.h),
                  OverviewCard(),
                  SizedBox(height: 16.h),
                  HealthVitalsCards(),
                  SizedBox(height: 16.h),
                  PatientCard(),
                ],
              ),
            ),
          ),
          const Positioned.fill(child: ChatLauncher()),
        ],
      ),
    );
  }
}
