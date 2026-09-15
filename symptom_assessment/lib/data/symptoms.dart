import 'package:flutter/foundation.dart';

/// How urgently a condition needs attention. Drives the pill, its colour and
/// the action card on the report.
enum Urgency { emergency, urgent, routine }

@immutable
class Symptom {
  const Symptom({
    required this.id,
    required this.name,
    this.hint,
    this.emoji,
    this.terms = const <String>[],
  });

  final String id;
  final String name;

  /// The greyed second line on a result tile, when the name needs one.
  final String? hint;

  /// Fluent 3D emoji asset name under `assets/emoji/`, when it has one.
  final String? emoji;

  /// Extra words a search should match against.
  final List<String> terms;

  String get emojiAsset => 'assets/emoji/$emoji.png';
}

@immutable
class Condition {
  const Condition({
    required this.name,
    required this.urgency,
    required this.summary,
  });

  final String name;
  final Urgency urgency;
  final String summary;
}

@immutable
class Assessment {
  const Assessment({
    required this.bestMatch,
    required this.lessLikely,
    required this.reported,
  });

  final Condition bestMatch;
  final List<Condition> lessLikely;
  final List<Symptom> reported;

  String get attentionLabel => switch (bestMatch.urgency) {
        Urgency.emergency => 'Needs immediate attention',
        Urgency.urgent => 'See a doctor soon',
        Urgency.routine => 'Usually manageable at home',
      };

  String get explanation => switch (bestMatch.urgency) {
        Urgency.emergency =>
          'If you think you have this condition, you should seek emergency '
              'care now. This is the best match and the safest approach to '
              'checking your reported symptoms.',
        Urgency.urgent =>
          'This is the best match for what you told us. It is not an '
              'emergency, but it should be looked at by a doctor within the '
              'next day or two.',
        Urgency.routine =>
          'This is the best match for what you told us. Most people can '
              'manage it at home, and it usually settles on its own.',
      };

  String get actionTitle => switch (bestMatch.urgency) {
        Urgency.emergency => 'Call an ambulance',
        Urgency.urgent => 'Book a doctor',
        Urgency.routine => 'Rest and monitor',
      };

  String get actionSub => switch (bestMatch.urgency) {
        Urgency.emergency => 'Seek emergency care immediately.',
        Urgency.urgent => 'A GP can confirm this and treat it.',
        Urgency.routine => 'Come back if it gets worse or lasts a week.',
      };

  String get actionEmoji => switch (bestMatch.urgency) {
        Urgency.emergency => 'ambulance',
        Urgency.urgent => 'stethoscope',
        Urgency.routine => 'sleeping_face',
      };
}

/// The catalogue. Small on purpose; it exists to drive the screens.
class Catalogue {
  Catalogue._();

  static const List<Symptom> popular = <Symptom>[
    Symptom(id: 'headache', name: 'Headache', emoji: 'brain',
        terms: <String>['head pain', 'migraine']),
    Symptom(id: 'runny-nose', name: 'Runny nose', emoji: 'nose',
        terms: <String>['nasal', 'cold', 'sniffles']),
    Symptom(id: 'sore-throat', name: 'Sore throat', emoji: 'mask_face',
        terms: <String>['throat pain', 'swallowing']),
    Symptom(id: 'fever', name: 'Fever', emoji: 'thermometer_face',
        terms: <String>['temperature', 'hot', 'chills']),
    Symptom(id: 'cough', name: 'Cough', emoji: 'lungs',
        terms: <String>['chest', 'dry cough', 'wet cough']),
    Symptom(id: 'fatigue', name: 'Fatigue', emoji: 'sleeping_face',
        terms: <String>['tired', 'exhausted', 'low energy']),
    Symptom(id: 'nausea', name: 'Nausea', emoji: 'nauseated_face',
        terms: <String>['sick', 'queasy', 'stomach']),
    Symptom(id: 'dizziness', name: 'Dizziness', emoji: 'spiral',
        terms: <String>['lightheaded', 'vertigo', 'spinning']),
    Symptom(id: 'chest-pain', name: 'Chest pain', emoji: 'heart',
        terms: <String>['tightness', 'pressure']),
    Symptom(id: 'toothache', name: 'Toothache', emoji: 'tooth',
        terms: <String>['tooth pain', 'dental']),
    Symptom(id: 'ear-pain', name: 'Ear pain', emoji: 'ear',
        terms: <String>['earache']),
    Symptom(id: 'eye-strain', name: 'Eye strain', emoji: 'eye',
        terms: <String>['blurry', 'vision']),
    Symptom(id: 'joint-pain', name: 'Joint pain', emoji: 'bone',
        terms: <String>['stiff', 'arthritis']),
    Symptom(id: 'rash', name: 'Skin rash', emoji: 'bandage',
        terms: <String>['itch', 'hives', 'red skin']),
  ];

  /// Everything searchable. Order matters: it is the tie-break when two
  /// entries match equally well, and it mirrors the reference results.
  static const List<Symptom> all = <Symptom>[
    Symptom(id: 'back-pain', name: 'Back pain',
        terms: <String>['spine', 'backache']),
    Symptom(id: 'lower-back-pain', name: 'Lower back pain',
        hint: 'Low back pain', terms: <String>['lumbar', 'spine']),
    Symptom(id: 'headache-back', name: 'Headache', hint: 'Back head pain',
        emoji: 'brain', terms: <String>['occipital', 'migraine']),
    Symptom(id: 'upper-back-pain', name: 'Upper back pain',
        terms: <String>['thoracic', 'shoulder blade']),
    Symptom(id: 'back-muscle', name: 'Muscle tenderness in the back',
        hint: 'Back muscle pain', terms: <String>['strain', 'sore']),
    Symptom(id: 'elbow-pain', name: 'Elbow pain', hint: 'Back of elbow pain',
        terms: <String>['tennis elbow', 'arm']),
    Symptom(id: 'knee-stiff', name: 'Knee stiffness after exercise',
        hint: 'Pain and tightness in the knee joint',
        terms: <String>['back of knee', 'joint']),
    Symptom(id: 'neck-pain', name: 'Neck pain', hint: 'Back of neck pain',
        terms: <String>['stiff neck', 'cervical']),
    Symptom(id: 'shoulder-pain', name: 'Shoulder pain',
        hint: 'Back of shoulder pain', terms: <String>['rotator cuff']),
    Symptom(id: 'sciatica', name: 'Pain down the back of the leg',
        hint: 'Sciatica', terms: <String>['nerve', 'buttock', 'leg']),
    ...popular,
    Symptom(id: 'stomach-ache', name: 'Stomach ache', hint: 'Abdominal pain',
        terms: <String>['belly', 'cramps', 'tummy']),
    Symptom(id: 'short-breath', name: 'Shortness of breath',
        hint: 'Trouble breathing', emoji: 'exhale',
        terms: <String>['wheeze', 'breathless']),
    Symptom(id: 'vomiting', name: 'Vomiting', emoji: 'vomiting',
        terms: <String>['throwing up', 'sick']),
    Symptom(id: 'sneezing', name: 'Sneezing', emoji: 'sneezing_face',
        terms: <String>['allergy', 'hay fever']),
    Symptom(id: 'chills', name: 'Chills', emoji: 'cold_face',
        terms: <String>['shivering', 'cold']),
    Symptom(id: 'sweats', name: 'Night sweats', emoji: 'hot_face',
        terms: <String>['sweating']),
    Symptom(id: 'anxiety', name: 'Feeling anxious', emoji: 'anxious',
        terms: <String>['panic', 'worry', 'stress']),
    Symptom(id: 'foot-pain', name: 'Foot pain', emoji: 'foot',
        terms: <String>['heel', 'arch']),
    Symptom(id: 'leg-pain', name: 'Leg pain', emoji: 'leg',
        terms: <String>['calf', 'thigh', 'cramp']),
    Symptom(id: 'mouth-ulcer', name: 'Mouth ulcer', emoji: 'mouth',
        terms: <String>['canker', 'sore']),
    Symptom(id: 'bleeding', name: 'Unexplained bleeding', emoji: 'blood',
        terms: <String>['blood']),
    Symptom(id: 'head-injury', name: 'Head injury', emoji: 'bandage_face',
        terms: <String>['bump', 'concussion']),
    Symptom(id: 'muscle-weak', name: 'Muscle weakness', emoji: 'muscle',
        terms: <String>['weak', 'heavy limbs']),
    Symptom(id: 'exhausted', name: 'Exhaustion', emoji: 'weary',
        terms: <String>['burnout', 'drained']),
    Symptom(id: 'tongue', name: 'Swollen tongue', emoji: 'tongue',
        terms: <String>['swelling', 'allergy']),
  ];

  /// Ranked search, in tiers: the whole phrase in the name, then every word
  /// in the name, then every word somewhere in name or hint, then anything
  /// that needed the hidden terms. Within a tier, catalogue order holds.
  /// Words are matched individually so "pain back" still finds "Back pain".
  static List<Symptom> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const <Symptom>[];
    final words = q.split(RegExp(r'\s+'));

    int score(Symptom s) {
      final name = s.name.toLowerCase();
      final hint = (s.hint ?? '').toLowerCase();
      final terms = s.terms.join(' ').toLowerCase();
      var tier = 3;
      for (final w in words) {
        if (name.contains(w)) {
          continue;
        } else if (hint.contains(w)) {
          tier = tier > 2 ? 2 : tier;
        } else if (terms.contains(w)) {
          tier = 1;
        } else {
          return 0;
        }
      }
      if (tier == 3 && name.contains(q)) tier = 4;
      if (name == q) tier = 5;
      return tier;
    }

    final scored = <(int, int, Symptom)>[];
    for (var i = 0; i < all.length; i++) {
      final sc = score(all[i]);
      if (sc > 0) scored.add((sc, i, all[i]));
    }
    scored.sort((a, b) {
      final byScore = b.$1.compareTo(a.$1);
      return byScore != 0 ? byScore : a.$2.compareTo(b.$2);
    });
    return <Symptom>[for (final e in scored) e.$3];
  }

  /// The report for a chosen symptom. Back-related symptoms escalate to the
  /// spine trauma case from the reference; everything else gets a plausible
  /// best match by family.
  static Assessment assess(Symptom chosen, {List<Symptom> also = const []}) {
    final id = chosen.id;
    final reported = <Symptom>[chosen, ...also.where((s) => s.id != id)];

    if (id.contains('back') || id == 'sciatica' || id == 'neck-pain') {
      return Assessment(
        bestMatch: const Condition(
          name: 'Thoracolumbar spine trauma',
          urgency: Urgency.emergency,
          summary: 'An injury to the middle or lower spine, usually after a '
              'fall or impact, that can involve the vertebrae or the nerves '
              'running through them.',
        ),
        lessLikely: const <Condition>[
          Condition(
              name: 'Lumbar muscle strain',
              urgency: Urgency.routine,
              summary: 'Overstretched back muscles after lifting or twisting.'),
          Condition(
              name: 'Herniated disc',
              urgency: Urgency.urgent,
              summary: 'A disc pressing on a nerve, often with leg pain.'),
          Condition(
              name: 'Kidney infection',
              urgency: Urgency.urgent,
              summary: 'Flank pain with fever and feeling unwell.'),
        ],
        reported: reported,
      );
    }

    if (id == 'chest-pain' || id == 'short-breath') {
      return Assessment(
        bestMatch: const Condition(
          name: 'Acute coronary syndrome',
          urgency: Urgency.emergency,
          summary: 'Reduced blood flow to the heart. Chest pressure, often '
              'with breathlessness, sweating or pain into the arm or jaw.',
        ),
        lessLikely: const <Condition>[
          Condition(
              name: 'Costochondritis',
              urgency: Urgency.routine,
              summary: 'Inflamed rib cartilage; sore to press on.'),
          Condition(
              name: 'Panic attack',
              urgency: Urgency.routine,
              summary: 'Sudden fear with a racing heart and tight chest.'),
          Condition(
              name: 'Acid reflux',
              urgency: Urgency.routine,
              summary: 'Burning behind the breastbone, worse lying down.'),
        ],
        reported: reported,
      );
    }

    if (id.startsWith('headache') || id == 'head-injury' || id == 'dizziness') {
      return Assessment(
        bestMatch: const Condition(
          name: 'Tension-type headache',
          urgency: Urgency.routine,
          summary: 'A dull, band-like ache around the head, often from '
              'stress, screens or poor sleep.',
        ),
        lessLikely: const <Condition>[
          Condition(
              name: 'Migraine',
              urgency: Urgency.urgent,
              summary: 'Throbbing one-sided pain with light sensitivity.'),
          Condition(
              name: 'Sinusitis',
              urgency: Urgency.routine,
              summary: 'Pressure behind the cheeks and forehead.'),
          Condition(
              name: 'Concussion',
              urgency: Urgency.urgent,
              summary: 'Headache after a knock, with fog or nausea.'),
        ],
        reported: reported,
      );
    }

    return Assessment(
      bestMatch: const Condition(
        name: 'Viral upper respiratory infection',
        urgency: Urgency.routine,
        summary: 'The common cold. A runny nose, sore throat and tiredness '
            'that clears within a week or so.',
      ),
      lessLikely: const <Condition>[
        Condition(
            name: 'Seasonal allergies',
            urgency: Urgency.routine,
            summary: 'Sneezing and itchy eyes that track the pollen count.'),
        Condition(
            name: 'Influenza',
            urgency: Urgency.urgent,
            summary: 'Sudden fever and aches that floor you.'),
        Condition(
            name: 'Strep throat',
            urgency: Urgency.urgent,
            summary: 'A very sore throat with fever and no cough.'),
      ],
      reported: reported,
    );
  }
}
