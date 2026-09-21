import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/store.dart';
import '../timeline/timeline_tab.dart';
import 'med_sheet.dart';

class _Med {
  const _Med(this.name, this.purpose, this.who, this.tone, this.doses);

  final String name;
  final String purpose;
  final String who;
  final Color tone;
  final List<Dose> doses;
}

class MedsTab extends StatefulWidget {
  const MedsTab({super.key});

  @override
  State<MedsTab> createState() => _MedsTabState();
}

class _MedsTabState extends State<MedsTab> with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  final _store = CareStore.instance;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _store.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_changed);
    _enter.dispose();
    super.dispose();
  }

  List<_Med> get _meds => [
    _Med('Metformin 500mg', 'Blood sugar', 'joe', Hue.iris, [for (final s in _store.slots) s.dose]),
    const _Med('Lisinopril 10mg', 'Blood pressure', 'rose', Hue.coral, [Dose.taken, Dose.taken]),
    const _Med('Atorvastatin 20mg', 'Cholesterol', 'dad', Hue.honey, [Dose.taken, Dose.upcoming]),
    const _Med('Vitamin D3', 'Daily supplement', 'leo', Hue.sage, [Dose.taken]),
    const _Med('Levothyroxine 50mcg', 'Thyroid', 'mom', Hue.blush, [Dose.taken, Dose.taken]),
  ];

  @override
  Widget build(BuildContext context) {
    final top = math.max(MediaQuery.viewPaddingOf(context).top, 20.0);
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 12.0);
    final taken = _store.medsTaken;
    return ListView(
      padding: EdgeInsets.fromLTRB(0, top + 6, 0, bottom + 110),
      physics: const BouncingScrollPhysics(),
      children: [
        const TabHeader(title: 'Medications', caption: 'Today for your circle'),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Staged(
            animation: _enter,
            begin: 0,
            end: 0.5,
            offset: const Offset(0, 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF9A7BFF), Color(0xFF6B48EC)]),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(color: Hue.iris.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12)),
                ],
              ),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 74,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: taken / 12),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => CustomPaint(
                        painter: _Progress(v),
                        child: Center(
                          child: Text('${(v * 100).round()}%', style: jakarta(16, 800, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$taken of 12 doses taken', style: jakarta(17, 800, color: Colors.white, spacing: -0.3)),
                        const SizedBox(height: 4),
                        Text(
                          taken == 12 ? 'Everyone is on track today' : '1 missed dose needs attention',
                          style: jakarta(13, 550, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (final (i, med) in _meds.indexed)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Staged(
              animation: _enter,
              begin: 0.15 + i * 0.08,
              end: 0.6 + i * 0.08,
              offset: const Offset(0, 22),
              child: Pressable(
                onTap: i == 0 ? () => MedSheet.show(context) : () {},
                scale: 0.97,
                child: Surface(
                  radius: 22,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: med.tone.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: GlyphIcon(Glyph.pill, size: 22, color: med.tone, stroke: 2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.name, style: jakarta(15, 750), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                ClipOval(child: Portrait(CareStore.byId(med.who).photo, size: 18)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${CareStore.byId(med.who).name} · ${med.purpose}',
                                    style: jakarta(12.5, 550, color: Hue.inkSoft),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          for (final dose in med.doses)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              margin: const EdgeInsets.only(left: 4),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: switch (dose) {
                                  Dose.taken => Hue.sage,
                                  Dose.missed => Hue.coral,
                                  Dose.upcoming => const Color(0xFFDCD5E6),
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Progress extends CustomPainter {
  const _Progress(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(5);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0x33FFFFFF),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_Progress oldDelegate) => oldDelegate.value != value;
}
