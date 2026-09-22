import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../core/widgets.dart';
import '../../scene/orb.dart';
import '../../scene/vessel.dart';
import '../../sound/mixer.dart';
import '../../sound/sounds.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.onOpenMix});

  final VoidCallback onOpenMix;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mixer = MixerScope.of(context);
    final mq = MediaQuery.of(context);
    final s = mq.size.width / 393;
    final mixes = mixer.library;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        21 * s,
        mq.padding.top + 20 * s,
        21 * s,
        78 * s + mq.padding.bottom + 24 * s,
      ),
      children: [
        Staged(
          controller: _intro,
          end: 0.5,
          slide: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Library',
                style: Typo.ui(
                  16.5 * s,
                  color: const Color(0xFFC9C8DA),
                  weight: 380,
                ),
              ),
              SizedBox(height: 6 * s),
              Text(
                'Soundscapes\nYou Return To',
                style: Typo.serifText(26 * s, height: 1.33, weight: 430),
              ),
            ],
          ),
        ),
        SizedBox(height: 26 * s),
        for (var i = 0; i < mixes.length; i++)
          Staged(
            key: ValueKey(mixes[i].name),
            controller: _intro,
            begin: 0.15 + i * 0.08,
            end: 0.6 + i * 0.08,
            slide: 16,
            child: Padding(
              padding: EdgeInsets.only(bottom: 14 * s),
              child: _MixCard(
                mix: mixes[i],
                current: mixes[i].name == mixer.name,
                scale: s,
                onTap: () {
                  mixer.open(mixes[i]);
                  widget.onOpenMix();
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _MixCard extends StatefulWidget {
  const _MixCard({
    required this.mix,
    required this.current,
    required this.scale,
    required this.onTap,
  });

  final Mix mix;
  final bool current;
  final double scale;
  final VoidCallback onTap;

  @override
  State<_MixCard> createState() => _MixCardState();
}

class _MixCardState extends State<_MixCard> {
  late final NebulaDriver _driver;

  @override
  void initState() {
    super.initState();
    _driver = NebulaDriver(
      NebulaMix.of(widget.mix.sounds, (s) => widget.mix.volumes[s] ?? 0.6),
      fill: 1,
      energy: 1,
    );
  }

  @override
  void dispose() {
    _driver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return Pressable(
      onTap: widget.onTap,
      scale: 0.97,
      child: Container(
        height: 104 * s,
        padding: EdgeInsets.all(12 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26 * s),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x14FFFFFF), Color(0x06FFFFFF)],
          ),
          border: Border.all(
            color: widget.current
                ? const Color(0x59B9A9FF)
                : const Color(0x1AFFFFFF),
          ),
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 80 * s,
              child: NebulaArt(driver: _driver, radius: 18 * s),
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mix.name,
                    style: Typo.serifText(17 * s, weight: 450),
                  ),
                  SizedBox(height: 8 * s),
                  Row(
                    children: [
                      for (final sound in widget.mix.sounds)
                        Padding(
                          padding: EdgeInsets.only(right: 6 * s),
                          child: Orb(sound: sound, diameter: 18 * s, glow: 0.6),
                        ),
                    ],
                  ),
                  SizedBox(height: 7 * s),
                  Text(
                    widget.mix.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Typo.ui(11.5 * s, color: Night.textDim),
                  ),
                ],
              ),
            ),
            Glyph(
              widget.current ? G.waveform : G.arrow,
              size: 20 * s,
              color: widget.current ? Night.lavenderSoft : Night.textDim,
              stroke: 1.6 * s,
            ),
            SizedBox(width: 6 * s),
          ],
        ),
      ),
    );
  }
}
