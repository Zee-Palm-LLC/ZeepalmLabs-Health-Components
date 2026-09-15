import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/pressable.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/symptoms.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/expandable_section.dart';
import '../../widgets/glass_orb.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/icons/glyphs.dart';
import '../../widgets/shimmer_button.dart';

/// Screen three: the report.
///
/// Arrives inside a container transform from the tapped result, then plays
/// its own entrance top to bottom: the head card, the orb popping in on the
/// right, the attention pill, the explanation, the action, the button, and
/// finally the two collapsed sections.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.assessment});

  final Assessment assessment;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: D.entrance,
  )..forward();

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  void _readMore() {
    final c = widget.assessment.bestMatch;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF1F272C).withValues(alpha: 0.28),
      isScrollControlled: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 520),
        curve: Cubic(0.05, 0.7, 0.1, 1.0),
        reverseDuration: Duration(milliseconds: 320),
      ),
      builder: (BuildContext context) => _ConditionSheet(condition: c),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assessment;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const AuroraBackground(drift: 0.8),
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                HeaderBar(
                  title: 'Symptom Assessment',
                  t: 1,
                  onBack: () => Navigator.maybePop(context),
                  onClose: () =>
                      Navigator.of(context).popUntil((Route r) => r.isFirst),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _in,
                    builder: (BuildContext context, Widget? _) {
                      final t = _in.value;
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                            D.gutter, 14, D.gutter, 24 + bottom),
                        children: <Widget>[
                          Rise(
                            t: D.reportHeadIn.transform(t),
                            distance: 24,
                            child: _HeadCard(orbT: D.reportOrbIn.transform(t)),
                          ),
                          const SizedBox(height: 12),
                          Rise(
                            t: D.reportCardIn.transform(t),
                            distance: 30,
                            child: _MainCard(
                              assessment: a,
                              t: t,
                              onReadMore: _readMore,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Rise(
                            t: D.pop.transform(D.stagger(t, D.sectionsStart,
                                0, D.sectionStagger, D.sectionSpan)),
                            distance: 26,
                            scaleFrom: 0.96,
                            child: ExpandableSection(
                              title: 'Less likely causes',
                              subtitle:
                                  'Other possible causes that are less likely.',
                              glyph: Glyph.branch,
                              glyphColor: Leaf.base,
                              body: _LessLikely(conditions: a.lessLikely),
                            ),
                          ),
                          const SizedBox(height: D.tileGap),
                          Rise(
                            t: D.pop.transform(D.stagger(t, D.sectionsStart,
                                1, D.sectionStagger, D.sectionSpan)),
                            distance: 26,
                            scaleFrom: 0.96,
                            child: ExpandableSection(
                              title: 'Symptoms you reported',
                              subtitle:
                                  'Review the symptoms you told us about.',
                              glyph: Glyph.list,
                              glyphColor: Leaf.sky,
                              body: _Reported(symptoms: a.reported),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadCard extends StatelessWidget {
  const _HeadCard({required this.orbT});

  final double orbT;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: D.reportHeadHeight),
      padding: const EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(D.radius),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Paper.reportCard, Paper.reportCardEnd],
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Your assessment report', style: T.cardTitle),
                  const SizedBox(height: 5),
                  Text(
                    "Based on what you've told us, there are several "
                    'possible causes for your symptoms.',
                    style: T.cardBody,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 92,
            child: Center(
              child: GlassOrb(
                size: 40,
                haloScale: orbT,
                appear: ((orbT - 0.15) / 0.85).clamp(0.0, 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainCard extends StatelessWidget {
  const _MainCard({
    required this.assessment,
    required this.t,
    required this.onReadMore,
  });

  final Assessment assessment;
  final double t;
  final VoidCallback onReadMore;

  @override
  Widget build(BuildContext context) {
    final a = assessment;
    final emergency = a.bestMatch.urgency == Urgency.emergency;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: Paper.white,
        borderRadius: BorderRadius.circular(D.radius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF1F272C).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Rise(
            t: D.attentionIn.transform(t),
            distance: 8,
            scaleFrom: 0.9,
            alignment: Alignment.centerLeft,
            child: _AttentionPill(label: a.attentionLabel, urgent: emergency),
          ),
          const SizedBox(height: 10),
          Rise(
            t: D.explainIn.transform(t),
            distance: 14,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Paper.tile,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(a.explanation, style: T.cardBody),
            ),
          ),
          const SizedBox(height: 12),
          Rise(
            t: D.conditionIn.transform(t),
            distance: 10,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(a.bestMatch.name, style: T.condition),
            ),
          ),
          const SizedBox(height: 10),
          Rise(
            t: D.actionIn.transform(t),
            distance: 16,
            child: _ActionTile(assessment: a),
          ),
          const SizedBox(height: 12),
          Rise(
            t: D.ctaIn.transform(t),
            distance: 14,
            scaleFrom: 0.94,
            child: ShimmerButton(
              label: 'Read about this condition',
              onTap: onReadMore,
            ),
          ),
        ],
      ),
    );
  }
}

/// The urgency pill. The dot carries an exclamation mark and, when the case
/// is an emergency, a ring pulses out of it - the one insistent thing on the
/// page, and it is small.
class _AttentionPill extends StatefulWidget {
  const _AttentionPill({required this.label, required this.urgent});

  final String label;
  final bool urgent;

  @override
  State<_AttentionPill> createState() => _AttentionPillState();
}

class _AttentionPillState extends State<_AttentionPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.urgent) _pulse.repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 24,
            height: 24,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (BuildContext context, Widget? child) {
                final p = _pulse.value;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    if (widget.urgent)
                      Transform.scale(
                        scale: 1 + Curves.easeOut.transform(p) * 1.1,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Leaf.base
                                  .withValues(alpha: (1 - p) * 0.55),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    child!,
                  ],
                );
              },
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Leaf.base,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon2(Glyph.exclamation,
                      size: 12, color: Paper.white, strokeWidth: 1.8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(widget.label, style: T.pill),
        ],
      ),
    );
  }
}

/// "Call an ambulance" and its kin. The emoji tile nods every few seconds.
class _ActionTile extends StatefulWidget {
  const _ActionTile({required this.assessment});

  final Assessment assessment;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _nod = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _nod.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assessment;
    return Pressable(
      pressedScale: 0.975,
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Paper.tile,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Paper.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _nod,
                  builder: (BuildContext context, Widget? child) {
                    // A short wiggle in the first fifth of the cycle, then rest.
                    final p = (_nod.value / 0.2).clamp(0.0, 1.0);
                    final angle = math.sin(p * math.pi * 3) * (1 - p) * 0.12;
                    return Transform.rotate(angle: angle, child: child);
                  },
                  child: Image.asset(
                    'assets/emoji/${a.actionEmoji}.png',
                    width: 30,
                    height: 30,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(a.actionTitle, style: T.tileTitle),
                  const SizedBox(height: 2),
                  Text(a.actionSub, style: T.tileSub),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessLikely extends StatelessWidget {
  const _LessLikely({required this.conditions});

  final List<Condition> conditions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var i = 0; i < conditions.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Paper.tile,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: switch (conditions[i].urgency) {
                      Urgency.emergency => Leaf.alert,
                      Urgency.urgent => Leaf.orange,
                      Urgency.routine => Leaf.base,
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(conditions[i].name, style: T.condition),
                      const SizedBox(height: 1),
                      Text(conditions[i].summary, style: T.tileSub),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Reported extends StatelessWidget {
  const _Reported({required this.symptoms});

  final List<Symptom> symptoms;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          for (final s in symptoms)
            Container(
              height: 38,
              padding: EdgeInsets.only(left: s.emoji != null ? 6 : 14, right: 14),
              decoration: BoxDecoration(
                color: Leaf.soft,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: Leaf.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (s.emoji != null) ...<Widget>[
                    Image.asset(s.emojiAsset, width: 22, height: 22),
                    const SizedBox(width: 6),
                  ],
                  Text(s.name, style: T.chip),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "Read about this condition" - a sheet with the plain-language summary.
class _ConditionSheet extends StatelessWidget {
  const _ConditionSheet({required this.condition});

  final Condition condition;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(22, 14, 22, 20 + bottom),
      decoration: const BoxDecoration(
        color: Paper.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Paper.edge,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(condition.name, style: T.headline.copyWith(fontSize: 22)),
          const SizedBox(height: 10),
          Text(condition.summary, style: T.cardBody.copyWith(fontSize: 13.5)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Paper.mintCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: <Widget>[
                Image.asset('assets/emoji/stethoscope.png',
                    width: 28, height: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is guidance, not a diagnosis. A clinician can '
                    'confirm it.',
                    style: T.tileSub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ShimmerButton(
            label: 'Got it',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
