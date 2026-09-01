import 'package:vital_heart/core/controllers/heart_controller.dart';
import 'package:vital_heart/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Heart rate screen loads', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      Get.reset();
    });

    await tester.pumpWidget(const VitalHeartApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Heart Rate'), findsOneWidget);
    expect(find.text('BPM'), findsOneWidget);
    expect(find.text('Measuring pulse...'), findsOneWidget);

    await Get.delete<HeartController>(force: true);
  });
}
