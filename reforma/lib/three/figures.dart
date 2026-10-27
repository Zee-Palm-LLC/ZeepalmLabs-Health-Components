import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'figure.dart';
import 'mesh.dart';
import 'vec.dart';

typedef _Job = ({Pose pose, Palette pal, int detail, int? fixedSpan, bool breathing});

Mesh _build(_Job j) =>
    buildFigure(j.pose, j.pal, detail: j.detail, fixedSpan: j.fixedSpan, breathing: j.breathing);

/// All meshes are procedural (nothing is fetched or decoded). [load] builds
/// them in parallel background isolates before the first frame, so every
/// screen — including the 3D check-in body — is ready instantly.
abstract final class Figures {
  static const heroPalette = Palette(
    skin: Color(0xFFE3BA9F),
    top: Color(0xFF6F7894),
    bottom: Color(0xFF3E4149),
    shoe: Color(0xFFE6E7EA),
    hair: Color(0xFF2B221E),
  );

  /// Pushes the forearms forward so the palms rest on a wall in front.
  static Pose _facingWall(Pose p) => p.withArms([
        for (final (i, j) in p.armL.indexed) j + V3(0, 0, const [0.0, 9.0, 13.5, 14.5][i]),
      ]);

  static final Map<String, _Job> _jobs = {
    'body': (pose: Pose.standing, pal: Palette.woman, detail: 2, fixedSpan: null, breathing: true),
    // Wall-slide keyframes share topology (fixedSpan), so the hero morphs between them.
    'heroLow': (pose: _facingWall(Pose.wallSlide(0)), pal: heroPalette, detail: 1, fixedSpan: 4, breathing: false),
    'heroHigh': (pose: _facingWall(Pose.wallSlide(1)), pal: heroPalette, detail: 1, fixedSpan: 4, breathing: false),
    // Thumbnails are ~80 px: lighter meshes are plenty.
    'glute': (pose: Pose.gluteBridge, pal: Palette.athlete, detail: 1, fixedSpan: null, breathing: false),
    'hip': (pose: Pose.hipThrust, pal: Palette.athlete, detail: 1, fixedSpan: null, breathing: false),
    'roll': (pose: Pose.shoulderRoll(0.5), pal: Palette.athlete, detail: 0, fixedSpan: null, breathing: false),
    'band': (pose: Pose.bandPull(0.75), pal: Palette.athlete, detail: 0, fixedSpan: null, breathing: false),
    'man': (
      pose: Pose.standing.withArms(const [V3(15.6, 134.6, -0.8), V3(19.0, 111, -1), V3(20.5, 88, 1), V3(21, 71.5, 2.4)]),
      pal: Palette.man,
      detail: 1,
      fixedSpan: null,
      breathing: false,
    ),
  };

  static final Map<String, Mesh> _meshes = {};

  /// Builds every figure concurrently (isolates on mobile/desktop).
  static Future<void> load() async {
    final keys = _jobs.keys.where((k) => !_meshes.containsKey(k)).toList();
    final built = await Future.wait([for (final k in keys) compute(_build, _jobs[k]!)]);
    for (final (i, k) in keys.indexed) {
      _meshes[k] = built[i];
    }
  }

  /// A prebuilt mesh (built synchronously if [load] has not run, e.g. in tests).
  static Mesh mesh(String key) => _meshes.putIfAbsent(key, () => _build(_jobs[key]!));

  static Mesh get body => mesh('body');
  static Mesh get heroLow => mesh('heroLow');
  static Mesh get heroHigh => mesh('heroHigh');

  static final Map<String, Picture> _pics = {};

  static Picture still(String key, Picture Function() make) => _pics.putIfAbsent(key, make);
}
