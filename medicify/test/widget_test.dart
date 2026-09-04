import 'package:flutter_test/flutter_test.dart';
import 'package:medicify/main.dart';

void main() {
  testWidgets('Medicify onboarding starts on language step', (tester) async {
    await tester.pumpWidget(const MedicifyApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('language'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
