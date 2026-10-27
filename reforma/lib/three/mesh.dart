import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'vec.dart';

/// A baked triangle mesh in flat typed arrays (model space, centimetres).
class Mesh {
  Mesh({
    required this.pos,
    required this.nrm,
    required this.col,
    required this.region,
    required this.tri,
    required this.breath,
    required this.bias,
  });

  final Float32List pos; // xyz per vertex
  final Float32List nrm; // xyz per vertex
  final Float32List col; // rgb 0..1 per vertex
  final Uint8List region; // body region id per vertex
  final Uint16List tri; // 3 indices per triangle
  final Float32List breath; // 0..1 chest weight for idle breathing
  final Float32List bias; // per-triangle depth bias (cm × 3) for the painter sort

  int get vertexCount => pos.length ~/ 3;
  int get triCount => tri.length ~/ 3;

  /// Interior edges as (a, b, triangle1, triangle2) quadruples, used to find
  /// silhouette edges for anti-aliasing. Cached per topology.
  Int32List? _edges;
  Int32List get edges => _edges ??= () {
    final first = <int, int>{};
    final out = <int>[];
    for (var t = 0; t < triCount; t++) {
      for (var e = 0; e < 3; e++) {
        final a = tri[t * 3 + e], b = tri[t * 3 + (e + 1) % 3];
        final key = a < b ? a * 65536 + b : b * 65536 + a;
        final o = first.remove(key);
        if (o == null) {
          first[key] = t;
        } else {
          out
            ..add(a)
            ..add(b)
            ..add(o)
            ..add(t);
        }
      }
    }
    return Int32List.fromList(out);
  }();

  /// Blend two meshes with identical topology (used to morph exercise poses).
  static void morph(Mesh a, Mesh b, double t, Mesh out) {
    final n = a.pos.length;
    for (var i = 0; i < n; i++) {
      out.pos[i] = a.pos[i] + (b.pos[i] - a.pos[i]) * t;
    }
    for (var i = 0; i < n; i += 3) {
      final x = a.nrm[i] + (b.nrm[i] - a.nrm[i]) * t;
      final y = a.nrm[i + 1] + (b.nrm[i + 1] - a.nrm[i + 1]) * t;
      final z = a.nrm[i + 2] + (b.nrm[i + 2] - a.nrm[i + 2]) * t;
      final l = math.sqrt(x * x + y * y + z * z);
      final k = l < 1e-6 ? 0.0 : 1 / l;
      out.nrm[i] = x * k;
      out.nrm[i + 1] = y * k;
      out.nrm[i + 2] = z * k;
    }
  }

  Mesh clone() => Mesh(
        pos: Float32List.fromList(pos),
        nrm: Float32List.fromList(nrm),
        col: col,
        region: region,
        tri: tri,
        breath: breath,
        bias: bias,
      ).._edges = edges;
}

/// A soft muscle/bone bulge on a cross-section: a Gaussian radial offset
/// around the ring. Angles are anatomical: 0° = lateral (away from the
/// midline), 90° = front, 180° = medial, 270° = back.
class Bump {
  const Bump(this.deg, this.amp, [this.width = 35]);

  final double deg, amp, width;
}

/// One cross-section of a lofted body part.
class Sec {
  const Sec(this.p, this.rx, this.rz, this.color, [this.region = 0, this.bumps = const []]);

  final V3 p;
  final double rx; // half-width along the lateral axis
  final double rz; // half-depth along the front axis
  final Color color;
  final int region;
  final List<Bump> bumps;
}

typedef Shade = Color Function(V3 p, V3 outward, Color base);
typedef RegionOf = int Function(V3 p, V3 outward, int base);

class _Ring {
  _Ring(this.c, this.t, this.l, this.f, this.rx, this.rz, this.off, this.color, this.region, this.pole);

  final V3 c, t, l, f;
  final double rx, rz;
  final Float64List off; // radial offset per ring vertex (muscle shape)
  final Color color;
  final int region;
  final V3? pole;
}

/// Non-uniform Catmull-Rom (Hermite) for a scalar sampled at uneven spacing:
/// smooth (C1) radius changes along a limb with no kinks at sections.
double _herm(double r0, double r1, double r2, double r3, double d01, double d12, double d23, double t) {
  final m1 = d01 + d12 > 1e-9 ? (r2 - r0) / (d01 + d12) * d12 : r2 - r1;
  final m2 = d12 + d23 > 1e-9 ? (r3 - r1) / (d12 + d23) * d12 : r2 - r1;
  final t2 = t * t, t3 = t2 * t;
  return (2 * t3 - 3 * t2 + 1) * r1 + (t3 - 2 * t2 + t) * m1 + (-2 * t3 + 3 * t2) * r2 + (t3 - t2) * m2;
}

/// The solid swept by a loft, as an implicit test: [value] < 0 inside.
class Volume {
  Volume(this._rings) {
    var lo = const V3(1e9, 1e9, 1e9), hi = const V3(-1e9, -1e9, -1e9);
    for (final r in _rings) {
      final m = math.max(r.rx, r.rz) + 2.5;
      lo = V3(math.min(lo.x, r.c.x - m), math.min(lo.y, r.c.y - m), math.min(lo.z, r.c.z - m));
      hi = V3(math.max(hi.x, r.c.x + m), math.max(hi.y, r.c.y + m), math.max(hi.z, r.c.z + m));
    }
    _lo = lo;
    _hi = hi;
    // Bounding sphere per ring pair for a cheap reject.
    for (var i = 0; i < _rings.length - 1; i++) {
      final a = _rings[i], b = _rings[i + 1];
      _mid.add(V3.lerp(a.c, b.c, 0.5));
      final r = (b.c - a.c).length / 2 + math.max(math.max(a.rx, a.rz), math.max(b.rx, b.rz)) + 2.5;
      _rad2.add(r * r);
    }
  }

  final List<_Ring> _rings;
  late final V3 _lo, _hi;
  final _mid = <V3>[];
  final _rad2 = <double>[];

  double value(V3 p) {
    if (p.x < _lo.x || p.y < _lo.y || p.z < _lo.z || p.x > _hi.x || p.y > _hi.y || p.z > _hi.z) return 1;
    var best = 1.0;
    for (var i = 0; i < _rings.length - 1; i++) {
      final m = _mid[i];
      final mx = p.x - m.x, my = p.y - m.y, mz = p.z - m.z;
      if (mx * mx + my * my + mz * mz > _rad2[i]) continue;
      final a = _rings[i], b = _rings[i + 1];
      final da = (p - a.c).dot(a.t), db = (p - b.c).dot(b.t);
      if (da < 0 || db > 0) continue;
      final s = da - db < 1e-9 ? 0.0 : da / (da - db);
      final rx = a.rx + (b.rx - a.rx) * s, rz = a.rz + (b.rz - a.rz) * s;
      if (rx < 0.05 || rz < 0.05) continue;
      final d = p - V3.lerp(a.c, b.c, s);
      final u = d.dot(V3.lerp(a.l, b.l, s)) / rx, w = d.dot(V3.lerp(a.f, b.f, s)) / rz;
      // Include the muscle offset at this angle.
      final n = a.off.length;
      var ang = math.atan2(w, u);
      if (ang < 0) ang += 2 * math.pi;
      final fj = ang / (2 * math.pi) * n;
      final j0 = fj.floor() % n, j1 = (j0 + 1) % n, fr = fj - fj.floor();
      final oa = a.off[j0] + (a.off[j1] - a.off[j0]) * fr, ob = b.off[j0] + (b.off[j1] - b.off[j0]) * fr;
      final off = oa + (ob - oa) * s;
      final v = math.sqrt(u * u + w * w) - 1 - off / ((rx + rz) / 2);
      if (v < best) best = v;
    }
    return best;
  }
}

/// A lofted piece of the figure: its triangles, its solid and its sort bias.
class Part {
  Part(this.vol, this.bias);

  final Volume vol;
  final double bias;
  List<int> tris = [];
}

class MeshBuilder {
  MeshBuilder({this.fixedSpan});

  /// When set, every span between two sections gets exactly this many rings,
  /// so two poses of the same figure share topology and can be morphed.
  final int? fixedSpan;

  final _p = <double>[];
  final _c = <double>[];
  final _hint = <double>[];
  final _r = <int>[];
  final _parts = <Part>[];
  final _fixedN = <int, V3>{};

  int get count => _r.length;

  V3 _pos(int i) => V3(_p[i * 3], _p[i * 3 + 1], _p[i * 3 + 2]);

  /// Sweeps cross-sections along a Catmull-Rom path through [secs], with
  /// rotation-minimising frames and hemispherical end caps. Each ring is an
  /// ellipse plus the sections' [Bump]s (muscle bellies, bones), blended
  /// smoothly along the path. [outward] (lateral direction of a limb) makes
  /// mirrored limbs read their bump angles the same way.
  Part loft(
    List<Sec> secs, {
    required V3 ref,
    int seg = 22,
    double step = 1.7,
    bool capStart = true,
    bool capEnd = true,
    Shade? shade,
    RegionOf? regionOf,
    double bias = 0,
    V3? outward,
    V3? axis,
  }) {
    // 1. Sample positions along the path (span index + local t).
    final n = secs.length;
    final spanI = <int>[], spanT = <double>[];
    for (var i = 0; i < n - 1; i++) {
      final d = (secs[i + 1].p - secs[i].p).length;
      final k = fixedSpan ?? math.max(1, (d / step).ceil());
      for (var j = 0; j < k; j++) {
        spanI.add(i);
        spanT.add(j / k);
      }
    }
    spanI.add(n - 2);
    spanT.add(1);
    final m = spanI.length;
    double dist(int a, int b) => (secs[b.clamp(0, n - 1)].p - secs[a.clamp(0, n - 1)].p).length;
    final cs = <V3>[], rxs = <double>[], rzs = <double>[], cols = <Color>[], regs = <int>[];
    for (var s = 0; s < m; s++) {
      final i = spanI[s], t = spanT[s];
      final a = secs[i], b = secs[i + 1];
      final i0 = math.max(0, i - 1), i3 = math.min(n - 1, i + 2);
      final d01 = dist(i0, i), d12 = dist(i, i + 1), d23 = dist(i + 1, i3);
      // Non-uniform (arc-length) spline: no wiggles where sections bunch up.
      final q0 = secs[i0].p, q3 = secs[i3].p;
      cs.add(V3(
        _herm(q0.x, a.p.x, b.p.x, q3.x, d01, d12, d23, t),
        _herm(q0.y, a.p.y, b.p.y, q3.y, d01, d12, d23, t),
        _herm(q0.z, a.p.z, b.p.z, q3.z, d01, d12, d23, t),
      ));
      rxs.add(math.max(0.02, _herm(secs[i0].rx, a.rx, b.rx, secs[i3].rx, d01, d12, d23, t)));
      rzs.add(math.max(0.02, _herm(secs[i0].rz, a.rz, b.rz, secs[i3].rz, d01, d12, d23, t)));
      cols.add(Color.lerp(a.color, b.color, t)!);
      regs.add(t < 0.5 ? a.region : b.region);
    }

    // 2. Tangents + parallel-transported frames.
    // With a fixed [axis] the rings are parallel slices (no crossing where the
    // path leans, e.g. the chin); otherwise they follow the path tangent.
    final ts = axis != null
        ? List<V3>.filled(m, axis.norm)
        : List<V3>.generate(m, (i) => (cs[math.min(m - 1, i + 1)] - cs[math.max(0, i - 1)]).norm);
    final ls = <V3>[];
    var l0 = ts[0].cross(ref);
    if (l0.length < 0.15) l0 = ts[0].cross(V3.right);
    ls.add(l0.norm);
    for (var i = 1; i < m; i++) {
      final prev = ls[i - 1];
      ls.add((prev - ts[i] * prev.dot(ts[i])).norm);
    }

    // 3. Muscle offsets per section, then blended per ring.
    var mirror = false;
    if (outward != null) {
      final o = outward - ts[0] * outward.dot(ts[0]);
      mirror = ls[0].dot(o) < 0;
    }
    final secOff = <Float64List>[];
    for (final sec in secs) {
      final o = Float64List(seg);
      for (final bmp in sec.bumps) {
        final c = bmp.deg * math.pi / 180, w = bmp.width * math.pi / 180;
        for (var j = 0; j < seg; j++) {
          var th = 2 * math.pi * j / seg;
          if (mirror) th = math.pi - th;
          var d = (th - c) % (2 * math.pi);
          if (d > math.pi) d -= 2 * math.pi;
          if (d < -math.pi) d += 2 * math.pi;
          o[j] += bmp.amp * math.exp(-d * d / (2 * w * w));
        }
      }
      secOff.add(o);
    }
    // Hermite along the path (like the radii) so muscle bellies flow
    // through each section instead of flattening there.
    final offs = <Float64List>[];
    for (var s = 0; s < m; s++) {
      final i = spanI[s], t = spanT[s];
      final i0 = math.max(0, i - 1), i3 = math.min(n - 1, i + 2);
      final d01 = dist(i0, i), d12 = dist(i, i + 1), d23 = dist(i + 1, i3);
      final o0 = secOff[i0], o1 = secOff[i], o2 = secOff[i + 1], o3 = secOff[i3];
      offs.add(Float64List.fromList([for (var j = 0; j < seg; j++) _herm(o0[j], o1[j], o2[j], o3[j], d01, d12, d23, t)]));
    }

    // 4. Ring list with caps.
    final rings = <_Ring>[];
    const capSteps = 4;
    Float64List scaled(Float64List o, double k) => Float64List.fromList([for (final v in o) v * k]);
    if (capStart) {
      final rc = math.min(rxs[0], rzs[0]) * 0.92;
      for (var k = capSteps; k >= 1; k--) {
        final a = k / capSteps * math.pi / 2;
        rings.add(_Ring(cs[0] - ts[0] * (rc * math.sin(a)), ts[0], ls[0], ls[0].cross(ts[0]), rxs[0] * math.cos(a),
            rzs[0] * math.cos(a), scaled(offs[0], math.cos(a)), cols[0], regs[0], k == capSteps ? -ts[0] : null));
      }
    }
    for (var i = 0; i < m; i++) {
      rings.add(_Ring(cs[i], ts[i], ls[i], ls[i].cross(ts[i]), rxs[i], rzs[i], offs[i], cols[i], regs[i], null));
    }
    if (capEnd) {
      final e = m - 1;
      final rc = math.min(rxs[e], rzs[e]) * 0.92;
      for (var k = 1; k <= capSteps; k++) {
        final a = k / capSteps * math.pi / 2;
        rings.add(_Ring(cs[e] + ts[e] * (rc * math.sin(a)), ts[e], ls[e], ls[e].cross(ts[e]), rxs[e] * math.cos(a),
            rzs[e] * math.cos(a), scaled(offs[e], math.cos(a)), cols[e], regs[e], k == capSteps ? ts[e] : null));
      }
    }

    // 5. Vertices.
    final base = count;
    final cosT = List<double>.generate(seg, (j) => math.cos(2 * math.pi * j / seg));
    final sinT = List<double>.generate(seg, (j) => math.sin(2 * math.pi * j / seg));
    for (final r in rings) {
      for (var j = 0; j < seg; j++) {
        final out = r.pole ?? (r.l * (cosT[j] / math.max(r.rx, 1e-3)) + r.f * (sinT[j] / math.max(r.rz, 1e-3))).norm;
        final p = r.c + r.l * (r.rx * cosT[j]) + r.f * (r.rz * sinT[j]) + out * r.off[j];
        final col = shade == null ? r.color : shade(p, out, r.color);
        final reg = regionOf == null ? r.region : regionOf(p, out, r.region);
        _add(p, out, col, reg);
        if (r.pole != null) _fixedN[count - 1] = r.pole!;
      }
    }

    // 6. Quads between consecutive rings.
    final part = Part(Volume(rings), bias);
    final t = part.tris;
    for (var k = 0; k < rings.length - 1; k++) {
      for (var j = 0; j < seg; j++) {
        final j1 = (j + 1) % seg;
        final a = base + k * seg + j, b = base + k * seg + j1;
        final c = base + (k + 1) * seg + j, d = base + (k + 1) * seg + j1;
        t
          ..add(a)
          ..add(c)
          ..add(b)
          ..add(b)
          ..add(c)
          ..add(d);
      }
    }
    _parts.add(part);
    return part;
  }

  /// CSG-style union: removes the surface of [part] that lies inside [vol],
  /// splitting straddling triangles exactly on the boundary. With no
  /// interpenetrating surfaces left, the painter's sort has nothing to fight
  /// over at joints (no saw-tooth seams at hips, collar, shoulders, chin).
  void clip(Part part, Volume vol, {double margin = 0.015}) {
    final f = <int, double>{};
    // Slightly conservative (keeps a hair of overlap) so joins never open a gap.
    double fv(int i) => f.putIfAbsent(i, () => vol.value(_pos(i)) + margin);
    final cuts = <int, int>{};
    int cut(int a, int b) {
      final key = a < b ? a * 1000003 + b : b * 1000003 + a;
      return cuts.putIfAbsent(key, () {
        final fa = fv(a), fb = fv(b);
        final t = (fa / (fa - fb)).clamp(0.0, 1.0);
        _lerpVertex(a, b, t);
        f[count - 1] = 0;
        return count - 1;
      });
    }

    final src = part.tris, out = <int>[];
    for (var i = 0; i < src.length; i += 3) {
      final v = [src[i], src[i + 1], src[i + 2]];
      final ins = [fv(v[0]) < 0, fv(v[1]) < 0, fv(v[2]) < 0];
      if (!ins[0] && !ins[1] && !ins[2]) {
        out.addAll(v);
        continue;
      }
      if (ins[0] && ins[1] && ins[2]) continue;
      final poly = <int>[];
      for (var e = 0; e < 3; e++) {
        final a = v[e], b = v[(e + 1) % 3];
        final ia = ins[e], ib = ins[(e + 1) % 3];
        if (!ia) poly.add(a);
        if (ia != ib) poly.add(cut(a, b));
      }
      for (var k = 1; k < poly.length - 1; k++) {
        out
          ..add(poly[0])
          ..add(poly[k])
          ..add(poly[k + 1]);
      }
    }
    part.tris = out;
  }

  void _lerpVertex(int a, int b, double t) {
    V3 l(List<double> s) => V3(
          s[a * 3] + (s[b * 3] - s[a * 3]) * t,
          s[a * 3 + 1] + (s[b * 3 + 1] - s[a * 3 + 1]) * t,
          s[a * 3 + 2] + (s[b * 3 + 2] - s[a * 3 + 2]) * t,
        );
    final c = l(_c);
    _add(l(_p), l(_hint).norm, Color.from(alpha: 1, red: c.x, green: c.y, blue: c.z), _r[t < 0.5 ? a : b]);
  }

  void _add(V3 p, V3 hint, Color c, int region) {
    _p
      ..add(p.x)
      ..add(p.y)
      ..add(p.z);
    _hint
      ..add(hint.x)
      ..add(hint.y)
      ..add(hint.z);
    _c
      ..add(c.r)
      ..add(c.g)
      ..add(c.b);
    _r.add(region);
  }

  /// Bakes smooth vertex normals (area-weighted, oriented by the outward hint).
  Mesh build({double Function(double x, double y, double z)? breath}) {
    final n = count;
    final pos = Float32List.fromList(_p);
    final nrm = Float32List(n * 3);
    final t = <int>[], bias = <double>[];
    for (final part in _parts) {
      t.addAll(part.tris);
      bias.addAll(List.filled(part.tris.length ~/ 3, part.bias * 3));
    }
    for (var i = 0; i < t.length; i += 3) {
      final a = t[i] * 3, b = t[i + 1] * 3, c = t[i + 2] * 3;
      final ux = pos[b] - pos[a], uy = pos[b + 1] - pos[a + 1], uz = pos[b + 2] - pos[a + 2];
      final vx = pos[c] - pos[a], vy = pos[c + 1] - pos[a + 1], vz = pos[c + 2] - pos[a + 2];
      final nx = uy * vz - uz * vy, ny = uz * vx - ux * vz, nz = ux * vy - uy * vx;
      for (final v in [a, b, c]) {
        nrm[v] += nx;
        nrm[v + 1] += ny;
        nrm[v + 2] += nz;
      }
    }
    for (var v = 0; v < n; v++) {
      final i = v * 3;
      final pole = _fixedN[v];
      if (pole != null) {
        nrm[i] = pole.x;
        nrm[i + 1] = pole.y;
        nrm[i + 2] = pole.z;
        continue;
      }
      var x = nrm[i], y = nrm[i + 1], z = nrm[i + 2];
      if (x * _hint[i] + y * _hint[i + 1] + z * _hint[i + 2] < 0) {
        x = -x;
        y = -y;
        z = -z;
      }
      final l = math.sqrt(x * x + y * y + z * z);
      if (l < 1e-9) {
        nrm[i] = _hint[i];
        nrm[i + 1] = _hint[i + 1];
        nrm[i + 2] = _hint[i + 2];
      } else {
        nrm[i] = x / l;
        nrm[i + 1] = y / l;
        nrm[i + 2] = z / l;
      }
    }
    final br = Float32List(n);
    if (breath != null) {
      for (var v = 0; v < n; v++) {
        br[v] = breath(pos[v * 3], pos[v * 3 + 1], pos[v * 3 + 2]);
      }
    }
    final mesh = Mesh(
      pos: pos,
      nrm: nrm,
      col: Float32List.fromList(_c),
      region: Uint8List.fromList(_r),
      tri: Uint16List.fromList(t),
      breath: br,
      bias: Float32List.fromList(bias),
    );
    mesh.edges; // adjacency for AA, computed here (off the UI isolate when built in one)
    return mesh;
  }
}
