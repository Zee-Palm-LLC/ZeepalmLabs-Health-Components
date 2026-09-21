import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../meds/med_sheet.dart';
import '../member/timeline_list.dart';

class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, required this.caption, this.trailing});

  final String title;
  final String caption;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caption, style: jakarta(14, 600, color: Hue.inkSoft)),
                const SizedBox(height: 2),
                Text(title, style: jakarta(28, 800, spacing: -0.9)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class TimelineTab extends StatefulWidget {
  const TimelineTab({super.key});

  @override
  State<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends State<TimelineTab> with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  int _filter = 0;
  static const _filters = ['All', 'Meds', 'Activity', 'Visits'];

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    CareStore.instance.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    CareStore.instance.removeListener(_changed);
    _enter.dispose();
    super.dispose();
  }

  List<Moment> get _moments {
    final all = CareStore.instance.moments;
    return switch (_filter) {
      1 => all.where((m) => m.glyph == Glyph.pill).toList(),
      2 => all.where((m) => m.glyph == Glyph.walk || m.glyph == Glyph.coffee || m.glyph == Glyph.phone).toList(),
      3 => all.where((m) => m.glyph == Glyph.calendar).toList(),
      _ => all,
    };
  }

  void _select(int index) {
    if (index == _filter) return;
    setState(() => _filter = index);
    _enter.forward(from: 0.35);
  }

  @override
  Widget build(BuildContext context) {
    final top = math.max(MediaQuery.viewPaddingOf(context).top, 20.0);
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 12.0);
    return ListView(
      padding: EdgeInsets.fromLTRB(0, top + 6, 0, bottom + 110),
      physics: const BouncingScrollPhysics(),
      children: [
        const TabHeader(title: 'Family timeline', caption: 'Thursday, 21 Sep'),
        const SizedBox(height: 18),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: _filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final on = i == _filter;
              return Pressable(
                onTap: () => _select(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: on ? Hue.irisGradient : null,
                    color: on ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: on ? Colors.transparent : const Color(0xFFEDE7F1)),
                    boxShadow: on
                        ? [
                            BoxShadow(
                              color: Hue.iris.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(_filters[i], style: jakarta(13.5, 700, color: on ? Colors.white : Hue.inkSoft)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        TimelineList(
          key: ValueKey(_filter),
          enter: _enter,
          begin: 0.3,
          moments: _moments,
          onMissed: () => MedSheet.show(context),
        ),
      ],
    );
  }
}
