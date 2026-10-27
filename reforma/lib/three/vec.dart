import 'dart:math' as math;

/// Minimal immutable 3D vector used while building meshes. Per-frame work
/// runs on flat typed arrays instead (see [BodyView]).
class V3 {
  const V3(this.x, this.y, this.z);

  final double x, y, z;

  static const zero = V3(0, 0, 0);
  static const up = V3(0, 1, 0);
  static const fwd = V3(0, 0, 1);
  static const right = V3(1, 0, 0);

  V3 operator +(V3 o) => V3(x + o.x, y + o.y, z + o.z);
  V3 operator -(V3 o) => V3(x - o.x, y - o.y, z - o.z);
  V3 operator *(double s) => V3(x * s, y * s, z * s);
  V3 operator -() => V3(-x, -y, -z);

  double dot(V3 o) => x * o.x + y * o.y + z * o.z;
  V3 cross(V3 o) => V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  double get length => math.sqrt(x * x + y * y + z * z);

  V3 get norm {
    final l = length;
    return l < 1e-9 ? this : V3(x / l, y / l, z / l);
  }

  /// Mirror across the body's sagittal plane.
  V3 get mx => V3(-x, y, z);

  static V3 lerp(V3 a, V3 b, double t) => V3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);

  /// Centripetal-ish Catmull-Rom between p1 and p2.
  static V3 catmull(V3 p0, V3 p1, V3 p2, V3 p3, double t) {
    final t2 = t * t, t3 = t2 * t;
    double c(double a, double b, double cc, double d) =>
        0.5 * ((2 * b) + (-a + cc) * t + (2 * a - 5 * b + 4 * cc - d) * t2 + (-a + 3 * b - 3 * cc + d) * t3);
    return V3(c(p0.x, p1.x, p2.x, p3.x), c(p0.y, p1.y, p2.y, p3.y), c(p0.z, p1.z, p2.z, p3.z));
  }

  @override
  String toString() => 'V3(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, ${z.toStringAsFixed(2)})';
}
