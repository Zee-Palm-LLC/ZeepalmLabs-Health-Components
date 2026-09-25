import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ante/features/create/create_pool_screen.dart';
import 'package:ante/features/home/home_screen.dart';
import 'package:ante/features/onboarding/onboarding_screen.dart';
import 'package:ante/features/pool/pool_screen.dart';

import 'support.dart';

void main() {
  setUpAll(loadFonts);

  testWidgets('flow', (tester) async {
    phone(tester, height: 852, top: 59, bottom: 34);
    await mount(tester, const OnboardingScreen());
    await run(tester, 100);
    await tester.tap(find.text('Get Started'));
    await run(tester, 9);
    await shoot(tester, 'flow_reveal', ratio: 1);
    await run(tester, 60);
    expect(find.byType(HomeScreen), findsOneWidget);
    await shoot(tester, 'flow_home_in', ratio: 1);
    await run(tester, 60);
    await tester.tap(find.text('Run Club'));
    await run(tester, 8);
    await shoot(tester, 'flow_pool_lift', ratio: 1);
    await run(tester, 80);
    expect(find.byType(PoolScreen), findsOneWidget);
    await tester.tap(find.text('Check In'));
    await run(tester, 2);
    await shoot(tester, 'flow_flash', ratio: 1);
    await run(tester, 20);
    await shoot(tester, 'flow_checked', ratio: 1);
    await run(tester, 40);
    await shoot(tester, 'flow_checked_end', ratio: 1);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await run(tester, 6);
    await shoot(tester, 'flow_pool_back', ratio: 1);
    await run(tester, 40);
    expect(find.byType(PoolScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    done(tester);
  });

  testWidgets('create flow', (tester) async {
    phone(tester, height: 852, top: 59, bottom: 34);
    await mount(tester, const CreatePoolScreen());
    await run(tester, 90);
    await tester.tap(find.text('Gym'));
    await run(tester, 6);
    await shoot(tester, 'flow_habit_roll', ratio: 1);
    await run(tester, 20);
    expect(find.text('Run'), findsOneWidget);
    await tester.tap(find.text('50'));
    await run(tester, 8);
    await shoot(tester, 'flow_slider', ratio: 1);
    await run(tester, 30);
    await tester.tap(find.text('Create Pool').last);
    await run(tester, 30);
    await shoot(tester, 'flow_confetti', ratio: 1);
    await run(tester, 80);
    expect(find.byType(PoolScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    done(tester);
  });
}
