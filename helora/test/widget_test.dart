import 'package:flutter_test/flutter_test.dart';
import 'package:helora/main.dart';

void main() {
  testWidgets('Portra onboarding loads', (tester) async {
    await tester.pumpWidget(const HeloraApp());
    expect(find.text('Helora'), findsWidgets);
    expect(find.text('Get Started'), findsWidgets);
  });
}
