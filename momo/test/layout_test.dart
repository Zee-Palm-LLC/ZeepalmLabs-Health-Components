import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momo/app.dart';
import 'package:momo/chat/chat_screen.dart';
import 'package:momo/chat/log_menu.dart';
import 'package:momo/core/diary.dart';

import 'support.dart';

void main() {
  const sizes = [
    (360.0, 640.0, 24.0, 0.0),
    (360.0, 740.0, 24.0, 16.0),
    (393.0, 852.0, 59.0, 34.0),
    (402.0, 874.0, 62.0, 34.0),
    (412.0, 915.0, 32.0, 48.0),
    (430.0, 932.0, 59.0, 34.0),
  ];
  for (final (w, h, top, bottom) in sizes) {
    testWidgets('full flow lays out at ${w.toInt()}x${h.toInt()}', (tester) async {
      await loadFonts();
      phone(tester, width: w, height: h, top: top, bottom: bottom);
      final script = ChatScript();
      await tester.pumpWidget(MomoApp(diary: Diary(now: DateTime(2026, 10, 4, 19, 30)), home: ChatScreen(script: script)));
      await run(tester, 70);
      script.state!.openMenu();
      await run(tester, 20);
      script.state!.pick(LogSource.sample);
      await run(tester, 30);
      script.state!.usePhoto();
      await run(tester, 110);
      await tester.tap(find.text('Dinner'));
      await run(tester, 120);
      script.state!.openCalendar();
      await run(tester, 50);
      script.state!.closeCalendar();
      await run(tester, 40);
      await tester.enterText(find.byType(TextField), 'how much protein');
      script.state!.send();
      await run(tester, 120);
      script.state!.startOver();
      await run(tester, 60);
      expect(tester.takeException(), isNull);
      done(tester);
    });
  }
}
