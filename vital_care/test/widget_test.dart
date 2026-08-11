import 'package:flutter_test/flutter_test.dart';
import 'package:vital_care/main.dart';

void main() {
  testWidgets('App loads dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Keep Moving Today!'), findsOneWidget);
    expect(find.text('Hi, Diana Soe'), findsOneWidget);
  });
}
