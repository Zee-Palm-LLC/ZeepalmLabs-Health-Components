import 'package:flutter_test/flutter_test.dart';
import 'package:lull_moods/home.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('home renders and switch steps mood', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LullHome())));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('88'), findsOneWidget);
    await tester.tapAt(const Offset(195, 474));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('RESILIENCE'), findsOneWidget);
  });
}
