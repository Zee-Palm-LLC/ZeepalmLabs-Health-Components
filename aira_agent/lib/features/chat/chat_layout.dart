import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/theme.dart';
import '../../data/conversation.dart';

TextStyle get bubbleStyle => inter(13.75, 400, color: const Color(0xFFF1F1F1), height: 19 / 13.75);
TextStyle get mineStyle => inter(13.75, 400, color: const Color(0xFFFFF4EC), height: 19 / 13.75);

class Slot {
  const Slot(this.message, this.bubble, this.avatar, this.textWidth, this.thinkingBubble);

  final Message message;
  final Rect bubble;
  final Rect? avatar;
  final double textWidth;
  final Rect? thinkingBubble;
}

class ChatLayout {
  ChatLayout(this.width, this.messages, {required this.working});

  final double width;
  final List<Message> messages;
  final bool working;

  static const double mineRight = 22;
  static const double minePadX = 15;
  static const double minePadY = 12;
  static const double mineMaxText = 214;
  static const double mineWrappedMin = 225;
  static const double airaLeft = 61;
  static const double airaPadX = 13;
  static const double airaPadY = 11;
  static const double airaMaxText = 246;
  static const double avatarLeft = 24;
  static const double avatar = 24;
  static const Size thinkingSize = Size(58, 41);

  late final List<Slot> slots = _build();
  late final double workingTop = (slots.isEmpty ? 0 : slots.last.bubble.bottom) + 16;
  double get contentBottom => working ? workingTop + 14 : (slots.isEmpty ? 0 : slots.last.bubble.bottom);

  List<Slot> _build() {
    final result = <Slot>[];
    var y = 0.0;
    var airaCount = 0;
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (i > 0) {
        final previous = messages[i - 1];
        if (previous.author == message.author) {
          y += 10;
        } else if (message.author == Author.aira) {
          y += airaCount == 0 ? 35 : 17;
        } else {
          y += 18;
        }
      }
      if (message.mine) {
        final measure = _measure(message.text, mineStyle, mineMaxText);
        final multi = measure.lines > 1;
        final bubbleWidth = multi ? math.max(measure.width + minePadX * 2, mineWrappedMin) : measure.width + minePadX * 2;
        final height = measure.height + minePadY * 2;
        final rect = Rect.fromLTWH(width - mineRight - bubbleWidth, y, bubbleWidth, height);
        result.add(Slot(message, rect, null, measure.width, null));
        y = rect.bottom;
      } else {
        airaCount++;
        final measure = _measure(message.text, bubbleStyle, airaMaxText);
        final multi = measure.lines > 1;
        final bubbleWidth = multi ? airaMaxText + airaPadX * 2 : measure.width + airaPadX * 2;
        final height = measure.height + airaPadY * 2;
        final rect = Rect.fromLTWH(airaLeft, y, bubbleWidth, height);
        final avatarRect = Rect.fromLTWH(avatarLeft, y, avatar, avatar);
        final thinking = Rect.fromLTWH(airaLeft, y, thinkingSize.width, thinkingSize.height);
        final shown = message.thinking ? thinking : rect;
        result.add(Slot(message, shown, avatarRect, multi ? airaMaxText : measure.width, thinking));
        y = shown.bottom;
      }
    }
    return result;
  }

  static final Map<String, ({double width, double height, int lines})> _cache = {};

  static ({double width, double height, int lines}) _measure(String text, TextStyle style, double max) {
    final key = '$max|${style.fontSize}|$text';
    final cached = _cache[key];
    if (cached != null) return cached;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    )..layout(maxWidth: max);
    final lines = painter.computeLineMetrics().length;
    final result = (width: painter.width.ceilToDouble(), height: painter.height, lines: lines);
    painter.dispose();
    _cache[key] = result;
    return result;
  }

  static Rect predictMine(double width, String text) {
    final measure = _measure(text, mineStyle, mineMaxText);
    final multi = measure.lines > 1;
    final bubbleWidth = multi ? math.max(measure.width + minePadX * 2, mineWrappedMin) : measure.width + minePadX * 2;
    return Rect.fromLTWH(width - mineRight - bubbleWidth, 0, bubbleWidth, measure.height + minePadY * 2);
  }
}
