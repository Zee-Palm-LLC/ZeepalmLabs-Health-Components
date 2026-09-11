import 'package:flutter_test/flutter_test.dart';
import 'package:nouriva/main.dart';

void main() {
  testWidgets('Nouriva boots into onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      NourivaApp(videosReady: Future<void>.value()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Skip'), findsOneWidget);
  });
}
