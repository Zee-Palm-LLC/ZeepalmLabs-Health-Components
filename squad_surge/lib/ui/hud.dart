import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/surge_game.dart';

TextStyle lilita(double size, {Color color = Colors.white, double ls = 0, List<Shadow>? shadows}) =>
    GoogleFonts.lilitaOne(fontSize: size, color: color, letterSpacing: ls, height: 1.05, shadows: shadows);

const _ink = [Shadow(color: Color(0x99000000), offset: Offset(0, 3), blurRadius: 0)];

/// The 390 × 844 game screen: the Flame world, drag-to-steer anywhere, and
/// the Flutter HUD (level, coins, progress, boss bar, start/win/lose cards).
class SurgeScreen extends StatefulWidget {
  const SurgeScreen({super.key, this.game});
  final SurgeGame? game;

  @override
  State<SurgeScreen> createState() => _SurgeScreenState();
}

class _SurgeScreenState extends State<SurgeScreen> {
  late final SurgeGame game = widget.game ?? SurgeGame();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 390,
        height: 844,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) => game.start(),
          onPanUpdate: (d) => game.steer(d.delta.dx),
          onTapUp: (_) => game.start(),
          child: Stack(
            children: [
              Positioned.fill(child: GameWidget(game: game)),
              Positioned.fill(
                child: ValueListenableBuilder<int>(
                  valueListenable: game.hud,
                  builder: (context, _, _) => _Hud(game: game, onRestart: () => setState(game.restart)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.game, required this.onRestart});
  final SurgeGame game;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final g = game;
    final since = g.clock - g.endAt;
    return Stack(
      children: [
        // Top bar.
        Positioned(
          left: 16,
          right: 16,
          top: 50,
          child: Row(
            children: [
              _Pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Coin(size: 20),
                    const SizedBox(width: 6),
                    Text('${g.coins}', style: lilita(18, shadows: _ink)),
                  ],
                ),
              ),
              const Spacer(),
              _Pill(
                child: Text('LEVEL ${g.level}', style: lilita(18, shadows: _ink, ls: 0.5)),
              ),
              const Spacer(),
              const _Pill(child: Icon(Icons.settings_rounded, color: Colors.white, size: 20)),
            ],
          ),
        ),
        // Progress to the boss, or the boss's health.
        Positioned(
          left: 46,
          right: 46,
          top: 100,
          child: g.bossHealth != null ? _BossBar(value: g.bossHealth!) : _Progress(value: g.progress),
        ),
        if (g.phase == Phase.ready) _StartCard(clock: g.clock),
        if (g.phase == Phase.won && since > 0.9) _WinCard(k: ((since - 0.9) / 0.6).clamp(0.0, 1.0), coins: g.coins),
        if (g.phase == Phase.lost && since > 0.6) _LoseCard(onRetry: onRestart),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    height: 38,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0x8C0B2A4A),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
    ),
    child: child,
  );
}

class _Coin extends StatelessWidget {
  const _Coin({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const RadialGradient(colors: [Color(0xFFFFE680), Color(0xFFF5A623)], center: Alignment(-0.3, -0.4)),
      border: Border.all(color: const Color(0xFFC77800), width: 1.5),
    ),
    child: Center(
      child: Text('\$', style: lilita(size * 0.6, color: const Color(0xFFB36B00))),
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 22,
    child: Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0x660B2A4A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
          ),
        ),
        FractionallySizedBox(
          widthFactor: math.max(0.04, value),
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7CF3A0), Color(0xFF2CC46B)]),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            '💀',
            style: TextStyle(fontSize: 18, fontFamilyFallback: ['Segoe UI Emoji', 'Apple Color Emoji', 'Noto Color Emoji']),
          ),
        ),
      ],
    ),
  );
}

class _BossBar extends StatelessWidget {
  const _BossBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'BOSS',
        style: lilita(16, color: const Color(0xFFFF5A5A), shadows: _ink, ls: 2),
      ),
      const SizedBox(height: 4),
      Container(
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xAA2A0A0F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF7A6B), Color(0xFFD3182B)]),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _StartCard extends StatelessWidget {
  const _StartCard({required this.clock});
  final double clock;

  @override
  Widget build(BuildContext context) {
    final swing = math.sin(clock * 3.2) * 70;
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 190,
          child: Column(
            children: [
              Text('SQUAD', style: lilita(62, shadows: _ink, ls: 2).copyWith(height: 0.9)),
              Text(
                'SURGE',
                style: lilita(62, color: const Color(0xFFFFD54F), shadows: _ink, ls: 2).copyWith(height: 0.9),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 120,
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(swing, 0),
                child: const Icon(Icons.touch_app_rounded, size: 64, color: Colors.white, shadows: _ink),
              ),
              const SizedBox(height: 10),
              Text('HOLD & DRAG TO STEER', style: lilita(20, shadows: _ink, ls: 1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WinCard extends StatelessWidget {
  const _WinCard({required this.k, required this.coins});
  final double k;
  final int coins;

  @override
  Widget build(BuildContext context) {
    final pop = Curves.easeOutBack.transform(k);
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35 * k),
        child: Center(
          child: Transform.scale(
            scale: 0.6 + 0.4 * pop,
            child: Opacity(
              opacity: k,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Transform.translate(
                          offset: Offset(0, i == 1 ? -14 : 0),
                          child: Icon(Icons.star_rounded, size: i == 1 ? 78 : 62, color: const Color(0xFFFFD54F), shadows: _ink),
                        ),
                    ],
                  ),
                  Text(
                    'VICTORY!',
                    style: lilita(58, color: const Color(0xFFFFE066), shadows: _ink, ls: 1),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _Coin(size: 28),
                      const SizedBox(width: 8),
                      Text('+250', style: lilita(30, shadows: _ink)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7CF3A0), Color(0xFF22B45E)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [BoxShadow(color: Color(0x66000000), offset: Offset(0, 6))],
                    ),
                    child: Text('NEXT LEVEL', style: lilita(24, shadows: _ink, ls: 1)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoseCard extends StatelessWidget {
  const _LoseCard({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0x99000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SQUAD DOWN',
              style: lilita(48, color: const Color(0xFFFF6B6B), shadows: _ink),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E9BFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Text('TRY AGAIN', style: lilita(24, shadows: _ink)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
