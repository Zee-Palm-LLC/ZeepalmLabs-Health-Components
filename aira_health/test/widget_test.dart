import 'package:aira_health/main.dart';
import 'package:aira_health/onboarding/components/primary_bg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Onboarding screen loads', (tester) async {
    await tester.pumpWidget(const AiraApp());
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Choose Your AI Health Assistant'), findsOneWidget);
    expect(find.text('Meet Aira Health'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.byType(PrimaryBg), findsOneWidget);
  });
}
