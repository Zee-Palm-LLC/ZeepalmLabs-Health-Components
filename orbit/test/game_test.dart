import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/app.dart';
import 'package:orbit/game/run_game.dart';
import 'package:orbit/game/run_page.dart';

import 'support.dart';

void main() {
  testWidgets('runner gameplay frames', (tester) async {
    await loadFonts();
    phone(tester);
    final game = RunGame(seed: 3);
    await tester.pumpWidget(RepaintBoundary(key: const ValueKey('shot'), child: OrbitApp(home: RunPage(game: game, onExit: () {}))));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await warm(tester);
    await run(tester, 30);
    await shoot(tester, 'game_ready', settle: false);
    await run(tester, 80);
    await shoot(tester, 'game_go', settle: false);
    var shot = 0;
    for (var f = 0; f < 600; f++) {
      if (f % 45 == 10) game.moveLane(f % 90 == 10 ? -1 : 1);
      if (f % 30 == 0) game.jump();
      if (f == 300) game.stats.boost.value = 1;
      if (f == 302) game.fireBoost();
      await tester.pump(const Duration(milliseconds: 33));
      if (f % 75 == 40) await shoot(tester, 'game_${shot++}', settle: false);
    }
    game.stats.lives.value = 1;
    for (var f = 0; f < 400 && game.stats.phase.value != Phase.over; f++) {
      await tester.pump(const Duration(milliseconds: 33));
    }
    await run(tester, 110);
    await shoot(tester, 'game_over', settle: false);
    expect(tester.takeException(), isNull);
    debugPrint('meters ${game.stats.meters.value} coins ${game.stats.coins.value} lives ${game.stats.lives.value} phase ${game.stats.phase.value}');
    await tester.pumpWidget(const SizedBox());
    done(tester);
  });
}
