import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';
import '../../core/page_transitions.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_bottom_nav.dart';
import '../heart/heart_health_screen.dart';
import 'body_scanner_stage.dart';
import 'home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final GlobalKey<BodyScannerStageState> _scannerKey = GlobalKey();

  static const _tiles = <OverviewTileData>[
    OverviewTileData(
      icon: Iconsax.heart,
      color: AppColors.rose,
      title: 'Heart',
      value: 82,
      unit: 'bpm',
      decimals: 0,
      delta: '+4 VS YESTERDAY',
      series: [40, 52, 44, 66, 50, 72, 58, 80],
    ),
    OverviewTileData(
      icon: Iconsax.moon,
      color: AppColors.indigo,
      title: 'Sleep',
      value: 6.2,
      unit: 'hrs',
      decimals: 1,
      delta: '-0.8 VS TARGET',
      series: [60, 42, 55, 38, 48, 34, 44, 30],
    ),
    OverviewTileData(
      icon: Iconsax.activity,
      color: AppColors.green,
      title: 'Steps',
      value: 8240,
      unit: 'today',
      decimals: 0,
      delta: '82% OF GOAL',
      series: [20, 34, 30, 48, 44, 62, 70, 86],
    ),
  ];

  void _syncScannerVisibility() {
    final ctx = _scannerKey.currentContext;
    final state = _scannerKey.currentState;
    if (ctx == null || state == null) return;

    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;
    final viewH = MediaQuery.sizeOf(context).height;
    // Keep mounted while any meaningful slice is on screen.
    final visible = bottom > 48 && top < viewH - 48;
    state.setStageVisible(visible);
  }

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
              bottom: false,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification ||
                      notification is ScrollEndNotification) {
                    _syncScannerVisibility();
                  }
                  return false;
                },
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const FadeSlideIn(child: GreetingHeader()),
                    SizedBox(height: 18.h),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: BodyScannerStage(key: _scannerKey),
                    ),
                    SizedBox(height: 16.h),
                    const SignalGrid(),
                    SizedBox(height: 18.h),
                    const FadeSlideIn(
                      delay: Duration(milliseconds: 520),
                      child: AiInsightCard(),
                    ),
                    SizedBox(height: 22.h),
                    const FadeSlideIn(
                      delay: Duration(milliseconds: 600),
                      child: SectionHeader(
                        title: 'Body Overview',
                        action: 'View All',
                      ),
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      height: 152.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        itemCount: _tiles.length,
                        separatorBuilder: (_, _) => SizedBox(width: 12.w),
                        itemBuilder: (context, i) => OverviewTile(
                          data: _tiles[i],
                          index: i,
                          onTap: i == 0
                              ? () => Navigator.of(context).push(
                                    AppPageRoute(
                                      builder: (_) =>
                                          const HeartHealthScreen(),
                                    ),
                                  )
                              : () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class AmbientGlow extends StatelessWidget {
  const AmbientGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -70.h,
            left: -50.w,
            child: _blob(AppColors.indigo.withValues(alpha: 0.24), 280.w),
          ),
          Positioned(
            top: 260.h,
            right: -90.w,
            child: _blob(AppColors.violet.withValues(alpha: 0.20), 300.w),
          ),
          Positioned(
            bottom: -60.h,
            left: -30.w,
            child: _blob(AppColors.cyan.withValues(alpha: 0.10), 240.w),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
}
