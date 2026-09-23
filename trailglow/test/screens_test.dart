import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:trailglow/app/app.dart';
import 'package:trailglow/app/routes/app_routes.dart';
import 'package:trailglow/services/map_support.dart';

import 'render_harness.dart';

const List<Size> phones = <Size>[
  Size(393, 852),
  Size(360, 740),
  Size(360, 640),
  Size(430, 932),
];

Future<void> boot(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const TrailglowApp());
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 1400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    MapSupport.override = false;
    await loadAppFonts();
  });

  tearDown(Get.reset);

  for (final size in phones) {
    testWidgets('every screen lays out at ${size.width}x${size.height}', (
      tester,
    ) async {
      await boot(tester, size);
      expect(tester.takeException(), isNull, reason: 'pre-run');

      Get.toNamed<void>(Routes.liveRun);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(tester.takeException(), isNull, reason: 'live run');

      Get.offNamed<void>(Routes.summary);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1800));
      expect(tester.takeException(), isNull, reason: 'summary');

      await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: 'summary scrolled');

      Get.offNamed<void>(Routes.lifetime);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      expect(tester.takeException(), isNull, reason: 'lifetime');
    });
  }

  testWidgets('heatmap range switching stays clean', (tester) async {
    await boot(tester, const Size(393, 852));
    Get.toNamed<void>(Routes.lifetime);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));

    for (final label in <String>['WEEK', 'MONTH', 'YEAR', 'ALL']) {
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull, reason: 'range $label');
    }
  });
}
