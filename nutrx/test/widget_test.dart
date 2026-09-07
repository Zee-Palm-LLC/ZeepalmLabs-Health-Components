import 'package:flutter_test/flutter_test.dart';
import 'package:nutrx/main.dart';

void main() {
  testWidgets('Progress timer screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const NutrxApp());
    await tester.pump();

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Find your workout'), findsOneWidget);
  });
}
