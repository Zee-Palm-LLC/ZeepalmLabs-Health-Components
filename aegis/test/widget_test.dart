import 'package:aegis/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Aegis app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AegisApp());
    await tester.pump();
    expect(find.text('Aegis'), findsWidgets);
  });
}
