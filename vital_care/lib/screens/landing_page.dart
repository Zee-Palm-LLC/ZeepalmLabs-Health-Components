import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_care/screens/home_screen.dart';
import 'package:iconsax/iconsax.dart';

class LandingPageView extends StatelessWidget {
  const LandingPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.document_copy),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: 40.h,
              width: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.add, color: Colors.white),
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Iconsax.health), label: 'Meals'),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
