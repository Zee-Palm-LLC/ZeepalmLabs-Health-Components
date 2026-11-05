import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'candle.dart';

TextStyle inter(double size, {Color color = const Color(0xFFF3E9DA), FontWeight w = FontWeight.w400, double ls = 0, double height = 1.2}) =>
    GoogleFonts.inter(fontSize: size, color: color, fontWeight: w, letterSpacing: ls, height: height);

const _cream = Color(0xFFF1DEC2);
const _muted = Color(0xFF8C7F72);

/// Ember: a focus timer where a candle burns down with the session. When
/// time is up the flame goes out in a curl of smoke; Reset grows a fresh
/// candle and relights it.
class FocusScreen extends StatefulWidget {
  /// Long-press the timer to toggle a ×60 demo speed.
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => FocusScreenState();
}

class FocusScreenState extends State<FocusScreen> with SingleTickerProviderStateMixin {
  static const total = 25 * 60.0;

  late final Ticker _ticker = createTicker(_tick);
  Duration? _last;
  double t = 0;
  double remaining = total;
  bool running = false, done = false;
  double _demo = 1;

  double? _outAt, _relightAt, _resetAt;
  double _fromH = 1, _warmFrom = 1;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration e) {
    final dt = _last == null ? 0.0 : (e - _last!).inMicroseconds / 1e6;
    _last = e;
    setState(() {
      t += dt;
      if (running) {
        remaining -= dt * _demo;
        if (remaining <= 0) {
          remaining = 0;
          running = false;
          done = true;
          _outAt = t;
          HapticFeedback.mediumImpact();
        }
      }
    });
  }

  void toggle() {
    if (done) return;
    HapticFeedback.selectionClick();
    setState(() => running = !running);
  }

  void reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _fromH = _height;
      _resetAt = t;
      if (done) {
        _warmFrom = _warm;
        _relightAt = t + 0.55;
      }
      remaining = total;
      running = false;
      done = false;
    });
  }

  // ── Derived animation values ──
  bool get _isOut => _outAt != null && (_relightAt == null || _relightAt! < _outAt! || t < _relightAt!);

  double get _flame {
    if (_isOut) return (1 - (t - _outAt!) / 0.22).clamp(0.0, 1.0);
    if (_relightAt != null && t >= _relightAt!) return Curves.easeOutBack.transform(((t - _relightAt!) / 0.6).clamp(0.0, 1.0));
    return 1;
  }

  double get _warm {
    if (_isOut) return 1 - Curves.easeInOut.transform(((t - _outAt!) / 1.8).clamp(0.0, 1.0));
    if (_relightAt != null && t >= _relightAt!) {
      return _warmFrom + (1 - _warmFrom) * Curves.easeOut.transform(((t - _relightAt!) / 1.1).clamp(0.0, 1.0));
    }
    return 1;
  }

  double get _height {
    final target = remaining / total;
    if (_resetAt != null && t - _resetAt! < 1.0) {
      return _fromH + (target - _fromH) * Curves.easeOutBack.transform(((t - _resetAt!) / 0.9).clamp(0.0, 1.0));
    }
    return target;
  }

  @override
  Widget build(BuildContext context) {
    final state = CandleState(
      t: t,
      height: _height,
      burn: 1 - _height,
      flame: _flame,
      warm: _warm,
      smokeAge: _outAt == null || (_relightAt != null && _relightAt! > _outAt! && t > _relightAt! + 0.3) ? -1 : t - _outAt!,
      sparkAge: _relightAt == null || t < _relightAt! ? -1 : t - _relightAt!,
    );
    final secs = remaining.ceil();
    final time = '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';
    final label = done
        ? 'Session complete · take a short break'
        : running
            ? 'Focus · ends at 10:25'
            : remaining < total
                ? 'Paused · $time left'
                : '25 min · tap start to light your focus';

    return SizedBox(
      width: 390,
      height: 844,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(children: [
          Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: CandlePainter(state)))),
          const Positioned(left: 0, right: 0, top: 0, child: _StatusBar()),
          Positioned(
            left: 28,
            right: 28,
            top: 104,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EMBER', style: inter(11.5, color: const Color(0xFFE39A5C), w: FontWeight.w700, ls: 2.4)),
              const SizedBox(height: 8),
              Text('Deep work', style: inter(28, w: FontWeight.w600, ls: -0.6)),
              const SizedBox(height: 6),
              Text('Draft the launch notes · session 3 of 4', style: inter(13.5, color: _muted)),
            ]),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: tableTop + 52,
            child: GestureDetector(
              onLongPress: () => setState(() => _demo = _demo == 1 ? 60 : 1),
              child: Column(children: [
                _RollingTime(time, dim: done),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(label, key: ValueKey(label.split('·').first), style: inter(13, color: _muted)),
                ),
              ]),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 52,
            child: Row(children: [
              Expanded(
                child: _Pill(
                  onTap: toggle,
                  dark: true,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                      done ? Icons.check_rounded : (running ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      size: 18,
                      color: _cream,
                    ),
                    const SizedBox(width: 6),
                    Text(done ? 'Complete' : (running ? 'Pause' : 'Start'), style: inter(15, color: _cream, w: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Pill(
                  onTap: reset,
                  dark: false,
                  child: Text('Reset', style: inter(15, color: const Color(0xFF2A1C10), w: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// mm:ss in thin numerals; each digit rolls up when it changes.
class _RollingTime extends StatelessWidget {
  const _RollingTime(this.text, {required this.dim});
  final String text;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final style = inter(66, w: FontWeight.w200, ls: 1, height: 1).copyWith(
      color: dim ? const Color(0xFFA79A8C) : const Color(0xFFF6EBDC),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < text.length; i++)
        text[i] == ':'
            ? Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(':', style: style))
            : ClipRect(
                child: SizedBox(
                  width: 40,
                  height: 70,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 170),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) {
                      final incoming = child.key == ValueKey('$i${text[i]}');
                      return SlideTransition(
                        position: anim.drive(Tween(begin: Offset(0, incoming ? 0.7 : -0.7), end: Offset.zero)),
                        child: FadeTransition(opacity: anim, child: child),
                      );
                    },
                    child: Center(key: ValueKey('$i${text[i]}'), child: Text(text[i], style: style)),
                  ),
                ),
              ),
    ]);
  }
}

class _Pill extends StatefulWidget {
  const _Pill({required this.child, required this.onTap, required this.dark});
  final Widget child;
  final VoidCallback onTap;
  final bool dark;

  @override
  State<_Pill> createState() => _PillState();
}

class _PillState extends State<_Pill> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.dark ? const Color(0xFF1E1915) : _cream,
            borderRadius: BorderRadius.circular(27),
            border: Border.all(color: widget.dark ? const Color(0xFF2E2620) : const Color(0xFFFFF0DA)),
            boxShadow: widget.dark
                ? const []
                : [BoxShadow(color: const Color(0xFFFFB86B).withValues(alpha: 0.28), blurRadius: 22, offset: const Offset(0, 6))],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(34, 16, 26, 0),
        child: Row(children: [
          Text('9:41', style: inter(16, w: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          const Icon(Icons.signal_cellular_alt_rounded, size: 18, color: Colors.white),
          const SizedBox(width: 4),
          const Icon(Icons.wifi_rounded, size: 18, color: Colors.white),
          const SizedBox(width: 4),
          const RotatedBox(quarterTurns: 1, child: Icon(Icons.battery_full_rounded, size: 20, color: Colors.white)),
        ]),
      );
}
