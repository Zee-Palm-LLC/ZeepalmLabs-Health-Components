import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/icons/glyphs.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/aurora.dart';
import '../../core/widgets/common.dart';
import '../../data/medications.dart';
import 'dose_card.dart';
import 'reminder_sheet.dart';
import 'schedule_card.dart';
import 'week_strip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenAssistant,
    required this.onOpenSchedule,
    required this.onScrollDirection,
  });

  final VoidCallback onOpenAssistant;
  final VoidCallback onOpenSchedule;
  final ValueChanged<ScrollDirection> onScrollDirection;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  final ScrollController _scroll = ScrollController();
  final WeekPlan _plan = WeekPlan(DateTime.now());
  late int _selected;
  late final Set<int> _takenDays;
  final Set<String> _takenMeds = {};
  int _bellSwing = 0;

  @override
  void initState() {
    super.initState();
    _selected = _plan.todayIndex;
    _takenDays = {for (var i = 0; i < _plan.todayIndex; i++) i};
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
    _intro.forward().whenComplete(() {
      if (mounted) setState(() => _bellSwing++);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _openReminders() {
    setState(() => _bellSwing++);
    showReminderSheet(context, taken: _takenMeds);
  }

  void _toggleDay() {
    setState(() {
      if (!_takenDays.remove(_selected)) _takenDays.add(_selected);
    });
    if (_takenDays.contains(_selected)) {
      Toast.show(context, '${_plan.doseFor(_selected).name} marked as taken');
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: Palette.canvas,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_scroll, _intro]),
            builder: (context, child) {
              final offset = _scroll.hasClients ? _scroll.offset : 0.0;
              return Positioned(
                top: -offset * 0.55,
                left: 0,
                right: 0,
                child: Opacity(opacity: window(_intro.value, 0, 0.3), child: child),
              );
            },
            child: const AuroraHero(),
          ),
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              widget.onScrollDirection(notification.direction);
              return false;
            },
            child: ListView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(16, top + 10, 16, 130),
              children: [
                _header(),
                const SizedBox(height: 26),
                _title(),
                const SizedBox(height: 16),
                _timeline(),
                const SizedBox(height: 17),
                Entrance(
                  animation: stage(_intro, 0.46, 0.78),
                  offset: const Offset(0, 18),
                  child: const Text('Dose Schedule', style: TextStyles.section),
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < Cabinet.schedule.length; i++) ...[
                  Entrance(
                    animation: stage(_intro, 0.5 + i * 0.06, 0.86 + i * 0.035, curve: Curves.easeOutCubic),
                    offset: const Offset(0, 40),
                    scale: 0.96,
                    child: ScheduleCard(
                      medication: Cabinet.schedule[i],
                      taken: _takenMeds.contains(Cabinet.schedule[i].name),
                      hint: i == 0,
                      onTaken: () {
                        setState(() => _takenMeds.add(Cabinet.schedule[i].name));
                        Toast.show(context, '${Cabinet.schedule[i].name} marked as taken');
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final greeting = greetingFor(DateTime.now());
    return Row(
      children: [
        Entrance(
          animation: stage(_intro, 0.04, 0.42),
          offset: const Offset(-30, 0),
          blur: 6,
          child: Container(
            height: 52,
            padding: const EdgeInsets.fromLTRB(4, 4, 24, 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: stage(_intro, 0.1, 0.5, curve: Curves.elasticOut),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/avatar_robert.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12.5,
                        height: 1.25,
                      ),
                    ),
                    Text(
                      'Robert fox',
                      style: TextStyles.title.copyWith(color: Colors.white, fontSize: 15, height: 1.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Entrance(
          animation: stage(_intro, 0.1, 0.5, curve: Curves.easeOutBack),
          offset: Offset.zero,
          scale: 0.3,
          child: CircleButton(glyph: Glyph.bell, onTap: _openReminders, badge: true, swingTrigger: _bellSwing),
        ),
      ],
    );
  }

  Widget _title() {
    final style = TextStyles.headline.copyWith(color: Colors.white.withValues(alpha: 0.94));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Entrance(
          animation: stage(_intro, 0.12, 0.46),
          offset: const Offset(0, 22),
          blur: 10,
          alignment: Alignment.centerLeft,
          child: Text('Stay track your health with', style: style),
        ),
        Entrance(
          animation: stage(_intro, 0.18, 0.52),
          offset: const Offset(0, 22),
          blur: 10,
          alignment: Alignment.centerLeft,
          child: Text('timely reminders', style: style),
        ),
      ],
    );
  }

  String _dayLabel(int index) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return switch (index - _plan.todayIndex) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ => '${names[index]} ${_plan.day(index).day}',
    };
  }

  Widget _timeline() {
    return Entrance(
      animation: stage(_intro, 0.2, 0.62, curve: const Cubic(0.2, 0.9, 0.25, 1.06)),
      offset: const Offset(0, 60),
      scale: 0.94,
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x0F0B2A2D), blurRadius: 30, offset: Offset(0, 12))],
        ),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 6, 0),
              child: Row(
                children: [
                  const Text('Timeline', style: TextStyles.title),
                  const Spacer(),
                  CircleButton(
                    glyph: Glyph.flash,
                    size: 32,
                    iconSize: 16,
                    background: const Color(0xFFF2F4F5),
                    onTap: widget.onOpenAssistant,
                  ),
                  const SizedBox(width: 8),
                  CircleButton(
                    glyph: Glyph.grid,
                    size: 32,
                    iconSize: 16,
                    background: const Color(0xFFF2F4F5),
                    onTap: widget.onOpenSchedule,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: WeekStrip(
                plan: _plan,
                selected: _selected,
                intro: _intro,
                onSelect: (i) => setState(() => _selected = i),
              ),
            ),
            const SizedBox(height: 5),
            Entrance(
              animation: stage(_intro, 0.36, 0.76, curve: Curves.easeOutCubic),
              offset: const Offset(0, 26),
              blur: 6,
              child: DoseCard(
                dayIndex: _selected,
                medication: _plan.doseFor(_selected),
                taken: _takenDays.contains(_selected),
                dayLabel: _dayLabel(_selected),
                onToggle: _toggleDay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
