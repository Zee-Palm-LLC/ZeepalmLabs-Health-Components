import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';
import '../../widgets/animations.dart';
import '../home/home_screen.dart';
import 'heart_widgets.dart';

class HeartHealthScreen extends StatelessWidget {
  const HeartHealthScreen({super.key});

  static const _metrics = <MetricCardData>[
    MetricCardData(
      icon: Iconsax.heart,
      color: AppColors.rose,
      title: 'Heart Rate',
      value: 82,
      unit: 'bpm',
      badge: 'Normal',
      decimals: 0,
      series: [30, 58, 36, 70, 44, 62, 40, 74, 52],
    ),
    MetricCardData(
      icon: Iconsax.activity,
      color: AppColors.cyan,
      title: 'Heart Variability (HRV)',
      value: 42,
      unit: 'ms',
      badge: 'Good',
      decimals: 0,
      series: [46, 30, 54, 38, 66, 42, 58, 34, 62],
    ),
    MetricCardData(
      icon: Iconsax.drop,
      color: AppColors.blue,
      title: 'Blood Oxygen (SpO₂)',
      value: 98,
      unit: '%',
      badge: 'Normal',
      decimals: 0,
      meter: 0.92,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.scaffold),
        child: Stack(
          children: [
            const AmbientGlow(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
                    child: FadeSlideIn(
                      child: HeartTopBar(
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 28.h),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const HeartHero(),
                        SizedBox(height: 14.h),
                        for (var i = 0; i < _metrics.length; i++) ...[
                          MetricCard(data: _metrics[i], index: i),
                          SizedBox(height: 11.h),
                        ],
                        SizedBox(height: 5.h),
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 700),
                          child: TrendsCard(),
                        ),
                        SizedBox(height: 14.h),
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 780),
                          child: TipCard(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
