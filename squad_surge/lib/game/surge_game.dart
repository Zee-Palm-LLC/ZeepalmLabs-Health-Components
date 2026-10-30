import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sprites.dart';

// ── Camera: a fixed perspective down the bridge ─────────────────────────────
// World x runs -1..1 across the deck; z is distance ahead of the camera.
const _w = 390.0, _h = 844.0;
const _horizon = 170.0, _groundNear = 760.0, _laneHalf = 170.0, _focal = 9.0;
const squadZ = 1.0;
const _scroll = 6.5; // world speed toward the camera (gates, deck)
const _bruteSpeed = 9.0;

double depth(double z) => _focal / (_focal + z);
Offset project(double x, double z, [double lift = 0]) {
  final s = depth(z);
  return Offset(_w / 2 + x * _laneHalf * s, _horizon + (_groundNear - _horizon) * s - lift * s);
}

enum Phase { ready, playing, won, lost }

enum Op { add, sub, mul, div }

class GateOp {
  const GateOp(this.op, this.v);
  final Op op;
  final int v;
  bool get good => op == Op.add || op == Op.mul;
  String get label => switch (op) {
    Op.add => '+$v',
    Op.sub => '-$v',
    Op.mul => '×$v',
    Op.div => '÷$v',
  };
  int apply(int n) => switch (op) {
    Op.add => n + v,
    Op.sub => n - v,
    Op.mul => n * v,
    Op.div => n ~/ v,
  }.clamp(0, 9999);
}

class _Unit {
  _Unit(this.x, this.z, this.born);
  double x, z, born;
  final double phase = math.Random().nextDouble() * 4;
}

class _Brute {
  _Brute(this.x, this.z, this.hp);
  double x, z, hp, flash = 0;
  final double phase = math.Random().nextDouble() * 4;
}

class _Gate {
  _Gate(this.z, this.left, this.right);
  double z;
  final GateOp left, right;
  bool passed = false;
  double fade = 1, flash = 0;
  bool tookLeft = false;
}

class _Boss {
  _Boss(this.z, this.hp) : maxHp = hp;
  double x = 0, z, hp, flash = 0;
  final double maxHp;
}

class _Bullet {
  _Bullet(this.x, this.z);
  double x, z;
}

class _Spark {
  _Spark(this.p, this.v, this.life, this.color, this.size, {this.gravity = 900});
  Offset p, v;
  double life, age = 0;
  final double size, gravity;
  final Color color;
}

class _Float {
  _Float(this.text, this.p, this.color, this.size);
  final String text;
  Offset p;
  double age = 0;
  final Color color;
  final double size;
}

/// One scripted level: squad steering, multiplier gates, red waves, and a boss.
class SurgeGame extends FlameGame {
  final hud = ValueNotifier<int>(0); // bumps every frame so overlays rebuild
  late final Sprites sprites;
  final _rnd = math.Random(7);

  Phase phase = Phase.ready;
  double t = 0, clock = 0, slowmo = 1, shake = 0, endAt = 0;
  int count = 5, coins = 1240, level = 7;
  double countPop = 0;
  double squadX = 0, targetX = 0;
  final _units = <_Unit>[];
  final _brutes = <_Brute>[];
  final _gates = <_Gate>[];
  final _bullets = <_Bullet>[];
  final _sparks = <_Spark>[];
  final _floats = <_Float>[];
  final _flashes = <(Offset, double)>[];
  _Boss? _boss;

  /// Boss health 0..1 while the boss is on the bridge.
  double? get bossHealth => _boss == null ? null : (_boss!.hp / _boss!.maxHp).clamp(0.0, 1.0);
  double _fireAcc = 0, _eatAcc = 0, _bossDmg = 0, _bossDmgAt = 0;
  int _next = 0;

  // ── Level script: (arrival time at the squad, what) ──
  late final List<(double, void Function(double z))> _script = [
    (1.7, (z) => _gates.add(_Gate(z, const GateOp(Op.add, 10), const GateOp(Op.mul, 2)))),
    (3.4, (z) => _wave(14, z, 5)),
    (5.0, (z) => _gates.add(_Gate(z, const GateOp(Op.mul, 3), const GateOp(Op.sub, 8)))),
    (6.9, (z) => _wave(26, z, 5)),
    (8.6, (z) => _gates.add(_Gate(z, const GateOp(Op.add, 40), const GateOp(Op.mul, 2)))),
    (10.5, (z) => _wave(44, z, 6)),
    (12.1, (z) => _gates.add(_Gate(z, const GateOp(Op.div, 2), const GateOp(Op.mul, 2)))),
  ];
  static const _bossAt = 13.2;

  double _lead(int i) => i.isOdd ? 30 / _bruteSpeed : 30 / _scroll;
  double get progress => phase == Phase.won ? 1 : (t / (_bossAt + 4)).clamp(0.0, 1.0);

  @override
  Future<void> onLoad() async {
    sprites = Sprites.bake();
    // Text is laid out once and cached, so wait for the display font first.
    GoogleFonts.lilitaOne();
    await GoogleFonts.pendingFonts();
    _formation();
  }

  void start() {
    if (phase != Phase.ready) return;
    phase = Phase.playing;
  }

  void steer(double dxPx) {
    if (phase == Phase.ready) start();
    targetX += dxPx / (_laneHalf * depth(squadZ)) * 1.15;
  }

  void restart() {
    phase = Phase.ready;
    t = 0;
    count = 5;
    squadX = targetX = 0;
    slowmo = 1;
    _boss = null;
    _next = 0;
    for (final l in [_brutes, _gates, _bullets, _sparks, _floats, _flashes]) {
      l.clear();
    }
    _units.clear();
    _formation();
  }

  // ── Squad formation (sunflower packing, squashed in depth) ──
  double get _radius => math.min(0.82, 0.07 * math.sqrt(math.max(1, _visible)) + 0.04);
  int get _visible => math.min(count, 240);

  Offset _slot(int i) {
    final n = math.max(1, _visible);
    final spread = math.min(1.0, 0.82 / (0.07 * math.sqrt(n) + 1e-6));
    final r = math.sqrt(i + 0.5) * 0.07 * spread;
    final a = i * 2.39996;
    final dz = (math.sin(a) * r / 0.07 * 0.16 * spread).clamp(-0.55, 2.4);
    return Offset(math.cos(a) * r, dz);
  }

  void _formation() {
    while (_units.length < _visible) {
      _units.add(_Unit(squadX + (_rnd.nextDouble() - 0.5) * 0.08, squadZ + _rnd.nextDouble() * 0.2, clock));
    }
    while (_units.length > _visible) {
      final u = _units.removeLast();
      _burst(project(u.x, u.z, 20), const Color(0xFF2F86F0), 6);
    }
  }

  void _wave(int n, double z0, double hp) {
    for (var i = 0; i < n; i++) {
      final row = i ~/ 6;
      _brutes.add(_Brute((_rnd.nextDouble() * 1.6 - 0.8), z0 + row * 1.1 + _rnd.nextDouble() * 0.8, hp));
    }
  }

  // ── Simulation ──
  @override
  void update(double dt) {
    super.update(dt);
    dt = math.min(dt, 1 / 20);
    clock += dt;
    final sdt = dt * slowmo;
    slowmo += (1 - slowmo) * math.min(1, dt * 1.6);
    shake *= math.pow(0.02, dt).toDouble();
    countPop *= math.pow(0.004, dt).toDouble();

    if (phase == Phase.playing) {
      t += sdt;
      while (_next < _script.length && t >= _script[_next].$1 - _lead(_next)) {
        final (at, spawn) = _script[_next];
        final speed = _next.isOdd ? _bruteSpeed : _scroll;
        spawn(squadZ + (at - t) * speed);
        _next++;
      }
      if (_boss == null && t >= _bossAt) {
        _boss = _Boss(19, 520);
        _floats.add(_Float('BOSS!', const Offset(_w / 2, 300), const Color(0xFFFF4D4D), 46));
      }
    }

    // Steering.
    final r = _radius;
    targetX = targetX.clamp(-1 + r, 1 - r);
    squadX += (targetX - squadX) * math.min(1, dt * 14);
    for (var i = 0; i < _units.length; i++) {
      final s = _slot(i);
      final u = _units[i];
      final k = math.min(1.0, dt * 9);
      u.x += (squadX + s.dx - u.x) * k;
      u.z += (squadZ + s.dy - u.z) * k;
    }

    if (phase != Phase.playing && phase != Phase.won) {
      _updateFx(dt);
      hud.value++;
      return;
    }

    // Firing.
    if (phase == Phase.playing && _units.isNotEmpty) {
      _fireAcc += math.min(count * 2.4, 95) * sdt;
      while (_fireAcc >= 1) {
        _fireAcc -= 1;
        final u = _units[_rnd.nextInt(_units.length)];
        _bullets.add(_Bullet(u.x + 0.02 + (_rnd.nextDouble() - 0.5) * 0.03, u.z + 0.2));
        if (_rnd.nextDouble() < 0.35) _flashes.add((project(u.x + 0.03, u.z, 50), clock));
      }
    }

    // Bullets.
    for (var i = _bullets.length - 1; i >= 0; i--) {
      final b = _bullets[i];
      final z0 = b.z;
      b.z += 40 * sdt;
      var hit = false;
      for (final e in _brutes) {
        if ((e.x - b.x).abs() < 0.085 && b.z >= e.z - 0.1 && z0 <= e.z + 0.5) {
          e.hp -= 1;
          e.flash = 1;
          hit = true;
          _burst(project(b.x, e.z, 28), const Color(0xFFFFD35A), 2, speed: 160, life: 0.25, size: 2.2);
          break;
        }
      }
      final bs = _boss;
      if (!hit && bs != null && (bs.x - b.x).abs() < 0.5 && b.z >= bs.z - 0.2) {
        bs.hp -= 1;
        bs.flash = 1;
        hit = true;
        _bossDmg += 1;
        shake = math.max(shake, 2.2);
        _burst(project(b.x, bs.z, 60 + _rnd.nextDouble() * 120), const Color(0xFFFFE07A), 2, speed: 220, life: 0.3, size: 2.6);
      }
      if (hit || b.z > 24) _bullets.removeAt(i);
    }
    if (_bossDmg > 0 && clock - _bossDmgAt > 0.2 && _boss != null) {
      final p = project(_boss!.x + (_rnd.nextDouble() - 0.5) * 1.2, _boss!.z, 200 + _rnd.nextDouble() * 120);
      _floats.add(_Float('-${(_bossDmg * 3).round()}', p, const Color(0xFFFFE07A), 30));
      _bossDmg = 0;
      _bossDmgAt = clock;
    }

    // Brutes charge and home in on the squad.
    for (var i = _brutes.length - 1; i >= 0; i--) {
      final e = _brutes[i];
      e.z -= _bruteSpeed * sdt;
      e.x += (squadX - e.x) * 0.45 * sdt;
      e.flash = math.max(0, e.flash - dt * 8);
      if (e.hp <= 0) {
        _brutes.removeAt(i);
        coins += 2;
        _burst(project(e.x, e.z, 22), const Color(0xFFE53935), 12, speed: 260);
        _ring(project(e.x, e.z, 18), depth(e.z));
        continue;
      }
      if (e.z <= squadZ + 0.45 && (e.x - squadX).abs() < _radius + 0.12 && count > 0) {
        _brutes.removeAt(i);
        count = math.max(0, count - 1);
        _formation();
        _burst(project(e.x, e.z, 22), const Color(0xFFE53935), 10, speed: 240);
        shake = math.max(shake, 4);
        continue;
      }
      if (e.z < -0.6) _brutes.removeAt(i);
    }

    // Gates.
    for (var i = _gates.length - 1; i >= 0; i--) {
      final g = _gates[i];
      g.z -= _scroll * sdt;
      g.flash = math.max(0, g.flash - dt * 3);
      if (!g.passed && g.z <= squadZ) {
        g.passed = true;
        g.tookLeft = squadX < 0;
        final op = g.tookLeft ? g.left : g.right;
        final before = count;
        count = op.apply(count);
        g.flash = 1;
        countPop = 1;
        _formation();
        final p = project(squadX, squadZ, 90);
        _floats.add(_Float(op.label, p, op.good ? const Color(0xFF7CFFB2) : const Color(0xFFFF6B6B), 40));
        if (count > before) {
          for (var k = 0; k < 14; k++) {
            _burst(
              project(squadX + (_rnd.nextDouble() - 0.5) * _radius * 2, squadZ, 10),
              const Color(0xFF8FD3FF),
              1,
              speed: 200,
              life: 0.6,
              size: 3,
            );
          }
        }
      }
      if (g.passed) g.fade -= dt * 2.5;
      if (g.fade <= 0 || g.z < -1) _gates.removeAt(i);
    }

    // Boss.
    final bs = _boss;
    if (bs != null) {
      bs.flash = math.max(0, bs.flash - dt * 7);
      if (bs.hp > 0) {
        if (bs.z > squadZ + 1.1) {
          bs.z -= 1.9 * sdt;
        } else if (count > 0) {
          _eatAcc += 14 * sdt;
          while (_eatAcc >= 1 && count > 0) {
            _eatAcc -= 1;
            count--;
          }
          _formation();
          shake = math.max(shake, 6);
        }
      } else if (phase == Phase.playing) {
        _bossDown(bs);
      }
    }
    if (phase == Phase.playing && count <= 0) {
      phase = Phase.lost;
      endAt = clock;
    }

    _updateFx(dt);
    hud.value++;
  }

  void _bossDown(_Boss bs) {
    phase = Phase.won;
    endAt = clock;
    slowmo = 0.25;
    shake = 16;
    coins += 250;
    final c = project(bs.x, bs.z, 110);
    for (var k = 0; k < 4; k++) {
      _ring(c, 2.4 + k * 0.8);
    }
    _burst(c, const Color(0xFFFF5A3C), 40, speed: 520, life: 1.0, size: 6);
    _burst(c, const Color(0xFFFFD35A), 40, speed: 420, life: 0.9, size: 5);
    // Confetti.
    const cols = [Color(0xFF4FC3F7), Color(0xFFFFD54F), Color(0xFFFF7043), Color(0xFF81C784), Color(0xFFBA68C8)];
    for (var k = 0; k < 90; k++) {
      _sparks.add(
        _Spark(
          Offset(_rnd.nextDouble() * _w, -20 - _rnd.nextDouble() * 200),
          Offset((_rnd.nextDouble() - 0.5) * 120, 120 + _rnd.nextDouble() * 160),
          3.5,
          cols[k % cols.length],
          5,
          gravity: 60,
        ),
      );
    }
    _boss = null;
  }

  void _burst(Offset p, Color c, int n, {double speed = 200, double life = 0.55, double size = 4}) {
    for (var i = 0; i < n; i++) {
      final a = _rnd.nextDouble() * math.pi * 2;
      final v = speed * (0.4 + _rnd.nextDouble() * 0.6);
      _sparks.add(
        _Spark(
          p,
          Offset(math.cos(a) * v, math.sin(a) * v - speed * 0.4),
          life * (0.6 + _rnd.nextDouble() * 0.5),
          c,
          size * (0.6 + _rnd.nextDouble() * 0.7),
        ),
      );
    }
  }

  final _rings = <(Offset, double, double)>[]; // centre, scale, born
  void _ring(Offset p, double s) => _rings.add((p, s, clock));

  void _updateFx(double dt) {
    for (var i = _sparks.length - 1; i >= 0; i--) {
      final s = _sparks[i];
      s.age += dt;
      s.v = Offset(s.v.dx * math.pow(0.3, dt), s.v.dy + s.gravity * dt);
      s.p += s.v * dt;
      if (s.age > s.life) _sparks.removeAt(i);
    }
    for (var i = _floats.length - 1; i >= 0; i--) {
      final f = _floats[i];
      f.age += dt;
      f.p += Offset(0, -60 * dt);
      if (f.age > 1.0) _floats.removeAt(i);
    }
    _flashes.removeWhere((f) => clock - f.$2 > 0.06);
    _rings.removeWhere((r) => clock - r.$3 > 0.5);
  }

  // ── Rendering ──
  @override
  void render(Canvas canvas) {
    canvas.save();
    if (shake > 0.2) {
      canvas.translate((_rnd.nextDouble() - 0.5) * shake, (_rnd.nextDouble() - 0.5) * shake);
    }
    _drawWorld(canvas);
    _drawActors(canvas);
    _drawFx(canvas);
    canvas.restore();
    super.render(canvas);
  }

  double get _travel => (phase == Phase.playing || phase == Phase.won) ? t * _scroll : clock * 1.2;

  void _drawWorld(Canvas c) {
    // Sky and distant haze.
    c.drawRect(
      const Rect.fromLTWH(-20, -20, _w + 40, _horizon + 22),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7EC8FF), Color(0xFFCFEBFF)],
        ).createShader(const Rect.fromLTWH(0, 0, _w, _horizon)),
    );
    final hills = Path()..moveTo(-20, _horizon + 2);
    for (var x = -20.0; x <= _w + 20; x += 10) {
      hills.lineTo(x, _horizon - 14 - 10 * math.sin(x * 0.021) - 6 * math.sin(x * 0.063 + 1));
    }
    hills
      ..lineTo(_w + 20, _horizon + 2)
      ..close();
    c.drawPath(hills, Paint()..color = const Color(0xFFA9CFEA));
    // Water.
    const water = Rect.fromLTWH(-20, _horizon, _w + 40, _h - _horizon + 20);
    c.drawRect(
      water,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6CC4EE), Color(0xFF1E8BD0), Color(0xFF1268B3)],
          stops: [0, 0.35, 1],
        ).createShader(water),
    );
    final glint = Paint()
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 46; i++) {
      final side = i.isEven ? -1 : 1;
      final x = side * (1.35 + (i * 37 % 100) / 100 * 2.6);
      final z = ((i * 13.7) - _travel * 0.9) % 40;
      final p = project(x, z), s = depth(z);
      glint.color = Colors.white.withValues(alpha: 0.35 * (1 - z / 40));
      c.drawLine(p - Offset(9 * s, 0), p + Offset(9 * s, 0), glint);
    }

    // Deck.
    const far = 80.0;
    Path quad(double x0, double x1, double z0, double z1, [double lift0 = 0, double lift1 = 0]) => Path()
      ..moveTo(project(x0, z0, lift0).dx, project(x0, z0, lift0).dy)
      ..lineTo(project(x1, z0, lift0).dx, project(x1, z0, lift0).dy)
      ..lineTo(project(x1, z1, lift1).dx, project(x1, z1, lift1).dy)
      ..lineTo(project(x0, z1, lift1).dx, project(x0, z1, lift1).dy)
      ..close();
    // Underside shadow on the water.
    c.drawPath(quad(-1.3, 1.3, -1.5, far), Paint()..color = const Color(0x33062A4F));
    c.drawPath(
      quad(-1.12, 1.12, -1.5, far),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEDEAE4), Color(0xFFD3CCC2)],
        ).createShader(const Rect.fromLTWH(0, _horizon, _w, _groundNear - _horizon)),
    );
    // Lane dashes and edge lines, scrolling.
    final dash = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (var k = 0; k < 27; k++) {
      final z0 = k * 3.0 - _travel % 3.0 - 1.5;
      if (z0 > far) continue;
      c.drawPath(quad(-0.025, 0.025, z0, z0 + 1.3), dash);
    }
    c.drawPath(quad(-1.02, -0.99, -1.5, far), Paint()..color = const Color(0xFFF4C430));
    c.drawPath(quad(0.99, 1.02, -1.5, far), Paint()..color = const Color(0xFFF4C430));
    // Side walls: red barriers with scrolling posts.
    for (final side in [-1.0, 1.0]) {
      final inner = side * 1.12, outer = side * 1.2;
      final wall = Path()
        ..moveTo(project(inner, -1.5).dx, project(inner, -1.5).dy)
        ..lineTo(project(inner, far).dx, project(inner, far).dy)
        ..lineTo(project(inner, far, 34).dx, project(inner, far, 34).dy)
        ..lineTo(project(inner, -1.5, 34).dx, project(inner, -1.5, 34).dy)
        ..close();
      c.drawPath(wall, Paint()..color = const Color(0xFFE5483E));
      final top = Path()
        ..moveTo(project(inner, -1.5, 34).dx, project(inner, -1.5, 34).dy)
        ..lineTo(project(inner, far, 34).dx, project(inner, far, 34).dy)
        ..lineTo(project(outer, far, 34).dx, project(outer, far, 34).dy)
        ..lineTo(project(outer, -1.5, 34).dx, project(outer, -1.5, 34).dy)
        ..close();
      c.drawPath(top, Paint()..color = const Color(0xFFFF7A6B));
      final stripe = Paint()..color = Colors.white.withValues(alpha: 0.9);
      for (var k = 0; k < 40; k++) {
        final z = k * 2.0 - _travel % 2.0;
        if (z < -1.4 || z > far) continue;
        final a = project(inner, z, 8), b = project(inner, z, 26);
        c.drawLine(a, b, stripe..strokeWidth = 3.2 * depth(z));
      }
    }
    // Distance haze where the bridge meets the horizon.
    const haze = Rect.fromLTWH(-20, _horizon - 4, _w + 40, 110);
    c.drawRect(
      haze,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFD6EEFF).withValues(alpha: 0.95), const Color(0xFFD6EEFF).withValues(alpha: 0)],
        ).createShader(haze),
    );
  }

  void _drawActors(Canvas c) {
    // Sort everything far → near.
    final items = <(double, void Function())>[];
    for (final g in _gates) {
      items.add((g.z + 0.01, () => _drawGate(c, g)));
    }
    for (final e in _brutes) {
      items.add((e.z, () => _drawChar(c, sprites.brute, e.x, e.z, 50, e.phase, e.flash)));
    }
    final bs = _boss;
    if (bs != null) items.add((bs.z, () => _drawBoss(c, bs)));
    for (final u in _units) {
      items.add((u.z, () => _drawChar(c, sprites.soldier, u.x, u.z, 44, u.phase, 0, born: u.born)));
    }
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final it in items) {
      it.$2();
    }
    // Bullets glow on top.
    final glow = Paint()
      ..blendMode = BlendMode.plus
      ..strokeCap = StrokeCap.round;
    for (final b in _bullets) {
      final a = project(b.x, b.z - 0.9, 30), p = project(b.x, b.z, 30), s = depth(b.z);
      glow
        ..color = const Color(0xAAFFB300)
        ..strokeWidth = 5 * s;
      c.drawLine(a, p, glow);
      glow
        ..color = const Color(0xFFFFF3C0)
        ..strokeWidth = 2 * s;
      c.drawLine(a, p, glow);
    }
    for (final (p, _) in _flashes) {
      c.drawCircle(p, 5, Paint()..color = const Color(0xFFFFF0A0));
      c.drawCircle(p, 10, Paint()..color = const Color(0x66FFB300));
    }
    if (_units.isNotEmpty && phase != Phase.won) _drawCount(c);
  }

  void _drawChar(Canvas c, Sprite sp, double x, double z, double baseH, double phase, double flash, {double? born}) {
    final s = depth(z);
    if (s <= 0) return;
    final p = project(x, z);
    var hPx = baseH * s;
    if (born != null) {
      final k = ((clock - born) / 0.25).clamp(0.0, 1.0);
      hPx *= Curves.easeOutBack.transform(k);
      if (hPx <= 0.5) return;
    }
    final wPx = hPx * sp.w / sp.h;
    c.drawOval(Rect.fromCenter(center: p, width: wPx * 0.9, height: wPx * 0.32), Paint()..color = const Color(0x33000000));
    final frame = sp.frames[((clock * 11 + phase) % sp.frames.length).floor()];
    // The squad hops in celebration after the boss falls.
    final hop = born != null && this.phase == Phase.won ? (math.sin(clock * 9 + phase * 2).abs() * 14 * s) : 0.0;
    final dst = Rect.fromLTWH(p.dx - wPx / 2, p.dy - hPx - hop, wPx, hPx);
    final paint = Paint()..filterQuality = FilterQuality.medium;
    if (flash > 0) {
      paint.colorFilter = ColorFilter.mode(Colors.white.withValues(alpha: flash * 0.7), BlendMode.srcATop);
    }
    c.drawImageRect(frame, Rect.fromLTWH(0, 0, frame.width.toDouble(), frame.height.toDouble()), dst, paint);
  }

  void _drawBoss(Canvas c, _Boss bs) {
    final stomp = math.sin(clock * 5).abs();
    final s = depth(bs.z);
    final p = project(bs.x, bs.z);
    final hPx = 330 * s * (1 + stomp * 0.03);
    final wPx = hPx * sprites.boss.w / sprites.boss.h;
    c.drawOval(Rect.fromCenter(center: p, width: wPx * 0.8, height: wPx * 0.22), Paint()..color = const Color(0x44000000));
    final frame = sprites.boss.frames[((clock * 6) % 4).floor()];
    final paint = Paint()..filterQuality = FilterQuality.medium;
    if (bs.flash > 0) paint.colorFilter = ColorFilter.mode(Colors.white.withValues(alpha: bs.flash * 0.5), BlendMode.srcATop);
    c.drawImageRect(
      frame,
      Rect.fromLTWH(0, 0, frame.width.toDouble(), frame.height.toDouble()),
      Rect.fromLTWH(p.dx - wPx / 2, p.dy - hPx, wPx, hPx),
      paint,
    );
  }

  void _drawGate(Canvas c, _Gate g) {
    final s = depth(g.z);
    final alpha = g.fade.clamp(0.0, 1.0);
    for (final left in [true, false]) {
      final op = left ? g.left : g.right;
      final x0 = left ? -0.97 : 0.03, x1 = left ? -0.03 : 0.97;
      final a = project(x0, g.z, 96), b = project(x1, g.z);
      final r = Rect.fromPoints(a, b);
      final base = op.good ? const Color(0xFF2E9BFF) : const Color(0xFFFF4D4D);
      final chosen = g.passed && g.tookLeft == left;
      final fill = Color.lerp(base, Colors.white, chosen ? g.flash * 0.7 : 0)!;
      c.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(10 * s)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              fill.withValues(alpha: 0.55 * alpha),
              fill.withValues(alpha: 0.25 * alpha),
            ],
          ).createShader(r),
      );
      c.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(10 * s)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 * s
          ..color = Color.lerp(base, Colors.white, 0.45)!.withValues(alpha: alpha),
      );
      _text(
        c,
        op.label,
        r.center,
        54 * s,
        Colors.white.withValues(alpha: alpha),
        stroke: base.withValues(alpha: alpha),
      );
    }
  }

  void _drawCount(Canvas c) {
    final p = project(squadX, squadZ + 0.6 + _radius * 2.2, 62);
    final scale = 1 + countPop * 0.45;
    final label = '$count';
    final w = 26.0 + label.length * 13;
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: p, width: w * scale, height: 34 * scale),
      Radius.circular(17 * scale),
    );
    c.drawRRect(r.shift(const Offset(0, 3)), Paint()..color = const Color(0x40000000));
    c.drawRRect(r, Paint()..color = const Color(0xFF1F6FE5));
    c.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.white,
    );
    _text(c, label, p, 22 * scale, Colors.white);
  }

  void _drawFx(Canvas c) {
    for (final s in _sparks) {
      final k = 1 - s.age / s.life;
      c.drawCircle(s.p, s.size * (0.4 + 0.6 * k), Paint()..color = s.color.withValues(alpha: k.clamp(0.0, 1.0)));
    }
    for (final (p, sc, born) in _rings) {
      final k = ((clock - born) / 0.5).clamp(0.0, 1.0);
      c.drawCircle(
        p,
        (10 + 50 * k) * sc,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 * (1 - k) * sc
          ..color = Colors.white.withValues(alpha: 0.8 * (1 - k)),
      );
    }
    for (final f in _floats) {
      final k = (f.age / 1.0).clamp(0.0, 1.0);
      final pop = f.age < 0.15 ? Curves.easeOutBack.transform(f.age / 0.15) : 1.0;
      _text(
        c,
        f.text,
        f.p,
        f.size * pop,
        f.color.withValues(alpha: 1 - k * k),
        stroke: const Color(0xCC000000).withValues(alpha: 0.8 * (1 - k * k)),
      );
    }
  }

  static final _textCache = <String, TextPainter>{};

  void _text(Canvas c, String s, Offset center, double size, Color color, {Color? stroke}) {
    if (size < 4) return;
    // Lay out at a fixed size once per string, then scale.
    final key = '$s|${stroke != null}';
    final tp = _textCache.putIfAbsent(key, () {
      final style = GoogleFonts.lilitaOne(fontSize: 64, color: Colors.white);
      return TextPainter(
        text: TextSpan(text: s, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
    });
    final k = size / 64;
    c.save();
    c.translate(center.dx, center.dy);
    c.scale(k);
    final o = Offset(-tp.width / 2, -tp.height / 2);
    if (stroke != null) {
      final outline = _textCache.putIfAbsent('$s|outline', () {
        final style = GoogleFonts.lilitaOne(
          fontSize: 64,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..strokeJoin = StrokeJoin.round
            ..color = Colors.white,
        );
        return TextPainter(
          text: TextSpan(text: s, style: style),
          textDirection: TextDirection.ltr,
        )..layout();
      });
      c.saveLayer(null, Paint()..colorFilter = ColorFilter.mode(stroke, BlendMode.srcIn));
      outline.paint(c, o);
      c.restore();
    }
    c.saveLayer(null, Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn));
    tp.paint(c, o);
    c.restore();
    c.restore();
  }
}
