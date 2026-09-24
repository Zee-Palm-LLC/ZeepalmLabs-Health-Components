import 'package:fit_journey/app.dart';
import 'package:fit_journey/core/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

Future<void> boot(WidgetTester tester, Stage start, {Size size = const Size(393, 852), double top = 59, double bottom = 34}) async {
  await loadFonts();
  usePhone(tester, size: size, top: top, bottom: bottom);
  await tester.pumpWidget(stage(FitJourneyApp(start: start)));
  await precache(tester, Assets.all);
}

void main() {
  testWidgets('onboarding', (tester) async {
    debugDisableShadows = false;
    await boot(tester, Stage.onboarding);
    await step(tester, 3000);
    await shoot(tester, 'onb_rest', ratio: 2);
    await tester.tap(find.text('Next'));
    await step(tester, 380);
    await shoot(tester, 'onb_flip_a', ratio: 2);
    await step(tester, 250);
    await shoot(tester, 'onb_flip_b', ratio: 2);
    await step(tester, 1200);
    await shoot(tester, 'onb_page2', ratio: 2);
    debugDisableShadows = true;
  });

  testWidgets('home', (tester) async {
    debugDisableShadows = false;
    await boot(tester, Stage.home);
    await step(tester, 500);
    await shoot(tester, 'home_0500', ratio: 2);
    await step(tester, 500);
    await shoot(tester, 'home_1000', ratio: 2);
    await step(tester, 2400);
    await shoot(tester, 'home_rest', ratio: 2);
    await tester.tapAt(const Offset(199.3, 792.7));
    await step(tester, 700);
    await shoot(tester, 'home_quick', ratio: 2);
    await tester.tapAt(const Offset(40, 300));
    await step(tester, 600);
    await tester.tap(find.text('View Route'));
    await step(tester, 300);
    await shoot(tester, 'route_morph', ratio: 2);
    await step(tester, 900);
    await shoot(tester, 'route_draw', ratio: 2);
    await step(tester, 3000);
    await shoot(tester, 'route_rest', ratio: 2);
    await tester.tap(find.text('Start Journey'));
    await step(tester, 5000);
    await shoot(tester, 'route_journey', ratio: 2);
    await tester.tapAt(const Offset(41.5, 76.5));
    await step(tester, 1200);
    await shoot(tester, 'route_back', ratio: 2);
    debugDisableShadows = true;
  });

  testWidgets('flow from splash', (tester) async {
    debugDisableShadows = false;
    await boot(tester, Stage.splash);
    await step(tester, 3200);
    await shoot(tester, 'flow_splash', ratio: 1);
    await step(tester, 1500);
    await step(tester, 450);
    await shoot(tester, 'flow_portal', ratio: 1);
    await step(tester, 2600);
    await shoot(tester, 'flow_onb', ratio: 1);
    await tester.tap(find.text('Skip'), warnIfMissed: false);
    await step(tester, 420);
    await shoot(tester, 'flow_bloom_a', ratio: 1);
    await step(tester, 450);
    await shoot(tester, 'flow_bloom_b', ratio: 1);
    await step(tester, 3000);
    await shoot(tester, 'flow_home', ratio: 1);
    debugDisableShadows = true;
  });

  for (final size in const [Size(360, 640), Size(360, 740), Size(412, 915)]) {
    testWidgets('fits ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      await boot(tester, Stage.home, size: size, top: 24, bottom: 16);
      await step(tester, 3000);
      expect(tester.takeException(), isNull);
      await tester.drag(find.text('Recommended For You'), const Offset(0, -300));
      await step(tester, 900);
      await tester.tap(find.text('View Route'));
      await step(tester, 4000);
      expect(tester.takeException(), isNull);
      await shoot(tester, 'fit_${size.width.toInt()}x${size.height.toInt()}');
    });
  }

  testWidgets('bottom inset', (tester) async {
    debugDisableShadows = false;
    await boot(tester, Stage.onboarding, size: const Size(393, 873), top: 24, bottom: 48);
    await step(tester, 3000);
    await shoot(tester, 'inset_onb');
    await tester.tap(find.text('Skip'), warnIfMissed: false);
    await step(tester, 4000);
    await shoot(tester, 'inset_home');
    await tester.tapAt(const Offset(199.3, 793));
    await step(tester, 800);
    await shoot(tester, 'inset_quick');
    await tester.tapAt(const Offset(40, 300));
    await step(tester, 700);
    await tester.tap(find.text('View Route'));
    await step(tester, 4000);
    await shoot(tester, 'inset_route');
    expect(tester.takeException(), isNull);
    debugDisableShadows = true;
  });
}
