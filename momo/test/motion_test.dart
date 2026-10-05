import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momo/app.dart';
import 'package:momo/chat/chat_screen.dart';
import 'package:momo/chat/log_menu.dart';
import 'package:momo/core/diary.dart';

import 'support.dart';

void main() {
  testWidgets('motion strips', (tester) async {
    await loadFonts();
    phone(tester);
    final script = ChatScript();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('shot'),
        child: MomoApp(diary: Diary(now: DateTime(2026, 10, 4, 19, 30)), home: ChatScreen(script: script)),
      ),
    );
    await warm(tester);
    Future<void> strip(String name, int frames, {int ms = 50}) async {
      for (var i = 0; i < frames; i++) {
        await tester.pump(Duration(milliseconds: ms));
        await shoot(tester, '${name}_${i.toString().padLeft(2, '0')}', ratio: 1, settle: false);
      }
    }

    await strip('a_intro', 24, ms: 80);
    await run(tester, 30);
    script.state!.openMenu();
    await strip('b_menu', 12);
    script.state!.pick(LogSource.camera);
    await strip('c_camera', 16);
    await run(tester, 20);
    script.state!.shutter();
    await strip('d_shutter', 12);
    await run(tester, 20);
    script.state!.usePhoto();
    await strip('e_flight', 24);
    await strip('f_card', 32, ms: 70);
    await run(tester, 20);
    await tester.tap(find.text('Dinner'));
    await strip('g_pick', 40, ms: 90);
    await run(tester, 40);
    script.state!.openCalendar();
    await strip('h_calendar', 20);
    await run(tester, 30);
    await tester.tapAt(const Offset(307.5, 302.7));
    await strip('i_month', 16);
    await run(tester, 30);
    await tester.tapAt(const Offset(107.1, 574));
    await strip('j_day', 16);
    await run(tester, 30);
    script.state!.closeCalendar();
    await strip('k_close', 16);
    await run(tester, 20);
    await tester.enterText(find.byType(TextField), 'how much protein');
    await run(tester, 5);
    script.state!.send();
    await strip('l_send', 40, ms: 80);
    expect(tester.takeException(), isNull);
    done(tester);
  });
}
