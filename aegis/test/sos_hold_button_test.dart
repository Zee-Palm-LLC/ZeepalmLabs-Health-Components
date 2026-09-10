import 'package:aegis/emergency/widgets/sos_hold_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The button breathes while idle, so there is never a settled frame to wait
  // for. Every test below pumps a known duration instead of calling
  // pumpAndSettle, which would time out.
  Future<int Function()> pumpButton(
    WidgetTester tester, {
    bool reduceMotion = false,
  }) async {
    var activations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          // Copies the ambient data rather than replacing it, so the view
          // keeps its real size.
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reduceMotion,
            ),
            child: Scaffold(
              body: Center(
                child: SosHoldButton(onActivated: () => activations++),
              ),
            ),
          ),
        ),
      ),
    );
    return () => activations;
  }

  // The hold controller's clock starts on the first frame pumped after the
  // touch, so every wait below is measured from here and given a little margin
  // rather than landing exactly on a boundary.
  Future<TestGesture> press(WidgetTester tester) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('SOS')),
    );
    await tester.pump(const Duration(milliseconds: 200));
    return gesture;
  }

  /// Comfortably past a full three-second hold.
  const pastFullHold = Duration(milliseconds: 3100);

  testWidgets('activates after a full three-second hold', (tester) async {
    final activations = await pumpButton(tester);

    final gesture = await press(tester);
    await tester.pump(pastFullHold);
    expect(activations(), 1);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 600));
    expect(activations(), 1, reason: 'releasing must not fire a second alert');
  });

  testWidgets('does not activate when released early', (tester) async {
    final activations = await pumpButton(tester);

    final gesture = await press(tester);
    await tester.pump(const Duration(seconds: 2));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 600));

    expect(activations(), 0);
  });

  testWidgets('counts the hold down on the face, then restores the label',
      (tester) async {
    await pumpButton(tester);
    expect(find.text('HOLD'), findsOneWidget);

    final gesture = await press(tester);
    expect(find.text('3'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('2'), findsOneWidget);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('HOLD'), findsOneWidget);
  });

  testWidgets('still activates with animations disabled', (tester) async {
    final activations = await pumpButton(tester, reduceMotion: true);

    final gesture = await press(tester);
    await tester.pump(pastFullHold);
    await gesture.up();

    expect(activations(), 1);
  });

  testWidgets('sizes the face from the given diameter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SosHoldButton(onActivated: _noop, size: 200),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(SosHoldButton)), const Size(200, 200));
  });
}

void _noop() {}
