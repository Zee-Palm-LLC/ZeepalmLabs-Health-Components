import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class FloatingBottomNav extends StatefulWidget {
  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const double barHeight = 68;
  static const double outerBottom = 16;
  static const double horizontalInset = 28;
  static const double _indicatorSize = 50;
  static const double _innerPad = 8;

  static const _barColor = Color(0xFF1A1C22);
  static const _inactive = Color(0xFFD6D6D8);
  static const _activeIcon = Color(0xFF14151A);

  static const _pillSpring = SpringDescription(
    mass: 0.85,
    stiffness: 148,
    damping: 10.4,
  );

  static const items = <NavDest>[
    NavDest(icon: LucideIcons.house, label: 'Home'),
    NavDest(icon: LucideIcons.alarm_clock, label: 'Reminders'),
    NavDest(icon: LucideIcons.hourglass, label: 'Timer', tilt: -0.65),
    NavDest(icon: LucideIcons.chart_column, label: 'Stats'),
    NavDest(icon: LucideIcons.circle_user, label: 'Profile'),
  ];

  static double contentClearance(BuildContext context) {
    return barHeight +
        outerBottom +
        MediaQuery.paddingOf(context).bottom +
        16;
  }

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pill;

  @override
  void initState() {
    super.initState();
    _pill = AnimationController.unbounded(vsync: this)
      ..value = widget.currentIndex.toDouble();
  }

  @override
  void didUpdateWidget(FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _pill.animateWith(
        SpringSimulation(
          FloatingBottomNav._pillSpring,
          _pill.value,
          widget.currentIndex.toDouble(),
          _pill.velocity,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        FloatingBottomNav.horizontalInset,
        0,
        FloatingBottomNav.horizontalInset,
        FloatingBottomNav.outerBottom + bottom,
      ),
      child: Container(
        height: FloatingBottomNav.barHeight,
        decoration: BoxDecoration(
          color: FloatingBottomNav._barColor,
          borderRadius:
              BorderRadius.circular(FloatingBottomNav.barHeight / 2),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.38),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = (constraints.maxWidth -
                    FloatingBottomNav._innerPad * 2) /
                FloatingBottomNav.items.length;
            final top = (FloatingBottomNav.barHeight -
                    FloatingBottomNav._indicatorSize) /
                2;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _pill,
                  builder: (context, child) {
                    final index = _pill.value;
                    final left = FloatingBottomNav._innerPad +
                        slot * index +
                        (slot - FloatingBottomNav._indicatorSize) / 2;
                    final speed = _pill.velocity.abs();
                    final stretch =
                        (1 + (speed * 0.055).clamp(0.0, 0.22));
                    final squash =
                        (1 - (speed * 0.028).clamp(0.0, 0.12));

                    return Positioned(
                      left: left,
                      top: top,
                      child: Transform.scale(
                        scaleX: stretch,
                        scaleY: squash,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: FloatingBottomNav._indicatorSize,
                    height: FloatingBottomNav._indicatorSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE45A), Color(0xFFFFC107)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFFFC107).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FloatingBottomNav._innerPad,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < FloatingBottomNav.items.length; i++)
                        Expanded(
                          child: _NavIcon(
                            dest: FloatingBottomNav.items[i],
                            selected: widget.currentIndex == i,
                            onTap: () => widget.onChanged(i),
                            color: widget.currentIndex == i
                                ? FloatingBottomNav._activeIcon
                                : FloatingBottomNav._inactive,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NavDest {
  const NavDest({
    required this.icon,
    required this.label,
    this.tilt = 0,
  });

  final IconData icon;
  final String label;
  final double tilt;
}

class _NavIcon extends StatefulWidget {
  const _NavIcon({
    required this.dest,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  final NavDest dest;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon>
    with SingleTickerProviderStateMixin {
  static const _iconSpring = SpringDescription(
    mass: 0.7,
    stiffness: 260,
    damping: 11,
  );

  late final AnimationController _scale;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController.unbounded(vsync: this)
      ..value = widget.selected ? 1.08 : 1.0;
  }

  @override
  void didUpdateWidget(_NavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;

    _scale.animateWith(
      SpringSimulation(
        _iconSpring,
        _scale.value,
        widget.selected ? 1.08 : 1.0,
        widget.selected ? 6.5 : _scale.velocity,
      ),
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(
      widget.dest.icon,
      size: widget.selected ? 23 : 24,
      color: widget.color,
    );

    if (widget.dest.tilt != 0) {
      icon = Transform.rotate(angle: widget.dest.tilt, child: icon);
    }

    return Tooltip(
      message: widget.dest.label,
      child: InkWell(
        onTap: widget.onTap,
        customBorder: const CircleBorder(),
        splashColor: const Color(0xFFFFC107).withValues(alpha: 0.16),
        highlightColor: Colors.transparent,
        child: SizedBox.expand(
          child: Center(
            child: AnimatedBuilder(
              animation: _scale,
              builder: (context, child) {
                return Transform.scale(scale: _scale.value, child: child);
              },
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
