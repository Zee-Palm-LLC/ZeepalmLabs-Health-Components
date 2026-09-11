import 'package:body_signals/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Body Signals app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BodySignalsApp());
    await tester.pump();
    expect(find.text('Body Signals'), findsOneWidget);
  });
}
