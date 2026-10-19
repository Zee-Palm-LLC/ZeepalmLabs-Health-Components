import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/app.dart';
import 'package:orbit/core/motion.dart';
import 'package:orbit/screens/world_screen.dart';

import 'support.dart';

void main() {
  testWidgets('short phone render', (tester) async {
    await loadFonts();
    phone(tester, width: 360, height: 640, top: 24, bottom: 0);
    Clock.frozen = true;
    await tester.pumpWidget(RepaintBoundary(key: const ValueKey('shot'), child: OrbitApp(home: WorldScreen(onOpen: (_) {}))));
    await warm(tester);
    await run(tester, 90);
    await shoot(tester, 'short_world');
    done(tester);
  });
}
