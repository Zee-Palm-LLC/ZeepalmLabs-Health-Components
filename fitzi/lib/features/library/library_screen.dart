import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/surfaces.dart';
import '../workout/workout_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _Item {
  const _Item(this.sprite, this.title, this.meta, this.level, this.tint);

  final Sprite sprite;
  final String title;
  final String meta;
  final String level;
  final Color tint;
}

const _items = [
  _Item(Art.recentBlast, 'Full Body Blast', '20 min • 210 kcal', 'Beginner', Color(0xFFF1EFFD)),
  _Item(Art.recentCore, 'Core Crusher', '15 min • 150 kcal', 'Intermediate', Color(0xFFEFF7D0)),
  _Item(Art.recentStretch, 'Morning Stretch', '10 min • 80 kcal', 'Beginner', Color(0xFFE6F3FA)),
  _Item(Art.recentBlast, 'Cardio Burst', '18 min • 190 kcal', 'Intermediate', Color(0xFFFDF1E4)),
  _Item(Art.recentCore, 'Power Legs', '25 min • 260 kcal', 'Advanced', Color(0xFFF1EFFD)),
];

const _filters = ['All', 'Strength', 'Cardio', 'Mobility', 'HIIT'];

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _in;
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final title = inter(27.04, 800, color: const Color(0xFF0B0B16), track: 0.02);
    final sub = inter(14.67, 400, color: const Color(0xFF6E6D6D), track: -0.001);
    return Scaffold(
      backgroundColor: Palette.cream,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 70 + lift, bottom: NavBar.height(frame) + 20),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Staged(
              animation: _in,
              begin: 0,
              end: 0.3,
              offset: const Offset(-20, 0),
              child: Text('Workouts', style: title),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Staged(
              animation: _in,
              begin: 0.05,
              end: 0.35,
              offset: const Offset(-20, 0),
              child: Text('Pick a session and let Fitzi coach you.', style: sub),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Staged(
                animation: _in,
                begin: 0.1 + i * 0.05,
                end: 0.45 + i * 0.05,
                scale: 0.6,
                child: _Chip(label: _filters[i], active: i == _filter, onTap: () => setState(() => _filter = i)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < _items.length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Staged(
                animation: _in,
                begin: 0.25 + i * 0.07,
                end: 0.6 + i * 0.07,
                offset: const Offset(0, 40),
                child: _Card(item: _items[i], index: i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: settle,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          color: active ? Palette.violet : Colors.white,
          boxShadow: [
            BoxShadow(
              color: active ? const Color(0x406A2FF2) : const Color(0x10655A80),
              blurRadius: active ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(label, style: inter(14, 600, color: active ? Colors.white : Palette.slate, track: -0.01)),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.item, required this.index});

  final _Item item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final title = inter(16, 700, color: Palette.ink, track: -0.01);
    final meta = inter(13.3, 400, color: const Color(0xFF807E7E), track: -0.03);
    return Pressable(
      scale: 0.97,
      onTap: () => Navigator.of(context).push(WorkoutRoute(builder: (_) => const WorkoutScreen())),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: item.tint,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Tick(
              builder: (context, seconds, child) => Transform.translate(
                offset: Offset(0, -1.5 * math.max(0.0, wave(seconds, 1.5, index * 0.2))),
                child: child,
              ),
              child: SizedBox(width: 72, height: 72, child: item.sprite.image(fit: BoxFit.cover)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: title),
                  const SizedBox(height: 6),
                  Text(item.meta, style: meta),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(10)),
                    child: Text(item.level, style: inter(11.5, 600, color: Palette.violetDeep)),
                  ),
                ],
              ),
            ),
            const ChevronDisc(colors: [Color(0xFF8B86F2), Color(0xFF4A40DC)], chevron: Colors.white, size: 30, glyph: 15),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

