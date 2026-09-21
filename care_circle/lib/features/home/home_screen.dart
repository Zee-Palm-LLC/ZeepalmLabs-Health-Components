import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/scenery.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/store.dart';
import '../member/member_screen.dart';
import 'family_orbit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onTab});

  final ValueChanged<int> onTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _sun;
  final _store = CareStore.instance;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
    _sun = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    _store.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_changed);
    _enter.dispose();
    _sun.dispose();
    super.dispose();
  }

  void _open(Member member) {
    Navigator.of(context).push(MemberScreen.route(member));
  }

  @override
  Widget build(BuildContext context) {
    final top = math.max(MediaQuery.viewPaddingOf(context).top, 20.0);
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 12.0);
    return Stack(
      children: [
        const Positioned(left: 0, right: 0, top: 40, child: Landscape(height: 300)),
        ListView(
          padding: EdgeInsets.fromLTRB(0, top + 6, 0, bottom + 104),
          physics: const BouncingScrollPhysics(),
          children: [
            Staged(
              animation: _enter,
              end: 0.4,
              offset: const Offset(0, -10),
              child: _Header(sun: _sun),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 312,
              child: FamilyOrbit(enter: _enter, onOpen: _open),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Staged(
                      animation: _enter,
                      begin: 0.35,
                      end: 0.8,
                      curve: Curves.easeOutBack,
                      offset: const Offset(0, 22),
                      child: _StatCard(
                        glyph: Glyph.leaf,
                        tone: Hue.sage,
                        value: _store.doingWell.toDouble(),
                        format: (v) => '${v.round()} of 5',
                        caption: 'doing well',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Staged(
                      animation: _enter,
                      begin: 0.42,
                      end: 0.87,
                      curve: Curves.easeOutBack,
                      offset: const Offset(0, 22),
                      child: _StatCard(
                        glyph: Glyph.pill,
                        tone: Hue.iris,
                        value: _store.medsTaken.toDouble(),
                        format: (v) => '${v.round()}/12',
                        caption: 'meds today',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Staged(
                      animation: _enter,
                      begin: 0.49,
                      end: 0.94,
                      curve: Curves.easeOutBack,
                      offset: const Offset(0, 22),
                      child: const _StatCard(
                        glyph: Glyph.calendar,
                        tone: Hue.honey,
                        text: 'Thu',
                        caption: 'next visit',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Staged(
              animation: _enter,
              begin: 0.55,
              end: 0.9,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Text('Quick actions', style: jakarta(16.5, 800, spacing: -0.2)),
                    const Spacer(),
                    Text('Edit', style: jakarta(13, 650, color: Hue.iris)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  for (final (i, action) in const [
                    (Glyph.pill, 'Meds', 2),
                    (Glyph.clock, 'Timeline', 1),
                    (Glyph.chat, 'Messages', -1),
                    (Glyph.user, 'Profile', 3),
                  ].indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: Staged(
                        animation: _enter,
                        begin: 0.6 + i * 0.06,
                        end: 0.95 + i * 0.015,
                        curve: Curves.easeOutBack,
                        scale: 0.7,
                        offset: const Offset(0, 14),
                        child: _Action(
                          glyph: action.$1,
                          label: action.$2,
                          badge: action.$1 == Glyph.chat ? 2 : 0,
                          onTap: action.$3 >= 0 ? () => widget.onTab(action.$3) : () {},
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.sun});

  final Animation<double> sun;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RotationTransition(
                      turns: sun,
                      child: const GlyphIcon(Glyph.sun, size: 22, color: Hue.honey, stroke: 2, fill: Color(0x33F2A12B)),
                    ),
                    const SizedBox(width: 8),
                    Text('Good morning,', style: jakarta(17, 600, color: Hue.inkSoft)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('Sara', style: jakarta(34, 800, spacing: -1, height: 1.15)),
                    const SizedBox(width: 8),
                    const _Beat(
                      child: GlyphIcon(Glyph.heart, size: 22, color: Hue.blush, fill: Hue.blush, stroke: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _Bell(),
        ],
      ),
    );
  }
}

class _Beat extends StatefulWidget {
  const _Beat({required this.child});

  final Widget child;

  @override
  State<_Beat> createState() => _BeatState();
}

class _BeatState extends State<_Beat> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final v = _c.value;
        final beat = math.sin(math.pi * span(v, 0, 0.15)) * 0.18 + math.sin(math.pi * span(v, 0.2, 0.35)) * 0.12;
        return Transform.scale(scale: 1 + beat, child: child);
      },
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
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _ring.forward(from: 0);
    });
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
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: softShadow()),
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _ring,
          builder: (context, child) {
            final v = _ring.value;
            final swing = math.sin(v * math.pi * 6) * (1 - v) * 0.45;
            return Transform.rotate(angle: swing, alignment: const Alignment(0, -0.9), child: child);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const GlyphIcon(Glyph.bell, size: 22, color: Hue.ink, stroke: 1.8),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Hue.coral,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.glyph, required this.tone, required this.caption, this.value, this.format, this.text});

  final Glyph glyph;
  final Color tone;
  final String caption;
  final double? value;
  final String Function(double)? format;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final valueStyle = jakarta(21, 800, spacing: -0.6);
    return RepaintBoundary(
      child: Surface(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(13, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconChip(glyph: glyph, tone: tone, size: 34),
            const SizedBox(height: 9),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: text != null
                  ? Text(text!, style: valueStyle)
                  : CountUp(value: value!, style: valueStyle, format: format, delay: 0.25),
            ),
            const SizedBox(height: 2),
            Text(caption, style: jakarta(12.5, 550, color: Hue.inkSoft), maxLines: 1),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.glyph, required this.label, required this.onTap, this.badge = 0});

  final Glyph glyph;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Surface(
        radius: 20,
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconChip(glyph: glyph, tone: Hue.iris, size: 40, soft: Hue.irisSoft),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -5,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        color: Hue.coral,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text('$badge', style: jakarta(10, 800, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: jakarta(12.5, 650), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
