import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../home/components/reveal.dart';
import '../../landing_page/components/math_motion.dart';

class _Ingredient {
  const _Ingredient({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

class _CommunityPost {
  const _CommunityPost({
    required this.name,
    required this.followers,
    required this.avatar,
    required this.image,
    required this.likes,
    required this.comments,
    required this.caption,
    required this.likers,
    required this.ingredients,
  });

  final String name;
  final String followers;
  final String avatar;
  final String image;
  final int likes;
  final int comments;
  final String caption;
  final List<String> likers;
  final List<_Ingredient> ingredients;
}

class CookingCommunitySection extends StatelessWidget {
  const CookingCommunitySection({super.key});

  static const _posts = <_CommunityPost>[
    _CommunityPost(
      name: 'Regina Fly',
      followers: '12k Followers',
      avatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&h=160&fit=crop&crop=faces',
      image:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=900&q=80',
      likes: 90,
      comments: 12,
      caption:
          'Power-packed bowl: quinoa, avocado, grilled protein, and greens...',
      likers: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&crop=faces',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=80&h=80&fit=crop&crop=faces',
      ],
      ingredients: [
        _Ingredient(icon: LucideIcons.cherry, color: Color(0xFFFF4D4D)),
        _Ingredient(icon: LucideIcons.salad, color: Color(0xFF7DDA58)),
        _Ingredient(icon: LucideIcons.apple, color: Color(0xFFFF6B6B)),
        _Ingredient(icon: LucideIcons.beef, color: Color(0xFFE07A5F)),
        _Ingredient(icon: LucideIcons.leaf, color: Color(0xFF58D68D)),
        _Ingredient(icon: LucideIcons.nut, color: Color(0xFFC9A66B)),
      ],
    ),
    _CommunityPost(
      name: 'Marcus Chen',
      followers: '8.4k Followers',
      avatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop&crop=faces',
      image:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=900&q=80',
      likes: 214,
      comments: 28,
      caption:
          'Salmon bowl with citrus glaze, brown rice, and roasted veggies 🔥',
      likers: [
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop&crop=faces',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&crop=faces',
      ],
      ingredients: [
        _Ingredient(icon: LucideIcons.fish, color: Color(0xFF4DA3FF)),
        _Ingredient(icon: LucideIcons.wheat, color: Color(0xFFFF9A3D)),
        _Ingredient(icon: LucideIcons.leaf, color: Color(0xFF58D68D)),
        _Ingredient(icon: LucideIcons.apple, color: Color(0xFFFFE45A)),
        _Ingredient(icon: LucideIcons.carrot, color: Color(0xFFFF8A3D)),
      ],
    ),
    _CommunityPost(
      name: 'Ava Brooks',
      followers: '21k Followers',
      avatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=160&h=160&fit=crop&crop=faces',
      image:
          'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=900&q=80',
      likes: 156,
      comments: 19,
      caption:
          'Morning smoothie board — berries, oats, and clean protein fuel.',
      likers: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&crop=faces',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop&crop=faces',
      ],
      ingredients: [
        _Ingredient(icon: LucideIcons.cherry, color: Color(0xFFFF4D4D)),
        _Ingredient(icon: LucideIcons.banana, color: Color(0xFFFFE45A)),
        _Ingredient(icon: LucideIcons.milk, color: Color(0xFFE8E8E8)),
        _Ingredient(icon: LucideIcons.egg, color: Color(0xFFFFC107)),
        _Ingredient(icon: LucideIcons.leaf, color: Color(0xFF58D68D)),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Cooking Community',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: KinoraColors.text,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => HapticFeedback.selectionClick(),
                child: Text(
                  'See all',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KinoraColors.lime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _posts.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Reveal(
              delay: revealDelay(i, stepMs: 70),
              offset: const Offset(0, 18),
              scaleFrom: 0.95,
              twist: 0.01,
              child: _CommunityCard(post: _posts[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommunityCard extends StatefulWidget {
  const _CommunityCard({required this.post});

  final _CommunityPost post;

  @override
  State<_CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<_CommunityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  bool _liked = false;
  bool _saved = false;
  bool _following = false;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      decoration: BoxDecoration(
        color: KinoraColors.cardSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: KinoraColors.limeDim,
                  backgroundImage: NetworkImage(post.avatar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: KinoraColors.text,
                        ),
                      ),
                      Text(
                        post.followers,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: KinoraColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _following = !_following);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _following
                          ? KinoraColors.surface
                          : KinoraColors.lime,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _following
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      boxShadow: _following
                          ? null
                          : [
                              BoxShadow(
                                color: KinoraColors.lime
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Text(
                      _following ? 'Following' : 'Follow',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _following
                            ? KinoraColors.text
                            : KinoraColors.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => HapticFeedback.selectionClick(),
                  icon: const Icon(
                    LucideIcons.ellipsis_vertical,
                    size: 18,
                    color: KinoraColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 1.15,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      post.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => Container(
                        color: KinoraColors.card,
                        alignment: Alignment.center,
                        child: const Icon(
                          LucideIcons.salad,
                          size: 40,
                          color: KinoraColors.lime,
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0x66000000),
                            Color(0x99000000),
                          ],
                          stops: [0.45, 0.75, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0;
                                  i < post.ingredients.length;
                                  i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                _IngredientDot(
                                  icon: post.ingredients[i].icon,
                                  color: post.ingredients[i].color,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _press.forward(from: 0);
                    setState(() => _liked = !_liked);
                  },
                  child: AnimatedBuilder(
                    animation: _press,
                    builder: (context, child) {
                      final pop = MathMotion.softBounce(_press.value);
                      return Transform.scale(
                        scale: 1 + 0.18 * pop * (_liked ? 1 : 0.4),
                        child: child,
                      );
                    },
                    child: Icon(
                      LucideIcons.heart,
                      size: 20,
                      color: _liked
                          ? const Color(0xFFFF4D4D)
                          : KinoraColors.muted,
                      fill: _liked ? 1 : 0,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_liked ? post.likes + 1 : post.likes} Likes',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KinoraColors.text,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 42,
                  height: 22,
                  child: Stack(
                    children: [
                      for (var i = 0; i < post.likers.length; i++)
                        Positioned(
                          left: i * 14.0,
                          child: _MiniAvatar(url: post.likers[i]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  LucideIcons.message_circle,
                  size: 18,
                  color: KinoraColors.muted,
                ),
                const SizedBox(width: 5),
                Text(
                  '${post.comments}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KinoraColors.muted,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _saved = !_saved);
                  },
                  child: Icon(
                    LucideIcons.bookmark,
                    size: 20,
                    color: _saved ? KinoraColors.lime : KinoraColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: Text(
              post.caption,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: KinoraColors.muted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientDot extends StatelessWidget {
  const _IngredientDot({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: KinoraColors.cardSoft, width: 1.5),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
