import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momo/core/motion.dart';
import 'package:momo/mascot/momo.dart';

import 'support.dart';

void main() {
  testWidgets('mascot poses', (tester) async {
    await loadFonts();
    phone(tester, width: 760, height: 220);
    Widget cell(Mood mood, {double wave = 0, double squash = 0}) => SizedBox(width: 180, height: 200, child: Momo(mood: mood, wave: wave, squash: squash));
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('shot'),
        child: ClockHost(
          child: ColoredBox(
            color: const Color(0xFFF3F3F0),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [cell(Mood.idle), cell(Mood.think), cell(Mood.happy, wave: 1), cell(Mood.talk, squash: 0.08)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await shoot(tester, 'mascot', ratio: 3);
    done(tester);
  });
}
