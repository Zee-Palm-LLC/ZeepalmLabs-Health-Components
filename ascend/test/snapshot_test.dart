import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/app.dart';
import 'package:ascend/core/motion.dart';
import 'package:ascend/onboarding/onboarding.dart';

import 'support.dart';

void main() {
  testWidgets('onboarding snapshots', (tester) async {
    await loadFonts();
    phone(tester);
    Clock.frozen = true;
    final script = OnboardingScript();
    await tester.pumpWidget(RepaintBoundary(key: const ValueKey('shot'), child: AscendApp(home: Onboarding(script: script))));
    await warm(tester);
    await run(tester, 12);
    await shoot(tester, 'a_intro', settle: false);
    await run(tester, 90);
    await shoot(tester, 'p1');
    script.state!.next();
    await run(tester, 8);
    await shoot(tester, 'a_slide', settle: false);
    await run(tester, 80);
    await shoot(tester, 'p2');
    script.state!.next();
    await run(tester, 20);
    await shoot(tester, 'a_rise', settle: false);
    await run(tester, 70);
    await shoot(tester, 'p3');
    script.state!.signIn('Apple');
    await run(tester, 20);
    await shoot(tester, 'p3_toast', settle: false);
    await run(tester, 80);
    expect(tester.takeException(), isNull);
    Clock.frozen = false;
    done(tester);
  });
}
