import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../data/sessions.dart';
import '../theme.dart';
import 'orb.dart';
import 'session_card.dart';
import 'top_bar.dart';

/// Layout of the header, in points from the top of a 393 x 852 screen with a
/// 59 pt status bar inset (the reference device). [dy] shifts it for others.
abstract final class HeaderMetrics {
  static const centerX = 196.5;

  // Expanded: the inverted arc. Cards hang from a pivot far above the screen,
  // so neighbours swing up and outward as they leave the centre.
  static const cardCenterY = 219.0;
  static const arcRadius = 1290.0;
  static const arcStep = 13 * math.pi / 180;
  static const sideShrink = 0.08;
  static const dotsY = 352.0;
  static const greetingTop = 380.0;

  // Collapsed: three orbs and their labels.
  static const orbY = 125.5;
  static const orbGap = 107.0;
  static const activeOrb = 52.0;
  static const sideOrb = 40.0;
  static const labelY = 165.0;

  static const maxExtent = 440.0;
  static const minExtent = 192.0;

  /// Points the carousel moves per page while expanded and collapsed.
  static double get expandedPageWidth => arcRadius * math.sin(arcStep);
  static const collapsedPageWidth = orbGap;
}

class ArcHeaderDelegate extends SliverPersistentHeaderDelegate {
  ArcHeaderDelegate({
    required this.page,
    required this.scroll,
    required this.dy,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onSelect,
  });

  final Animation<double> page;

  /// Read for the pull-down overscroll, so the header bounces with the page.
  final ScrollController scroll;
  final double dy;
  final VoidCallback onDragStart;
  final void Function(double dx, double pageWidth) onDragUpdate;
  final void Function(double velocity, double pageWidth) onDragEnd;
  final ValueChanged<int> onSelect;

  @override
  double get maxExtent => HeaderMetrics.maxExtent + dy;

  @override
  double get minExtent => HeaderMetrics.minExtent + dy;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final p = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: Listenable.merge([page, scroll]),
      builder: (context, _) {
        // A pinned header would stay put while the list rubber-bands away
        // from it; ride the pull instead so the whole page bounces as one.
        final pull = scroll.hasClients ? math.max(0.0, -scroll.offset) : 0.0;
        return Transform.translate(
          offset: Offset(0, pull),
          child: ArcHeader(
            page: page.value,
            progress: p,
            shrink: shrinkOffset.clamp(0.0, maxExtent - minExtent),
            dy: dy,
            onDragStart: onDragStart,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
            onSelect: onSelect,
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(ArcHeaderDelegate old) => old.page != page || old.scroll != scroll || old.dy != dy;
}

class ArcHeader extends StatelessWidget {
  const ArcHeader({
    super.key,
    required this.page,
    required this.progress,
    required this.shrink,
    required this.dy,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onSelect,
  });

  final double page;
  final double progress;
  final double shrink;
  final double dy;
  final VoidCallback onDragStart;
  final void Function(double dx, double pageWidth) onDragUpdate;
  final void Function(double velocity, double pageWidth) onDragEnd;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final e = Curves.easeInOutCubic.transform(progress);
    final pageWidth = lerpDouble(HeaderMetrics.expandedPageWidth, HeaderMetrics.collapsedPageWidth, e)!;
    final order = List.generate(sessions.length, (i) => i)..sort((a, b) => (b - page).abs().compareTo((a - page).abs()));

    // Centre on the real width, so any phone (or a browser window) lines up.
    final mid = MediaQuery.sizeOf(context).width / 2;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => onDragStart(),
      onHorizontalDragUpdate: (d) => onDragUpdate(d.delta.dx, pageWidth),
      onHorizontalDragEnd: (d) => onDragEnd(d.velocity.pixelsPerSecond.dx, pageWidth),
      child: ColoredBox(
        color: Tone.canvas,
        child: SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              _Greeting(top: HeaderMetrics.greetingTop + dy - shrink, opacity: (1 - progress * 1.7).clamp(0.0, 1.0)),
              Positioned(
                left: 0,
                right: 0,
                top: HeaderMetrics.dotsY + dy - shrink * 0.6,
                child: Opacity(
                  opacity: (1 - progress * 3).clamp(0.0, 1.0),
                  child: PageDots(page: page, count: sessions.length),
                ),
              ),
              for (final i in order) _card(i, e, mid),
              for (var i = 0; i < sessions.length; i++) _label(i, mid),
              Positioned(top: dy, left: 0, right: 0, child: const TopBar()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(int i, double e, double mid) {
    final d = i - page;
    final ad = d.abs();
    final near = math.min(ad, 1.0);
    final session = sessions[i];

    // Expanded pose on the arc.
    final theta = d * HeaderMetrics.arcStep;
    final s = 1 - HeaderMetrics.sideShrink * math.min(ad, 1.5);
    final ex = mid + HeaderMetrics.arcRadius * math.sin(theta);
    final ey = HeaderMetrics.cardCenterY - HeaderMetrics.arcRadius * (1 - math.cos(theta));

    // Collapsed pose in the top menu.
    final dia = lerpDouble(HeaderMetrics.activeOrb, HeaderMetrics.sideOrb, near)!;
    final cx = mid + d * HeaderMetrics.orbGap;

    final w = lerpDouble(cardSize.width * s, dia, e)!;
    final h = lerpDouble(cardSize.height * s, dia, e)!;
    final x = lerpDouble(ex, cx, e)!;
    final y = lerpDouble(ey, HeaderMetrics.orbY, e)! + dy;
    final radius = lerpDouble(cardRadius * s, dia / 2, e)!;
    final angle = lerpDouble(-theta, 0, e)!;

    // Neighbours wash out toward white and become plain glass orbs.
    final white = e * near;
    final colourOrb = (e * e) * (1 - near);
    final glass = (1 - math.max(white, colourOrb)).clamp(0.0, 1.0).toDouble();
    final face = (1 - progress / 0.22).clamp(0.0, 1.0);
    final count = ((progress - 0.1) / 0.22).clamp(0.0, 1.0);
    final fadeFar = (1 - (ad - 1.2) * 2.5).clamp(0.0, 1.0);
    final visible = lerpDouble(1, fadeFar, e)!;
    if (visible <= 0.01) return const SizedBox.shrink();

    return Positioned(
      key: ValueKey('card$i'),
      left: x - w / 2,
      top: y - h / 2,
      width: w,
      height: h,
      child: Opacity(
        opacity: visible,
        child: Transform.rotate(
          angle: angle,
          child: GestureDetector(
            onTap: progress > 0.6 || ad > 0.5 ? () => onSelect(i) : null,
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                if (colourOrb > 0.02)
                  Positioned.fill(
                    left: -6,
                    top: -6,
                    right: -6,
                    bottom: -6,
                    child: Opacity(
                      opacity: ((colourOrb - 0.4) / 0.6).clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: session.mood.light.withValues(alpha: 0.75), width: 4.5),
                        ),
                      ),
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B4A30).withValues(alpha: 0.08 * (1 - e) + 0.06 * white),
                        blurRadius: lerpDouble(28, 10, e)!,
                        offset: Offset(0, lerpDouble(10, 4, e)!),
                      ),
                    ],
                  ),
                ),
                if (glass > 0.01)
                  Opacity(
                    opacity: glass,
                    child: CardGlass(session: session, radius: radius),
                  ),
                if (white > 0.01)
                  Opacity(
                    opacity: white.clamp(0.0, 1.0),
                    child: CustomPaint(
                      painter: OrbPainter(
                        base: const Color(0xFFF2EFEB),
                        light: Colors.white,
                        deep: const Color(0xFFDCD7D0),
                        glow: 0,
                        opacity: (white * 1.4).clamp(0.0, 1.0),
                      ),
                    ),
                  ),
                if (colourOrb > 0.01)
                  CustomPaint(
                    painter: OrbPainter(
                      base: session.mood.base,
                      light: session.mood.light,
                      deep: session.mood.deep,
                      glow: 0.6,
                      opacity: colourOrb.clamp(0.0, 1.0),
                    ),
                  ),
                // Glass edge and the white wash on neighbours.
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: Colors.white.withValues(alpha: 0.5 * near * (1 - e)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.75 * (1 - e)), width: 1),
                  ),
                ),
                if (face > 0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: Opacity(
                      opacity: face,
                      child: OverflowBox(
                        maxWidth: cardSize.width,
                        maxHeight: cardSize.height,
                        child: Transform.scale(
                          scale: w / cardSize.width,
                          child: CardFace(session: session),
                        ),
                      ),
                    ),
                  ),
                if (count > 0)
                  Center(
                    child: Opacity(
                      opacity: count,
                      child: Text(
                        session.count,
                        style: mono(
                          lerpDouble(70, near > 0.5 ? 16.5 : 25, e)!,
                          color: Color.lerp(Colors.white, const Color(0xFF8E8A86), e * near)!,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(int i, double mid) {
    final d = i - page;
    final ad = d.abs();
    final show = ((progress - 0.62) / 0.38).clamp(0.0, 1.0) * (1 - (ad - 1.2) * 2.5).clamp(0.0, 1.0);
    if (show <= 0.01) return const SizedBox.shrink();
    final active = 1.0 - math.min(ad, 1.0);
    return Positioned(
      left: mid + d * HeaderMetrics.orbGap - 40,
      width: 80,
      top: HeaderMetrics.labelY + dy,
      child: Opacity(
        opacity: show,
        child: Text(
          sessions[i].menuLabel,
          textAlign: TextAlign.center,
          style: sans(10.5, weight: active > 0.5 ? FontWeight.w500 : FontWeight.w400, color: Color.lerp(Tone.soft, Tone.text, active)!),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.top, required this.opacity});

  final double top;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 22,
      right: 22,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'good morning ',
                    style: sans(32.8, weight: FontWeight.w500, spacing: -1.1, height: 1.1),
                  ),
                  TextSpan(
                    text: 'maya',
                    style: sans(32.8, weight: FontWeight.w500, spacing: -1.1, height: 1.1, color: const Color(0xFF8E8A86)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text('4 workouts done this week. One to go.', style: sans(13.9, color: const Color(0xFF77736F), spacing: -0.1)),
          ],
        ),
      ),
    );
  }
}

/// Five dots; the current page stretches into a dark pill.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.page, required this.count});

  final double page;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Builder(
            builder: (context) {
              final k = (1 - (i - page).abs()).clamp(0.0, 1.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.2),
                width: lerpDouble(4, 15, k),
                height: 4,
                decoration: BoxDecoration(color: Color.lerp(Tone.dot, Tone.text, k), borderRadius: BorderRadius.circular(2)),
              );
            },
          ),
      ],
    );
  }
}
