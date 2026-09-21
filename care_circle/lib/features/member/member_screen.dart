import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/scenery.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/store.dart';
import '../meds/med_sheet.dart';
import 'timeline_list.dart';

class Vitals {
  const Vitals(this.bpm, this.bp, this.steps, this.sleepMinutes);

  final int bpm;
  final String bp;
  final int steps;
  final int sleepMinutes;
}

const _vitals = {
  'joe': Vitals(72, '128/82', 2140, 400),
  'rose': Vitals(68, '122/78', 3860, 445),
  'mom': Vitals(64, '116/74', 7420, 410),
  'dad': Vitals(70, '124/80', 6210, 390),
  'leo': Vitals(84, '104/66', 9120, 560),
};

class MemberScreen extends StatefulWidget {
  const MemberScreen({super.key, required this.member});

  final Member member;

  static Route<void> route(Member member) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 650),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondary) => MemberScreen(member: member),
      transitionsBuilder: (context, animation, secondary, child) {
        final t = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: t,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(t),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _pulse;
  late final AnimationController _hearts;
  final _store = CareStore.instance;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
    _hearts = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _store.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_changed);
    _enter.dispose();
    _pulse.dispose();
    _hearts.dispose();
    super.dispose();
  }

  bool get _isJoe => widget.member.id == 'joe';

  Color get _halo {
    if (!_isJoe) return widget.member.halo;
    if (_store.morningTaken) return Hue.sage;
    return _store.nudged ? Hue.honey : Hue.coral;
  }

  void _nudge() {
    if (_store.nudged) return;
    _store.nudge();
    _hearts.forward(from: 0);
  }

  Future<void> _openMed() async {
    _pulse.stop();
    await MedSheet.show(context);
    if (mounted) _pulse.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final top = math.max(media.viewPadding.top, 20.0);
    final bottom = math.max(media.viewPadding.bottom, 12.0);
    final member = widget.member;
    final vitals = _vitals[member.id]!;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: Wash()),
          const Positioned(left: 0, right: 0, top: 20, child: Landscape(height: 280, seed: 2)),
          ListView(
            padding: EdgeInsets.fromLTRB(0, top + 4, 0, bottom + 128),
            physics: const BouncingScrollPhysics(),
            children: [
              _topBar(context),
              _identity(),
              const SizedBox(height: 18),
              _vitalsRow(vitals),
              const SizedBox(height: 24),
              Staged(
                animation: _enter,
                begin: 0.45,
                end: 0.8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('Shared Timeline', style: jakarta(19, 800, spacing: -0.4)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1ECF4)),
                        ),
                        child: Row(
                          children: [
                            Text('Today', style: jakarta(13, 650, color: Hue.inkSoft)),
                            const SizedBox(width: 2),
                            const GlyphIcon(Glyph.down, size: 16, color: Hue.inkSoft),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TimelineList(enter: _enter, begin: 0.5, onMissed: _openMed),
            ],
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _actions(bottom)),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    Widget round(Glyph glyph, VoidCallback onTap) {
      return Pressable(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: softShadow(0.8),
          ),
          alignment: Alignment.center,
          child: GlyphIcon(glyph, size: 22, color: Hue.ink, stroke: 2),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [round(Glyph.back, () => Navigator.of(context).pop()), const Spacer(), round(Glyph.more, () {})],
      ),
    );
  }

  Widget _identity() {
    final member = widget.member;
    final needsNudge = _isJoe && !_store.morningTaken;
    final String chip;
    final Color chipTone;
    final Glyph chipGlyph;
    if (!_isJoe || _store.morningTaken) {
      chip = 'Doing well';
      chipTone = Hue.sage;
      chipGlyph = Glyph.check;
    } else if (_store.nudged) {
      chip = 'Nudged just now';
      chipTone = Hue.honey;
      chipGlyph = Glyph.bellRing;
    } else {
      chip = 'Needs a nudge';
      chipTone = const Color(0xFFD9861A);
      chipGlyph = Glyph.bell;
    }
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -18),
          child: SizedBox(
            width: 150,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (needsNudge)
                  RepaintBoundary(
                    child: CustomPaint(size: const Size(112, 112), painter: _RipplePainter(_pulse, _halo)),
                  ),
                Hero(
                  tag: member.heroTag,
                  child: HaloAvatar(photo: member.photo, size: 112, halo: _halo, glow: 1.2, ring: 3.5),
                ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -30),
          child: Column(
            children: [
              Staged(
                animation: _enter,
                begin: 0.2,
                end: 0.55,
                curve: Curves.easeOutBack,
                scale: 0.6,
                offset: Offset.zero,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Container(
                    key: ValueKey(chip),
                    padding: const EdgeInsets.fromLTRB(10, 6, 13, 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: chipTone.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(color: chipTone.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlyphIcon(chipGlyph, size: 15, color: chipTone, stroke: 2),
                        const SizedBox(width: 6),
                        Text(chip, style: jakarta(12.5, 700, color: chipTone)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Staged(
                animation: _enter,
                begin: 0.25,
                end: 0.6,
                child: Text('${member.title}, ${member.age}', style: jakarta(26, 800, spacing: -0.8)),
              ),
              const SizedBox(height: 4),
              Staged(
                animation: _enter,
                begin: 0.3,
                end: 0.65,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Family member', style: jakarta(14, 550, color: Hue.inkSoft)),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: Hue.blush, shape: BoxShape.circle),
                    ),
                    Text(member.relation, style: jakarta(14, 550, color: Hue.inkSoft)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vitalsRow(Vitals v) {
    final tiles = [
      (Glyph.heart, Hue.coral, v.bpm.toDouble(), 'bpm', null as String?),
      (Glyph.drop, Hue.iris, 0.0, 'BP', v.bp),
      (Glyph.steps, Hue.sage, v.steps.toDouble(), 'steps', null),
      (Glyph.moon, Hue.honey, v.sleepMinutes.toDouble(), 'sleep', null),
    ];
    return Transform.translate(
      offset: const Offset(0, -26),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final (i, tile) in tiles.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Staged(
                  animation: _enter,
                  begin: 0.3 + i * 0.06,
                  end: 0.7 + i * 0.06,
                  curve: Curves.easeOutBack,
                  offset: const Offset(0, 20),
                  child: Surface(
                    radius: 20,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        if (i == 0)
                          _Beating(
                            child: GlyphIcon(
                              tile.$1,
                              size: 26,
                              color: tile.$2,
                              stroke: 2,
                              fill: tile.$2.withValues(alpha: 0.15),
                            ),
                          )
                        else
                          GlyphIcon(tile.$1, size: 26, color: tile.$2, stroke: 2),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: tile.$5 != null
                              ? Text(tile.$5!, style: jakarta(16.5, 800, spacing: -0.4))
                              : CountUp(
                                  value: tile.$3,
                                  delay: 0.2,
                                  style: jakarta(16.5, 800, spacing: -0.4),
                                  format: _format(i),
                                ),
                        ),
                        const SizedBox(height: 1),
                        Text(tile.$4, style: jakarta(12, 550, color: Hue.inkSoft)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String Function(double) _format(int index) {
    if (index == 2) {
      return (v) {
        final n = v.round();
        return n >= 1000 ? '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}' : '$n';
      };
    }
    if (index == 3) {
      return (v) {
        final n = v.round();
        return '${n ~/ 60}h ${n % 60}m';
      };
    }
    return (v) => '${v.round()}';
  }

  Widget _actions(double bottom) {
    final name = widget.member.title.split(' ').first == 'Grandpa' ? 'Grandpa' : widget.member.name;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 26, 18, bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Hue.canvas.withValues(alpha: 0), Hue.canvas.withValues(alpha: 0.95), Hue.canvas],
          stops: const [0, 0.35, 1],
        ),
      ),
      child: AnimatedBuilder(
        animation: _enter,
        builder: (context, child) {
          final t = span(_enter.value, 0.55, 1, Curves.easeOutBack);
          return Transform.translate(
            offset: Offset(0, 60 * (1 - t)),
            child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Nudge $name',
                        leading: Glyph.bell,
                        done: _store.nudged,
                        doneLabel: 'Nudge sent',
                        onTap: _nudge,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Pressable(
                      onTap: () {},
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Hue.irisSoft, width: 1.5),
                          boxShadow: softShadow(),
                        ),
                        alignment: Alignment.center,
                        child: const GlyphIcon(Glyph.phone, size: 22, color: Hue.iris, stroke: 2),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 66,
                  top: -120,
                  height: 140,
                  child: IgnorePointer(
                    child: RepaintBoundary(child: CustomPaint(painter: _FloatingHearts(_hearts))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GlyphIcon(Glyph.heart, size: 15, color: Hue.blush, fill: Hue.blush, stroke: 1),
                const SizedBox(width: 7),
                Text('Small nudges make a big difference', style: jakarta(12, 600, color: Hue.inkMute)),
                const SizedBox(width: 7),
                const GlyphIcon(Glyph.leaf, size: 15, color: Hue.sage, stroke: 1.8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Beating extends StatefulWidget {
  const _Beating({required this.child});

  final Widget child;

  @override
  State<_Beating> createState() => _BeatingState();
}

class _BeatingState extends State<_Beating> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 833))..repeat();
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
        final beat = math.sin(math.pi * span(v, 0, 0.14)) * 0.16 + math.sin(math.pi * span(v, 0.2, 0.34)) * 0.1;
        return Transform.scale(scale: 1 + beat, child: child);
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.animation, this.color) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    for (var k = 0; k < 2; k++) {
      final p = (t + k * 0.5) % 1.0;
      canvas.drawCircle(
        c,
        r * (1 + p * 0.32),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * (1 - p) + 0.3
          ..color = color.withValues(alpha: 0.45 * (1 - p)),
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => oldDelegate.color != color;
}

class _FloatingHearts extends CustomPainter {
  _FloatingHearts(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    if (t <= 0 || t >= 1) return;
    final heart = glyphPaths(Glyph.heart).first;
    const colors = [Hue.blush, Hue.coral, Hue.iris, Hue.honey, Hue.blush, Hue.irisLight];
    for (var i = 0; i < 9; i++) {
      final delay = i * 0.06;
      final p = span(t, delay, delay + 0.6);
      if (p <= 0 || p >= 1) continue;
      final x = size.width * (0.15 + (i * 0.37) % 0.7) + math.sin(p * math.pi * 2 + i) * 10;
      final y = size.height - Curves.easeOutCubic.transform(p) * size.height;
      final scale = (0.5 + (i % 3) * 0.2) * (1 - p * 0.3);
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(scale);
      canvas.translate(-12, -12);
      canvas.drawPath(heart, Paint()..color = colors[i % colors.length].withValues(alpha: 1 - p));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FloatingHearts oldDelegate) => false;
}
