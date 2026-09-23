import 'dart:math' as math;

enum Depth { surface, personal, honest, raw }

extension DepthLabel on Depth {
  String get label => switch (this) {
    Depth.surface => 'Surface',
    Depth.personal => 'Personal',
    Depth.honest => 'Honest',
    Depth.raw => 'Raw',
  };
}

const prompts = <Depth, List<String>>{
  Depth.surface: [
    'What made today feel like today ?',
    'Which small thing went better than expected ?',
    'What did you notice on the way home ?',
    'What is the last thing that made you laugh ?',
    'What did your hands do today ?',
  ],
  Depth.personal: [
    "Three things you're grateful for today ?",
    'What were you protecting when you said no ?',
    'Who did you think about but never told ?',
    'What would you do without fear ?',
    'What do you wish you did earlier ?',
    'When were you last proud ?',
  ],
  Depth.honest: [
    'What are you pretending not to know ?',
    'Where did you abandon yourself today ?',
    'What makes you feel alive ?',
    'Are you where you wanted to be ?',
    'What would you say if nobody replied ?',
  ],
  Depth.raw: [
    'What still hurts when nobody is looking ?',
    'What are you afraid people would see ?',
    'What have you not forgiven yourself for ?',
    'What would you write if this was burned after ?',
  ],
};

const teaserCards = [
  'When were you last proud?',
  'What would you do without fear?',
  'What do you wish you did earlier?',
  'What makes you feel alive?',
  'Are you where you wanted to be?',
];

class PromptDeck {
  PromptDeck([int? seed]) : _rand = math.Random(seed ?? 7);

  final math.Random _rand;
  Depth depth = Depth.personal;
  int _index = 0;

  String get current => prompts[depth]![_index % prompts[depth]!.length];

  String roll() {
    final pool = prompts[depth]!;
    if (pool.length > 1) {
      var next = _index;
      while (next == _index) {
        next = _rand.nextInt(pool.length);
      }
      _index = next;
    }
    return current;
  }

  void setDepth(Depth value) {
    depth = value;
    _index = _rand.nextInt(prompts[value]!.length);
  }
}
