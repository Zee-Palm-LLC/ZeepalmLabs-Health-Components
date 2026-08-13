import 'dart:ui';

class Organ {
  const Organ({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.system,
    required this.poetic,
    required this.accent,
    required this.description,
    this.hotspots = const [],
  });

  final String id;
  final String name;
  final String scientificName;
  final String system;
  final String poetic;
  final Color accent;
  final String description;
  final List<Hotspot> hotspots;

  String get thumb => 'assets/images/anatomy/$id/thumb.webp';
  String get model => 'assets/models/$id.glb';
}

class Hotspot {
  const Hotspot({
    required this.id,
    required this.label,
    required this.detail,
    required this.x,
    required this.y,
    required this.z,
    required this.color,
  });

  final String id;
  final String label;
  final String detail;
  final double x;
  final double y;
  final double z;
  final Color color;

  String get position => '$x $y $z';
}

class BodySystem {
  const BodySystem({required this.name, required this.organIds});

  final String name;
  final List<String> organIds;
}
