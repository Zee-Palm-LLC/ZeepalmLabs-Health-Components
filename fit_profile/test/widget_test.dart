import 'package:fit_profile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Profile setup loads gender step', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FitProfileApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Tell Us About Yourself!'), findsOneWidget);
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('Others'), findsOneWidget);
  });
}
