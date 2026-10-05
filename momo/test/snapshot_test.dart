import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momo/app.dart';
import 'package:momo/chat/chat_screen.dart';
import 'package:momo/chat/log_menu.dart';
import 'package:momo/core/diary.dart';
import 'package:momo/core/motion.dart';

import 'support.dart';

void main() {
  testWidgets('flow snapshots', (tester) async {
    await loadFonts();
    phone(tester);
    Clock.frozen = true;
    final script = ChatScript();
    final diary = Diary(now: DateTime(2026, 10, 4, 19, 30));
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('shot'),
        child: MomoApp(diary: diary, home: ChatScreen(script: script)),
      ),
    );
    await warm(tester);
    await run(tester, 90);
    await shoot(tester, '01_home');

    script.state!.openMenu();
    await run(tester, 30);
    await shoot(tester, '02_menu');

    script.state!.pick(LogSource.camera);
    await run(tester, 40);
    await shoot(tester, '03_camera');

    script.state!.shutter();
    await run(tester, 30);
    await shoot(tester, '04_review');

    script.state!.usePhoto();
    await run(tester, 12);
    await shoot(tester, '05_flight', settle: false);
    await run(tester, 30);
    await shoot(tester, '06_typing');
    await run(tester, 70);
    await shoot(tester, '07_dinner');

    await tester.tap(find.text('Dinner'));
    await run(tester, 30);
    await shoot(tester, '08_analyzing');
    await run(tester, 140);
    await shoot(tester, '09_result');

    script.state!.openCalendar();
    await run(tester, 80);
    await shoot(tester, '10_calendar');

    await tester.tapAt(const Offset(307.5, 302.7));
    await run(tester, 70);
    await shoot(tester, '11_september');

    await tester.tapAt(const Offset(107.1, 574));
    await run(tester, 70);
    await shoot(tester, '12_sep29');

    script.state!.closeCalendar();
    await run(tester, 40);
    await tester.enterText(find.byType(TextField), 'how much protein');
    await run(tester, 10);
    await shoot(tester, '13_typed');
    script.state!.send();
    await run(tester, 160);
    await shoot(tester, '14_answer');

    expect(tester.takeException(), isNull);
    Clock.frozen = false;
    done(tester);
  });
}
