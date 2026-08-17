import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:fitonist/app.dart';

void main() {
  setUp(() => Get.testMode = true);

  tearDown(Get.reset);

  testWidgets('Onboarding renders fitonist branding', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const TickerMode(
        enabled: false,
        child: FitonistApp(),
      ),
    );
    await tester.pump();

    expect(find.text('fitonist'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Gym workout generator'), findsOneWidget);
  });

  testWidgets('Get started navigates to About You', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const TickerMode(
        enabled: false,
        child: FitonistApp(),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('About You'), findsOneWidget);
    expect(find.text('What is your name?'), findsOneWidget);
    expect(Get.currentRoute, '/about-you');
  });
}
