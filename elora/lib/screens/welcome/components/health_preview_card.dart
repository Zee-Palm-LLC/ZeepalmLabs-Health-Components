
import 'dart:math' as math;

import 'package:flutter/material.dart';


class HealthPreviewCard extends StatefulWidget {
  const HealthPreviewCard({super.key});

  static const ink = Color(0xFF101713);
  static const muted = Color(0xFF718078);
  static const green = Color(0xFF287B58);
  static const canvas = Color(0xFFF4F8F2);

  @override
  State<HealthPreviewCard> createState() =>
      _HealthPreviewCardState();
}

class _HealthPreviewCardState extends State<HealthPreviewCard>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _ambient;

  late final Animation<double> _energy;
  late final Animation<double> _sleep;
  late final Animation<double> _recovery;
  late final Animation<double> _activity;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _energy = CurvedAnimation(
      parent: _intro,
      curve: const Interval(
        0.00,
        0.58,
        curve: Curves.easeOutBack,
      ),
    );

    _sleep = CurvedAnimation(
      parent: _intro,
      curve: const Interval(
        0.18,
        0.70,
        curve: Curves.easeOutBack,
      ),
    );

    _recovery = CurvedAnimation(
      parent: _intro,
      curve: const Interval(
        0.36,
        0.84,
        curve: Curves.easeOutBack,
      ),
    );

    _activity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(
        0.52,
        1.00,
        curve: Curves.easeOutBack,
      ),
    );

    _ambient.repeat(reverse: true);

    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 40,
            right: 18,
            child: AnimatedBuilder(
              animation: _ambient,
              builder: (context, child) {
                final pulse = _ambient.value;

                return Transform.scale(
                  scale: 0.85 + pulse * 0.2,
                  child: Opacity(
                    opacity: 0.35 + pulse * 0.25,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF91DDB1)
                                .withValues(alpha: 0.36),
                            const Color(0xFF91DDB1)
                                .withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: 38,
            left: 8,
            right: 36,
            child: _AnimatedLayer(
              animation: _energy,
              style: 0,
              child: _EnergyCard(),
            ),
          ),

          Positioned(
            top: 3,
            right: 0,
            child: _AnimatedLayer(
              animation: _sleep,
              style: 1,
              child: _SleepCard(),
            ),
          ),

          Positioned(
            bottom: 12,
            left: 0,
            child: _AnimatedLayer(
              animation: _recovery,
              style: 2,
              child: _RecoveryCard(),
            ),
          ),

          Positioned(
            bottom: 19,
            right: 1,
            child: _AnimatedLayer(
              animation: _activity,
              style: 3,
              child: _ActivityCard(),
            ),
          ),

          Positioned(
            top: 25,
            left: 12,
            child: AnimatedBuilder(
              animation: _ambient,
              builder: (context, child) {
                final pulse = _ambient.value;

                return Transform.translate(
                  offset: Offset(
                    math.sin(pulse * math.pi) * 4,
                    -pulse * 5,
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF70C89A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: HealthPreviewCard.green
                              .withValues(alpha: 0.2 + pulse * 0.3),
                          blurRadius: 8 + pulse * 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedLayer extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final int style;

  const _AnimatedLayer({
    required this.animation,
    required this.child,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final raw = animation.value;
        final t = raw.clamp(0.0, 1.0);
        final remaining = 1.0 - t;

        late Offset offset;
        late double rotation;
        late double rotateX;
        late double rotateY;
        late double scale;

        switch (style) {
          case 0:
            // Main card: emerges from depth.
            offset = Offset(0, 42 * remaining);
            rotation = -0.09 * remaining;
            rotateX = -0.18 * remaining;
            rotateY = 0.24 * remaining;
            scale = 0.72 + 0.28 * t;
            break;

          case 1:
            // Sleep: swings in from the upper-right.
            offset = Offset(
              82 * remaining,
              -35 * remaining,
            );
            rotation = 0.42 * remaining;
            rotateX = 0.08 * remaining;
            rotateY = -0.48 * remaining;
            scale = 0.78 + 0.22 * t;
            break;

          case 2:
            // Recovery: lifts up and unfolds.
            offset = Offset(
              -38 * remaining,
              68 * remaining,
            );
            rotation = -0.32 * remaining;
            rotateX = 0.58 * remaining;
            rotateY = 0.12 * remaining;
            scale = 0.76 + 0.24 * t;
            break;

          default:
            // Activity: swings horizontally into place.
            offset = Offset(
              100 * remaining,
              12 * math.sin(t * math.pi) * remaining,
            );
            rotation = 0.62 * remaining;
            rotateX = -0.12 * remaining;
            rotateY = 0.42 * remaining;
            scale = 0.68 + 0.32 * t;
        }

        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateX(rotateX)
          ..rotateY(rotateY)
          ..rotateZ(rotation);

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: offset,
            child: Transform(
              alignment: Alignment.center,
              transform: matrix,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EnergyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE6EEE6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF244C35).withValues(alpha: 0.13),
            blurRadius: 28,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF5E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: HealthPreviewCard.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR ENERGY',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w800,
                        color: HealthPreviewCard.muted,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Daily readiness',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: HealthPreviewCard.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.north_east_rounded,
                size: 18,
                color: HealthPreviewCard.muted,
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 83,
                height: 83,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF9FE7BB)
                                .withValues(alpha: 0.42),
                            const Color(0xFF9FE7BB)
                                .withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 73,
                      height: 73,
                      child: CircularProgressIndicator(
                        value: 0.82,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFFE8F0E9),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF3C9B6D),
                        ),
                      ),
                    ),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '82',
                          style: TextStyle(
                            color: HealthPreviewCard.ink,
                            fontSize: 27,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'OF 100',
                          style: TextStyle(
                            color: HealthPreviewCard.muted,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Looking good',
                      style: TextStyle(
                        color: HealthPreviewCard.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your body is ready for a productive day.',
                      style: TextStyle(
                        color: HealthPreviewCard.muted,
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: HealthPreviewCard.green,
                          size: 15,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+8% this week',
                          style: TextStyle(
                            color: HealthPreviewCard.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 0.82,
              minHeight: 5,
              backgroundColor: Color(0xFFEAF1E9),
              valueColor: AlwaysStoppedAnimation(
                Color(0xFF5DB786),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 133,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0FF),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7765C9).withValues(alpha: 0.17),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5DEFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  size: 17,
                  color: Color(0xFF7765C9),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF7765C9),
                size: 19,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'SLEEP',
            style: TextStyle(
              color: Color(0xFF8175B0),
              fontSize: 9,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            '7h 42m',
            style: TextStyle(
              color: Color(0xFF29233E),
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.82,
              minHeight: 4,
              backgroundColor: Color(0xFFE4DFFD),
              valueColor: AlwaysStoppedAnimation(
                Color(0xFF8976DE),
              ),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '82% of goal',
            style: TextStyle(
              color: Color(0xFF8175B0),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F6EA),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF287B58).withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF31996B),
                  size: 17,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF31996B),
                size: 17,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'RECOVERY',
            style: TextStyle(
              color: Color(0xFF628D75),
              fontSize: 9,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Looking strong',
            style: TextStyle(
              color: Color(0xFF173E2B),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: List.generate(
              12,
              (index) => Expanded(
                child: Container(
                  height: index % 3 == 0 ? 15 : 9,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: index < 9
                        ? const Color(0xFF51AD7D)
                        : const Color(0xFFC6E5D0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DD),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD69A49).withValues(alpha: 0.17),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              color: Color(0xFFD58C32),
              size: 18,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'MOVEMENT',
            style: TextStyle(
              color: Color(0xFFB1844A),
              fontSize: 9,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            '6,840',
            style: TextStyle(
              color: Color(0xFF47351D),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'steps today',
            style: TextStyle(
              color: Color(0xFF9B7B50),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}