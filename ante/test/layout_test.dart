import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ante/features/create/create_pool_screen.dart';
import 'package:ante/features/home/home_screen.dart';
import 'package:ante/features/onboarding/onboarding_screen.dart';
import 'package:ante/features/pool/pool_screen.dart';

import 'support.dart';

void main() {
  setUpAll(loadFonts);

  const sizes = [
    (Size(360, 640), 24.0, 0.0),
    (Size(360, 740), 24.0, 16.0),
    (Size(393, 852), 59.0, 34.0),
    (Size(412, 915), 32.0, 24.0),
    (Size(430, 932), 59.0, 34.0),
  ];
  final screens = <String, Widget Function()>{
    'onboarding': () => const OnboardingScreen(),
    'home': () => const HomeScreen(),
    'create': () => const CreatePoolScreen(),
    'pool': () => const PoolScreen(),
  };

  for (final (size, top, bottom) in sizes) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        phone(tester, width: size.width, height: size.height, top: top, bottom: bottom);
        await tester.pumpWidget(AnteAppHost(home: entry.value()));
        for (var i = 0; i < 90; i++) {
          await tester.pump(const Duration(milliseconds: 40));
        }
        expect(tester.takeException(), isNull);
        done(tester);
      });
    }
  }
}
