import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/design.dart';
import '../../core/palette.dart';
import 'innur_mark.dart';

/// The launch screen.
///
/// The mark draws itself, the wordmark follows it in, and the whole thing hands
/// over on its own. [onDone] fires once — the caller decides what that means.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pen;
  bool _handedOver = false;

  /// Held so it can be cancelled. A bare Future.delayed would still fire
  /// after the splash was torn down, calling back into a dead widget.
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _pen = AnimationController(vsync: this, duration: D.draw)
      ..addStatusListener(_onStatus);
    _pen.forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _handedOver) return;
    _handedOver = true;
    _holdTimer = Timer(D.hold, () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _pen.removeStatusListener(_onStatus);
    _pen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: Ground.splash),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: D.w,
            height: D.h,
            child: AnimatedBuilder(
              animation: _pen,
              builder: (context, _) {
                final t = _pen.value;
                final word = D.wordmarkIn.transform(t);

                return Stack(
                  children: <Widget>[
                    Positioned(
                      left: (D.w - 168) / 2,
                      top: 378,
                      child: InnurMark(size: 168, progress: t),
                    ),
                    Positioned(
                      left: 0,
                      top: 574,
                      width: D.w,
                      child: Opacity(
                        opacity: word.clamp(0.0, 1.0),
                        child: Transform.translate(
                          // Rises the last few units as it arrives, so it
                          // settles under the mark rather than blinking on.
                          offset: Offset(0, (1 - word) * 10),
                          child: const Text(
                            'innur',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 42,
                              height: 1.1,
                              // The reference sets the wordmark wide and light
                              // against the heavy mark above it.
                              letterSpacing: 3.2,
                              color: Paper.primary,
                              fontVariations: <FontVariation>[
                                FontVariation('wght', 500),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
