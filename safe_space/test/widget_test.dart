import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_space/app.dart';

void main() {
  testWidgets('Onboarding screen renders core copy', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SafeSpaceApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('safe space'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Advance past delayed float timers so nothing is pending on dispose.
    await tester.pump(const Duration(milliseconds: 600));
  });
}
