import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:move_quest/app.dart';
import 'package:move_quest/core/motion.dart';
import 'package:move_quest/core/sprites.dart';
import 'package:move_quest/features/home_screen.dart';
import 'package:move_quest/features/onboarding_screen.dart';
import 'package:move_quest/features/route_screen.dart';
import 'package:move_quest/features/splash_screen.dart';

import 'fonts.dart';

const dir = String.fromEnvironment('SNAP_DIR');

Future<void> run(WidgetTester tester, int frames, [int ms = 34]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(Duration(milliseconds: ms));
  }
}

Future<void> warm(WidgetTester tester) async {
  final paths = [Scenes.splash, Scenes.path, Scenes.map, Scenes.river, for (final s in Art.all) s.asset];
  await tester.runAsync(() async {
    for (final p in paths) {
      final data = await rootBundle.load(p);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      await codec.getNextFrame();
    }
  });
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pump();
  }
}

Future<void> shoot(WidgetTester tester, String name) async {
  if (dir.isEmpty) return;
  await warm(tester);
  final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
  late ui.Image image;
  await tester.runAsync(() async {
    image = await boundary.toImage(pixelRatio: 3);
  });
  final bytes = await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.png));
  File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

Future<void> mount(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('shot'),
      child: MediaQuery.fromView(
        view: tester.view,
        child: MoveQuestApp(home: home),
      ),
    ),
  );
  await warm(tester);
}

void main() {
  setUp(() async {
    await loadCabin();
  });

  void phone(WidgetTester tester) {
    debugDisableShadows = false;
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.reset);
  }

  testWidgets('splash', (tester) async {
    phone(tester);
    Clock.frozen = true;
    await mount(tester, const SplashScreen());
    await run(tester, 12);
    await shoot(tester, 'splash_early');
    await run(tester, 40);
    await shoot(tester, 'splash_mid');
    await run(tester, 80);
    await shoot(tester, 'splash');
    Clock.frozen = false;
    debugDisableShadows = true;
  });

  testWidgets('onboarding', (tester) async {
    phone(tester);
    Clock.frozen = true;
    await mount(tester, const OnboardingScreen());
    await run(tester, 22);
    await shoot(tester, 'path_mid');
    await run(tester, 80);
    await shoot(tester, 'path');
    Clock.frozen = false;
    debugDisableShadows = true;
  });

  testWidgets('home', (tester) async {
    phone(tester);
    Clock.frozen = true;
    await mount(tester, const HomeScreen());
    await run(tester, 30);
    await shoot(tester, 'home_mid');
    await run(tester, 90);
    await shoot(tester, 'home');
    await tester.tap(find.text('Progress'));
    await run(tester, 7);
    await shoot(tester, 'nav_moving');
    await run(tester, 30);
    await shoot(tester, 'nav_progress');
    Clock.frozen = false;
    debugDisableShadows = true;
  });

  testWidgets('route', (tester) async {
    phone(tester);
    Clock.frozen = true;
    await mount(tester, const RouteScreen());
    await run(tester, 24);
    await shoot(tester, 'route_mid');
    await run(tester, 80);
    await shoot(tester, 'route');
    Clock.frozen = false;
    debugDisableShadows = true;
  });

  testWidgets('flow', (tester) async {
    phone(tester);
    await mount(tester, const SplashScreen());
    await run(tester, 110);
    await tester.tap(find.text('Tap to Begin'));
    await run(tester, 12);
    await shoot(tester, 'portal');
    await run(tester, 90);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await tester.tap(find.text('Next'));
    await run(tester, 14);
    await shoot(tester, 'descend');
    await run(tester, 100);
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.tap(find.text('Start Quest'));
    await run(tester, 10);
    await shoot(tester, 'expand');
    await run(tester, 90);
    expect(find.byType(RouteScreen), findsOneWidget);
    await tester.tap(find.text('Start Quest'));
    await run(tester, 18);
    await shoot(tester, 'launch');
    await run(tester, 80);
    expect(tester.takeException(), isNull);
    debugDisableShadows = true;
  });
}
