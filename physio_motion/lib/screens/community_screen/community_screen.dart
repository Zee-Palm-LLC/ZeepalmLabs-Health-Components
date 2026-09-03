import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:physio_motion/components/fade_slide_in.dart';
import 'package:physio_motion/screens/home/home_screen.dart';
import 'package:physio_motion/theme/app_colors.dart';
import 'package:physio_motion/utils/community_images.dart';
import 'package:physio_motion/widgets/bottom_nav.dart';
import 'package:physio_motion/widgets/premium_page_route.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  int _filter = 0;
  final Set<String> _likedIds = {'sarah'};

  late final AnimationController _enter;
  late final AnimationController _navEnter;
  late final AnimationController _ringAnim;
  late final AnimationController _ambient;
  late final AnimationController _kenBurns;
  late final AnimationController _metric;

  static const _filters = ['For You', 'Following', 'Challenges', 'Experts'];

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    );
    _navEnter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    _ringAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat(reverse: true);
    _kenBurns = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    )..repeat(reverse: true);
    _metric = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CommunityImages.preload(context);
      _enter.forward();
      Future.delayed(const Duration(milliseconds: 220), () {
        if (mounted) _metric.forward();
      });
      Future.delayed(const Duration(milliseconds: 360), () {
        if (mounted) {
          _ringAnim.forward();
          _navEnter.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _navEnter.dispose();
    _ringAnim.dispose();
    _ambient.dispose();
    _kenBurns.dispose();
    _metric.dispose();
    super.dispose();
  }

  void _onNav(int i) {
    if (i == 0) {
      Navigator.of(context).pushReplacement(
        PremiumPageRoute(
          page: const HomeScreen(),
          slideFromRight: false,
        ),
      );
    }
  }

  void _toggleLike(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true,
      bottomNavigationBar: Material(
        type: MaterialType.transparency,
        child: FadeSlideIn(
          animation: _navEnter,
          begin: 0,
          end: 1,
          offset: const Offset(0, 24),
          scaleFrom: 0.94,
          child: PhysioBottomNav(index: 1, onChanged: _onNav),
        ),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _ambient,
            builder: (context, _) {
              final t = _ambient.value;
              return IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      top: 120 + math.sin(t * math.pi) * 10,
                      right: -70,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFB24DFF)
                                  .withValues(alpha: 0.05 + t * 0.03),
                              const Color(0xFFB24DFF).withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 420,
                      left: -90,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.lime
                                  .withValues(alpha: 0.04 + (1 - t) * 0.03),
                              AppColors.lime.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                PhysioBottomNav.contentClearance(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0,
                    end: 0.28,
                    offset: const Offset(0, 10),
                    scaleFrom: 0.98,
                    child: const _CommunityHeader(),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.05,
                    end: 0.4,
                    offset: const Offset(0, 14),
                    child: _StoriesRow(enter: _enter, ambient: _ambient),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.12,
                    end: 0.42,
                    offset: const Offset(0, 10),
                    child: _FilterTabs(
                      filters: _filters,
                      selected: _filter,
                      onChanged: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _filter = i);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.2,
                    end: 0.58,
                    offset: const Offset(0, 22),
                    scaleFrom: 0.96,
                    curve: Curves.easeOutCubic,
                    child: _FeedPostCard(
                      liked: _likedIds.contains('sarah'),
                      onLike: () => _toggleLike('sarah'),
                      kenBurns: _kenBurns,
                      metric: _metric,
                      enter: _enter,
                      imageUrl: CommunityImages.postHero,
                      avatarUrl: CommunityImages.sarah,
                      name: 'Sarah K.',
                      subtitle: 'Lower Back Recovery',
                      timeAgo: '2h ago',
                      dayLabel: 'Day 12',
                      headline: 'Consistency\nis paying off!',
                      metricValue: 18,
                      metricLabel: 'Mobility Improvement',
                      likes: 152,
                      comments: '24',
                      likedBy: 'Liked by Mike R. and 151 others',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.38,
                    end: 0.82,
                    offset: const Offset(0, 18),
                    scaleFrom: 0.97,
                    child: _RecoveryPostCard(
                      ringAnim: _ringAnim,
                      ambient: _ambient,
                      avatarUrl: CommunityImages.mike,
                      name: 'Mike R.',
                      subtitle: 'Shoulder Mobility',
                      timeAgo: '5h ago',
                      titleWhite: 'Finally',
                      titleLime: 'Pain Free!',
                      score: 85,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.48,
                    end: 0.9,
                    offset: const Offset(0, 18),
                    scaleFrom: 0.97,
                    child: _FeedPostCard(
                      liked: _likedIds.contains('anita'),
                      onLike: () => _toggleLike('anita'),
                      kenBurns: _kenBurns,
                      metric: _metric,
                      enter: _enter,
                      imageUrl: CommunityImages.postYoga,
                      avatarUrl: CommunityImages.anita,
                      name: 'Anita P.',
                      subtitle: 'Hip Mobility',
                      timeAgo: '8h ago',
                      dayLabel: 'Week 3',
                      headline: 'Morning flow\nunlocked!',
                      metricValue: 22,
                      metricLabel: 'Flexibility Gain',
                      likes: 98,
                      comments: '17',
                      likedBy: 'Liked by PhysioLife and 97 others',
                      height: 390,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.55,
                    end: 0.95,
                    offset: const Offset(0, 16),
                    scaleFrom: 0.97,
                    child: _ChallengePostCard(
                      ambient: _ambient,
                      avatarUrl: CommunityImages.physio,
                      name: 'PhysioLife',
                      subtitle: '30-Day Challenge',
                      timeAgo: '12h ago',
                      title: 'Neck Reset Challenge',
                      progress: 0.62,
                      dayText: 'Day 18 of 30',
                      joined: '2.4k joined',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.6,
                    end: 1,
                    offset: const Offset(0, 16),
                    scaleFrom: 0.97,
                    child: _FeedPostCard(
                      liked: _likedIds.contains('jordan'),
                      onLike: () => _toggleLike('jordan'),
                      kenBurns: _kenBurns,
                      metric: _metric,
                      enter: _enter,
                      imageUrl: CommunityImages.postGym,
                      avatarUrl: CommunityImages.jordan,
                      name: 'Jordan M.',
                      subtitle: 'Knee Rehab',
                      timeAgo: '1d ago',
                      dayLabel: 'Session 9',
                      headline: 'Back under\nthe bar.',
                      metricValue: 14,
                      metricLabel: 'Strength Return',
                      likes: 211,
                      comments: '41',
                      likedBy: 'Liked by Sarah K. and 210 others',
                      height: 400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.65,
                    end: 1,
                    offset: const Offset(0, 14),
                    scaleFrom: 0.97,
                    child: _RecoveryPostCard(
                      ringAnim: _ringAnim,
                      ambient: _ambient,
                      avatarUrl: CommunityImages.physio,
                      name: 'Coach Lena',
                      subtitle: 'Expert Tip',
                      timeAgo: '1d ago',
                      titleWhite: 'Breath first,',
                      titleLime: 'then move.',
                      score: 92,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    animation: _enter,
                    begin: 0.7,
                    end: 1,
                    offset: const Offset(0, 14),
                    scaleFrom: 0.97,
                    child: _FeedPostCard(
                      liked: _likedIds.contains('mike_run'),
                      onLike: () => _toggleLike('mike_run'),
                      kenBurns: _kenBurns,
                      metric: _metric,
                      enter: _enter,
                      imageUrl: CommunityImages.postRun,
                      avatarUrl: CommunityImages.mike,
                      name: 'Mike R.',
                      subtitle: 'Return to Run',
                      timeAgo: '2d ago',
                      dayLabel: 'Milestone',
                      headline: 'First 5K\npain-free.',
                      metricValue: 100,
                      metricLabel: 'Goal Complete',
                      likes: 340,
                      comments: '56',
                      likedBy: 'Liked by Anita P. and 339 others',
                      height: 390,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityHeader extends StatelessWidget {
  const _CommunityHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Community',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.7,
            height: 1.1,
          ),
        ),
        const Spacer(),
        _HeaderIcon(icon: Iconsax.search_normal_1, onTap: () {}),
        const SizedBox(width: 4),
        _HeaderIcon(icon: Iconsax.setting_4, onTap: () {}),
      ],
    );
  }
}

class _HeaderIcon extends StatefulWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_HeaderIcon> createState() => _HeaderIconState();
}

class _HeaderIconState extends State<_HeaderIcon> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.88 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(widget.icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _StoriesRow extends StatelessWidget {
  const _StoriesRow({required this.enter, required this.ambient});

  final Animation<double> enter;
  final Animation<double> ambient;

  static const _stories = [
    _StoryData('Your Story', null, isYou: true),
    _StoryData('Sarah K.', CommunityImages.sarah),
    _StoryData('Mike R.', CommunityImages.mike),
    _StoryData('PhysioLife', CommunityImages.physio),
    _StoryData('Anita P.', CommunityImages.anita),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _stories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final s = _stories[i];
          final begin = (0.08 + i * 0.07).clamp(0.0, 0.7);
          final end = (begin + 0.28).clamp(0.0, 1.0);
          return FadeSlideIn(
            animation: enter,
            begin: begin,
            end: end,
            offset: Offset(12 + i * 2.0, 10),
            scaleFrom: 0.86,
            curve: Curves.easeOutBack,
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  if (s.isYou)
                    _YourStoryButton(ambient: ambient)
                  else
                    _GradientStoryRing(
                      ambient: ambient,
                      index: i,
                      child: CachedAvatar(url: s.imageUrl!, size: 52),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    s.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoryData {
  const _StoryData(this.name, this.imageUrl, {this.isYou = false});
  final String name;
  final String? imageUrl;
  final bool isYou;
}

class _YourStoryButton extends StatelessWidget {
  const _YourStoryButton({required this.ambient});

  final Animation<double> ambient;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (context, child) {
        final t = ambient.value;
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.lime,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.lime.withValues(alpha: 0.28 + t * 0.28),
                blurRadius: 12 + t * 8,
                spreadRadius: t * 1.2,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 1 + t * 0.03,
            child: child,
          ),
        );
      },
      child: const Icon(Iconsax.add, size: 26, color: AppColors.dark),
    );
  }
}

class _GradientStoryRing extends StatelessWidget {
  const _GradientStoryRing({
    required this.child,
    required this.ambient,
    required this.index,
  });

  final Widget child;
  final Animation<double> ambient;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (context, child) {
        final turn = (ambient.value + index * 0.12) * 0.35;
        return Transform.rotate(
          angle: turn * math.pi * 2,
          child: Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFFB24DFF),
                  AppColors.cobalt,
                  AppColors.lime,
                  Color(0xFFB24DFF),
                ],
              ),
            ),
            child: Transform.rotate(
              angle: -turn * math.pi * 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  shape: BoxShape.circle,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  final List<String> filters;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.dark : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.white : AppColors.textSecondary,
                ),
                child: Text(filters[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  const _FeedPostCard({
    required this.liked,
    required this.onLike,
    required this.kenBurns,
    required this.metric,
    required this.enter,
    required this.imageUrl,
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.timeAgo,
    required this.dayLabel,
    required this.headline,
    required this.metricValue,
    required this.metricLabel,
    required this.likes,
    required this.comments,
    required this.likedBy,
    this.height = 420,
  });

  final bool liked;
  final VoidCallback onLike;
  final Animation<double> kenBurns;
  final Animation<double> metric;
  final Animation<double> enter;
  final String imageUrl;
  final String avatarUrl;
  final String name;
  final String subtitle;
  final String timeAgo;
  final String dayLabel;
  final String headline;
  final int metricValue;
  final String metricLabel;
  final int likes;
  final String comments;
  final String likedBy;
  final double height;

  @override
  Widget build(BuildContext context) {
    final likeCount = liked ? likes : math.max(0, likes - 1);
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: kenBurns,
            builder: (context, child) {
              final t = kenBurns.value;
              return Transform.scale(
                scale: 1.06 + t * 0.06,
                child: Transform.translate(
                  offset: Offset(t * 6, (1 - t) * 4),
                  child: child,
                ),
              );
            },
            child: CachedCoverImage(
              url: imageUrl,
              alignment: const Alignment(0, -0.15),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
                stops: const [0, 0.4, 1],
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 8,
            child: FadeSlideIn(
              animation: enter,
              begin: 0.28,
              end: 0.55,
              offset: const Offset(0, -8),
              child: Row(
                children: [
                  CachedAvatar(url: avatarUrl, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: Icon(
                      Iconsax.more,
                      size: 20,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 64,
            top: 108,
            child: FadeSlideIn(
              animation: enter,
              begin: 0.34,
              end: 0.68,
              offset: const Offset(0, 16),
              scaleFrom: 0.96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    headline,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      height: 1.05,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedBuilder(
                    animation: metric,
                    builder: (context, _) {
                      final t = Curves.easeOutCubic.transform(metric.value);
                      final value = (metricValue * t).round();
                      return Text(
                        '+$value%',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lime,
                          height: 1,
                          letterSpacing: -1,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metricLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 72,
            child: FadeSlideIn(
              animation: enter,
              begin: 0.4,
              end: 0.75,
              offset: const Offset(16, 0),
              child: Column(
                children: [
                  _SideAction(
                    icon: Iconsax.heart,
                    filled: liked,
                    fillColor: const Color(0xFFFF3B5C),
                    count: '$likeCount',
                    onTap: onLike,
                  ),
                  const SizedBox(height: 16),
                  _SideAction(icon: Iconsax.message, count: comments),
                  const SizedBox(height: 16),
                  const _SideAction(icon: Iconsax.send_2),
                  const SizedBox(height: 16),
                  const _SideAction(icon: Iconsax.archive_1),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 14,
            right: 60,
            child: FadeSlideIn(
              animation: enter,
              begin: 0.48,
              end: 0.82,
              offset: const Offset(0, 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 54,
                    height: 22,
                    child: Stack(
                      children: [
                        for (var i = 0; i < 3; i++)
                          Positioned(
                            left: i * 14.0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                              ),
                              child: CachedAvatar(
                                url: [
                                  CommunityImages.like1,
                                  CommunityImages.like2,
                                  CommunityImages.like3,
                                ][i],
                                size: 22,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      likedBy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideAction extends StatefulWidget {
  const _SideAction({
    required this.icon,
    this.count,
    this.onTap,
    this.filled = false,
    this.fillColor,
  });

  final IconData icon;
  final String? count;
  final VoidCallback? onTap;
  final bool filled;
  final Color? fillColor;

  @override
  State<_SideAction> createState() => _SideActionState();
}

class _SideActionState extends State<_SideAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    if (widget.filled) _pop.value = 1;
  }

  @override
  void didUpdateWidget(covariant _SideAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filled && !oldWidget.filled) {
      _pop.forward(from: 0);
    } else if (!widget.filled && oldWidget.filled) {
      _pop.reverse();
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pop,
            builder: (context, child) {
              final t = Curves.easeOutBack.transform(_pop.value);
              final burst = widget.filled
                  ? (1 - (_pop.value - 0.35).clamp(0.0, 1.0) / 0.65)
                  : 0.0;
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (burst > 0.05)
                    Container(
                      width: 36 + burst * 18,
                      height: 36 + burst * 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (widget.fillColor ?? AppColors.lime)
                              .withValues(alpha: burst * 0.45),
                          width: 1.5,
                        ),
                      ),
                    ),
                  Transform.scale(
                    scale: 1 + t * 0.22,
                    child: child,
                  ),
                ],
              );
            },
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.filled
                  ? (widget.fillColor ?? AppColors.lime)
                  : AppColors.white,
            ),
          ),
          if (widget.count != null) ...[
            const SizedBox(height: 3),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                widget.count!,
                key: ValueKey(widget.count),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecoveryPostCard extends StatelessWidget {
  const _RecoveryPostCard({
    required this.ringAnim,
    required this.ambient,
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.timeAgo,
    required this.titleWhite,
    required this.titleLime,
    required this.score,
  });

  final Animation<double> ringAnim;
  final Animation<double> ambient;
  final String avatarUrl;
  final String name;
  final String subtitle;
  final String timeAgo;
  final String titleWhite;
  final String titleLime;
  final int score;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (context, child) {
        final glow = 0.04 + ambient.value * 0.06;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.lime.withValues(alpha: glow),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              CachedAvatar(url: avatarUrl, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.softGray,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                timeAgo,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.softGray,
                ),
              ),
              IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(
                  Iconsax.more,
                  size: 20,
                  color: AppColors.softGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$titleWhite\n',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          height: 1.05,
                          letterSpacing: -0.6,
                        ),
                      ),
                      TextSpan(
                        text: titleLime,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lime,
                          height: 1.05,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: Listenable.merge([ringAnim, ambient]),
                builder: (context, _) {
                  final t = Curves.easeOutCubic.transform(ringAnim.value);
                  final pulse = 1 + ambient.value * 0.02;
                  return Transform.scale(
                    scale: pulse,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CustomPaint(
                        painter: _RecoveryRingPainter(
                          progress: (score / 100) * t,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(score * t).round()}%',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Recovery\nScore',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  height: 1.15,
                                  color: AppColors.softGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengePostCard extends StatelessWidget {
  const _ChallengePostCard({
    required this.ambient,
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.timeAgo,
    required this.title,
    required this.progress,
    required this.dayText,
    required this.joined,
  });

  final Animation<double> ambient;
  final String avatarUrl;
  final String name;
  final String subtitle;
  final String timeAgo;
  final String title;
  final double progress;
  final String dayText;
  final String joined;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (context, child) {
        final glow = 0.05 + ambient.value * 0.05;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF141414),
                AppColors.dark,
                Color(0xFF0E0E12),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.lime.withValues(alpha: 0.18 + ambient.value * 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.lime.withValues(alpha: glow),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CachedAvatar(url: avatarUrl, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.softGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'CHALLENGE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.lime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            timeAgo,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.softGray,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: Colors.white.withValues(alpha: 0.1)),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(color: AppColors.lime),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                dayText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              Text(
                joined,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.softGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecoveryRingPainter extends CustomPainter {
  _RecoveryRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bg = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = AppColors.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final glow = Paint()
      ..color = AppColors.lime.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..strokeCap = StrokeCap.round;

    const start = math.pi * 0.75;
    const sweep = math.pi * 1.5;
    final drawn = sweep * progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, start, sweep, false, bg);
    canvas.drawArc(rect, start, drawn, false, glow);
    canvas.drawArc(rect, start, drawn, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RecoveryRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
