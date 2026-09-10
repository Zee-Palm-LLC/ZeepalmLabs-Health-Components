import 'package:aegis/emergency/models.dart';
import 'package:aegis/emergency/preview_data.dart';
import 'package:aegis/emergency/responder_tracking_screen.dart';
import 'package:aegis/theme/aegis_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  const journey = Duration(seconds: 6);

  // "Arrived" is also a step in the timeline, so the headline is identified by
  // the status line that only ever accompanies it.
  final enRouteLine = find.text('Help is on the way. Stay calm.');
  final arrivedLine = find.text('Your responder is with you.');

  Future<int Function()> pumpTracking(
    WidgetTester tester, {
    bool autoAdvance = true,
  }) async {
    var arrivals = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAegisTheme(),
        home: ResponderTrackingScreen(
          dispatch: PreviewData.dispatch,
          journeyDuration: journey,
          autoAdvance: autoAdvance,
          onBack: () {},
          onArrived: () => arrivals++,
        ),
      ),
    );
    await tester.pump();
    return () => arrivals;
  }

  testWidgets('counts the ETA down as the responder travels', (tester) async {
    await pumpTracking(tester);

    // The fixture starts four minutes out.
    expect(find.text('4'), findsOneWidget);
    expect(find.text('minutes'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3500));
    // The numeral rolls over rather than cutting, so the outgoing digit is
    // briefly still mounted. Let that transition finish before asserting.
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text('4'),
      findsNothing,
      reason: 'the headline should have counted down by now',
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.text('minute'), findsOneWidget, reason: 'singular at one');
  });

  testWidgets('reaches arrived, then reports it once', (tester) async {
    final arrivals = await pumpTracking(tester);

    expect(enRouteLine, findsOneWidget);
    expect(arrivals(), 0);

    // Past the travel leg: the stage flips and the arrival beat begins.
    await tester.pump(const Duration(milliseconds: 5400));
    expect(arrivedLine, findsOneWidget);
    expect(arrivals(), 0, reason: 'the arrival beat has not finished yet');

    // Past the end of the journey.
    await tester.pump(const Duration(milliseconds: 900));
    expect(arrivals(), 1);

    await tester.pump(const Duration(seconds: 2));
    expect(arrivals(), 1, reason: 'arrival must not be announced twice');
  });

  testWidgets('holds still and never advances when told not to',
      (tester) async {
    final arrivals = await pumpTracking(tester, autoAdvance: false);

    await tester.pump(const Duration(seconds: 10));

    expect(arrivals(), 0);
    expect(arrivedLine, findsNothing);
    expect(enRouteLine, findsOneWidget);
    expect(find.text('4'), findsOneWidget, reason: 'ETA stays as given');
  });

  test('copyWith projects a dispatch forward and carries the rest across', () {
    final dispatch = PreviewData.dispatch;
    final halfway = dispatch.copyWith(
      eta: dispatch.eta * 0.5,
      distanceMeters: dispatch.distanceMeters * 0.5,
      stage: DispatchStage.arrived,
    );

    expect(halfway.eta, const Duration(minutes: 2));
    expect(halfway.distanceMeters, 900);
    expect(halfway.stage, DispatchStage.arrived);

    expect(halfway.route, dispatch.route);
    expect(halfway.responder, dispatch.responder);
    expect(halfway.alertSentAt, dispatch.alertSentAt);
    expect(halfway.waypoint, dispatch.waypoint);
  });
}
