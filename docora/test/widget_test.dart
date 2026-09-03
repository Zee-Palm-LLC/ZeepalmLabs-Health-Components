
import 'package:docora/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  Future<void> pumpDocora(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const TickerMode(
        enabled: false,
        child: DocoraApp(),
      ),
    );
    await tester.pump();
  }

  testWidgets('Docora home renders greeting and sections', (tester) async {
    await pumpDocora(tester);

    expect(find.text('Hey, Good Morning'), findsOneWidget);
    expect(find.text('Muhammad Farhan'), findsOneWidget);
    expect(find.text('Upcoming Appointment'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Doctor detail screen opens with simple navigation', (tester) async {
    await pumpDocora(tester);

    await tester.pumpAndSettle();

    expect(find.text('Doctor Information'), findsOneWidget);
    expect(find.text('Book Now'), findsOneWidget);
    expect(find.text('Starting From \$120/session'), findsOneWidget);
  });
}
