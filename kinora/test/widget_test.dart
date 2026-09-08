import 'package:flutter_test/flutter_test.dart';
import 'package:kinora/main.dart';

void main() {
  testWidgets('Kinora landing shows bottom nav', (WidgetTester tester) async {
    await tester.pumpWidget(const KinoraApp());
    await tester.pump();
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Meals'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
