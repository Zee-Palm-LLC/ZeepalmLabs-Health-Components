import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animated_profile_ui/app.dart';
import 'package:animated_profile_ui/screens/profile/widgets/profile_avatar.dart';

void main() {
  testWidgets('shows avatar before reveal', (tester) async {
    await tester.pumpWidget(const AnimatedProfileApp());

    expect(find.byType(ProfileAvatar), findsOneWidget);
    expect(find.text('Dr. Sarah Mitchell'), findsOneWidget);
    expect(find.text('Book Appointment'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reveals profile when avatar is tapped', (tester) async {
    await tester.pumpWidget(const AnimatedProfileApp());

    await tester.tap(find.byType(ProfileAvatar));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1900));

    expect(find.text('Dr. Sarah Mitchell'), findsOneWidget);
    expect(find.text('Cardiologist • MD, FACC'), findsOneWidget);
    expect(find.text('City Heart Institute'), findsOneWidget);
    expect(find.text('AVAILABLE NOW'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('books an appointment', (tester) async {
    await tester.pumpWidget(const AnimatedProfileApp());

    await tester.tap(find.byType(ProfileAvatar));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1900));

    await tester.ensureVisible(find.text('Book Appointment'));
    await tester.tap(find.text('Book Appointment'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Booked'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
