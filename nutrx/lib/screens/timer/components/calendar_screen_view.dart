import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/nutrx_colors.dart';
import '../../../theme/nutrx_text.dart';
import 'reveal.dart';

class CalendarDayMark {
  const CalendarDayMark({
    required this.emoji,
    required this.label,
    required this.detail,
    required this.tint,
  });

  final String emoji;
  final String label;
  final String detail;
  final Color tint;
}

class CalendarScreenView extends StatefulWidget {
  const CalendarScreenView({super.key});

  @override
  State<CalendarScreenView> createState() => _CalendarScreenViewState();
}

class _CalendarScreenViewState extends State<CalendarScreenView> {
  static final _today = DateUtils.dateOnly(DateTime.now());
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late DateTime _month = DateTime(_today.year, _today.month);
  late DateTime _selected = _today;
  late final Map<String, List<CalendarDayMark>> _marks = _buildMarks(_today);

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Map<String, List<CalendarDayMark>> _buildMarks(DateTime today) {
    final marks = <String, List<CalendarDayMark>>{};
    void put(int offset, List<CalendarDayMark> list) {
      marks[_key(today.add(Duration(days: offset)))] = list;
    }

    put(0, const [
      CalendarDayMark(
        emoji: '⏱️',
        label: 'HIIT Timer',
        detail: '25 min · 320 kcal',
        tint: Color(0xFFFFC107),
      ),
      CalendarDayMark(
        emoji: '💧',
        label: 'Hydration',
        detail: '2.1 L done',
        tint: Color(0xFF4FC3F7),
      ),
    ]);
    put(-1, const [
      CalendarDayMark(
        emoji: '💪',
        label: 'Upper body',
        detail: '30 min · 280 kcal',
        tint: Color(0xFFFF8A65),
      ),
    ]);
    put(-2, const [
      CalendarDayMark(
        emoji: '🧘',
        label: 'Stretching',
        detail: '20 min · 90 kcal',
        tint: Color(0xFFCE93D8),
      ),
    ]);
    put(-3, const [
      CalendarDayMark(
        emoji: '🔥',
        label: 'Cardio burn',
        detail: '40 min · 410 kcal',
        tint: Color(0xFFFF7043),
      ),
      CalendarDayMark(
        emoji: '⏱️',
        label: 'Tabata',
        detail: '12 min',
        tint: Color(0xFFFFC107),
      ),
    ]);
    put(-5, const [
      CalendarDayMark(
        emoji: '🏃',
        label: 'Morning run',
        detail: '5.2 km · 38 min',
        tint: Color(0xFF81C784),
      ),
    ]);
    put(-7, const [
      CalendarDayMark(
        emoji: '🏋️',
        label: 'Full body',
        detail: '45 min · 360 kcal',
        tint: Color(0xFFFFC107),
      ),
    ]);
    put(1, const [
      CalendarDayMark(
        emoji: '⏱️',
        label: 'Planned timer',
        detail: '20 min HIIT',
        tint: Color(0xFFFFC107),
      ),
    ]);
    put(3, const [
      CalendarDayMark(
        emoji: '🏃',
        label: 'Easy jog',
        detail: '3 km planned',
        tint: Color(0xFF81C784),
      ),
    ]);
    put(5, const [
      CalendarDayMark(
        emoji: '🏋️',
        label: 'Strength',
        detail: 'Upper · 40 min',
        tint: Color(0xFFFFC107),
      ),
    ]);
    return marks;
  }

  List<DateTime?> _grid() {
    final first = DateTime(_month.year, _month.month);
    final lead = (first.weekday + 6) % 7;
    final count = DateUtils.getDaysInMonth(_month.year, _month.month);
    return [
      ...List<DateTime?>.filled(lead, null),
      for (var d = 1; d <= count; d++) DateTime(_month.year, _month.month, d),
      ...List<DateTime?>.filled((7 - ((lead + count) % 7)) % 7, null),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final selectedMarks = _marks[_key(_selected)] ?? const [];
    final streak = _marks.keys.where((k) {
      final p = k.split('-').map(int.parse).toList();
      final d = DateTime(p[0], p[1], p[2]);
      return !d.isAfter(_today) && d.month == _today.month;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Reveal(
          child: _SummaryStrip(streak: streak, workouts: _marks.length),
        ),
        const SizedBox(height: 14),
        Reveal(
          delay: revealDelay(1),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            decoration: BoxDecoration(
              color: NutrxColors.card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${_months[_month.month - 1]} ${_month.year}',
                      style: NutrxText.workoutTitle.copyWith(fontSize: 17),
                    ),
                    const Spacer(),
                    _NavBtn(
                      icon: LucideIcons.chevron_left,
                      onTap: () => setState(
                        () => _month = DateTime(_month.year, _month.month - 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _NavBtn(
                      icon: LucideIcons.chevron_right,
                      onTap: () => setState(
                        () => _month = DateTime(_month.year, _month.month + 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _Weekdays(),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _DateGrid(
                    key: ValueKey('${_month.year}-${_month.month}'),
                    cells: _grid(),
                    today: _today,
                    selected: _selected,
                    marks: _marks,
                    onSelect: (d) => setState(() => _selected = d),
                  ),
                ),
                const SizedBox(height: 8),
                const _Legend(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Reveal(
          delay: revealDelay(2),
          child: Text(
            DateUtils.isSameDay(_selected, _today)
                ? "Today's plan"
                : '${_selected.day} ${_shortMonths[_selected.month - 1]} sessions',
            style: NutrxText.section.copyWith(fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 340),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_key(_selected)),
            child: selectedMarks.isEmpty
                ? const _EmptyDay()
                : Column(
                    children: [
                      for (var i = 0; i < selectedMarks.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        Reveal(
                          delay: revealDelay(i, stepMs: 60),
                          offset: const Offset(0, 16),
                          child: _SessionCard(mark: selectedMarks[i]),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.streak, required this.workouts});

  final int streak;
  final int workouts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MiniStat(emoji: '🔥', title: '$streak day', subtitle: 'Streak')),
        const SizedBox(width: 10),
        Expanded(child: _MiniStat(emoji: '🏋️', title: '$workouts', subtitle: 'Logged')),
        const SizedBox(width: 10),
        const Expanded(child: _MiniStat(emoji: '⏱️', title: 'Timer', subtitle: 'Focus')),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: NutrxColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            title,
            style: NutrxText.chip.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          Text(
            subtitle,
            style: NutrxText.meta.copyWith(color: NutrxColors.textDim),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NutrxColors.iconCircle,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: NutrxColors.text),
        ),
      ),
    );
  }
}

class _Weekdays extends StatelessWidget {
  const _Weekdays();

  static const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final d in _days)
          Expanded(
            child: Center(
              child: Text(
                d,
                style: NutrxText.meta.copyWith(
                  color: NutrxColors.textDim,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DateGrid extends StatelessWidget {
  const _DateGrid({
    super.key,
    required this.cells,
    required this.today,
    required this.selected,
    required this.marks,
    required this.onSelect,
  });

  final List<DateTime?> cells;
  final DateTime today;
  final DateTime selected;
  final Map<String, List<CalendarDayMark>> marks;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < cells.length; i += 7)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                for (final day in cells.sublist(i, i + 7))
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 0.82,
                      child: day == null
                          ? const SizedBox.shrink()
                          : _DayCell(
                              date: day,
                              isToday: DateUtils.isSameDay(day, today),
                              isSelected: DateUtils.isSameDay(day, selected),
                              marks: marks[
                                      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}'] ??
                                  const [],
                              onTap: () => onSelect(day),
                            ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.marks,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<CalendarDayMark> marks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final emoji = marks.isEmpty ? null : marks.first.emoji;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [NutrxColors.yellowSoft, NutrxColors.yellow],
                    )
                  : null,
              color: isSelected
                  ? null
                  : marks.isNotEmpty
                      ? NutrxColors.cardSoft
                      : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(
                      color: NutrxColors.yellow.withValues(alpha: 0.55),
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: NutrxColors.yellow.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? NutrxColors.onYellow : NutrxColors.text,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                if (emoji != null)
                  Text(emoji, style: const TextStyle(fontSize: 12, height: 1))
                else
                  SizedBox(
                    height: 12,
                    child: isToday && !isSelected
                        ? Center(
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: NutrxColors.yellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(String emoji, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: NutrxText.meta.copyWith(
                fontSize: 11,
                color: NutrxColors.textDim,
              ),
            ),
          ],
        );

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        item('⏱️', 'Timer'),
        item('💪', 'Strength'),
        item('🏃', 'Cardio'),
        item('🧘', 'Mobility'),
      ],
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: NutrxColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: NutrxColors.iconCircle,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('😴', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rest day',
                  style: NutrxText.workoutTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'No workout or timer logged. Perfect day to recover ✨',
                  style: NutrxText.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.mark});

  final CalendarDayMark mark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NutrxColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mark.tint.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: mark.tint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(mark.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mark.label,
                  style: NutrxText.workoutTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(mark.detail, style: NutrxText.body),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevron_right,
            size: 18,
            color: NutrxColors.textDim,
          ),
        ],
      ),
    );
  }
}
