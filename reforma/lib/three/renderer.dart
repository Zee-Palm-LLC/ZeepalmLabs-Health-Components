import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart' show Alignment;

import 'mesh.dart';
import 'vec.dart';

class Hit {
  const Hit(this.region, this.point, this.normal);

  final int region;
  final V3 point; // model space
  final V3 normal; // model space
}

/// Software 3D pipeline feeding [Canvas.drawVertices]: rotates + lights every
/// vertex on the CPU, culls back faces, depth-sorts the rest with an O(n)
/// bucket sort (painter's algorithm) and keeps all buffers preallocated so a
/// frame allocates nothing but the [Vertices] handle.
///
/// drawVertices has no anti-aliasing, so silhouette edges (one adjacent
/// triangle facing us, the other away) get a 1-px fringe quad fading from the
/// edge colour to transparent. The fringe is depth-sorted with everything
/// else, so edges hidden behind nearer geometry stay hidden.
class BodyView {
  BodyView(this.mesh) : _fringeCap = math.min(7000, (65535 - mesh.vertexCount) ~/ 2) {
    final n = mesh.vertexCount, tc = mesh.triCount, f2 = _fringeCap * 2;
    xy = Float32List((n + f2) * 2);
    vz = Float32List(n);
    vn = Float32List(n * 3);
    colors = Int32List(n + f2);
    order = Uint16List((tc + f2) * 3);
    _visT = Int32List(tc + f2);
    _dep = Float32List(tc + f2);
    _key = Int32List(tc + f2);
    _sorted = Int32List(tc + f2);
    _front = Uint8List(tc);
    _extra = Uint16List(f2 * 3);
  }

  Mesh mesh;
  final int _fringeCap;
  late final Float32List xy, vz, vn;
  late final Int32List colors;
  late final Uint16List order;
  late final Int32List _visT, _key, _sorted;
  late final Float32List _dep;
  late final Uint8List _front;
  late final Uint16List _extra;
  static const _buckets = 1024;
  final _counts = Int32List(_buckets + 1);
  int visible = 0;

  // Camera of the last update (for projecting hotspots and hit-testing).
  double _cy = 1, _sy = 0, _cp = 1, _sp = 0, _scale = 1, _ox = 0, _oy = 0;
  V3 _pivot = V3.zero;
  double _breath = 0;
  static const focal = 900.0;

  // Light rig (view space, y up, +z toward the viewer).
  static final _key0 = const V3(-0.45, 0.42, 0.79).norm;
  static final _fill = const V3(0.75, 0.05, 0.45).norm;
  static final _half = (_key0 + V3.fwd).norm;

  void update({
    required double yaw,
    double pitch = 0,
    required double scale,
    required Offset origin,
    V3 pivot = V3.zero,
    double breath = 0,
    int selected = -1,
    double selAmt = 0,
    Color rim = const Color(0xFFB9A6F5),
    double rimAmt = 0.34,
    double exposure = 1,
    V3? spot,
    double spotR = 8.5,
    double spotAmt = 0,
    double aa = 0.9,
  }) {
    _cy = math.cos(yaw);
    _sy = math.sin(yaw);
    _cp = math.cos(pitch);
    _sp = math.sin(pitch);
    _scale = scale;
    _ox = origin.dx;
    _oy = origin.dy;
    _pivot = pivot;
    _breath = breath;

    final m = mesh;
    final pos = m.pos, nrm = m.nrm, col = m.col, reg = m.region, br = m.breath, bias = m.bias;
    final n = m.vertexCount;
    final rr = rim.r * rimAmt, rg = rim.g * rimAmt, rb = rim.b * rimAmt;
    final lx = _key0.x, ly = _key0.y, lz = _key0.z;
    final fx = _fill.x, fy = _fill.y, fz = _fill.z;
    final hx = _half.x, hy = _half.y, hz = _half.z;
    final selOn = selected >= 0 && selAmt > 0.001;
    final spotOn = spot != null && spotAmt > 0.001;
    final spx = spot?.x ?? 0, spy = spot?.y ?? 0, spz = spot?.z ?? 0, sr2 = 1 / (spotR * spotR);
    final px = pivot.x, py = pivot.y, pz = pivot.z;
    final cy = _cy, sy = _sy, cp = _cp, sp = _sp;

    for (var v = 0; v < n; v++) {
      final i3 = v * 3;
      var x = pos[i3] - px, y = pos[i3 + 1] - py, z = pos[i3 + 2] - pz;
      if (breath != 0) {
        final w = br[v];
        if (w > 0) {
          final k = 1 + 0.016 * breath * w;
          x *= k;
          z = (z + pz) * k - pz;
        }
        final yy = pos[i3 + 1];
        if (yy > 118) y += 0.38 * breath * ((yy - 118) / 18).clamp(0.0, 1.0);
      }
      // yaw about Y, then pitch about X
      final x1 = x * cy + z * sy;
      final z1 = -x * sy + z * cy;
      final y2 = y * cp - z1 * sp;
      final z2 = y * sp + z1 * cp;
      final k = focal / (focal - z2);
      xy[v * 2] = _ox + x1 * scale * k;
      xy[v * 2 + 1] = _oy - y2 * scale * k;
      vz[v] = z2;

      final nx0 = nrm[i3], ny0 = nrm[i3 + 1], nz0 = nrm[i3 + 2];
      final nx = nx0 * cy + nz0 * sy;
      final nz1 = -nx0 * sy + nz0 * cy;
      final ny = ny0 * cp - nz1 * sp;
      final nz = ny0 * sp + nz1 * cp;
      vn[i3] = nx;
      vn[i3 + 1] = ny;
      vn[i3 + 2] = nz;

      var d1 = (nx * lx + ny * ly + nz * lz + 0.3) / 1.3;
      if (d1 < 0) d1 = 0;
      var d2 = nx * fx + ny * fy + nz * fz;
      if (d2 < 0) d2 = 0;
      var s = nx * hx + ny * hy + nz * hz;
      if (s < 0) s = 0;
      final s2 = s * s, s4 = s2 * s2, s8 = s4 * s4, s16 = s8 * s8;
      final spec = s16 * s8 * s4 * 0.15;
      final f = 1 - (nz < 0 ? 0 : nz);
      final rimK = f * f * f;
      final light = (0.44 + 0.08 * ny + 0.56 * d1 + 0.16 * d2) * exposure;

      var r = col[i3], g = col[i3 + 1], b = col[i3 + 2];
      if (selOn && reg[v] == selected) {
        final t = selAmt * 0.62;
        r += (0.66 - r) * t;
        g += (0.55 - g) * t;
        b += (0.98 - b) * t;
      }
      if (spotOn) {
        final dx = pos[i3] - spx, dy = pos[i3 + 1] - spy, dz = pos[i3 + 2] - spz;
        final q = 1 - (dx * dx + dy * dy + dz * dz) * sr2;
        if (q > 0) {
          final t = q * q * spotAmt * 0.7;
          r += (0.64 - r) * t;
          g += (0.53 - g) * t;
          b += (0.98 - b) * t;
        }
      }
      r = r * light + spec + rimK * rr;
      g = g * light + spec + rimK * rg;
      b = b * light + spec + rimK * rb;
      final ri = r >= 1 ? 255 : (r <= 0 ? 0 : (r * 255).toInt());
      final gi = g >= 1 ? 255 : (g <= 0 ? 0 : (g * 255).toInt());
      final bi = b >= 1 ? 255 : (b <= 0 ? 0 : (b * 255).toInt());
      colors[v] = (0xFF << 24) | (ri << 16) | (gi << 8) | bi;
    }

    // Cull + bucket sort back-to-front.
    final tri = m.tri;
    final tc = m.triCount;
    var vc = 0;
    var zmin = double.infinity, zmax = -double.infinity;
    final front = _front;
    for (var t = 0; t < tc; t++) {
      final a = tri[t * 3], b = tri[t * 3 + 1], c = tri[t * 3 + 2];
      final ax = xy[a * 2], ay = xy[a * 2 + 1];
      final area = (xy[b * 2] - ax) * (xy[c * 2 + 1] - ay) - (xy[b * 2 + 1] - ay) * (xy[c * 2] - ax);
      if (area >= 0) {
        front[t] = 0;
        continue;
      }
      front[t] = 1;
      final d = vz[a] + vz[b] + vz[c] + bias[t];
      _visT[vc] = t;
      _dep[vc] = d;
      if (d < zmin) zmin = d;
      if (d > zmax) zmax = d;
      vc++;
    }

    // Silhouette fringe (anti-aliasing).
    if (aa > 0) {
      final e = m.edges;
      var fv = n, fx = 0;
      for (var i = 0; i < e.length && fx < _fringeCap; i += 4) {
        final t1 = e[i + 2], t2 = e[i + 3];
        if (front[t1] == front[t2]) continue;
        final tf = front[t1] == 1 ? t1 : t2;
        final a = e[i], b = e[i + 1];
        var c = tri[tf * 3];
        if (c == a || c == b) c = tri[tf * 3 + 1];
        if (c == a || c == b) c = tri[tf * 3 + 2];
        final ax = xy[a * 2], ay = xy[a * 2 + 1], bx = xy[b * 2], by = xy[b * 2 + 1];
        final ex = bx - ax, ey = by - ay;
        final len = math.sqrt(ex * ex + ey * ey);
        if (len < 1e-4) continue;
        var nx = -ey / len, ny = ex / len;
        if ((xy[c * 2] - ax) * nx + (xy[c * 2 + 1] - ay) * ny > 0) {
          nx = -nx;
          ny = -ny;
        }
        xy[fv * 2] = ax + nx * aa;
        xy[fv * 2 + 1] = ay + ny * aa;
        xy[fv * 2 + 2] = bx + nx * aa;
        xy[fv * 2 + 3] = by + ny * aa;
        colors[fv] = colors[a] & 0x00FFFFFF;
        colors[fv + 1] = colors[b] & 0x00FFFFFF;
        final x6 = fx * 6;
        _extra[x6] = a;
        _extra[x6 + 1] = b;
        _extra[x6 + 2] = fv + 1;
        _extra[x6 + 3] = a;
        _extra[x6 + 4] = fv + 1;
        _extra[x6 + 5] = fv;
        final d = (vz[a] + vz[b]) * 1.5 + bias[tf] + 0.2;
        for (var k = 0; k < 2; k++) {
          _visT[vc] = tc + fx * 2 + k;
          _dep[vc] = d;
          vc++;
        }
        if (d < zmin) zmin = d;
        if (d > zmax) zmax = d;
        fv += 2;
        fx++;
      }
    }
    final counts = _counts..fillRange(0, _buckets + 1, 0);
    final kk = zmax > zmin ? (_buckets - 1) / (zmax - zmin) : 0.0;
    for (var i = 0; i < vc; i++) {
      final key = ((_dep[i] - zmin) * kk).toInt();
      _key[i] = key;
      counts[key + 1]++;
    }
    for (var i = 1; i <= _buckets; i++) {
      counts[i] += counts[i - 1];
    }
    for (var i = 0; i < vc; i++) {
      _sorted[counts[_key[i]]++] = _visT[i];
    }
    for (var i = 0; i < vc; i++) {
      final id = _sorted[i];
      if (id < tc) {
        final t = id * 3;
        order[i * 3] = tri[t];
        order[i * 3 + 1] = tri[t + 1];
        order[i * 3 + 2] = tri[t + 2];
      } else {
        final t = (id - tc) * 3;
        order[i * 3] = _extra[t];
        order[i * 3 + 1] = _extra[t + 1];
        order[i * 3 + 2] = _extra[t + 2];
      }
    }
    visible = vc;
  }

  void draw(Canvas canvas, [Paint? paint]) {
    if (visible == 0) return;
    final v = Vertices.raw(
      VertexMode.triangles,
      xy,
      colors: colors,
      indices: Uint16List.sublistView(order, 0, visible * 3),
    );
    canvas.drawVertices(v, BlendMode.dst, paint ?? Paint());
    v.dispose();
  }

  /// Projects a model-space point; `facing` > 0 when its normal faces the camera.
  (Offset, double facing) project(V3 p, [V3 n = V3.fwd]) {
    final x = p.x - _pivot.x, z = p.z - _pivot.z;
    var y = p.y - _pivot.y;
    if (_breath != 0 && p.y > 118) y += 0.38 * _breath * ((p.y - 118) / 18).clamp(0.0, 1.0);
    final x1 = x * _cy + z * _sy;
    final z1 = -x * _sy + z * _cy;
    final y2 = y * _cp - z1 * _sp;
    final z2 = y * _sp + z1 * _cp;
    final k = focal / (focal - z2);
    final nz1 = -n.x * _sy + n.z * _cy;
    final nz = n.y * _sp + nz1 * _cp;
    return (Offset(_ox + x1 * _scale * k, _oy - y2 * _scale * k), nz);
  }

  /// Front-most triangle under [p] → region + exact surface point.
  Hit? hitTest(Offset p) {
    final pos = mesh.pos, nrm = mesh.nrm, n = mesh.vertexCount;
    for (var i = visible - 1; i >= 0; i--) {
      final a = order[i * 3], b = order[i * 3 + 1], c = order[i * 3 + 2];
      if (a >= n || b >= n || c >= n) continue; // AA fringe
      final ax = xy[a * 2], ay = xy[a * 2 + 1];
      final bx = xy[b * 2], by = xy[b * 2 + 1];
      final cx = xy[c * 2], cy = xy[c * 2 + 1];
      final den = (by - cy) * (ax - cx) + (cx - bx) * (ay - cy);
      if (den.abs() < 1e-9) continue;
      final w0 = ((by - cy) * (p.dx - cx) + (cx - bx) * (p.dy - cy)) / den;
      final w1 = ((cy - ay) * (p.dx - cx) + (ax - cx) * (p.dy - cy)) / den;
      final w2 = 1 - w0 - w1;
      if (w0 < 0 || w1 < 0 || w2 < 0) continue;
      V3 at(Float32List l) => V3(
            l[a * 3] * w0 + l[b * 3] * w1 + l[c * 3] * w2,
            l[a * 3 + 1] * w0 + l[b * 3 + 1] * w1 + l[c * 3 + 1] * w2,
            l[a * 3 + 2] * w0 + l[b * 3 + 2] * w1 + l[c * 3 + 2] * w2,
          );
      final r = w0 >= w1 && w0 >= w2 ? a : (w1 >= w2 ? b : c);
      return Hit(mesh.region[r], at(pos), at(nrm).norm);
    }
    return null;
  }

  /// Screen-space bounds of the visible mesh after [update].
  Rect bounds() {
    var l = double.infinity, t = double.infinity, r = -double.infinity, b = -double.infinity;
    for (var i = 0; i < visible * 3; i++) {
      final v = order[i];
      final x = xy[v * 2], y = xy[v * 2 + 1];
      if (x < l) l = x;
      if (x > r) r = x;
      if (y < t) t = y;
      if (y > b) b = y;
    }
    return Rect.fromLTRB(l, t, r, b);
  }
}

/// Renders a still of [mesh] fitted into [box] (used for thumbnails, cached
/// as a [Picture] so it costs one replay per paint).
Picture renderStill(
  Mesh mesh, {
  required Rect box,
  double yaw = 0,
  double pitch = 0,
  Alignment align = Alignment.center,
  double fill = 0.9,
  bool fitWidth = false,
  Color rim = const Color(0xFFB9A6F5),
  double rimAmt = 0.34,
  List<V3>? frame,
  double frameDx = 0,
  void Function(Canvas canvas, BodyView view)? under,
  void Function(Canvas canvas, BodyView view)? over,
}) {
  final view = BodyView(mesh);
  view.update(yaw: yaw, pitch: pitch, scale: 1, origin: Offset.zero, rim: rim, rimAmt: rimAmt);
  late final double s;
  late final Offset origin;
  if (frame != null) {
    // Frame a vertical span of the body (e.g. head to chest for a bust).
    final (a, _) = view.project(frame[0]);
    final (b, _) = view.project(frame[1]);
    s = box.height * fill / (b.dy - a.dy).abs();
    final top = a.dy < b.dy ? a : b;
    origin = Offset(box.center.dx + frameDx * box.width - (a.dx + b.dx) / 2 * s, box.top + box.height * (1 - fill) / 2 - top.dy * s);
  } else {
    final bb = view.bounds();
    s = fitWidth ? box.width * fill / bb.width : math.min(box.width * fill / bb.width, box.height * fill / bb.height);
    final dst = align.inscribe(Size(bb.width * s, bb.height * s), box.deflate(box.shortestSide * (1 - fill) / 2));
    origin = Offset(dst.left - bb.left * s, dst.top - bb.top * s);
  }
  view.update(yaw: yaw, pitch: pitch, scale: s, origin: origin, rim: rim, rimAmt: rimAmt);
  final rec = PictureRecorder();
  final canvas = Canvas(rec);
  under?.call(canvas, view);
  view.draw(canvas);
  over?.call(canvas, view);
  return rec.endRecording();
}
