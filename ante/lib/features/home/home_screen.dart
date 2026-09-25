import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/routes.dart';
import '../../core/type.dart';
import '../../widgets/avatar.dart';
import '../../widgets/nav_bar.dart';
import '../create/create_pool_screen.dart';
import '../pool/pool_screen.dart';
import 'stat_tile.dart';
import 'streak_card.dart';
import 'task_card.dart';
import 'week_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _in;
  final _fab = GlobalKey();

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  void _create() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      RevealRoute(
        center: centerOf(context, _fab),
        builder: (_) => const CreatePoolScreen(),
        tint: const [Color(0xFF7A3CFF), Color(0xFFF77AA3), Color(0xFF4533FC)],
      ),
    );
  }

  void _open() {
    Navigator.of(context).push(LiftRoute(builder: (_) => const PoolScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final navTop = NavBar.topIn(frame);
    final content = math.max(frame.height, 852.3 + lift + 14 + (frame.height - navTop));
    final e = _in;

    final section = inter(15.8, 600, color: const Color(0xFFE4E6EC));
    final due = inter(16.46, 600, color: const Color(0xFFE4E6EC));
    final yours = inter(16.23, 600, color: const Color(0xFFE4E6EC));
    final link = inter(13.08, 600, color: const Color(0xFF9C7BFF));
    final cheer = inter(12.7, 500, color: const Color(0xFFA58AF2));

    return Scaffold(
      backgroundColor: const Color(0xFF000817),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF010D26), Color(0xFF000918), Color(0xFF010611)],
            stops: [0.0, 0.38, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: Frame.width,
                  height: content,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(left: 0, top: lift, width: Frame.width, height: 110, child: _Header(entrance: e)),
                      Positioned(
                        left: StreakCard.origin.dx,
                        top: StreakCard.origin.dy + lift,
                        child: StreakCard(entrance: e),
                      ),
                      Positioned(
                        left: 13.33 - bearing('W', section),
                        top: 328.33 + lift - capInset(section),
                        child: Staged(animation: e, begin: 0.3, end: 0.6, offset: const Offset(-12, 0), child: Text('Weekly Progress', style: section)),
                      ),
                      Positioned(
                        left: 305.33 - bearing('K', cheer),
                        top: 331 + lift - capInset(cheer),
                        child: Staged(
                          animation: e,
                          begin: 0.36,
                          end: 0.66,
                          offset: const Offset(12, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Keep it up!', style: cheer),
                              SizedBox(width: 370.3 - 305.33 - 59 - 2),
                              Transform.translate(offset: const Offset(-2, -2.2), child: const Flicker(size: 14)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(left: 0, top: lift, width: Frame.width, height: 420, child: WeekRow(entrance: e)),
                      Positioned(
                        left: 14 - bearing('D', due),
                        top: 436.33 + lift - capInset(due),
                        child: Staged(animation: e, begin: 0.4, end: 0.7, offset: const Offset(-12, 0), child: Text('Due Today', style: due)),
                      ),
                      Positioned(
                        left: 331.33 - bearing('V', link),
                        top: 438.67 + lift - capInset(link),
                        child: Staged(
                          animation: e,
                          begin: 0.44,
                          end: 0.74,
                          offset: const Offset(12, 0),
                          child: GestureDetector(onTap: _open, child: Text('View All', style: link)),
                        ),
                      ),
                      for (final (i, t) in tasks.indexed)
                        Positioned(
                          left: 12.2,
                          top: TaskCard.top + i * TaskCard.pitch + lift,
                          child: Staged(
                            animation: e,
                            begin: 0.44 + i * 0.07,
                            end: 0.84 + i * 0.07,
                            offset: const Offset(70, 0),
                            rotateY: -0.35,
                            alignment: Alignment.centerRight,
                            child: TaskCard(task: t, index: i, onTap: _open),
                          ),
                        ),
                      Positioned(
                        left: 13.33 - bearing('Y', yours),
                        top: 692 + lift - capInset(yours),
                        child: Staged(animation: e, begin: 0.5, end: 0.8, offset: const Offset(-12, 0), child: Text('Your Stats', style: yours)),
                      ),
                      for (final (i, s) in stats.indexed)
                        Positioned(
                          left: s.rect.left,
                          top: s.rect.top + lift,
                          child: Staged(
                            animation: e,
                            begin: 0.55 + i * 0.06,
                            end: 0.9 + i * 0.03,
                            offset: const Offset(0, 30),
                            scale: 0.88,
                            curve: settle,
                            child: StatTile(stat: s, entrance: e, order: i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: navTop - 30,
              child: NavBar(entrance: e, onCreate: _create, fabKey: _fab),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final hello = inter(15.1, 400, color: const Color(0xFFA9B3CA));
    final name = inter(23.4, 700, color: const Color(0xFFEEF0F4), optical: 28);
    final e = entrance;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 45.5 - 27.8,
          top: 84.5 - 27.8,
          child: AnimatedBuilder(
            animation: e,
            builder: (context, _) {
              final pop = spring(span(e.value, 0.0, 0.4, Curves.linear), bounce: 0.3);
              return Opacity(
                opacity: span(e.value, 0, 0.12, Curves.linear),
                child: Transform.scale(
                  scale: lerp(0.5, 1, pop),
                  child: RingAvatar(
                    asset: Art.avatar('john'),
                    radius: 27.8,
                    photo: 24.6,
                    stroke: 2.5,
                    sweep: span(e.value, 0.1, 0.5, gentle),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          left: 91 - bearing('G', hello),
          top: 64.8 - capInset(hello),
          child: Staged(animation: e, begin: 0.05, end: 0.35, offset: const Offset(16, 0), child: Text('Good Morning,', style: hello)),
        ),
        Positioned(
          left: 91 - bearing('J', name),
          top: 86.7 - capInset(name),
          child: Staged(animation: e, begin: 0.1, end: 0.42, offset: const Offset(16, 0), child: Text('John Doe', style: name)),
        ),
        Positioned(
          left: Art.crownName.left,
          top: Art.crownName.top,
          width: Art.crownName.width,
          height: Art.crownName.height,
          child: Staged(
            animation: e,
            begin: 0.3,
            end: 0.62,
            offset: const Offset(0, -18),
            rotateZ: 0.8,
            scale: 0.3,
            curve: settle,
            child: Tick(
              builder: (context, s, child) {
                final k = s % 5.0;
                final a = k < 0.8 ? math.sin(k / 0.8 * math.pi * 2) * (1 - k / 0.8) : 0.0;
                return Transform.rotate(angle: a * 0.18, alignment: Alignment.bottomCenter, child: child);
              },
              child: Art.crownName.image(),
            ),
          ),
        ),
        Positioned(
          left: 359.4 - 22,
          top: 81.5 - 22,
          width: 44,
          height: 44,
          child: Staged(
            animation: e,
            begin: 0.2,
            end: 0.5,
            scale: 0.4,
            curve: settle,
            child: const _Bell(),
          ),
        ),
      ],
    );
  }
}

class _Bell extends StatefulWidget {
  const _Bell();

  @override
  State<_Bell> createState() => _BellState();
}

class _BellState extends State<_Bell> with SingleTickerProviderStateMixin {
  late final AnimationController _ring;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => _ring.forward(from: 0),
      child: Tick(
        builder: (context, s, child) => AnimatedBuilder(
          animation: _ring,
          builder: (context, child) {
            final k = s % 6.0;
            final idle = k > 1.2 && k < 2.3 ? (k - 1.2) / 1.1 : 0.0;
            final t = math.max(_ring.value > 0 && _ring.value < 1 ? _ring.value : 0.0, idle);
            final a = t > 0 ? math.sin(t * math.pi * 5) * (1 - t) * 0.42 : 0.0;
            return Transform.rotate(angle: a, alignment: const Alignment(0, -0.62), child: child);
          },
          child: child,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(child: PhIcon(Ph.bell, size: 31, color: Color(0xFFE4E8F0))),
            Positioned(
              left: 367.3 - 359.4 + 22 - 7,
              top: 70.3 - 81.5 + 22 - 7,
              child: Tick(
                builder: (context, s, child) {
                  final p = (s % 2.4) / 2.4;
                  return CustomPaint(
                    painter: s > 0 ? _Ping(p) : null,
                    child: child,
                  );
                },
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFFFF8A9A), Color(0xFFEE4663), Color(0xFFD9344F)], stops: [0.0, 0.55, 1.0]),
                    border: Border.all(color: const Color(0xFF000D24), width: 1.4),
                  ),
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFE3E8)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ping extends CustomPainter {
  _Ping(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      7 + 7 * t,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * (1 - t)
        ..color = Color.fromRGBO(238, 70, 99, 0.6 * (1 - t)),
    );
  }

  @override
  bool shouldRepaint(_Ping old) => old.t != t;
}
