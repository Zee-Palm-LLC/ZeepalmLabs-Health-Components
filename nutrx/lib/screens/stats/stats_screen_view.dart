import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/nutrx_colors.dart';
import '../../theme/nutrx_text.dart';
import '../landing_page/components/floating_bottom_nav.dart';
import '../timer/components/math_motion.dart';
import '../timer/components/reveal.dart';

class StatsScreenView extends StatefulWidget {
  const StatsScreenView({super.key});

  @override
  State<StatsScreenView> createState() => _StatsScreenViewState();
}

class _StatsScreenViewState extends State<StatsScreenView> {
  static const _categories = [
    (LucideIcons.footprints, 'Steps'),
    (LucideIcons.heart, 'Heart rate'),
    (LucideIcons.chart_column, 'Regularity'),
  ];

  static const _bars = <(String, double)>[
    ('Sat', 0.42),
    ('Sun', 0.78),
    ('Mon', 0.55),
    ('Tue', 0.88),
    ('Wed', 0.48),
    ('Thu', 0.70),
    ('Fri', 0.62),
  ];

  int _category = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrxColors.bg,
      appBar: const _StatsAppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          FloatingBottomNav.contentClearance(context),
        ),
        children: [
          Reveal(
            offset: const Offset(0, 16),
            scaleFrom: 0.94,
            child: _CategoryChips(
              categories: _categories,
              index: _category,
              onChanged: (i) => setState(() => _category = i),
            ),
          ),
          const SizedBox(height: 16),
          Reveal(
            delay: revealDelay(1),
            child: _ChartCard(
              key: ValueKey(_category),
              average: _category == 0
                  ? 4325
                  : _category == 1
                      ? 78
                      : 92,
              unit: _category == 0
                  ? 'Steps on average'
                  : _category == 1
                      ? 'BPM on average'
                      : 'Score on average',
              bars: _bars,
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            delay: revealDelay(2),
            child: const _RankRow(),
          ),
          const SizedBox(height: 14),
          Reveal(
            delay: revealDelay(3),
            offset: const Offset(0, 24),
            child: const _ActivityTile(
              icon: LucideIcons.heart,
              title: 'Average heart rate',
              date: 'January 2023',
              value: '72',
              unit: 'per min',
            ),
          ),
          const SizedBox(height: 12),
          Reveal(
            delay: revealDelay(4),
            offset: const Offset(0, 24),
            child: const _ActivityTile(
              icon: LucideIcons.book_open,
              title: 'Kilometres run',
              date: 'February 2023',
              value: '124',
              unit: 'km',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _StatsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NutrxColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text('Statistic', style: NutrxText.title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Material(
            color: NutrxColors.iconCircle,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {},
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  LucideIcons.ellipsis_vertical,
                  size: 18,
                  color: NutrxColors.text,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.index,
    required this.onChanged,
  });

  final List<(IconData, String)> categories;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final selected = index == i;
          final (icon, label) = categories[i];
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? NutrxColors.yellow : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                border: selected
                    ? null
                    : Border.all(
                        color: NutrxColors.cardSoft,
                      ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: NutrxColors.yellow.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: selected ? NutrxColors.onYellow : NutrxColors.yellow,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: NutrxText.chip.copyWith(
                      color:
                          selected ? NutrxColors.onYellow : NutrxColors.text,
                      fontWeight: FontWeight.w600,
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    super.key,
    required this.average,
    required this.unit,
    required this.bars,
  });

  final int average;
  final String unit;
  final List<(String, double)> bars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: NutrxColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  children: [
                    _CountUp(
                      value: average,
                      style: NutrxText.metric.copyWith(fontSize: 32),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(unit, style: NutrxText.cardLabel),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: NutrxColors.iconCircle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This week',
                      style: NutrxText.meta.copyWith(
                        color: NutrxColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.chevron_down,
                      size: 14,
                      color: NutrxColors.textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 168,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < bars.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _WeekBar(
                      label: bars[i].$1,
                      value: bars[i].$2,
                      delay: revealDelay(i, stepMs: 55),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekBar extends StatefulWidget {
  const _WeekBar({
    required this.label,
    required this.value,
    required this.delay,
  });

  final String label;
  final double value;
  final Duration delay;

  @override
  State<_WeekBar> createState() => _WeekBarState();
}

class _WeekBarState extends State<_WeekBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = MathMotion.softBounce(_c.value);
        final h = (widget.value * t).clamp(0.0, 1.0);
        return Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final trackH = box.maxHeight;
                    final fillH = trackH * h;
                    return Container(
                      width: double.infinity,
                      height: trackH,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: NutrxColors.iconCircle,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: math.max(fillH, h > 0.01 ? 10.0 : 0.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              NutrxColors.yellowSoft,
                              NutrxColors.yellow,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: h > 0.2
                              ? [
                                  BoxShadow(
                                    color: NutrxColors.yellow
                                        .withValues(alpha: 0.22 * t),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: NutrxText.meta.copyWith(
                fontSize: 11,
                color: NutrxColors.textDim,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CountUp extends StatelessWidget {
  const _CountUp({required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: MathCurves.softBounce,
      builder: (context, v, _) => Text('${v.round()}', style: style),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _RankCard(
            icon: LucideIcons.circle_check,
            iconColor: Color(0xFF4CAF50),
            value: '174',
            label: 'Your score',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _RankCard(
            emoji: '🔥',
            value: '3',
            label: 'Among friends',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _RankCard(
            icon: LucideIcons.globe,
            iconColor: NutrxColors.yellow,
            value: '124',
            label: 'Among world',
          ),
        ),
      ],
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({
    this.icon,
    this.emoji,
    this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData? icon;
  final String? emoji;
  final Color? iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: NutrxColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 20))
          else
            Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: NutrxColors.text,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: NutrxText.meta.copyWith(
              fontSize: 11,
              color: NutrxColors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.date,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String title;
  final String date;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NutrxColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: NutrxColors.iconCircle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: NutrxColors.text),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NutrxText.chip.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: NutrxText.meta.copyWith(color: NutrxColors.textDim),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: NutrxText.chip.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                unit,
                style: NutrxText.meta.copyWith(color: NutrxColors.textDim),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
