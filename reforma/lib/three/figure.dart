import 'dart:math' as math;
import 'dart:ui';

import 'mesh.dart';
import 'vec.dart';

/// Body regions. A vertex's region id is `base | side << 5`
/// (side 0 = centre, 1 = figure's left / +x, 2 = figure's right / −x).
abstract final class Region {
  static const head = 1, neck = 2, shoulder = 3, upperArm = 4, elbow = 5, forearm = 6, wrist = 7, hand = 8;
  static const chest = 9, upperBack = 10, abdomen = 11, lowerBack = 12, hip = 13;
  static const thigh = 14, knee = 15, calf = 16, ankle = 17, foot = 18;

  static const names = <int, String>{
    head: 'Head', neck: 'Neck', shoulder: 'Shoulder', upperArm: 'Upper arm', elbow: 'Elbow', forearm: 'Forearm',
    wrist: 'Wrist', hand: 'Hand', chest: 'Chest', upperBack: 'Upper back', abdomen: 'Abdomen',
    lowerBack: 'Lower back', hip: 'Hip', thigh: 'Thigh', knee: 'Knee', calf: 'Calf', ankle: 'Ankle', foot: 'Foot',
  };

  static int base(int id) => id & 31;
  static int side(int id) => id >> 5;
  static String name(int id) => names[base(id)] ?? 'Body';
  static String sideLabel(int id) => switch (side(id)) { 1 => 'Left', 2 => 'Right', _ => 'Centre' };
  static int of(int base, double x) => base | ((x.abs() < 2.5 && base <= 2) ? 0 : (x > 0 ? 1 : 2)) << 5;
}

class Palette {
  const Palette({
    required this.skin,
    required this.top,
    required this.bottom,
    required this.shoe,
    required this.hair,
    this.ponytail = true,
    this.beard,
    this.sleeve = 0.44,
    this.cropTop = false,
  });

  final Color skin, top, bottom, shoe, hair;
  final bool ponytail;
  final Color? beard;
  final double sleeve; // fraction of the upper arm covered by the sleeve (0 = sleeveless)
  final bool cropTop;

  static const woman = Palette(
    skin: Color(0xFFE5BDA3),
    top: Color(0xFF7D9B8E),
    bottom: Color(0xFF3B3F45),
    shoe: Color(0xFFE6E7EA),
    hair: Color(0xFF2E2420),
  );

  static const athlete = Palette(
    skin: Color(0xFFE2B89C),
    top: Color(0xFF6E7BA3),
    bottom: Color(0xFF34373D),
    shoe: Color(0xFFE6E7EA),
    hair: Color(0xFF2B211D),
    sleeve: 0.0,
    cropTop: true,
  );

  static const man = Palette(
    skin: Color(0xFFD7A588),
    top: Color(0xFFEDEAE6),
    bottom: Color(0xFF3B3F45),
    shoe: Color(0xFFE6E7EA),
    hair: Color(0xFF2A211C),
    ponytail: false,
    beard: Color(0xFF5E4638),
  );
}

/// Joint positions (cm, y up, +z toward the camera) describing one pose.
class Pose {
  const Pose({
    required this.spine,
    required this.front,
    required this.headC,
    required this.headUp,
    required this.headFront,
    required this.armL,
    required this.armR,
    required this.legL,
    required this.legR,
    required this.toeL,
    required this.toeR,
    this.footUp = V3.up,
  });

  /// Spine points at heights 78 (crotch), 90 (pelvis), 105 (waist), 122 (chest), 137 (shoulders), 146 (neck).
  final List<V3> spine;
  final V3 front;
  final V3 headC, headUp, headFront;
  final List<V3> armL, armR; // shoulder, elbow, wrist, fingertip
  final List<V3> legL, legR; // hip, knee, ankle
  final V3 toeL, toeR, footUp;

  static const _h = [78.0, 90.0, 105.0, 122.0, 137.0, 146.0];

  V3 spineAt(double h) {
    if (h <= _h.first) return spine.first + (spine[1] - spine[0]) * ((h - _h[0]) / (_h[1] - _h[0]));
    for (var i = 0; i < _h.length - 1; i++) {
      if (h <= _h[i + 1]) return V3.lerp(spine[i], spine[i + 1], (h - _h[i]) / (_h[i + 1] - _h[i]));
    }
    final n = _h.length;
    return spine[n - 1] + (spine[n - 1] - spine[n - 2]) * ((h - _h[n - 1]) / (_h[n - 1] - _h[n - 2]));
  }

  static const standing = Pose(
    spine: [V3(0, 78, 0), V3(0, 90, 0), V3(0, 105, 0), V3(0, 122, 0), V3(0, 137, 0), V3(0, 146, 0)],
    front: V3.fwd,
    headC: V3(0, 158.6, 1.0),
    headUp: V3(0, 1, 0.04),
    headFront: V3.fwd,
    armL: [V3(14.7, 134.6, -0.6), V3(19.6, 110.5, -2.4), V3(21.4, 87.5, 1.2), V3(22.0, 71.5, 3.4)],
    armR: [V3(-14.7, 134.6, -0.6), V3(-19.6, 110.5, -2.4), V3(-21.4, 87.5, 1.2), V3(-22.0, 71.5, 3.4)],
    legL: [V3(8.8, 85, 0), V3(7.2, 47, 1.2), V3(6.4, 9.5, -0.6)],
    legR: [V3(-8.8, 85, 0), V3(-7.2, 47, 1.2), V3(-6.4, 9.5, -0.6)],
    toeL: V3(0.16, 0, 1),
    toeR: V3(-0.16, 0, 1),
  );

  Pose withArms(List<V3> l, {List<V3>? r}) => Pose(
        spine: spine,
        front: front,
        headC: headC,
        headUp: headUp,
        headFront: headFront,
        armL: l,
        armR: r ?? l.map((p) => p.mx).toList(),
        legL: legL,
        legR: legR,
        toeL: toeL,
        toeR: toeR,
        footUp: footUp,
      );

  /// Wall slides: arms in a "W" (t = 0) sliding up to a "Y" (t = 1).
  static Pose wallSlide(double t) {
    V3 l(V3 a, V3 b) => V3.lerp(a, b, t);
    return standing.withArms([
      const V3(16.6, 137.5, -0.4),
      l(const V3(30.5, 140, 2.2), const V3(24.5, 158, 3.6)),
      l(const V3(29.5, 161, 4.2), const V3(19.5, 183, 5.0)),
      l(const V3(29.0, 177, 4.6), const V3(16.5, 199, 5.4)),
    ]);
  }

  /// Band pull-aparts: arms reaching forward, pulled out to the sides.
  static Pose bandPull(double t) {
    V3 l(V3 a, V3 b) => V3.lerp(a, b, t);
    return standing.withArms([
      const V3(16.2, 136, 0.2),
      l(const V3(14.5, 133, 25.0), const V3(36.0, 135, 13.0)),
      l(const V3(10.5, 132, 47.5), const V3(56.0, 135, 23.0)),
      l(const V3(9.0, 132, 63.0), const V3(70.0, 135, 30.0)),
    ]);
  }

  static Pose shoulderRoll(double t) {
    final lift = math.sin(t * math.pi) * 2.2;
    return standing.withArms([
      V3(16.2, 136 + lift, -0.8 - lift * 0.4),
      V3(20.0, 112 + lift, -1.8),
      const V3(22.0, 89, 0.6),
      const V3(22.6, 72.5, 2.4),
    ]);
  }

  /// Supine glute bridge seen from the side (head toward −x).
  static const gluteBridge = Pose(
    spine: [V3(13, 31, 0), V3(2, 35, 0), V3(-12, 28.5, 0), V3(-27.5, 19.5, 0), V3(-41.5, 11.5, 0), V3(-50.5, 10, 0)],
    front: V3(-0.3, 0.95, 0),
    headC: V3(-61.5, 10.5, 0),
    headUp: V3(-1, 0.04, 0),
    headFront: V3(0, 1, 0),
    armL: [V3(-41, 12, -16.5), V3(-17, 5.5, -20.5), V3(5, 4, -21.5), V3(20, 3, -21.5)],
    armR: [V3(-41, 12, 16.5), V3(-17, 5.5, 20.5), V3(5, 4, 21.5), V3(20, 3, 21.5)],
    legL: [V3(6, 32, -8.4), V3(40, 46, -9), V3(47, 9.5, -9.5)],
    legR: [V3(6, 32, 8.4), V3(40, 46, 9), V3(47, 9.5, 9.5)],
    toeL: V3(1, 0, -0.08),
    toeR: V3(1, 0, 0.08),
  );

  /// Hip thrust with the upper back on a bench (head toward −x).
  static const hipThrust = Pose(
    spine: [V3(25, 50, 0), V3(14, 53, 0), V3(-1, 53, 0), V3(-17, 50, 0), V3(-30, 47, 0), V3(-37.5, 50.5, 0)],
    front: V3(0, 1, 0),
    headC: V3(-46, 57.5, 0),
    headUp: V3(-0.82, 0.57, 0),
    headFront: V3(0.57, 0.82, 0),
    armL: [V3(-29, 49, -16), V3(-22, 37, -21.5), V3(-6, 43, -20), V3(2, 47.5, -18.5)],
    armR: [V3(-29, 49, 16), V3(-22, 37, 21.5), V3(-6, 43, 20), V3(2, 47.5, 18.5)],
    legL: [V3(17, 51, -8.4), V3(54, 51, -9.5), V3(56, 9.5, -10)],
    legR: [V3(17, 51, 8.4), V3(54, 51, 9.5), V3(56, 9.5, 10)],
    toeL: V3(1, 0, -0.08),
    toeR: V3(1, 0, 0.08),
  );
}

/// Builds the whole figure as one mesh. Every part is a loft of anatomical
/// cross-sections: an ellipse plus Gaussian muscle/bone bulges ([Bump]), with
/// radii interpolated by a C1 Hermite curve so contours flow with no kinks.
Mesh buildFigure(Pose p, Palette pal, {int detail = 2, int? fixedSpan, bool breathing = false}) {
  final b = MeshBuilder(fixedSpan: fixedSpan);
  final seg = [14, 20, 28][detail];
  final step = [3.0, 2.0, 1.4][detail];
  final skin = pal.skin, top = pal.top, bot = pal.bottom;
  const noBumps = <Bump>[];

  // ---- Torso -------------------------------------------------------------
  // Angles: 0° = figure's left side, 90° = front, 180° = right, 270° = back.
  final topHem = pal.cropTop ? 116.0 : 99.8;
  final rows = <(double, double, double, double, List<Bump>)>[
    // h, rx, rz, forward offset, bumps
    // The pelvis/glutes belong to the leg lofts; the torso starts at the waist
    // and its join with them hides under the shirt hem.
    (93, 12.6, 8.0, 0.2, noBumps),
    (96, 13.4, 8.6, 0.3, const [Bump(90, 0.3, 40)]),
    (99.6, 14.2, 9.0, 0.2, const [Bump(90, 0.5, 40), Bump(270, -0.4, 10)]),
    // waist: obliques taper, spine groove between the erectors
    (105, 12.4, 8.6, 0.4, const [Bump(270, -0.6, 10), Bump(250, 0.35, 16), Bump(290, 0.35, 16), Bump(90, 0.2, 45)]),
    (113, 13.0, 9.0, 0.7, const [Bump(270, -0.6, 10), Bump(248, 0.4, 18), Bump(292, 0.4, 18), Bump(18, 0.3, 30), Bump(162, 0.3, 30)]),
    // bust + lats
    (119.5, 14.8, 9.6, 1.0, const [Bump(62, 1.7, 24), Bump(118, 1.7, 24), Bump(270, -0.5, 10), Bump(15, 0.5, 30), Bump(165, 0.5, 30)]),
    (124.5, 15.5, 9.8, 0.9, const [Bump(64, 1.4, 25), Bump(116, 1.4, 25), Bump(232, 0.7, 26), Bump(308, 0.7, 26), Bump(270, -0.4, 10)]),
    // scapulae + upper chest
    (129.5, 15.4, 9.4, 0.5, const [Bump(66, 0.5, 30), Bump(114, 0.5, 30), Bump(230, 0.9, 26), Bump(310, 0.9, 26)]),
    (134, 15.6, 8.6, 0, const [Bump(232, 0.6, 28), Bump(308, 0.6, 28), Bump(90, 0.2, 40)]),
    // trapezius slope to the neck
    (137.8, 14.4, 7.2, -0.6, const [Bump(250, 0.4, 30), Bump(290, 0.4, 30)]),
    (141.2, 10.4, 6.0, -0.8, const [Bump(255, 0.3, 30), Bump(285, 0.3, 30)]),
  ];
  final torso = <Sec>[];
  for (var i = 0; i < rows.length; i++) {
    final (h, rx, rz, fwd, bumps) = rows[i];
    // Below the hem: bare midriff for a crop top, leggings otherwise.
    final under = pal.cropTop && h > 97 ? skin : bot;
    torso.add(Sec(p.spineAt(h) + p.front * fwd, rx, rz, h < topHem ? under : top, 0, bumps));
    if (h < topHem && i < rows.length - 1 && rows[i + 1].$1 >= topHem) {
      // Clean colour edge at the hem: two sections a hair apart, a slim lip.
      final n = rows[i + 1];
      final t = (topHem - h) / (n.$1 - h);
      double l(double a, double c) => a + (c - a) * t;
      final bb = t < 0.5 ? bumps : n.$5;
      torso.add(Sec(p.spineAt(topHem - 0.15) + p.front * l(fwd, n.$4), l(rx, n.$2), l(rz, n.$3), pal.cropTop ? skin : bot, 0, bb));
      torso.add(Sec(p.spineAt(topHem + 0.15) + p.front * l(fwd, n.$4), l(rx, n.$2) + 0.32, l(rz, n.$3) + 0.32, top, 0, bb));
    }
  }
  // The neck continues the same loft (collar → neck → under the skull).
  final neckTop = p.headC - p.headUp * 7.6 + p.headFront * -0.8;
  final neckBase = p.spineAt(146) + p.front * -0.6;
  const scm = noBumps;
  torso
    ..add(Sec(p.spineAt(143.0) + p.front * -0.7, 6.1, 5.5, top))
    ..add(Sec(p.spineAt(143.3) + p.front * -0.7, 5.5, 5.2, skin, 0, scm))
    ..add(Sec(neckBase, 5.0, 4.9, skin, 0, scm))
    ..add(Sec(V3.lerp(neckBase, neckTop, 0.5), 4.55, 4.7, skin, 0, scm))
    ..add(Sec(neckTop, 4.6, 4.9, skin));
  final spineUp = (p.spineAt(137) - p.spineAt(90)).norm;
  final pelvis = p.spineAt(90);
  final torsoP = b.loft(
    torso,
    ref: p.front,
    seg: seg + 12,
    step: step * 0.75,
    shade: pal.cropTop
        ? (pt, o, c) {
            // Sports top: scoop neckline + bare midriff handled by hem; skin above the scoop.
            final h = 90 + (pt - pelvis).dot(spineUp);
            final fr = o.dot(p.front);
            if (h > 131 - 5 * fr.clamp(0, 1) && fr > 0.25) return skin;
            if (h > 139 && fr <= 0.25) return skin;
            return c;
          }
        : null,
    regionOf: (pt, o, _) {
      final h = 90 + (pt - pelvis).dot(spineUp);
      final fr = o.dot(p.front);
      final lat = (pt - p.spineAt(h)).dot(spineUp.cross(p.front).norm);
      if (h > 134 && lat.abs() > 9) return Region.of(Region.shoulder, lat);
      if (h > 136) return Region.of(Region.neck, 0);
      if (h > 113) return fr >= -0.1 ? Region.of(Region.chest, 0) : Region.of(Region.upperBack, 0);
      if (h > 96) return fr >= -0.1 ? Region.of(Region.abdomen, 0) : Region.of(Region.lowerBack, 0);
      return Region.of(Region.hip, lat);
    },
  );

  // ---- Head ------------------------------------------------------------------
  final headRows = <(double, double, double, double, List<Bump>)>[
    // u (along head up), rx, rz, forward offset, facial landmarks
    (-10.7, 0.02, 0.02, 2.0, noBumps),
    (-10.3, 2.4, 2.6, 2.1, const [Bump(90, 0.3, 30)]),
    (-9.6, 3.8, 4.3, 2.2, const [Bump(90, 0.5, 26)]), // chin
    (-8.3, 5.1, 6.2, 1.5, const [Bump(90, 0.2, 30)]), // jaw
    (-6.0, 6.1, 7.5, 0.8, const [Bump(90, 0.12, 30)]), // mouth
    (-4.2, 6.55, 8.05, 0.6, noBumps), // under the nose
    (-3.3, 6.8, 8.4, 0.6, const [Bump(90, 1.3, 11), Bump(78, 0.2, 12), Bump(102, 0.2, 12)]), // nose tip + alae
    (-1.3, 7.0, 8.8, 0.5, const [Bump(90, 0.75, 11), Bump(56, 0.35, 24), Bump(124, 0.35, 24)]), // bridge, cheekbones
    (0.9, 7.2, 9.0, 0.4, const [Bump(90, 0.4, 11), Bump(68, -0.25, 12), Bump(112, -0.25, 12)]), // eye sockets
    (2.6, 7.3, 9.2, 0.1, const [Bump(76, 0.32, 18), Bump(104, 0.32, 18)]), // brow ridge
    (3.6, 7.4, 9.3, -0.2, noBumps),
    (6.6, 6.7, 8.4, -0.6, noBumps),
    (9.0, 5.3, 6.7, -0.7, noBumps),
    (10.3, 3.1, 3.9, -0.8, noBumps),
    (11.15, 0.02, 0.02, -0.8, noBumps),
  ];
  final hc = p.headC, hu = p.headUp, hf = p.headFront;
  final male = !pal.ponytail;
  final headP = b.loft(
    [for (final r in headRows) Sec(hc + hu * r.$1 + hf * r.$4, r.$2, r.$3, skin, Region.head, r.$5)],
    ref: hf,
    axis: hu,
    seg: seg * 2,
    step: step * 0.45,
    capStart: false,
    capEnd: false,
    bias: 1,
    shade: (pt, o, c) {
      final u = (pt - hc).dot(hu);
      final fr = o.dot(hf);
      final thr = male
          ? (fr >= 0 ? 4.2 + 3.2 * fr : 4.2 + 9.5 * fr)
          : (fr >= 0 ? 1.4 + 5.6 * fr : 1.4 + 8.5 * fr);
      // Soft hairline: blend across ~1.6 cm so it never staircases.
      final hb = ((u - thr + 0.8) / 1.6).clamp(0.0, 1.0);
      if (hb >= 1) return pal.hair;
      if (hb > 0) return Color.lerp(c, pal.hair, hb * hb * (3 - 2 * hb))!;
      if (pal.beard != null && u < -2.5 && fr > -0.35) {
        return Color.lerp(c, pal.beard, ((-2.5 - u) / 3).clamp(0, 1) * 0.85)!;
      }
      return c;
    },
  );
  Part? pony;
  if (pal.ponytail) {
    final s = hc + hu * 2.6 + hf * -7.4;
    pony = b.loft([
      Sec(s, 2.8, 2.7, pal.hair, Region.head),
      Sec(hc + hu * 1.6 + hf * -11.2, 3.0, 2.9, pal.hair, Region.head),
      Sec(hc + hu * -5.0 + hf * -12.4, 2.4, 2.3, pal.hair, Region.head),
      Sec(hc + hu * -12.5 + hf * -11.0, 1.1, 1.0, pal.hair, Region.head),
    ], ref: hu, seg: math.max(10, seg - 8), step: step, bias: 1);
  }

  // ---- Arms ------------------------------------------------------------------
  // Angles: 0° = lateral (outer arm), 90° = front, 180° = medial, 270° = back.
  final chest = p.spineAt(130);
  (Part, Part) arm(List<V3> j, double side) {
    final s = j[0], e = j[1], w = j[2], tip = j[3];
    V3 se(double t) => V3.lerp(s, e, t);
    V3 ew(double t) => V3.lerp(e, w, t);
    V3 wt(double t) => V3.lerp(w, tip, t);
    int reg(int r) => Region.of(r, side);
    final sl = pal.sleeve;
    final sleeve = sl > 0 ? top : skin;
    final secs = <Sec>[
      Sec(s, 4.3, 4.6, sleeve, reg(Region.shoulder), const [Bump(0, 0.5, 50)]),
      // deltoid: lateral head biggest, front/rear heads either side
      Sec(se(0.18), 4.2, 4.5, sleeve, reg(Region.shoulder), const [Bump(0, 0.85, 42), Bump(70, 0.45, 32), Bump(290, 0.5, 32)]),
      Sec(se(0.36), 3.95, 4.15, sleeve, reg(Region.upperArm), const [Bump(0, 0.6, 38), Bump(90, 0.3, 40), Bump(270, 0.45, 40)]),
      if (sl > 0) ...[
        Sec(se(sl), 3.8, 4.0, top, reg(Region.upperArm), const [Bump(0, 0.3, 40), Bump(90, 0.4, 40), Bump(270, 0.5, 40)]),
        Sec(se(sl + 0.015), 3.62, 3.82, skin, reg(Region.upperArm), const [Bump(0, 0.3, 40), Bump(90, 0.4, 40), Bump(270, 0.5, 40)]),
      ],
      // biceps / triceps bellies
      Sec(se(0.64), 3.5, 3.7, skin, reg(Region.upperArm), const [Bump(90, 0.8, 36), Bump(270, 0.75, 40), Bump(180, 0.2, 40)]),
      Sec(se(0.86), 3.05, 3.25, skin, reg(Region.upperArm), const [Bump(90, 0.35, 38), Bump(270, 0.4, 38)]),
      Sec(e, 2.85, 3.05, skin, reg(Region.elbow), const [Bump(270, 0.45, 22), Bump(180, 0.3, 28)]),
      // forearm: brachioradialis + flexor mass, tapering to the wrist
      Sec(ew(0.22), 3.25, 3.35, skin, reg(Region.forearm), const [Bump(28, 0.85, 36), Bump(150, 0.6, 38), Bump(270, 0.25, 40)]),
      Sec(ew(0.6), 2.55, 2.75, skin, reg(Region.forearm), const [Bump(50, 0.3, 40), Bump(150, 0.2, 40)]),
      Sec(w, 1.85, 2.45, skin, reg(Region.wrist), const [Bump(0, 0.22, 22)]),
      Sec(wt(0.32), 1.45, 3.85, skin, reg(Region.hand)),
      Sec(wt(0.56), 1.3, 3.7, skin, reg(Region.hand)),
      Sec(wt(0.8), 1.1, 3.0, skin, reg(Region.hand)),
      Sec(tip, 0.7, 2.1, skin, reg(Region.hand)),
    ];
    final out = s - chest;
    final armP = b.loft(secs, ref: p.front, seg: seg, step: step, outward: out);
    // Thumb along the front edge of the hand.
    final dir = (tip - w).norm;
    final fw = (p.front - dir * p.front.dot(dir)).norm;
    final t0 = wt(0.12) + fw * 2.0;
    final thumb = b.loft([
      Sec(t0, 1.05, 1.1, skin, reg(Region.hand)),
      Sec(t0 + dir * 2.6 + fw * 1.0, 0.9, 0.9, skin, reg(Region.hand)),
      Sec(t0 + dir * 4.6 + fw * 1.5, 0.66, 0.66, skin, reg(Region.hand)),
    ], ref: p.front, seg: math.max(8, seg - 12), step: step);
    return (armP, thumb);
  }

  final arms = [arm(p.armL, 1), arm(p.armR, -1)];

  // ---- Legs + shoes --------------------------------------------------------------
  final hipC = p.spineAt(85);
  (Part, Part) leg(List<V3> j, V3 toe, double side) {
    final h = j[0], k = j[1], a = j[2];
    int reg(int r) => Region.of(r, side);
    final legFront = (toe - p.footUp * toe.dot(p.footUp)).norm;
    V3 hk(double t, [double f = 0]) => V3.lerp(h, k, t) + legFront * f;
    V3 ka(double t, [double f = 0]) => V3.lerp(k, a, t) + legFront * f;
    // Each leg loft continues up as half of the pelvis (glute included), so
    // the two halves meet on the midline (gluteal cleft / centre seam) and
    // the waist joins the torso under the hem: no visible part boundaries.
    final lat = (h - hipC - spineUp * (h - hipC).dot(spineUp)).norm;
    V3 pv(double hh, double l, double f) => p.spineAt(hh) + lat * l + p.front * f;
    final legP = b.loft([
      Sec(pv(96.9, 5.4, 0.3), 5.6, 6.4, bot, reg(Region.hip), const [Bump(160, 1.4, 28)]),
      Sec(pv(95.3, 7.2, 0.2), 8.3, 9.0, bot, reg(Region.hip), const [Bump(255, 0.8, 40), Bump(105, 0.5, 40), Bump(160, 2.1, 28)]),
      Sec(pv(90.5, 8.2, -0.1), 8.9, 9.9, bot, reg(Region.hip), const [Bump(248, 1.9, 38), Bump(15, 0.35, 40), Bump(105, 0.4, 40), Bump(160, 2.0, 28)]),
      Sec(h, 8.2, 9.0, bot, reg(Region.hip), const [Bump(252, 2.0, 36), Bump(25, 0.45, 40), Bump(158, 1.0, 28)]),
      Sec(hk(0.1), 7.7, 8.1, bot, reg(Region.thigh), const [Bump(262, 1.0, 40), Bump(45, 0.7, 40), Bump(110, 0.4, 30)]),
      // quads (vastus lateralis, rectus femoris), adductors, hamstrings
      Sec(hk(0.25), 7.4, 7.7, bot, reg(Region.thigh),
          const [Bump(40, 1.2, 36), Bump(100, 0.8, 26), Bump(190, 0.6, 38), Bump(270, 0.7, 42)]),
      Sec(hk(0.55), 6.1, 6.4, bot, reg(Region.thigh),
          const [Bump(32, 1.0, 36), Bump(95, 0.7, 26), Bump(150, 0.4, 32), Bump(265, 0.6, 42)]),
      // vastus medialis "teardrop" above the knee
      Sec(hk(0.8), 5.5, 5.8, bot, reg(Region.thigh), const [Bump(22, 0.35, 38), Bump(132, 1.0, 24), Bump(270, 0.3, 40)]),
      Sec(k + legFront * 0.35, 4.5, 4.9, bot, reg(Region.knee), const [Bump(90, 0.55, 20), Bump(180, 0.3, 28), Bump(270, -0.2, 32)]),
      Sec(ka(0.12), 4.7, 4.9, bot, reg(Region.calf), const [Bump(240, 0.6, 30)]),
      // gastrocnemius: medial head larger and lower than the lateral head
      Sec(ka(0.28, -0.7), 4.9, 5.2, bot, reg(Region.calf), const [Bump(234, 1.3, 28), Bump(302, 0.9, 26), Bump(110, -0.15, 30)]),
      Sec(ka(0.55, -0.4), 3.85, 4.1, bot, reg(Region.calf), const [Bump(250, 0.5, 34)]),
      Sec(ka(0.8), 3.15, 3.35, bot, reg(Region.ankle), const [Bump(270, 0.2, 24)]),
      Sec(ka(0.88), 3.1, 3.3, bot, reg(Region.ankle)),
      Sec(ka(0.9), 2.95, 3.15, skin, reg(Region.ankle)),
      Sec(a, 2.85, 3.05, skin, reg(Region.ankle), const [Bump(0, 0.35, 22), Bump(180, 0.3, 22)]), // malleoli
    ], ref: legFront, seg: seg + 4, step: step * 0.8, outward: h - hipC);

    final base = a - p.footUp * 9.5;
    final td = toe.norm;
    final rows = <List<double>>[
      [-4.6, 4.2, 3.4, 3.8],
      [-3.0, 4.2, 3.9, 4.2],
      [1.0, 4.3, 4.3, 4.3],
      [6.0, 3.4, 4.3, 3.4],
      [10.0, 2.6, 3.6, 2.5],
      [12.4, 2.2, 2.4, 1.8],
    ];
    final shoeP = b.loft(
      [for (final r in rows) Sec(base + td * r[0] + p.footUp * r[1], r[2], r[3], pal.shoe, reg(Region.foot))],
      ref: p.footUp,
      seg: seg,
      step: step,
      shade: (pt, o, c) {
        final v = (pt - base).dot(p.footUp);
        if (v < 0.9) return const Color(0xFFBFC3C9); // sole
        if (v > 5.8 && o.dot(p.footUp) > 0.3) return Color.lerp(c, const Color(0xFF9AA3AB), 0.35)!; // laces
        return c;
      },
    );
    return (legP, shoeP);
  }

  final legs = [leg(p.legL, p.toeL, 1), leg(p.legR, p.toeR, -1)];

  // Union the parts: cut away every surface hidden inside another part so
  // nothing interpenetrates. Morph keyframes skip the arms (the only parts
  // that move between them) so both keyframes keep identical topology.
  b
    ..clip(headP, torsoP.vol, margin: 0.07)
    ..clip(torsoP, headP.vol, margin: 0.07);
  if (pony != null) b.clip(pony, headP.vol);
  if (fixedSpan == null) {
    for (final (a, thumb) in arms) {
      b
        ..clip(thumb, a.vol)
        ..clip(a, thumb.vol)
        ..clip(a, torsoP.vol)
        ..clip(torsoP, a.vol);
    }
  }
  b
    ..clip(legs[0].$1, legs[1].$1.vol)
    ..clip(legs[1].$1, legs[0].$1.vol);
  for (final (l, sh) in legs) {
    b
      ..clip(l, torsoP.vol)
      ..clip(torsoP, l.vol)
      ..clip(l, sh.vol)
      ..clip(sh, l.vol);
  }

  final mesh = b.build(
    breath: breathing
        ? (x, y, z) {
            double sm(double e0, double e1, double v) {
              final t = ((v - e0) / (e1 - e0)).clamp(0.0, 1.0);
              return t * t * (3 - 2 * t);
            }
            return sm(104, 120, y) * (1 - sm(136, 146, y));
          }
        : null,
  );
  // Studio-style shading: soften the downward-facing normals under the jaw
  // and pelvis so they don't read as shadows at phone size.
  void soften(Part part, V3 origin, V3 axis, double from, double to, double amount) {
    final n = mesh.nrm, pos = mesh.pos;
    final seen = <int>{};
    for (final v in part.tris) {
      if (!seen.add(v)) continue;
      final i = v * 3;
      final along = (pos[i] - origin.x) * axis.x + (pos[i + 1] - origin.y) * axis.y + (pos[i + 2] - origin.z) * axis.z;
      final w = ((from - along) / (from - to)).clamp(0.0, 1.0) * amount;
      if (w <= 0) continue;
      final d = n[i] * axis.x + n[i + 1] * axis.y + n[i + 2] * axis.z;
      if (d >= 0) continue; // only the downward-facing part
      final x = n[i] - axis.x * d * w, y = n[i + 1] - axis.y * d * w, z = n[i + 2] - axis.z * d * w;
      final l = math.sqrt(x * x + y * y + z * z);
      if (l < 1e-6) continue;
      n[i] = x / l;
      n[i + 1] = y / l;
      n[i + 2] = z / l;
    }
  }

  soften(torsoP, pelvis, spineUp, 6, -3, 0.7);
  return mesh;
}
