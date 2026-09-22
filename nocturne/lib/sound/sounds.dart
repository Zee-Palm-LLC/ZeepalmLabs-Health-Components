import 'package:flutter/painting.dart';

enum Category { all, nature, home, whiteNoise, asmr }

extension CategoryLabel on Category {
  String get label => switch (this) {
    Category.all => 'All',
    Category.nature => 'Nature',
    Category.home => 'Home',
    Category.whiteNoise => 'White Noise',
    Category.asmr => 'ASMR',
  };
}

enum Sound {
  rain(
    'Rain',
    0,
    Color(0xFF071A5C),
    Color(0xFF2560E6),
    Color(0xFFA9D2FF),
    Color(0xFF3F7BFF),
    {Category.nature, Category.home, Category.whiteNoise},
    'rain on the glass, soft and steady',
  ),
  waves(
    'Waves',
    1,
    Color(0xFF053247),
    Color(0xFF1FB0CF),
    Color(0xFFDDFBFF),
    Color(0xFF2FD0E8),
    {Category.nature, Category.whiteNoise},
    'slow swells on a moonlit shore',
  ),
  fire(
    'Fire',
    2,
    Color(0xFF3B0D03),
    Color(0xFFE2600F),
    Color(0xFFFFD07A),
    Color(0xFFFF8A2A),
    {Category.home, Category.asmr},
    'a hearth that crackles and settles',
  ),
  wind(
    'Wind',
    3,
    Color(0xFF5B5FB5),
    Color(0xFFB8BEF6),
    Color(0xFFFFFFFF),
    Color(0xFFB7A6FF),
    {Category.nature, Category.whiteNoise},
    'high air moving through pines',
  ),
  forest(
    'Forest',
    4,
    Color(0xFF042A1D),
    Color(0xFF1E8A5B),
    Color(0xFFB6FFD6),
    Color(0xFF3FD690),
    {Category.nature},
    'leaves, distant birds, deep green hush',
  ),
  night(
    'Night',
    5,
    Color(0xFF190A4C),
    Color(0xFF6A3BE0),
    Color(0xFFDCC6FF),
    Color(0xFF8A5BFF),
    {Category.home, Category.asmr},
    'a low warm hum under the stars',
  ),
  stream(
    'Stream',
    6,
    Color(0xFF06205C),
    Color(0xFF2E7BE6),
    Color(0xFFE6F4FF),
    Color(0xFF4C98FF),
    {Category.nature, Category.whiteNoise, Category.asmr},
    'water over stones, close and bright',
  ),
  crickets(
    'Crickets',
    7,
    Color(0xFF3A2704),
    Color(0xFFC89530),
    Color(0xFFFFEFB5),
    Color(0xFFFFC34D),
    {Category.nature, Category.asmr},
    'a meadow chorus after dusk',
  ),
  thunder(
    'Thunder',
    8,
    Color(0xFF0C0D17),
    Color(0xFF3B3E54),
    Color(0xFFF1F3FF),
    Color(0xFF9EA6C8),
    {Category.nature},
    'far rolling storms, safe indoors',
  );

  const Sound(
    this.label,
    this.kind,
    this.deep,
    this.mid,
    this.hi,
    this.glow,
    this.categories,
    this.mood,
  );

  Color get tint => switch (this) {
    Sound.rain => const Color(0xFF2A6BFF),
    Sound.waves => const Color(0xFF1FD2EE),
    Sound.fire => const Color(0xFFFF7424),
    Sound.wind => const Color(0xFF9A6BFF),
    Sound.forest => const Color(0xFF2ED68A),
    Sound.night => const Color(0xFF7446FF),
    Sound.stream => const Color(0xFF3A9DFF),
    Sound.crickets => const Color(0xFFFFB636),
    Sound.thunder => const Color(0xFF8B95C8),
  };

  final String label;
  final int kind;
  final Color deep;
  final Color mid;
  final Color hi;
  final Color glow;
  final Set<Category> categories;
  final String mood;

  String get asset => 'audio/$name.wav';

  bool matches(Category category, String query) {
    final inCategory =
        category == Category.all || categories.contains(category);
    if (!inCategory) return false;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (label.toLowerCase().contains(q) || mood.contains(q)) return true;
    return categories.any((c) => c.label.toLowerCase().contains(q));
  }
}

class Mix {
  const Mix({
    required this.name,
    required this.sounds,
    required this.volumes,
    this.saved = false,
  });

  final String name;
  final List<Sound> sounds;
  final Map<Sound, double> volumes;
  final bool saved;

  String get subtitle => sounds.map((s) => s.label).join('  ·  ');

  Mix copyWith({
    String? name,
    List<Sound>? sounds,
    Map<Sound, double>? volumes,
    bool? saved,
  }) => Mix(
    name: name ?? this.name,
    sounds: sounds ?? this.sounds,
    volumes: volumes ?? this.volumes,
    saved: saved ?? this.saved,
  );
}

const presetMixes = <Mix>[
  Mix(
    name: 'My Peace Mix',
    sounds: [Sound.rain, Sound.fire, Sound.waves, Sound.wind],
    volumes: {
      Sound.rain: 0.72,
      Sound.fire: 0.6,
      Sound.waves: 0.66,
      Sound.wind: 0.5,
    },
    saved: true,
  ),
  Mix(
    name: 'Midnight Forest',
    sounds: [Sound.forest, Sound.crickets, Sound.stream],
    volumes: {Sound.forest: 0.7, Sound.crickets: 0.45, Sound.stream: 0.55},
    saved: true,
  ),
  Mix(
    name: 'Storm Shelter',
    sounds: [Sound.rain, Sound.thunder, Sound.fire],
    volumes: {Sound.rain: 0.8, Sound.thunder: 0.55, Sound.fire: 0.4},
    saved: true,
  ),
  Mix(
    name: 'Starlit Shore',
    sounds: [Sound.waves, Sound.night, Sound.wind],
    volumes: {Sound.waves: 0.75, Sound.night: 0.5, Sound.wind: 0.35},
    saved: true,
  ),
];
