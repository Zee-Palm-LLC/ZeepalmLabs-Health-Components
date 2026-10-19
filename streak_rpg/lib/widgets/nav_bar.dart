import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import 'fx.dart';
import 'parts.dart';

/// The game dock: a floating glass bar with a socket carved out of its top
/// edge. The active tab lives in a glowing orb sitting in that socket; picking
/// another tab makes the orb hop along an arc, trailing sparks, while the
/// socket slides underneath it.
class NavBar extends StatefulWidget {
  const NavBar({super.key, required this.index, required this.onTap, this.badges = const {1: 3, 2: 0}});

  static const centers = [59.25, 153.75, 248.25, 342.75];
  static const labels = ['Home', 'Quests', 'Friends', 'Profile'];
  static const icons = [Ph.house, Ph.trophy, Ph.users, Ph.user];

  /// Bar top inside the widget; the orb rises above it.
  static const barTop = 30.0;
  static const barHeight = 64.0;

  final int index;
  final ValueChanged<int> onTap;

  /// Tab → count (0 shows a dot).
  final Map<int, int> badges;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  late final AnimationController _hop;
  late double _from = NavBar.centers[widget.index];
  late int _shown = widget.index;

  @override
  void initState() {
    super.initState();
    _hop = AnimationController(vsync: this, duration: const Duration(milliseconds: 680), value: 1);
    _hop.addListener(() {
      final icon = _hop.value > 0.5 ? widget.index : _shown;
      if (icon != _shown) setState(() => _shown = icon);
    });
  }

  @override
  void didUpdateWidget(NavBar old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _from = _x;
      _hop.forward(from: 0);
    }
  }

  double get _x => lerp(_from, NavBar.centers[widget.index], Curves.easeInOutCubic.transform(_hop.value));

  @override
  void dispose() {
    _hop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hop,
      builder: (context, _) {
        final t = _hop.value;
        final x = _x;
        final lift = math.sin(t * math.pi) * 22;
        final squash = 1 + shake(t, freq: 1.5, decay: 3) * 0.18;
        return SizedBox(
          height: 120,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Light pool under the active tab.
              Positioned(
                left: x - 70,
                top: NavBar.barTop + 18,
                width: 140,
                height: 90,
                child: const Glow(color: Color(0xFFFFB82E), opacity: 0.28),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 120,
                child: Tick(
                  builder: (context, s, _) => _Bar(notch: x, seconds: s),
                ),
              ),
              for (var i = 0; i < 4; i++)
                Positioned(
                  left: NavBar.centers[i] - 47,
                  top: NavBar.barTop,
                  width: 94,
                  height: NavBar.barHeight,
                  child: Pressable(
                    onTap: () => widget.onTap(i),
                    scale: 0.88,
                    child: _Item(index: i, active: i == widget.index, badge: widget.badges[i], hidden: i == widget.index || (t < 1 && i == _shown)),
                  ),
                ),
              // Spark trail while hopping.
              if (t > 0 && t < 1)
                for (var k = 1; k <= 6; k++)
                  Builder(
                    builder: (context) {
                      final tt = (t - k * 0.04).clamp(0.0, 1.0);
                      final px = lerp(_from, NavBar.centers[widget.index], Curves.easeInOutCubic.transform(tt));
                      final py = NavBar.barTop - 6 - math.sin(tt * math.pi) * 22;
                      final r = 5.0 - k * 0.6;
                      return Positioned(
                        left: px - r,
                        top: py - r + 8,
                        width: r * 2,
                        height: r * 2,
                        child: Glow(color: const Color(0xFFFFE07A), opacity: 1 - k / 7),
                      );
                    },
                  ),
              Positioned(
                left: x - 29,
                top: NavBar.barTop - 6 - 29 - lift,
                width: 58,
                height: 58,
                child: Pressable(
                  onTap: () => widget.onTap(widget.index),
                  child: Transform.scale(
                    scaleX: squash,
                    scaleY: 2 - squash,
                    child: _Orb(index: _shown),
                  ),
                ),
              ),
              Positioned(
                left: x - 47,
                width: 94,
                top: NavBar.barTop + 37,
                child: Opacity(
                  opacity: span(t, 0.55, 1, Curves.easeOut),
                  child: Center(
                    child: GradientText(NavBar.labels[widget.index], style: poppins(12.6, FontWeight.w700), colors: goldText, stops: goldStops),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.notch, required this.seconds});

  final double notch;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final path = _NotchPath(notch);
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: path,
          child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: const SizedBox.expand()),
        ),
        CustomPaint(painter: _BarPainter(notch, seconds)),
      ],
    );
  }
}

Path barPath(Size size, double notch) {
  const left = 10.0;
  final right = size.width - 10;
  const top = NavBar.barTop;
  const bottom = NavBar.barTop + NavBar.barHeight;
  final bar = Path()..addRRect(RRect.fromLTRBR(left, top, right, bottom, const Radius.circular(26)));
  final socket = Path()..addOval(Rect.fromCircle(center: Offset(notch, top - 6), radius: 36));
  return Path.combine(PathOperation.difference, bar, socket);
}

class _NotchPath extends CustomClipper<Path> {
  _NotchPath(this.notch);

  final double notch;

  @override
  Path getClip(Size size) => barPath(size, notch);

  @override
  bool shouldReclip(_NotchPath old) => old.notch != notch;
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.notch, this.s);

  final double notch;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final path = barPath(size, notch);
    final bounds = Rect.fromLTRB(10, NavBar.barTop, size.width - 10, NavBar.barTop + NavBar.barHeight);
    canvas.drawPath(
      path.shift(const Offset(0, 8)),
      Paint()
        ..color = const Color(0xAA020210)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawPath(path, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xD9221A4E), Color(0xEB110C2C)]).createShader(bounds));
    // Inner sheen on the upper half.
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(bounds.left, bounds.top, bounds.width, bounds.height * 0.45),
      Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)]).createShader(bounds),
    );
    // Hex-grid texture, very faint.
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = const Color(0x0FB9A6FF);
    for (var gx = bounds.left; gx < bounds.right; gx += 18) {
      for (var gy = bounds.top; gy < bounds.bottom; gy += 16) {
        final o = Offset(gx + ((gy - bounds.top) ~/ 16).isOdd.toInt() * 9, gy);
        canvas.drawPath(_hex(o, 6), grid);
      }
    }
    canvas.restore();
    // Gold edge that brightens toward the socket, with a spark circling it.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..shader = ui.Gradient.radial(Offset(notch, NavBar.barTop), 220, const [Color(0xFFFFE07A), Color(0x88B98CFF), Color(0x40B98CFF)], const [0, 0.45, 1]),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..shader = ui.Gradient.radial(Offset(notch, NavBar.barTop), 90, const [Color(0x66FFC94A), Color(0x00FFC94A)])
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    final metric = path.computeMetrics().first;
    final d = (s * 0.12 % 1) * metric.length;
    for (var k = 0; k < 8; k++) {
      final tan = metric.getTangentForOffset((d - k * 4) % metric.length);
      if (tan == null) continue;
      canvas.drawCircle(
        tan.position,
        2.4 - k * 0.25,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85 - k * 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  Path _hex(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = math.pi / 6 + i * math.pi / 3;
      final q = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? p.moveTo(q.dx, q.dy) : p.lineTo(q.dx, q.dy);
    }
    return p..close();
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.notch != notch || old.s != s;
}

extension on bool {
  int toInt() => this ? 1 : 0;
}

/// The glowing orb holding the active tab's icon.
class _Orb extends StatelessWidget {
  const _Orb({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (index == 0) {
      icon = SizedBox(width: 30, height: 28, child: Art.navHome.image(fit: BoxFit.contain));
    } else if (index == 1) {
      icon = SizedBox(width: 30, height: 27, child: Art.trophy.image(fit: BoxFit.contain));
    } else {
      icon = GradientIcon(NavBar.icons[index], size: 26, colors: const [Color(0xFFFFF0A0), Color(0xFFF5A623)]);
    }
    return Tick(
      builder: (context, s, child) => CustomPaint(painter: _OrbPainter(s), child: child),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (c, a) => ScaleTransition(
            scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
            child: c,
          ),
          child: KeyedSubtree(key: ValueKey(index), child: icon),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter(this.s);

  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 2;
    final pulse = (math.sin(s * 2.6) + 1) / 2;
    canvas.drawCircle(
      c,
      r + 6 + pulse * 3,
      Paint()
        ..color = const Color(0xFFFFB82E).withValues(alpha: 0.35 + 0.2 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFF5A3FB0), Color(0xFF2A1A62), Color(0xFF170F3C)],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(s * 1.2);
    canvas.drawCircle(
      Offset.zero,
      r - 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = const SweepGradient(
          colors: [Color(0xFFFFF0A0), Color(0xFFF08A10), Color(0xFFFFD45A), Color(0xFFB0721E), Color(0xFFFFF0A0)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
    );
    canvas.restore();
    for (var i = 0; i < 3; i++) {
      final a = -s * 1.8 + i * math.pi * 2 / 3;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * (r + 5), 1.8, Paint()..color = const Color(0xFFFFF4C2));
    }
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.25, -r * 0.5), width: r * 0.9, height: r * 0.35),
      Paint()
        ..color = const Color(0x30FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.s != s;
}

class _Item extends StatelessWidget {
  const _Item({required this.index, required this.active, required this.badge, required this.hidden});

  final int index;
  final bool active;
  final int? badge;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hidden ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          const SizedBox(height: 9),
          SizedBox(
            width: 40,
            height: 28,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: GradientIcon(NavBar.icons[index], size: 25, colors: const [Color(0xFFD4CEF2), Color(0xFF8E88B8)])),
                if (badge != null)
                  Positioned(
                    right: badge! > 0 ? -2 : 4,
                    top: badge! > 0 ? -5 : -1,
                    child: Tick(
                      builder: (context, s, _) => Transform.scale(
                        scale: 1 + math.max(0, math.sin(s * 3.2)) * 0.12,
                        child: Container(
                          padding: badge! > 0 ? const EdgeInsets.symmetric(horizontal: 5, vertical: 1) : EdgeInsets.zero,
                          width: badge! > 0 ? null : 9,
                          height: badge! > 0 ? null : 9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            gradient: badge! > 0 ? const LinearGradient(colors: [Color(0xFFFF5F8F), Color(0xFFE5306A)]) : null,
                            color: badge! > 0 ? null : Tone.green,
                            border: Border.all(color: const Color(0xFF171035), width: 1.6),
                            boxShadow: [BoxShadow(color: (badge! > 0 ? const Color(0xFFFF5F8F) : Tone.green).withValues(alpha: 0.6), blurRadius: 6)],
                          ),
                          child: badge! > 0 ? Line('$badge', style: poppins(9.5, FontWeight.w700)) : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Line(NavBar.labels[index], style: poppins(12, FontWeight.w600, color: const Color(0xFFB4AFD6))),
        ],
      ),
    );
  }
}
