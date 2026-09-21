import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class Frame {
  Frame(this.size, EdgeInsets padding)
    : top = math.max(padding.top, 20),
      bottom = padding.bottom;

  factory Frame.of(BuildContext context) {
    final media = MediaQuery.of(context);
    return Frame(media.size, media.viewPadding);
  }

  final Size size;
  final double top;
  final double bottom;

  double get width => size.width;
  double get height => size.height;
  double get midX => size.width / 2;

  double get headerY => top + 37;

  double get panelHeight => (height * 0.3427).clamp(236.0, 300.0);
  double get panelTop => height - panelHeight;
  double get cardsTop => panelTop - 142;
  double get headlineBaseline => cardsTop - 31;

  double get safeBottom => math.max(bottom, 12);

  double get dockY => height - safeBottom - 12 - 24;
  Offset get homeMic => Offset(width - 53, dockY);

  double get pillTop => top + 16;
  double get pillBottom => pillTop + 38;

  double get controlsY => height - safeBottom - 16 - 54;
  Offset get voiceMic => Offset(midX, controlsY);

  static const double orbFull = 220;
  static const double _voiceContent = 434.5;
  static const double _gapTopShare = 98 / 146.5;

  ({double orbTop, double orbSize}) get voiceStack {
    final ringTop = controlsY - 54;
    final free = ringTop - pillBottom - _voiceContent;
    if (free >= 80) {
      return (orbTop: pillBottom + free * _gapTopShare, orbSize: orbFull);
    }
    final shrink = math.min(80 - free, orbFull - 130);
    final size = orbFull - shrink;
    final content = _voiceContent - shrink;
    final gap = math.max(ringTop - pillBottom - content, 24.0);
    return (orbTop: pillBottom + gap * _gapTopShare, orbSize: size);
  }

  Offset get orbCentre {
    final stack = voiceStack;
    return Offset(midX, stack.orbTop + stack.orbSize / 2);
  }

  double get orbSize => voiceStack.orbSize;
  double get listeningY => voiceStack.orbTop + voiceStack.orbSize + 37;
  double get transcriptTop => listeningY + 61.5;

  double get chatListTop => pillBottom + 37;
  double get inputHeight => 58;
  double get inputBottom => safeBottom + 8;
  double get inputTop => height - inputBottom - inputHeight;
  Offset get chatMic => Offset(width - 51, inputTop + inputHeight / 2);
}
