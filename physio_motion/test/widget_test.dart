import 'package:flutter_test/flutter_test.dart';
import 'package:physio_motion/main.dart';

void main() {
  testWidgets('Welcome screen renders', (tester) async {
    await tester.pumpWidget(const PhysioMotionApp());
    await tester.pump();

    expect(find.text('PhysioMotion'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('MOVE'), findsOneWidget);
    expect(find.text('STRONGER'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
  });
}
