import 'package:flutter/material.dart';

import 'screens/profile/profile_screen.dart';
import 'theme/app_theme.dart';

class AnimatedProfileApp extends StatelessWidget {
  const AnimatedProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animated Profile',
      theme: AppTheme.light,
      home: const ProfileScreen(),
    );
  }
}
