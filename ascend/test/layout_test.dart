import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/app.dart';
import 'package:ascend/onboarding/onboarding.dart';

import 'support.dart';

void main() {
  const sizes = [(360.0, 640.0, 24.0, 0.0), (360.0, 740.0, 24.0, 16.0), (393.0, 852.0, 59.0, 34.0), (402.0, 874.0, 62.0, 34.0), (430.0, 932.0, 59.0, 34.0)];
  for (final (w, h, top, bottom) in sizes) {
    testWidgets('onboarding lays out at ${w.toInt()}x${h.toInt()}', (tester) async {
      await loadFonts();
      phone(tester, width: w, height: h, top: top, bottom: bottom);
      final script = OnboardingScript();
      await tester.pumpWidget(AscendApp(home: Onboarding(script: script)));
      await run(tester, 80);
      await tester.tap(find.text('Continue'));
      await run(tester, 70);
      await tester.tap(find.text('Continue'));
      await run(tester, 70);
      await tester.tap(find.text('Continue with Google'));
      await run(tester, 80);
      script.state!.back();
      await run(tester, 40);
      script.state!.back();
      await run(tester, 40);
      expect(tester.takeException(), isNull);
      done(tester);
    });
  }
}
