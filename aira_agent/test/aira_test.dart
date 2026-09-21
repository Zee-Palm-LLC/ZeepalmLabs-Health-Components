import 'dart:io';

import 'package:aira_agent/data/conversation.dart';
import 'package:aira_agent/main.dart';
import 'package:aira_agent/scene/frame.dart';
import 'package:aira_agent/scene/stage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadFonts() async {
  final loader = FontLoader('Inter')
    ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Inter-Variable.ttf').readAsBytesSync())));
  await loader.load();
}

Future<void> settle(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<StageState> launch(WidgetTester tester, {Size size = const Size(393, 852)}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const AiraApp(simulateDevice: true));
  await settle(tester, 2400);
  expect(tester.takeException(), isNull);
  return tester.state<StageState>(find.byType(Stage));
}

void main() {
  setUpAll(loadFonts);

  testWidgets('home shows the design copy', (tester) async {
    await launch(tester);
    expect(find.text('Roobinium,'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('What '), findsOneWidget);
    expect(find.text('today?'), findsOneWidget);
    expect(find.text('Deploy\nautonomous agent'), findsOneWidget);
    expect(find.text('Opus 4.8'), findsOneWidget);
    expect(find.text('Ask AI a question or describe your idea'), findsOneWidget);
  });

  testWidgets('voice flow listens, sends and lands in the design chat', (tester) async {
    final stage = await launch(tester);
    final frame = Frame(const Size(393, 852), const EdgeInsets.only(top: 59, bottom: 34));
    await tester.tapAt(frame.homeMic);
    await settle(tester, 1200);
    expect(stage.scene, Scene.voice);
    expect(find.text('Aira is listening...'), findsOneWidget);
    expect(find.text('Close chat'), findsOneWidget);

    await settle(tester, 9000);
    expect(stage.scene, Scene.chat);
    expect(find.text(Script.voiceBubble), findsOneWidget);

    await settle(tester, 16000);
    expect(find.text(Script.firstReply), findsOneWidget);
    expect(find.text(Script.followUp), findsOneWidget);
    expect(find.text(Script.followUpReply), findsOneWidget);
    expect(find.text('Aira is working...'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pause stops the transcript and the send button jumps to chat', (tester) async {
    final stage = await launch(tester);
    stage.go(Scene.voice);
    await settle(tester, 1600);
    stage.director.paused.value = true;
    await settle(tester, 300);
    final heard = stage.director.heard.value;
    await settle(tester, 1500);
    expect(stage.director.heard.value, heard);
    expect(find.text('Paused'), findsOneWidget);
    stage.director.sendVoice();
    await settle(tester, 1600);
    expect(stage.scene, Scene.chat);
  });

  testWidgets('suggestion card opens a chat with its prompt and reply', (tester) async {
    final stage = await launch(tester);
    await tester.tap(find.text('Optimize gas\nfor ZK-proofs'));
    await settle(tester, 1400);
    expect(stage.scene, Scene.chat);
    expect(find.text('Optimize gas for ZK-proofs'), findsOneWidget);
    await settle(tester, 6000);
    expect(find.text(Script.replies['Optimize gas for ZK-proofs']!), findsOneWidget);
    await tester.tap(find.text('Close chat'));
    await settle(tester, 1200);
    expect(stage.scene, Scene.home);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing on home sends a message, typing in chat replies', (tester) async {
    final stage = await launch(tester);
    await tester.enterText(find.byType(TextField), 'Watch ETH gas');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await settle(tester, 1400);
    expect(stage.scene, Scene.chat);
    expect(find.text('Watch ETH gas'), findsOneWidget);
    await settle(tester, 6000);
    await tester.enterText(find.byType(TextField), 'Thanks');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await settle(tester, 6000);
    expect(find.text('Thanks'), findsOneWidget);
    expect(stage.director.conversation.messages.length, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu opens history, model picker switches model', (tester) async {
    final stage = await launch(tester);
    final frame = Frame(const Size(393, 852), const EdgeInsets.only(top: 59, bottom: 34));
    await tester.tap(find.text('Opus 4.8'));
    await settle(tester, 600);
    await tester.tap(find.text('Sonnet 4.8'));
    await settle(tester, 600);
    expect(find.text('Sonnet 4.8'), findsOneWidget);

    await tester.tapAt(Offset(393 - 35.5, frame.headerY));
    await settle(tester, 600);
    expect(find.text('Recent chats'), findsOneWidget);
    await tester.tap(find.text('Liquidity pool monitor'));
    await settle(tester, 1600);
    expect(stage.scene, Scene.chat);
    expect(find.text(Script.followUpReply), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(360, 640), Size(360, 740), Size(393, 852), Size(412, 915)]) {
    testWidgets('every scene fits ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      final stage = await launch(tester, size: size);
      final frame = Frame(size, const EdgeInsets.only(top: 59, bottom: 34));
      expect(frame.homeMic.dy + 24, lessThanOrEqualTo(size.height));
      expect(frame.cardsTop, greaterThan(frame.headerY + 20));

      stage.go(Scene.voice);
      await settle(tester, 1600);
      expect(tester.takeException(), isNull);
      final stack = frame.voiceStack;
      expect(stack.orbTop, greaterThan(frame.pillBottom));
      expect(frame.transcriptTop + 116, lessThan(frame.controlsY - 54));

      stage.director.sendVoice();
      await settle(tester, 12000);
      expect(tester.takeException(), isNull);
      expect(frame.inputTop + frame.inputHeight, lessThanOrEqualTo(size.height));

      stage.go(Scene.home);
      await settle(tester, 1400);
      expect(tester.takeException(), isNull);
    });
  }
}
