enum Speaker { user, helper }

class ChatMessage {
  ChatMessage(this.speaker, this.text) : id = _next++;

  static int _next = 0;

  final Speaker speaker;
  final String text;
  final int id;
}

class Topic {
  const Topic(this.label, this.emoji, this.question);

  final String label;
  final String emoji;
  final String question;
}

abstract final class AssistantBrain {
  static const topics = [
    Topic('Painkillers', 'assets/emoji/brain.png', 'How should I take painkillers safely?'),
    Topic('Antibiotics', '', 'Any tips for my Amoxicillin course?'),
    Topic('Cardio', 'assets/emoji/heart.png', 'When should I take Amlodipine?'),
  ];

  static const suggestions = ['Generate summary', 'Are they a good fit for me?', 'I missed a dose'];

  static const voicePrompt = 'When should I take Amlodipine?';

  static String reply(String question) {
    final q = question.toLowerCase();
    if (q.contains('summary')) {
      return 'Here is today so far: Omeprazole and Metformin are done. Amlodipine 5mg is next at 10:00 AM before meals, then Amoxicillin at 2:00 PM and Vitamin D with dinner. You are on a 12 day streak.';
    }
    if (q.contains('missed') || q.contains('forgot')) {
      return 'Take it as soon as you remember, unless your next dose is less than 4 hours away. In that case skip it and carry on as normal. Never take two doses at once.';
    }
    if (q.contains('fit') || q.contains('together') || q.contains('interaction')) {
      return 'Your current list has no known interactions. Amlodipine, Amoxicillin and Vitamin D are safe together. Check with your doctor before adding anything new.';
    }
    if (q.contains('painkiller') || q.contains('pain')) {
      return 'Take painkillers with food and a full glass of water. Leave at least 6 hours between ibuprofen doses, and do not mix two products with the same ingredient.';
    }
    if (q.contains('antibiotic') || q.contains('amoxicillin')) {
      return 'Amoxicillin works best at even intervals, every 8 hours. Finish the whole course even when you feel better. I have set reminders for 6:00, 14:00 and 22:00.';
    }
    if (q.contains('amlodipine') || q.contains('cardio') || q.contains('heart') || q.contains('blood')) {
      return 'Take Amlodipine 5mg once a day at the same time. Your reminder is set for 10:00 AM, before meals. Stand up slowly if you feel light headed.';
    }
    if (q.contains('hello') || q.contains('hi')) {
      return 'Hi Robert! Ask me about any medicine in your cabinet, or say "summary" to see your day.';
    }
    return 'Good question. Based on your plan, keep taking each dose at the reminder time. For anything about changing a dose, your doctor or pharmacist should confirm first.';
  }
}
