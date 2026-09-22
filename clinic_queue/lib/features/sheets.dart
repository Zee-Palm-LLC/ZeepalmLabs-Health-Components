import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/sheet.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/visit.dart';

class TokenSheet extends StatefulWidget {
  const TokenSheet({super.key, required this.visit, required this.onIssued});

  final Visit visit;
  final VoidCallback onIssued;

  @override
  State<TokenSheet> createState() => _TokenSheetState();
}

class _TokenSheetState extends State<TokenSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _print;
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _print = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
  }

  @override
  void dispose() {
    _print.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _printing = true);
    await _print.forward();
    if (mounted) widget.onIssued();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: _printing
            ? _Printer(key: const ValueKey('print'), progress: _print, visit: widget.visit)
            : _confirmation(),
      ),
    );
  }

  Widget _confirmation() {
    final sim = widget.visit.sim;
    return Column(
      key: const ValueKey('confirm'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetTitle(
          title: 'Confirm your token',
          caption: 'Join the line from home. We will tell you when to leave.',
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: cardShadow(0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFE3F3EE), borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: const GlyphIcon(Glyph.plus, size: 20, color: Hue.orange, stroke: 2.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CityCare Family Clinic', style: jakarta(15, 800, spacing: -0.3)),
                      const SizedBox(height: 2),
                      Text('Dr. Oliver Hayes · ${widget.visit.department}', style: jakarta(12.5, 500, color: Hue.gray)),
                    ],
                  ),
                ),
                const GlyphIcon(Glyph.star, size: 13, color: Color(0xFFF59E0B), fill: Color(0xFFF59E0B), stroke: 0.6),
                const SizedBox(width: 4),
                Text('4.8', style: jakarta(12.5, 800, color: const Color(0xFFB0590F))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const _Tile(label: 'YOUR TOKEN', value: 'A–${QueueSim.you}'),
              const SizedBox(width: 10),
              _Tile(label: 'EST. WAIT', value: '~${sim.wait} min'),
              const SizedBox(width: 10),
              _Tile(label: 'YOUR TURN', value: '${sim.turnTime} AM'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              const GlyphIcon(Glyph.shield, size: 15, color: Hue.teal, stroke: 1.9),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your spot is held for 10 minutes after your turn.',
                  style: jakarta(12, 600, color: const Color(0xFF1F5A55)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TealButton(label: 'Confirm token', trailing: Glyph.arrow, onTap: _confirm, height: 56, halo: false),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64,
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
        decoration: BoxDecoration(color: const Color(0xFFEEF6F3), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: caps(8.5, color: const Color(0xFF5E7370), tracking: 0.14)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: jakarta(16, 800, spacing: -0.4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Printer extends StatelessWidget {
  const _Printer({super.key, required this.progress, required this.visit});

  final Animation<double> progress;
  final Visit visit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 318,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final t = progress.value;
          final feed = Curves.easeOutCubic.transform(span(t, 0.05, 0.62));
          final stamp = span(t, 0.6, 0.85, Curves.elasticOut);
          final caption = span(t, 0.65, 0.9);
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 6,
                child: Container(
                  width: 250,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0F5550), Color(0xFF0E403C)]),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: const [BoxShadow(color: Color(0x330F3B3A), blurRadius: 12, offset: Offset(0, 6))],
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 214,
                    height: 5,
                    decoration: BoxDecoration(color: const Color(0xFF062624), borderRadius: BorderRadius.circular(3)),
                  ),
                ),
              ),
              Positioned(
                top: 22,
                width: 214,
                height: 210,
                child: ClipRect(
                  child: Transform.translate(
                    offset: Offset(0, -196 * (1 - feed)),
                    child: CustomPaint(
                      painter: const _TicketPainter(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('YOUR TOKEN', style: caps(9, color: const Color(0xFF5E7370), tracking: 0.18)),
                            Text('A–${QueueSim.you}', style: jakarta(46, 800, spacing: -2, height: 1.15)),
                            Text('CityCare · ${visit.department}', style: jakarta(12, 600, color: Hue.gray)),
                            const Spacer(),
                            const DashedLine(dash: 4, gap: 4, color: Color(0xFFD8E3E0)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text('4th in line', style: jakarta(12.5, 800, color: Hue.teal)),
                                const Spacer(),
                                Text('~18 min', style: jakarta(12.5, 800)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 174,
                right: 76,
                child: Transform.scale(
                  scale: stamp.clamp(0.0, 1.3),
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Hue.live,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(color: Color(0x4D22C55E), blurRadius: 12, offset: Offset(0, 5))],
                      ),
                      alignment: Alignment.center,
                      child: const GlyphIcon(Glyph.check, size: 22, color: Colors.white, stroke: 3),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 250,
                child: Opacity(
                  opacity: caption,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - caption)),
                    child: Column(
                      children: [
                        Text("You're in line!", style: jakarta(20, 800, spacing: -0.5)),
                        const SizedBox(height: 4),
                        Text('Opening your live queue…', style: jakarta(12.5, 500, color: Hue.gray)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TicketPainter extends CustomPainter {
  const _TicketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final body = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Offset.zero & size,
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
      );
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, size.height - 46), radius: 8))
      ..addOval(Rect.fromCircle(center: Offset(size.width, size.height - 46), radius: 8));
    final ticket = Path.combine(PathOperation.difference, body, notches);
    canvas.drawPath(
      ticket.shift(const Offset(0, 6)),
      Paint()
        ..color = const Color(0x1F0F3B3A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(ticket, Paint()..color = Colors.white);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 5),
      Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(size.width, 0), const [Hue.teal, Hue.aqua]),
    );
    final rng = math.Random(3);
    final dot = Paint()..color = const Color(0x140F766E);
    for (var i = 0; i < 18; i++) {
      canvas.drawCircle(Offset(rng.nextDouble() * size.width, 10 + rng.nextDouble() * (size.height - 70)), 1.2, dot);
    }
  }

  @override
  bool shouldRepaint(_TicketPainter oldDelegate) => false;
}

class SwapSheet extends StatefulWidget {
  const SwapSheet({super.key, required this.visit, required this.onSwapped});

  final Visit visit;
  final ValueChanged<int> onSwapped;

  @override
  State<SwapSheet> createState() => _SwapSheetState();
}

class _SwapSheetState extends State<SwapSheet> {
  int _choice = 1;

  @override
  Widget build(BuildContext context) {
    final rank = widget.visit.sim.rank;
    final room = math.max(0, 5 - rank);
    final options = [(1, 'Let 1 person go ahead', '+4 min'), (2, 'Let 2 people go ahead', '+8 min')];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetTitle(
          title: 'Need more time?',
          caption: 'Let people go ahead of you. You keep your token and move a few places back.',
        ),
        const SizedBox(height: 14),
        for (final (n, title, extra) in options)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: _Option(
              title: title,
              caption: 'You become ${ordinal(rank + n)} · $extra',
              selected: _choice == n,
              enabled: n <= room,
              onTap: () => setState(() => _choice = n),
            ),
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Opacity(
            opacity: room == 0 ? 0.45 : 1,
            child: TealButton(
              label: 'Swap spot',
              trailing: Glyph.arrow,
              height: 56,
              halo: false,
              onTap: room == 0 ? null : () => widget.onSwapped(math.min(_choice, room)),
            ),
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.caption,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String caption;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Pressable(
        onTap: enabled ? onTap : null,
        scale: 0.98,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: selected && enabled ? const Color(0xFFE6F5F0) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected && enabled ? Hue.teal : const Color(0xFFE3EDEA),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: jakarta(14, 800, spacing: -0.2)),
                    const SizedBox(height: 2),
                    Text(caption, style: jakarta(12, 500, color: Hue.gray)),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected && enabled ? Hue.teal : Colors.white,
                  border: Border.all(color: selected && enabled ? Hue.teal : const Color(0xFFC9D6D3), width: 1.6),
                ),
                alignment: Alignment.center,
                child: selected && enabled
                    ? const GlyphIcon(Glyph.check, size: 12, color: Colors.white, stroke: 2.8)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VisitSheet extends StatelessWidget {
  const VisitSheet({super.key, required this.visit, required this.onCancel});

  final Visit visit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final sim = visit.sim;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(title: 'Visit details', caption: 'Token A–${QueueSim.you} · ${ordinal(sim.rank)} in line'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const InfoRow(glyph: Glyph.plus, label: 'Clinic', value: 'CityCare Family Clinic', tone: Hue.orange),
              InfoRow(glyph: Glyph.user, label: 'Doctor', value: 'Dr. Oliver Hayes · ${visit.department}'),
              const InfoRow(glyph: Glyph.door, label: 'Room', value: 'Room 3'),
              InfoRow(glyph: Glyph.calendar, label: 'Your turn', value: '${sim.turnTime} AM'),
              const InfoRow(glyph: Glyph.shield, label: 'Spot held', value: '10 min after your turn'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Pressable(
            onTap: onCancel,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('Cancel my token', style: jakarta(14, 800, color: const Color(0xFFD9541E))),
            ),
          ),
        ),
      ],
    );
  }
}
