import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:healthscan_ai/core/controllers/scan_controller.dart';
import 'package:healthscan_ai/main.dart';

void main() {
  testWidgets('Dashboard screen loads', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      Get.reset();
    });

    await tester.pumpWidget(const HealthScanApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('September 1st - 30th, 2026'), findsOneWidget);
    expect(find.text('All Systems Good'), findsOneWidget);
    expect(find.text('AI Health Score'), findsOneWidget);
    expect(find.text('Vital Signs'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);

    await Get.delete<ScanController>(force: true);
  });
}
