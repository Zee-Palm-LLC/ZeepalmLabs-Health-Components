import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/visit.dart';
import '../scenes/clinic_scene.dart';

class HomeBackdrop extends StatelessWidget {
  const HomeBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(child: CustomPaint(painter: _Backdrop()));
  }
}

class _Backdrop extends CustomPainter {
  const _Backdrop();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF1F8F6));
    void glow(Offset c, double r, Color color) {
      canvas.drawCircle(c, r, Paint()..shader = ui.Gradient.radial(c, r, [color, color.withValues(alpha: 0)]));
    }

    glow(Offset(-size.width * 0.05, size.height * 0.02), size.width * 0.9, const Color(0xFFC6ECE3));
    glow(Offset(size.width * 1.05, size.height * 0.68), size.width * 0.62, const Color(0xFFF8E3D1));
  }

  @override
  bool shouldRepaint(_Backdrop oldDelegate) => false;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.visit, required this.onToken, required this.onQueue});

  final Visit visit;
  final VoidCallback onToken;
  final VoidCallback onQueue;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  static const _departments = [
    ('General', 19.5, 73.0),
    ('Pediatrics', 101.25, 87.5),
    ('Dental', 198.75, 66.25),
    ('Lab Tests', 275.5, 80.75),
  ];

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _stage(double begin, Widget child, {Offset offset = const Offset(0, 14)}) {
    return Staged(animation: _enter, begin: begin, end: begin + 0.5, offset: offset, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final spare = (CanvasScope.of(context).barTop - 14 - 752).clamp(0.0, 90.0);
    final lift = spare * 0.35;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: 393,
          height: 852,
          child: _stage(
            0,
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 20,
                  top: 64.5,
                  child: Row(
                    children: [
                      Text(
                        'Hi Grace',
                        style: jakarta(14.5, 600, color: const Color(0xFF6E8C87), height: 19 / 14.5),
                      ),
                      const SizedBox(width: 5),
                      Image.asset('assets/images/wave.png', width: 17, height: 17),
                    ],
                  ),
                ),
                Positioned(
                  left: 19,
                  top: 91,
                  child: Text(
                    'Where are you\nvisiting?',
                    style: jakarta(28.5, 800, spacing: -1.14, height: 31.5 / 28.5),
                  ),
                ),
                Positioned(left: 325.3, top: 62.7, child: _Avatar()),
              ],
            ),
            offset: const Offset(0, -10),
          ),
        ),
        Positioned(left: 20.5, top: 170 + lift, width: 352.5, height: 318.5, child: _stage(0.1, _clinicCard())),
        Positioned(
          left: 19.25,
          top: 505 + spare,
          child: _stage(0.25, Text('Departments', style: jakarta(14.5, 800, spacing: -0.29, height: 18 / 14.5))),
        ),
        Positioned(
          right: 21,
          top: 506 + spare,
          child: _stage(
            0.25,
            Pressable(
              onTap: () {},
              child: Text(
                'See all',
                style: jakarta(12.5, 700, color: const Color(0xFF1E8277), height: 18 / 12.5),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 532 + spare,
          width: 393,
          height: 36,
          child: _Departments(enter: _enter, items: _departments, visit: widget.visit),
        ),
        Positioned(
          left: 19.3,
          top: 585 + spare,
          width: 354.7,
          child: _stage(
            0.4,
            ListenableBuilder(
              listenable: widget.visit,
              builder: (context, _) => TealButton(
                label: widget.visit.hasToken ? 'View live queue' : 'Get my token',
                trailing: Glyph.arrow,
                onTap: widget.visit.hasToken ? widget.onQueue : widget.onToken,
              ),
            ),
          ),
        ),
        Positioned(
          left: 21,
          top: 666 + spare,
          width: 351.7,
          height: 86,
          child: _stage(
            0.5,
            Pressable(
              onTap: () => widget.visit.hasToken ? widget.onQueue() : widget.onToken(),
              scale: 0.98,
              child: _NextToken(visit: widget.visit),
            ),
          ),
        ),
      ],
    );
  }

  Widget _clinicCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: cardShadow(1.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            const Positioned(left: 0, top: 0, right: 0, height: 148.5, child: CustomPaint(painter: ClinicScene())),
            Positioned(
              left: 14,
              top: 14,
              height: 30.5,
              child: Container(
                padding: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.25),
                  boxShadow: const [BoxShadow(color: Color(0x140F3B3A), blurRadius: 8, offset: Offset(0, 3))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 13.25),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: Hue.live, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6.5),
                    Text('Open until 8:00 PM', style: jakarta(12, 700, color: const Color(0xFF1F3E3C), height: 1.2)),
                  ],
                ),
              ),
            ),
            const Positioned(left: 301, top: 13.5, child: _LikeButton()),
            Positioned(
              left: 17.5,
              top: 166,
              child: Text('CityCare Family Clinic', style: jakarta(17, 800, spacing: -0.34, height: 21 / 17)),
            ),
            Positioned(
              left: 273.25,
              top: 165.25,
              width: 60,
              height: 28.75,
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFFDEBD6), borderRadius: BorderRadius.circular(14.4)),
                child: Stack(
                  children: [
                    const Positioned(
                      left: 11,
                      top: 8.4,
                      child: GlyphIcon(
                        Glyph.star,
                        size: 12,
                        color: Color(0xFFF59E0B),
                        fill: Color(0xFFF59E0B),
                        stroke: 0.6,
                      ),
                    ),
                    Positioned(
                      left: 28.25,
                      top: 5.9,
                      child: Text(
                        '4.8',
                        style: jakarta(13, 800, color: const Color(0xFFB0590F), spacing: 0.6, height: 17 / 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 17.5,
              top: 193.5,
              child: Text(
                'Dr. Oliver Hayes · General Physician',
                style: jakarta(12.5, 500, color: const Color(0xFF7E8E8B), height: 15.5 / 12.5),
              ),
            ),
            const Positioned(
              left: 18.5,
              top: 221.7,
              child: GlyphIcon(Glyph.pin, size: 13, color: Color(0xFF3F5553), stroke: 1.9),
            ),
            Positioned(
              left: 37.5,
              top: 219.5,
              child: Text(
                '3.2 km away',
                style: jakarta(13, 600, color: const Color(0xFF3F5553), height: 17 / 13),
              ),
            ),
            Positioned(
              left: 124.75,
              top: 226.75,
              child: Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(color: Color(0xFFBCC9C6), shape: BoxShape.circle),
              ),
            ),
            const Positioned(
              left: 141,
              top: 222.25,
              child: GlyphIcon(Glyph.bell, size: 12, color: Color(0xFF3F5553), stroke: 2),
            ),
            Positioned(
              left: 162.75,
              top: 219.5,
              child: Text(
                '11 min drive',
                style: jakarta(12.25, 600, color: const Color(0xFF3F5553), height: 17 / 12.25),
              ),
            ),
            const Positioned(
              left: 17.5,
              top: 248,
              width: 315.5,
              height: 1,
              child: DashedLine(dash: 5, gap: 5, color: Color(0xFFDCE6E3)),
            ),
            Positioned(
              left: 18.25,
              top: 262.75,
              width: 315,
              height: 39.5,
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFE5F4EF), borderRadius: BorderRadius.circular(19.75)),
                child: Stack(
                  children: [
                    Positioned(
                      left: 14.25,
                      top: 14.75,
                      child: Container(
                        width: 9.5,
                        height: 9.5,
                        decoration: const BoxDecoration(color: Hue.teal, shape: BoxShape.circle),
                      ),
                    ),
                    Positioned(
                      left: 33.25,
                      top: 11.25,
                      child: Text(
                        '12 people waiting · ~45 min',
                        style: jakarta(12.75, 700, color: const Color(0xFF1F4A47), height: 16.25 / 12.75),
                      ),
                    ),
                    Positioned(
                      left: 275.25,
                      top: 12,
                      child: Text(
                        'LIVE',
                        style: caps(10, color: Hue.teal, tracking: 0.16, height: 15 / 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD8EFEA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6F5F1), width: 1),
            ),
            alignment: Alignment.center,
            child: Text('GB', style: jakarta(13, 800, color: const Color(0xFF1E7F74), spacing: 0.3)),
          ),
          Positioned(
            left: 31.7,
            top: 0.3,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(color: Hue.orange, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextToken extends StatelessWidget {
  const _NextToken({required this.visit});

  final Visit visit;

  static const _clip = NotchClipper(radius: 20, notch: 10.5, at: 231.7);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(child: CustomPaint(painter: ShadowPath(_clip))),
        Positioned.fill(
          child: ClipPath(
            clipper: _clip,
            child: ColoredBox(
              color: Colors.white,
              child: ListenableBuilder(
                listenable: Listenable.merge([visit, visit.sim]),
                builder: (context, _) {
                  final live = visit.hasToken;
                  return Stack(
                    children: [
                      const Positioned(
                        left: 231.2,
                        top: 12,
                        width: 1,
                        height: 63,
                        child: DashedLine(vertical: true, dash: 4, gap: 4, color: Color(0xFFD8E3E0)),
                      ),
                      Positioned(
                        left: 17.3,
                        top: 19.5,
                        child: Text(
                          live ? 'YOUR TOKEN' : 'YOUR NEXT TOKEN',
                          style: caps(9.5, color: const Color(0xFF5E7370), tracking: 0.18, height: 11.4 / 9.5),
                        ),
                      ),
                      Positioned(
                        left: live ? 108 : 146,
                        top: 17.8,
                        height: 14.4,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          child: live
                              ? const _LivePill(key: ValueKey('live'))
                              : const _PreviewPill(key: ValueKey('preview')),
                        ),
                      ),
                      Positioned(
                        left: 16.5,
                        top: 36.5,
                        child: Text('A–${QueueSim.you}', style: jakarta(28, 800, spacing: -0.84, height: 1.15)),
                      ),
                      Positioned(
                        left: 95.7,
                        top: 51.5,
                        child: Text(visit.department, style: jakarta(12.5, 500, color: Hue.gray, height: 1.25)),
                      ),
                      Positioned(
                        left: 256.5,
                        top: 24.5,
                        child: Text(
                          live ? 'IN LINE' : 'EST. WAIT',
                          style: caps(9.5, color: const Color(0xFF5E7370), tracking: 0.18, height: 11.7 / 9.5),
                        ),
                      ),
                      Positioned(
                        left: 256,
                        top: 40,
                        child: Text(
                          live ? '${ordinal(visit.sim.rank)} · ${visit.sim.wait}m' : '~${visit.sim.wait} min',
                          style: jakarta(15, 800, spacing: -0.3, height: 1.25),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(left: 221.2, top: -10.5, child: _hole()),
        Positioned(left: 221.2, top: 75.5, child: _hole()),
      ],
    );
  }

  Widget _hole() {
    return IgnorePointer(
      child: Container(
        width: 21,
        height: 21,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x0F0F3B3A), width: 1),
        ),
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  const _LikeButton();

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => setState(() => _liked = !_liked),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFFBFDFC),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x1A0F3B3A), blurRadius: 8, offset: Offset(0, 3))],
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: GlyphIcon(
            Glyph.heart,
            key: ValueKey(_liked),
            size: 17,
            color: Hue.teal,
            stroke: 1.7,
            fill: _liked ? Hue.teal : null,
          ),
        ),
      ),
    );
  }
}

class _Departments extends StatefulWidget {
  const _Departments({required this.enter, required this.items, required this.visit});

  final Animation<double> enter;
  final List<(String, double, double)> items;
  final Visit visit;

  @override
  State<_Departments> createState() => _DepartmentsState();
}

class _DepartmentsState extends State<_Departments> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: widget.visit, builder: (context, _) => _chips());
  }

  Widget _chips() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final (i, d) in widget.items.indexed)
          Positioned(
            left: d.$2,
            top: 0,
            width: d.$3,
            height: 36,
            child: Staged(
              animation: widget.enter,
              begin: 0.3 + i * 0.05,
              end: 0.8 + i * 0.05,
              offset: const Offset(12, 0),
              child: _chip(i, d.$1),
            ),
          ),
      ],
    );
  }

  Widget _chip(int index, String label) {
    final on = label == widget.visit.department;
    final locked = widget.visit.hasToken && !on;
    return Pressable(
      onTap: locked ? null : () => widget.visit.choose(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? Hue.teal : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? Hue.teal : const Color(0xFFE3EDEA), width: 1),
          boxShadow: on
              ? const [BoxShadow(color: Color(0x4D0F766E), blurRadius: 12, offset: Offset(0, 6))]
              : const [BoxShadow(color: Color(0x0A0F3B3A), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Text(
          label,
          maxLines: 1,
          textScaler: TextScaler.noScaling,
          style: jakarta(12, on ? 800 : 700, color: on ? Colors.white : const Color(0xFF2E4A47), height: 1.2),
        ),
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 59.3,
      decoration: BoxDecoration(color: const Color(0xFFFDE3D3), borderRadius: BorderRadius.circular(7.2)),
      alignment: Alignment.center,
      child: Text('PREVIEW', style: caps(9, color: const Color(0xFFD9541E), tracking: 0.12, height: 1.1)),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: const Color(0xFFDDF7E6), borderRadius: BorderRadius.circular(7.2)),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(color: Hue.live, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text('LIVE', style: caps(9, color: const Color(0xFF15803D), tracking: 0.12, height: 1.1)),
        ],
      ),
    );
  }
}
