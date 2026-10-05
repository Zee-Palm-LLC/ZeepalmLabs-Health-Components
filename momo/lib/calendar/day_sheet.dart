import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/art.dart';
import '../core/diary.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/kinetic.dart';
import '../widgets/surfaces.dart';

const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const _short = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class DaySheet extends StatefulWidget {
  const DaySheet({super.key, required this.diary, required this.onSelect});

  static const size = Size(371.6, 563.6);
  static const pitch = 47.12;
  static const firstRow = 123.3;
  static const rowGap = 48.0;

  final Diary diary;
  final ValueChanged<List<Meal>> onSelect;

  @override
  State<DaySheet> createState() => _DaySheetState();
}

class _DaySheetState extends State<DaySheet> with TickerProviderStateMixin {
  late DateTime _month;
  late DateTime _selected;
  late final AnimationController _swap;
  late final AnimationController _summary;
  late final AnimationController _cursor;
  int _direction = 1;
  DateTime? _previousMonth;
  Offset _cursorFrom = Offset.zero;
  Offset _cursorTo = Offset.zero;

  @override
  void initState() {
    super.initState();
    final today = widget.diary.today;
    _month = DateTime(today.year, today.month);
    _selected = today;
    _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 760), value: 1);
    _summary = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _cursor = AnimationController(vsync: this, duration: const Duration(milliseconds: 620), value: 1);
    _cursorTo = _cellCenter(_selected);
    _cursorFrom = _cursorTo;
    Future<void>.delayed(const Duration(milliseconds: 240), () {
      if (mounted) _summary.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _swap.dispose();
    _summary.dispose();
    _cursor.dispose();
    super.dispose();
  }

  int _lead(DateTime month) => (DateTime(month.year, month.month, 1).weekday - 1) % 7;

  Offset _cellCenter(DateTime day) {
    final index = _lead(DateTime(day.year, day.month)) + day.day - 1;
    return Offset(44.8 + DaySheet.pitch * (index % 7), DaySheet.firstRow + DaySheet.rowGap * (index ~/ 7));
  }

  bool get _atToday => _month.year == widget.diary.today.year && _month.month == widget.diary.today.month && _selected == widget.diary.today;

  bool get _canNext {
    final today = widget.diary.today;
    return _month.isBefore(DateTime(today.year, today.month));
  }

  void _select(DateTime day) {
    if (day.isAfter(widget.diary.today)) return;
    HapticFeedback.selectionClick();
    final next = _cellCenter(day);
    final current = Offset.lerp(_cursorFrom, _cursorTo, Curves.easeOutBack.transform(_cursor.value))!;
    setState(() {
      _cursorFrom = current;
      _cursorTo = next;
      _selected = day;
    });
    _cursor.forward(from: 0);
    _summary.forward(from: 0);
    widget.onSelect(widget.diary.mealsOn(day));
  }

  void _go(int step) {
    if (step > 0 && !_canNext) return;
    HapticFeedback.selectionClick();
    final month = DateTime(_month.year, _month.month + step);
    final today = widget.diary.today;
    final day = month.year == today.year && month.month == today.month ? today : DateTime(month.year, month.month, 1);
    setState(() {
      _previousMonth = _month;
      _direction = step;
      _month = month;
      _selected = day;
      _cursorTo = _cellCenter(day);
      _cursorFrom = _cursorTo;
    });
    _swap.forward(from: 0);
    _summary.forward(from: 0);
    _cursor.value = 1;
    widget.onSelect(widget.diary.mealsOn(day));
  }

  void _reset() {
    final today = widget.diary.today;
    if (_month.year == today.year && _month.month == today.month) {
      _select(today);
      return;
    }
    final months = (today.year - _month.year) * 12 + today.month - _month.month;
    _go(months);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DaySheet.size.width,
      height: DaySheet.size.height,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0x0F000000), width: 0.8),
        boxShadow: const [
          BoxShadow(color: Color(0x143A2A1A), blurRadius: 40, offset: Offset(0, 16)),
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_swap, _summary, _cursor]),
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          children: [
            ..._header(),
            for (var i = 0; i < 7; i++)
              Positioned(
                left: 44.8 + DaySheet.pitch * i - 20,
                width: 40,
                top: 87.8 - 9.7 * interAscent,
                child: Center(child: BaseText(const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i], style: Typo.weekday)),
              ),
            const Positioned(left: 21.1, right: 21.1, top: 352.5, height: 0.8, child: ColoredBox(color: Color(0xFFECEAE4))),
            ..._cursorLayer(),
            if (_previousMonth != null && _swap.value < 1) ..._grid(_previousMonth!, leaving: true),
            ..._grid(_month, leaving: false),
            ..._summaryLayer(),
          ],
        ),
      ),
    );
  }

  List<Widget> _header() {
    final t = _swap.value;
    final title = _months[_month.month - 1];
    final old = _previousMonth == null ? null : _months[_previousMonth!.month - 1];
    Widget heading(String name, int year) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        BaseText(name, style: Typo.month),
        const SizedBox(width: 2.6),
        Transform.translate(offset: const Offset(0, -0.8), child: BaseText('$year', style: Typo.year)),
      ],
    );
    final e = Curves.easeOutCubic.transform(t);
    return [
      if (old != null && t < 1)
        Positioned(
          left: 21.1,
          top: 53.3 - 28 * interAscent,
          child: Opacity(
            opacity: 1 - span(t, 0, 0.4),
            child: Transform.translate(offset: Offset(0, -14 * e * _direction.sign), child: heading(old, _previousMonth!.year)),
          ),
        ),
      Positioned(
        left: 21.1,
        top: 53.3 - 28 * interAscent,
        child: Opacity(
          opacity: old == null ? 1 : span(t, 0.15, 0.6),
          child: Transform.translate(offset: Offset(0, old == null ? 0 : 14 * (1 - e) * _direction.sign), child: heading(title, _month.year)),
        ),
      ),
      Positioned(
        left: 249 - 18,
        top: 44.1 - 18,
        child: IgnorePointer(
          ignoring: _atToday,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 260),
            opacity: _atToday ? 0 : 1,
            child: Pressable(
              onTap: _reset,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 600),
                curve: gentle,
                turns: _atToday ? 0.5 : 0,
                child: const SizedBox.square(dimension: 36, child: Center(child: PhIcon(Ph.reset, size: 16, color: Shade.muted))),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 292.3 - 20,
        top: 44 - 20,
        child: Pressable(
          onTap: () => _go(-1),
          child: const SizedBox.square(dimension: 40, child: Center(child: PhIcon(Ph.caretLeft, size: 21, color: Shade.soft))),
        ),
      ),
      Positioned(
        left: 338.3 - 20,
        top: 44 - 20,
        child: Opacity(
          opacity: _canNext ? 1 : 0.32,
          child: Pressable(
            onTap: _canNext ? () => _go(1) : null,
            child: const SizedBox.square(dimension: 40, child: Center(child: PhIcon(Ph.caretRight, size: 21, color: Shade.soft))),
          ),
        ),
      ),
    ];
  }

  List<Widget> _cursorLayer() {
    final inMonth = _selected.year == _month.year && _selected.month == _month.month;
    if (!inMonth) return const [];
    final c = _cursor.value;
    final p = Offset.lerp(_cursorFrom, _cursorTo, Curves.easeOutBack.transform(c))!;
    final travel = (_cursorTo - _cursorFrom).distance;
    final stretch = travel > 1 ? math.sin(c * math.pi) * 0.22 : 0.0;
    final appear = _previousMonth != null && _swap.value < 1 ? span(_swap.value, 0.5, 1) : 1.0;
    final dir = travel > 1 ? (_cursorTo - _cursorFrom) / travel : Offset.zero;
    return [
      Positioned(
        left: p.dx - 22,
        top: p.dy - 24,
        child: Opacity(
          opacity: appear,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(1 + stretch * dir.dx.abs(), 1 + stretch * dir.dy.abs() - stretch * 0.3 * dir.dx.abs(), 1),
            child: Container(
              width: 44,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x12000000), width: 0.8),
                boxShadow: const [BoxShadow(color: Color(0x0D3A2A1A), blurRadius: 10, offset: Offset(0, 3))],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _grid(DateTime month, {required bool leaving}) {
    final diary = widget.diary;
    final lead = _lead(month);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final t = _swap.value;
    final cells = <Widget>[];
    for (var d = 1; d <= days; d++) {
      final day = DateTime(month.year, month.month, d);
      final index = lead + d - 1;
      final row = index ~/ 7;
      final col = index % 7;
      final c = Offset(44.8 + DaySheet.pitch * col, DaySheet.firstRow + DaySheet.rowGap * row);
      final stagger = (row * 0.07 + col * 0.018);
      double opacity;
      double dx;
      if (_previousMonth == null || t >= 1) {
        opacity = 1;
        dx = 0;
      } else if (leaving) {
        final k = span(t, stagger * 0.5, stagger * 0.5 + 0.35, Curves.easeIn);
        opacity = 1 - k;
        dx = -26 * k * _direction;
      } else {
        final k = span(t, 0.2 + stagger, 0.2 + stagger + 0.45, Curves.easeOutCubic);
        opacity = k;
        dx = 26 * (1 - k) * _direction;
      }
      cells.add(
        Positioned(
          left: c.dx - 22,
          top: c.dy - 24,
          width: 44,
          height: 48,
          child: IgnorePointer(
            ignoring: leaving,
            child: Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: _DayCell(day: day, diary: diary, onTap: () => _select(day), appear: leaving ? 1 : _cellAppear(t, stagger)),
              ),
            ),
          ),
        ),
      );
    }
    return cells;
  }

  double _cellAppear(double t, double stagger) {
    if (_previousMonth == null) return 1;
    return span(t, 0.3 + stagger, 0.3 + stagger + 0.5, Curves.linear);
  }

  List<Widget> _summaryLayer() {
    final diary = widget.diary;
    final meals = diary.mealsOn(_selected);
    final total = meals.fold(0, (s, m) => s + m.kcal);
    final s = _summary.value;
    final label = _selected == diary.today ? 'Today' : '${_short[_selected.month - 1]} ${_selected.day}';
    final fill = (total / Diary.guide * 12).round().clamp(0, 12);
    final over = total > Diary.guide;
    final count = span(s, 0.0, 0.55, Curves.easeOutCubic);
    return [
      Positioned(left: 19.9, top: 377.3 - 11.1 * interAscent, child: Opacity(opacity: span(s, 0, 0.2), child: BaseText(label, style: Typo.dayLabel))),
      Positioned(
        left: 21.1,
        top: 422.3 - 42 * interAscent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Odometer(value: total, progress: count, style: Typo.total, grouped: true),
            const SizedBox(width: 4.8),
            Transform.translate(offset: const Offset(0, -1.3), child: BaseText('kcal', style: Typo.unit)),
          ],
        ),
      ),
      for (var i = 0; i < 12; i++)
        Positioned(
          left: 269.8 + i * 7.03,
          top: 380.8,
          width: 3.9,
          height: 16.8,
          child: _Bar(
            lit: i < fill ? span(s, 0.1 + i * 0.035, 0.3 + i * 0.035) : 0,
            color: over ? Shade.amber : Shade.sage,
          ),
        ),
      Positioned(right: 371.6 - 352.1, top: 415.3 - 10.2 * interAscent, child: BaseText('guide 2,000', style: Typo.guide)),
      if (meals.isEmpty)
        ..._blank(s)
      else
        for (var i = 0; i < meals.length && i < 3; i++) ..._meal(meals[i], i, s),
    ];
  }

  List<Widget> _blank(double s) {
    final a = span(s, 0.15, 0.6);
    return [
      Positioned(
        left: 71.8 - 40,
        top: 481.3 - 40,
        child: Opacity(
          opacity: 0.32 * a,
          child: Transform.rotate(
            angle: -0.08,
            child: Image.asset(Art.empty, width: 80, height: 80, filterQuality: FilterQuality.medium),
          ),
        ),
      ),
      Positioned(
        left: 128.3,
        top: 487.8 - 14.6 * interAscent,
        child: Opacity(opacity: a, child: Typed('A blank page.', progress: span(s, 0.2, 0.7, Curves.linear), style: inter(14.6, 400, tracking: 0, color: const Color(0xFFA8A7A2)))),
      ),
    ];
  }

  List<Widget> _meal(Meal meal, int i, double s) {
    final cx = 75.8 + 110.5 * i;
    final appear = span(s, 0.18 + i * 0.1, 0.62 + i * 0.1, Curves.linear);
    final tilt = const [-0.13, 0.08, -0.035][i];
    return [
      Positioned(
        left: cx - 40,
        top: 478.3 - 40,
        width: 80,
        height: 80,
        child: Pop(
          t: appear,
          from: 0.4,
          dy: 18,
          child: Center(
            child: meal.photo
                ? Transform.rotate(angle: tilt, child: SizedBox(width: 51, height: 68, child: Photo(meal.art, radius: 7)))
                : Tick(
                    builder: (context, t, child) => Transform.translate(offset: Offset(0, 1.5 * wave(t, 2.6, i * 0.3)), child: child),
                    child: Image.asset(meal.art, width: 84, height: 84, filterQuality: FilterQuality.medium),
                  ),
          ),
        ),
      ),
      Positioned(
        left: cx - 40,
        width: 80,
        top: 533.1 - 13.3 * interAscent,
        child: Opacity(opacity: span(appear, 0.3, 1), child: Center(child: BaseText('${meal.kcal}', style: Typo.kcal))),
      ),
    ];
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.lit, required this.color});

  final double lit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: const Color(0xFFE9E7E1), borderRadius: BorderRadius.circular(2)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 16.8 * Curves.easeOutBack.transform(lit.clamp(0.0, 1.0)).clamp(0.0, 1.06),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(color, Colors.white, 0.18)!, color],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.diary, required this.onTap, required this.appear});

  final DateTime day;
  final Diary diary;
  final VoidCallback onTap;
  final double appear;

  @override
  Widget build(BuildContext context) {
    final future = day.isAfter(diary.today);
    final icon = diary.iconOn(day);
    final isToday = day == diary.today;
    final child = icon.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: BaseText('${day.day}', style: Typo.day.copyWith(color: future ? const Color(0xFFC3C1BC) : const Color(0xFF3B3935))),
            ),
          )
        : Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 22 - 18,
                top: 24 - 6.5 - 16,
                width: 36,
                height: 32,
                child: Pop(
                  t: appear,
                  from: 0.3,
                  child: isToday
                      ? Center(child: Transform.rotate(angle: -0.06, child: SizedBox(width: 19, height: 26, child: Photo(icon, radius: 4.5, border: 1))))
                      : Image.asset(icon, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
                ),
              ),
              Positioned(left: 0, right: 0, top: 24 + 16.5 - 10.5 * interAscent, child: Center(child: BaseText('${day.day}', style: Typo.dayTiny))),
            ],
          );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: future ? null : onTap,
      child: icon.isEmpty ? Transform.translate(offset: const Offset(0, 0.4), child: child) : child,
    );
  }
}
