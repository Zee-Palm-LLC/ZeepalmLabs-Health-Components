import 'package:aegis/emergency/arrival_screen.dart';
import 'package:aegis/emergency/preview_data.dart';
import 'package:aegis/emergency/responder_tracking_screen.dart';
import 'package:aegis/emergency/sos_home_screen.dart';
import 'package:aegis/theme/aegis_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_fonts.dart';

const _devices = {
  'iPhone 15 Pro': Size(393, 852),
  'iPhone SE': Size(375, 667),
};

final _screens = <String, WidgetBuilder>{
  'home': (_) => SosHomeScreen(
        heartRate: PreviewData.elevatedHeartRate,
        location: PreviewData.location,
        contacts: PreviewData.contacts,
        onAlertActivated: () {},
      ),
  'home without data': (_) => SosHomeScreen(
        heartRate: null,
        location: null,
        contacts: const [],
        onAlertActivated: () {},
      ),
  'tracking': (_) => ResponderTrackingScreen(
        dispatch: PreviewData.dispatch,
        onBack: () {},
      ),
  'arrival': (_) => ArrivalScreen(
        heartRate: PreviewData.stableHeartRate,
        notifiedContacts: PreviewData.notifiedContacts,
        onClose: () {},
      ),
};

void main() {
  setUpAll(loadAppFonts);

  for (final device in _devices.entries) {
    for (final screen in _screens.entries) {
      testWidgets('${screen.key} lays out on ${device.key}', (tester) async {
        tester.view
          ..physicalSize = device.value * 3
          ..devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAegisTheme(),
            home: Builder(builder: screen.value),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
