import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../landing_page/components/math_motion.dart';

class WeekDay {
  const WeekDay({
    required this.label,
    required this.date,
  });

  final String label;
  final int date;
}

class WeekCalendar extends StatefulWidget {
  const WeekCalendar({super.key});

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  static const _days = <WeekDay>[
    WeekDay(label: 'Sun', date: 13),
    WeekDay(label: 'Mon', date: 14),
    WeekDay(label: 'Tue', date: 15),
    WeekDay(label: 'Wed', date: 16),
    WeekDay(label: 'Thu', date: 17),
    WeekDay(label: 'Fri', date: 18),
    WeekDay(label: 'Sat', date: 19),
  ];

  int _selected = 3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          for (var i = 0; i < _days.length; i++)
            Expanded(
              child: _DayCell(
                day: _days[i],
                selected: _selected == i,
                onTap: () {
                  if (_selected == i) return;
                  HapticFeedback.selectionClick();
                  setState(() => _selected = i);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatefulWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final WeekDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      value: widget.selected ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(_DayCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;
    if (widget.selected) {
      _c.forward(from: 0);
    } else {
      _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = MathMotion.softBounce(_c.value);
          final settle = MathMotion.settle(_c.value);
          final labelColor = Color.lerp(
            KinoraColors.muted,
            KinoraColors.lime,
            t,
          )!;
          // Design: selected date stays readable on lime fill.
          final dateColor = Color.lerp(
            KinoraColors.text,
            KinoraColors.ink,
            t,
          )!;

          return Column(
            children: [
              Text(
                widget.day.label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: t > 0.5 ? FontWeight.w600 : FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 10),
              Transform.translate(
                offset: Offset(0, -2 * settle),
                child: Transform.scale(
                  scale: 0.9 + 0.1 * t,
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        Colors.transparent,
                        KinoraColors.lime,
                        t,
                      ),
                      border: Border.all(
                        color: Color.lerp(
                          Colors.white.withValues(alpha: 0.06),
                          KinoraColors.lime.withValues(alpha: 0.55),
                          t,
                        )!,
                        width: 1.6,
                      ),
                      boxShadow: [
                        if (t > 0.05)
                          BoxShadow(
                            color: KinoraColors.lime
                                .withValues(alpha: 0.4 * t),
                            blurRadius: 14 * t,
                            spreadRadius: 0.5 * t,
                          ),
                      ],
                    ),
                    child: Text(
                      '${widget.day.date}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: dateColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.4 + 0.6 * t,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: KinoraColors.lime,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: KinoraColors.lime.withValues(alpha: 0.55 * t),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
