import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../core/icons/glyphs.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';
import '../../data/medications.dart';

class ScheduleCard extends StatefulWidget {
  const ScheduleCard({
    super.key,
    required this.medication,
    required this.taken,
    required this.onTaken,
    this.hint = false,
  });

  final Medication medication;
  final bool taken;
  final VoidCallback onTaken;
  final bool hint;

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> with TickerProviderStateMixin {
  late final AnimationController _drag;
  late final AnimationController _badge;
  static const _reach = 104.0;
  static const _spring = SpringDescription(mass: 1, stiffness: 380, damping: 22);
  bool _armed = false;

  @override
  void initState() {
    super.initState();
    _drag = AnimationController.unbounded(vsync: this);
    _badge = AnimationController(vsync: this, duration: const Duration(milliseconds: 700), value: widget.taken ? 1 : 0);
    if (widget.hint) {
      Future.delayed(const Duration(milliseconds: 2600), () async {
        if (!mounted || widget.taken) return;
        await _drag.animateTo(-46, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
        if (!mounted) return;
        _drag.animateWith(SpringSimulation(_spring, _drag.value, 0, 0));
      });
    }
  }

  @override
  void didUpdateWidget(ScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taken != oldWidget.taken) {
      widget.taken ? _badge.forward(from: 0) : _badge.reverse();
    }
  }

  @override
  void dispose() {
    _drag.dispose();
    _badge.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails details) {
    var next = _drag.value + details.delta.dx;
    if (next > 0) next *= 0.3;
    if (next < -_reach) next = -_reach + (next + _reach) * 0.25;
    _drag.value = next;
    final armed = next <= -_reach * 0.72;
    if (armed != _armed) {
      _armed = armed;
      HapticFeedback.selectionClick();
    }
  }

  void _end(DragEndDetails details) {
    if (_armed && !widget.taken) {
      HapticFeedback.mediumImpact();
      widget.onTaken();
    }
    _armed = false;
    _drag.animateWith(SpringSimulation(_spring, _drag.value, 0, details.velocity.pixelsPerSecond.dx));
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medication;
    return GestureDetector(
      onHorizontalDragUpdate: _update,
      onHorizontalDragEnd: _end,
      child: AnimatedBuilder(
        animation: Listenable.merge([_drag, _badge]),
        builder: (context, child) {
          final offset = _drag.value;
          final pull = (-offset / _reach).clamp(0.0, 1.2);
          return Stack(
            children: [
              Positioned.fill(
                child: Offstage(
                  offstage: offset > -0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.lerp(Palette.tealChip, Palette.deep, pull.clamp(0.0, 1.0)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 22),
                    child: Opacity(
                      opacity: pull.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: lerp(0.5, 1, Curves.easeOutBack.transform(pull.clamp(0.0, 1.0))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: pull >= 0.72 ? const Color(0xFFCFEDE7) : const Color(0x33FFFFFF),
                                shape: BoxShape.circle,
                              ),
                              child: GlyphIcon(
                                Glyph.check,
                                size: 34,
                                color: pull >= 0.72 ? Palette.deep : Colors.white,
                                stroke: 1.4,
                                progress: pull.clamp(0.0, 1.0),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.taken ? 'Taken' : 'Mark taken',
                              style: TextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(offset: Offset(offset, 0), child: child),
            ],
          );
        },
        child: _face(med),
      ),
    );
  }

  Widget _face(Medication med) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 16),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: Palette.tile, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: med.shape == PillShape.capsule ? const CapsuleArt(size: 27) : const TabletArt(size: 27),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name, style: TextStyles.title),
                    const SizedBox(height: 3),
                    Text(
                      '${med.category} ${med.instruction}',
                      style: TextStyles.caption.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _badge,
                builder: (context, _) {
                  final t = _badge.value;
                  if (t <= 0) return const SizedBox.shrink();
                  final pop = Curves.elasticOut.transform(t);
                  return Transform.scale(
                    scale: pop,
                    child: Transform.rotate(
                      angle: (1 - math.min(t * 1.5, 1)) * -1.2,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(color: Palette.deep, shape: BoxShape.circle),
                        child: GlyphIcon(
                          Glyph.check,
                          size: 26,
                          color: Colors.white,
                          stroke: 1.5,
                          progress: window(t, 0.2, 0.8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _Fact(label: med.timing, value: med.supply, align: CrossAxisAlignment.start),
              ),
              Expanded(
                child: _Fact(label: 'Dose', value: med.dose, align: CrossAxisAlignment.center),
              ),
              Expanded(
                child: _Fact(label: 'Frequency', value: med.frequency, align: CrossAxisAlignment.end),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, required this.align});

  final String label;
  final String value;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    final parts = value.split('/');
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: TextStyles.caption.copyWith(color: const Color(0xFFA3A9AC))),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: parts.first,
            style: TextStyles.title.copyWith(fontSize: 14.5),
            children: [
              if (parts.length > 1)
                TextSpan(
                  text: '/${parts[1]}',
                  style: TextStyles.caption.copyWith(color: Palette.ink, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
