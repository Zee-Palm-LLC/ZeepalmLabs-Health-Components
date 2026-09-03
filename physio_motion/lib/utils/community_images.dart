import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:physio_motion/theme/app_colors.dart';

/// Community network assets + disk cache preload helpers.
abstract final class CommunityImages {
  static const postHero =
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=900&q=80';
  static const postYoga =
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=900&q=80';
  static const postGym =
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=900&q=80';
  static const postRun =
      'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&w=900&q=80';
  static const sarah =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80';
  static const mike =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80';
  static const physio =
      'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=200&q=80';
  static const anita =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80';
  static const jordan =
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80';
  static const like1 =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80';
  static const like2 =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80';
  static const like3 =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&q=80';

  static const List<String> all = [
    postHero,
    postYoga,
    postGym,
    postRun,
    sarah,
    mike,
    physio,
    anita,
    jordan,
    like1,
    like2,
    like3,
  ];

  static bool _preloading = false;
  static bool _preloaded = false;

  /// Warms disk + memory cache. Safe to call multiple times.
  static Future<void> preload(BuildContext context) async {
    if (_preloaded || _preloading) return;
    _preloading = true;
    try {
      await Future.wait(
        all.map((url) async {
          try {
            await precacheImage(CachedNetworkImageProvider(url), context);
          } catch (_) {}
        }),
      );
      _preloaded = true;
    } finally {
      _preloading = false;
    }
  }
}

class CachedAvatar extends StatelessWidget {
  const CachedAvatar({
    super.key,
    required this.url,
    required this.size,
  });

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        fadeInDuration: const Duration(milliseconds: 180),
        fadeOutDuration: const Duration(milliseconds: 120),
        placeholder: (_, _) => Container(
          width: size,
          height: size,
          color: AppColors.border,
        ),
        errorWidget: (_, _, _) => Container(
          width: size,
          height: size,
          color: AppColors.softGray,
        ),
      ),
    );
  }
}

class CachedCoverImage extends StatelessWidget {
  const CachedCoverImage({
    super.key,
    required this.url,
    this.alignment = Alignment.center,
  });

  final String url;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: (420 * dpr).round(),
      fadeInDuration: const Duration(milliseconds: 220),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholder: (_, _) => Container(color: AppColors.dark),
      errorWidget: (_, _, _) => Container(color: AppColors.dark),
    );
  }
}
