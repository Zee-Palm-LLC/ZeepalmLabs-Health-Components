import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';
import '../../widgets/avatar.dart';

class Entry {
  const Entry(this.name, this.photo, this.time, this.ok, this.avatarY, this.radius);

  final String name;
  final String? photo;
  final String time;
  final bool ok;
  final double avatarY;
  final double radius;
}

const entries = [
  Entry('Sarah', 'f_sarah', '9:12 AM', true, 643.5, 20.4),
  Entry('Mike', 'f_mike', '8:47 AM', true, 695.2, 19.2),
  Entry('Priya', 'f_priya', '8:32 AM', true, 747.8, 20.9),
  Entry('Marcus', null, '7:32 AM', false, 799.2, 18.6),
];

const pitch = 51.9;

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key, required this.entrance, required this.check});

  final Animation<double> entrance;
  final Animation<double> check;

  @override
  Widget build(BuildContext context) {
    final e = entrance;
    final head = inter(17.5, 700, color: const Color(0xFFE6E8EC));
    return AnimatedBuilder(
      animation: check,
      builder: (context, _) {
        final push = span(check.value, 0.45, 0.85, gentle);
        final shift = pitch * push;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 16.67 - bearing('A', head),
              top: 590 - capInset(head),
              child: Staged(animation: e, begin: 0.5, end: 0.8, offset: const Offset(-12, 0), child: Text('Activity Feed', style: head)),
            ),
            Positioned(
              left: 78.8 - 0.8,
              top: 639.5,
              child: AnimatedBuilder(
                animation: e,
                builder: (context, _) => Container(
                  width: 1.6,
                  height: (796.5 - 639.5 + shift) * span(e.value, 0.55, 0.95, gentle),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF14233D), Color(0xFF0D1828), Color(0xFF0C1428)],
                    ),
                  ),
                ),
              ),
            ),
            for (var i = 0; i < entries.length; i++)
              Positioned(
                left: 95,
                top: 617.0 + i * 52.2 + shift,
                child: Staged(
                  animation: e,
                  begin: 0.6 + i * 0.05,
                  end: 0.9 + i * 0.03,
                  child: Container(
                    width: 280,
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF0E1B34), Color(0xFF0A1630), Color(0x000A1630)], stops: [0, 0.8, 1]),
                    ),
                  ),
                ),
              ),
            if (push > 0)
              Positioned(
                left: 0,
                top: 0,
                width: 393,
                height: 900,
                child: Opacity(
                  opacity: span(check.value, 0.6, 0.9, Curves.linear),
                  child: Transform.translate(
                    offset: Offset(-30 * (1 - span(check.value, 0.6, 0.95, settle)), 0),
                    child: _Row(entry: const Entry('You', 'm_you', 'Just now', true, 643.5, 20.4), index: 0, entrance: e, fresh: true),
                  ),
                ),
              ),
            for (final (i, entry) in entries.indexed)
              Positioned(
                left: 0,
                top: shift,
                width: 393,
                height: 900,
                child: _Row(entry: entry, index: i, entrance: e),
              ),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry, required this.index, required this.entrance, this.fresh = false});

  final Entry entry;
  final int index;
  final Animation<double> entrance;
  final bool fresh;

  @override
  Widget build(BuildContext context) {
    final e = entrance;
    final name = inter(12.3, 500, color: const Color(0xFFD5DAE3));
    final status = inter(10.56, 400, color: entry.ok ? const Color(0xFF3FD29B) : const Color(0xFFE0485F));
    final time = inter(12.3, 400, color: const Color(0xFF858EA7));
    final dy = index * pitch;
    final begin = fresh ? 0.0 : 0.62 + index * 0.07;
    final end = fresh ? 0.0 : 0.95 + index * 0.02;
    Widget stage(Widget child, {Offset offset = const Offset(24, 0), double scale = 1}) => fresh
        ? child
        : Staged(animation: e, begin: begin, end: end, offset: offset, scale: scale, curve: scale < 1 ? settle : gentle, child: child);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 37.5 - entry.radius,
          top: entry.avatarY - entry.radius,
          child: stage(
            entry.photo == null
                ? _Missed(radius: entry.radius)
                : RingAvatar(
                    asset: Art.avatar(entry.photo!),
                    radius: entry.radius,
                    photo: entry.radius - 1.8,
                    stroke: 1.5,
                    ring: index == 0 && !fresh
                        ? const [Color(0xFF7FE9E4), Color(0xFF3FB6B4), Color(0xFF1F6F75)]
                        : const [Color(0xFFBFC6D2), Color(0xFF7D8598), Color(0xFF4A5165)],
                  ),
            offset: const Offset(-16, 0),
            scale: 0.6,
          ),
        ),
        Positioned(
          left: 78.8 - 7.2,
          top: 639.5 + dy - 7.2,
          child: stage(_Dot(ok: entry.ok, seconds: 0), offset: Offset.zero, scale: 0),
        ),
        Positioned(
          left: 99.67 - bearing(entry.name, name),
          top: 629.3 + dy - capInset(name),
          child: stage(Text(entry.name, style: name)),
        ),
        Positioned(
          left: 99.67 - bearing(entry.ok ? 'C' : 'M', status),
          top: 647.67 + dy - capInset(status),
          child: stage(Text(entry.ok ? 'Checked In' : 'Missed Check-In', style: status)),
        ),
        Positioned(
          right: 393 - 375.2,
          top: 636.3 + dy - capInset(time),
          child: stage(Text(entry.time, style: time), offset: const Offset(-12, 0)),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.ok, required this.seconds});

  final bool ok;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final c = ok ? const Color(0xFF3DDDB0) : const Color(0xFFE0455E);
    return Container(
      width: 14.4,
      height: 14.4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.lerp(c, Colors.white, 0.25)!, c]),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.45), blurRadius: 8)],
      ),
      child: Center(
        child: ok
            ? const PhIcon(Ph.check, size: 8.2, color: Color(0xFF07352A))
            : Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF5A0F1D))),
      ),
    );
  }
}

class _Missed extends StatelessWidget {
  const _Missed({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, s, child) {
        final k = s % 5.0;
        final shake = s > 0 && k < 0.5 ? math.sin(k / 0.5 * math.pi * 6) * (1 - k / 0.5) * 3 : 0.0;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFFFF5D73), Color(0xFFED4053), Color(0xFFD7324A)], stops: [0.0, 0.55, 1.0]),
          boxShadow: [BoxShadow(color: Color(0x55ED4053), blurRadius: 12)],
        ),
        child: const Center(child: PhIcon(Ph.x, size: 16, color: Color(0xFFFFF4F6))),
      ),
    );
  }
}
