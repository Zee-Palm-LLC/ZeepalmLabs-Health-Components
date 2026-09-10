import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_decoration.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/motion.dart';
import 'meditation_detail_screen.dart';

class MeditationLibraryScreen extends StatefulWidget {
  const MeditationLibraryScreen({super.key});

  @override
  State<MeditationLibraryScreen> createState() => _MeditationLibraryScreenState();
}

class _MeditationLibraryScreenState extends State<MeditationLibraryScreen> {
  final ScrollController _filters = ScrollController();

  String _filter = kMeditationFilters.first;

  List<Meditation> get _visible => _filter == kMeditationFilters.first
      ? kMeditations
      : kMeditations.where((m) => m.category == _filter).toList();

  @override
  void dispose() {
    _filters.dispose();
    super.dispose();
  }

  void _select(String label, int index) {
    if (label == _filter) return;
    HapticFeedback.selectionClick();
    setState(() => _filter = label);

    final target = (index * 92.w - 40.w).clamp(0.0, _filters.position.maxScrollExtent);
    _filters.animateTo(target, duration: AppMotion.tab, curve: AppMotion.enterCurve);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppTopBar(
        title: 'Meditation Library',
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(LucideIcons.search, size: 20.r),
            color: AppColors.textSecondary,
          ),
        ],
      ),
      body: StaggeredList(
        padding: EdgeInsets.only(top: 4.h, bottom: 22.h),
        children: [
          SizedBox(
            height: 34.h,
            child: ListView.separated(
              controller: _filters,
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: kMeditationFilters.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final label = kMeditationFilters[index];
                return _FilterChip(
                  label: label,
                  selected: label == _filter,
                  onTap: () => _select(label, index),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _visible.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.84,
              ),
              itemBuilder: (context, index) => Entrance(
                key: ValueKey(_visible[index].title),
                delay: AppMotion.stagger * (index ~/ 2),
                child: _MeditationCard(item: _visible[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.94,
      child: AnimatedContainer(
        duration: AppMotion.tab,
        curve: Curves.easeOutBack,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 17.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: selected ? AppColors.gold : AppColors.border),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.goldDark.withValues(alpha: 0.28),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : AppShadows.card,
        ),
        child: Text(
          label,
          style: AppText.body(
            13.5,
            weight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MeditationCard extends StatelessWidget {
  const _MeditationCard({required this.item});
  final Meditation item;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => MeditationDetailScreen(item: item))),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Hero(
              tag: meditationHeroTag(item),
              flightShuttleBuilder: meditationHeroShuttle,
              child: MeditationPoster(item: item),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 10.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  item.title,
                  style: AppText.body(16, weight: FontWeight.w600, color: Colors.white),
                ),
                SizedBox(height: 1.h),
                Text(
                  item.subtitle,
                  style: AppText.body(11.5, color: Colors.white.withValues(alpha: 0.82)),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 12.r,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item.duration,
                      style: AppText.body(11, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const Spacer(),
                    Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.26),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(LucideIcons.play, size: 10.r, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
