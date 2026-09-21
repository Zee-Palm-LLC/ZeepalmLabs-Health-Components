import 'package:flutter/foundation.dart';

enum Author { me, aira }

class Message {
  Message(this.author, this.text, {double reveal = 1, this.thinking = false})
    : id = _next++,
      reveal = ValueNotifier(reveal);

  static int _next = 0;

  final int id;
  final Author author;
  final String text;
  final ValueNotifier<double> reveal;
  bool thinking;

  bool get mine => author == Author.me;
}

class Conversation extends ChangeNotifier {
  final List<Message> messages = [];
  bool working = false;

  void add(Message message) {
    messages.add(message);
    notifyListeners();
  }

  void setWorking(bool value) {
    if (working == value) return;
    working = value;
    notifyListeners();
  }

  void touch() => notifyListeners();

  void clear() {
    for (final message in messages) {
      message.reveal.dispose();
    }
    messages.clear();
    working = false;
    notifyListeners();
  }
}

abstract final class Script {
  static const voicePrompt = 'Deploy an autonomous AI agent to monitor liquidity pools. Make it a tactical trading bot.';
  static const voiceBubble = 'Deploy an autonomous AI agent to monitor liquidity pools';
  static const firstReply =
      'Deployed AlphaRaptor.sh to your agent network. The automation loop is active. Need to configure risk mitigation parameters?';
  static const followUp = 'Show me the active core parameters.';
  static const followUpReply = 'Core agent parameters initialized.';

  static const suggestions = [
    ('Deploy\nautonomous agent', 'Deploy an autonomous agent'),
    ('Optimize gas\nfor ZK-proofs', 'Optimize gas for ZK-proofs'),
    ('Audit lending\nprotocols', 'Audit lending protocols'),
    ('Backtest a\nmomentum strategy', 'Backtest a momentum strategy'),
  ];

  static const replies = {
    'Deploy an autonomous agent':
        'Spinning up a fresh agent on your network. Tell me what it should watch and I will wire the triggers.',
    'Optimize gas for ZK-proofs':
        'Batched proof verification and calldata compression cut estimated gas by 38%. Want me to open a pull request?',
    'Audit lending protocols':
        'Scanning 4 lending pools for oracle drift, reentrancy and liquidation edge cases. First report in about a minute.',
    'Backtest a momentum strategy':
        'Backtesting 90 days of hourly candles with a 20/50 crossover. Sharpe 1.84, max drawdown 7.2%.',
  };

  static const fallbackReplies = [
    'On it. I have queued that task and linked it to your active agent.',
    'Done. The change is live on your agent network and the automation loop picked it up.',
    'Got it. I will keep monitoring and ping you if anything drifts outside your limits.',
  ];

  static String replyFor(String prompt, int turn) {
    return replies[prompt] ?? fallbackReplies[turn % fallbackReplies.length];
  }
}
