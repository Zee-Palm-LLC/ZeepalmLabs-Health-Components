import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/nutrx_colors.dart';
import '../../theme/nutrx_text.dart';
import '../landing_page/components/floating_bottom_nav.dart';
import '../timer/components/reveal.dart';

class MealScheduleScreen extends StatefulWidget {
  const MealScheduleScreen({super.key});

  @override
  State<MealScheduleScreen> createState() => _MealScheduleScreenState();
}

class _MealScheduleScreenState extends State<MealScheduleScreen> {
  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _fullMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late final List<DateTime> _days;
  late int _selected;

  @override
  void initState() {
    super.initState();
    final start = DateTime(2025, 5, 1);
    _days = List.generate(14, (i) => start.add(Duration(days: i)));
    _selected = 3;
  }

  DateTime get _day => _days[_selected];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrxColors.bg,
      appBar: const _MealAppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          18,
          4,
          18,
          FloatingBottomNav.contentClearance(context),
        ),
        children: [
          Reveal(
            offset: const Offset(0, 12),
            scaleFrom: 0.97,
            child: _MonthToolbar(
              label: '${_fullMonths[_day.month - 1]} ${_day.year}',
            ),
          ),
          const SizedBox(height: 16),
          Reveal(
            delay: revealDelay(1),
            child: SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final d = _days[i];
                  return _DatePill(
                    weekday: _weekdays[d.weekday - 1],
                    day: '${d.day}',
                    month: _shortMonths[d.month - 1],
                    selected: i == _selected,
                    onTap: () => setState(() => _selected = i),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 22),
          Reveal(delay: revealDelay(2), child: const _BalanceHeader()),
          const SizedBox(height: 24),
          ..._mealBlocks(),
        ],
      ),
    );
  }

  List<Widget> _mealBlocks() {
    const breakfast = [
      _Meal(
        title: 'Honey pancake',
        time: '07:00am',
        image:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=240&q=80',
        fallback: LucideIcons.cooking_pot,
      ),
      _Meal(
        title: 'Coffee',
        time: '07:30am',
        image:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=240&q=80',
        fallback: LucideIcons.coffee,
      ),
    ];
    const lunch = [
      _Meal(
        title: 'Chicken steak',
        time: '01:00pm',
        image:
            'https://images.unsplash.com/photo-1432139555190-58524dae6a55?auto=format&fit=crop&w=240&q=80',
        fallback: LucideIcons.beef,
      ),
      _Meal(
        title: 'Milk',
        time: '01:20pm',
        image:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=240&q=80',
        fallback: LucideIcons.cup_soda,
      ),
    ];

    Widget section(String title, String meta, List<_Meal> meals, int base) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            delay: revealDelay(base),
            child: _SectionTitle(title: title, meta: meta),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < meals.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Reveal(
              delay: revealDelay(base + 1 + i),
              offset: const Offset(0, 20),
              child: _MealCard(meal: meals[i]),
            ),
          ],
        ],
      );
    }

    return [
      section('Breakfast', '2 meals, 230 calories', breakfast, 3),
      const SizedBox(height: 26),
      section('Lunch', '2 meals, 500 calories', lunch, 6),
    ];
  }
}

class _MealAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MealAppBar();

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
      title: Text('Meal schedule', style: NutrxText.title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _RoundAction(
            icon: LucideIcons.ellipsis,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NutrxColors.card,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: NutrxColors.text),
        ),
      ),
    );
  }
}

class _MonthToolbar extends StatelessWidget {
  const _MonthToolbar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: NutrxColors.text,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(
          LucideIcons.chevron_down,
          size: 18,
          color: NutrxColors.textMuted,
        ),
        const Spacer(),
        _RoundAction(icon: LucideIcons.calendar_days, onTap: () {}),
        const SizedBox(width: 10),
        _RoundAction(icon: LucideIcons.pen_line, onTap: () {}),
      ],
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.weekday,
    required this.day,
    required this.month,
    required this.selected,
    required this.onTap,
  });

  final String weekday;
  final String day;
  final String month;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = selected ? NutrxColors.onYellow : NutrxColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 64,
        height: 108,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NutrxColors.yellow : NutrxColors.card,
          borderRadius: BorderRadius.circular(32),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: NutrxColors.yellow.withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              weekday,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.1,
                color: on,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : NutrxColors.iconCircle,
              ),
              child: Text(
                day,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: selected ? NutrxColors.onYellow : NutrxColors.text,
                ),
              ),
            ),
            const Spacer(),
            Text(
              month,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.1,
                color: selected ? NutrxColors.onYellow : NutrxColors.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Balanced',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: NutrxColors.text,
          ),
        ),
        const Spacer(),
        Material(
          color: NutrxColors.yellow,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              child: Text(
                'Calorie chart',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NutrxColors.onYellow,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: NutrxColors.text,
          ),
        ),
        const Spacer(),
        Text(
          meta,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: NutrxColors.textDim,
          ),
        ),
      ],
    );
  }
}

class _Meal {
  const _Meal({
    required this.title,
    required this.time,
    required this.image,
    required this.fallback,
  });

  final String title;
  final String time;
  final String image;
  final IconData fallback;
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final _Meal meal;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NutrxColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  meal.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 56,
                    height: 56,
                    color: NutrxColors.iconCircle,
                    alignment: Alignment.center,
                    child: Icon(
                      meal.fallback,
                      size: 22,
                      color: NutrxColors.yellow,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: NutrxColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.clock_3,
                          size: 13,
                          color: NutrxColors.textDim,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          meal.time,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: NutrxColors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: NutrxColors.iconCircle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.chevron_right,
                  size: 16,
                  color: NutrxColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
