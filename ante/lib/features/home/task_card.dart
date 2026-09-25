import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';

class Task {
  const Task({
    required this.title,
    required this.note,
    required this.time,
    required this.accent,
    required this.tile,
    required this.tileEdge,
    required this.glyph,
    this.emoji,
    this.hero,
  });

  final String title;
  final String note;
  final String time;
  final Color accent;
  final List<Color> tile;
  final Color tileEdge;
  final Sprite glyph;
  final String? emoji;
  final String? hero;
}

const tasks = [
  Task(
    title: 'Gym Session',
    note: 'Keep pushing',
    time: '7:00 PM',
    accent: Color(0xFF8D4EF7),
    tile: [Color(0xFF0E2560), Color(0xFF0A1C50)],
    tileEdge: Color(0xFF1A2C6A),
    glyph: Art.gDumbbell,
    emoji: Art.biceps,
  ),
  Task(
    title: 'Run Club',
    note: '5K • All levels',
    time: '9:00 PM',
    accent: Color(0xFF2CDAA2),
    tile: [Color(0xFF0C3A3A), Color(0xFF082A2E)],
    tileEdge: Color(0xFF155049),
    glyph: Art.gRun,
    hero: 'run-club',
  ),
  Task(
    title: 'Read 20 Pages',
    note: 'Build a better you',
    time: '10:00 PM',
    accent: Color(0xFFFCA743),
    tile: [Color(0xFF55301F), Color(0xFF3F2419)],
    tileEdge: Color(0xFF6E4127),
    glyph: Art.gBook,
  ),
];

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.index, required this.onTap});

  static const top = 461.0;
  static const pitch = 74.3;
  static const height = 66.6;

  final Task task;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final y0 = top + index * pitch;
    final title = inter(12.3, 600, color: const Color(0xFFDDE1EA));
    final note = inter(11.3, 400, color: const Color(0xFF7A86A6));
    final time = inter(11.45, 400, color: const Color(0xFF7D89A8));
    final g = task.glyph;

    return Pressable(
      onTap: onTap,
      scale: 0.975,
      child: SizedBox(
        width: 383 - 12.2,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: 40,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color.lerp(task.accent, Colors.white, 0.12)!, task.accent, Color.lerp(task.accent, Colors.black, 0.1)!],
                  ),
                  boxShadow: [BoxShadow(color: task.accent.withValues(alpha: 0.35), blurRadius: 10)],
                ),
              ),
            ),
            Positioned(
              left: 23 - 12.2,
              top: 0,
              right: 0,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0A1839), Color(0xFF081633)],
                  ),
                  border: Border.all(color: const Color(0xFF1E3052), width: 1),
                ),
              ),
            ),
            Positioned(
              left: 33.5 - 12.2,
              top: 469.7 - top,
              width: 52.1,
              height: 50.6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: task.tile),
                  border: Border.all(color: task.tileEdge, width: 1),
                  boxShadow: [BoxShadow(color: task.accent.withValues(alpha: 0.12), blurRadius: 12)],
                ),
              ),
            ),
            Positioned(
              left: g.left - 12.2,
              top: g.top - y0,
              width: g.width,
              height: g.height,
              child: _Glyph(task: task, child: g.image()),
            ),
            Positioned(
              left: 103.33 - 12.2 - bearing(task.title, title),
              top: 476.5 - top - capInset(title),
              child: Text(task.title, style: title),
            ),
            Positioned(
              left: 103.67 - 12.2 - bearing(task.note, note),
              top: 499.0 - top - capInset(note),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(task.note, style: note),
                  if (task.emoji != null) ...[
                    const SizedBox(width: 4),
                    Transform.translate(
                      offset: const Offset(0, -1.4),
                      child: Image.asset(task.emoji!, width: 14.5, height: 14.5, filterQuality: FilterQuality.medium),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 244.2 - 12.2 - 6.6,
              top: 504.2 - top - 6.6,
              child: const PhIcon(Ph.clock, size: 13.2, color: Color(0xFF65739A)),
            ),
            Positioned(
              left: 254.67 - 12.2 - bearing(task.time, time),
              top: 499.3 - top - capInset(time),
              child: Text(task.time, style: time),
            ),
            Positioned(
              left: 364.2 - 12.2 - 7.5,
              top: 494.5 - top - 7.5,
              child: Tick(
                builder: (context, s, child) {
                  final k = (s - index * 0.4) % 3.2;
                  final dx = k < 0.5 ? (k < 0.25 ? k / 0.25 : (0.5 - k) / 0.25) * 2.5 : 0.0;
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: const PhIcon(Ph.caretRight, size: 15, color: Color(0xFF929FBF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph({required this.task, required this.child});

  final Task task;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final body = Tick(
      builder: (context, s, inner) {
        final k = (s - task.title.length * 0.13) % 4.0;
        final hop = k < 0.6 ? (k / 0.6) : 1.0;
        final a = hop < 1 ? (1 - (2 * hop - 1) * (2 * hop - 1)) : 0.0;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(0, -3 * a, 0, 1)
            ..rotateZ(0.12 * a * (task.title.length.isEven ? 1 : -1)),
          child: inner,
        );
      },
      child: child,
    );
    if (task.hero == null) return body;
    return Hero(tag: task.hero!, child: body);
  }
}
