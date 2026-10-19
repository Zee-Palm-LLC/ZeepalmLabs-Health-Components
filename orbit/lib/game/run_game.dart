import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Phase { ready, playing, over }

enum Kind { coin, gem, heart, magnet, shield, rock, fire, wood }

class Thing {
  Thing(this.kind, this.lane, this.z, {this.lift = 0});

  final Kind kind;
  final int lane;
  double z;
  double lift;
  bool taken = false;
  double pull = 0;
  double pullX = 0;

  bool get hazard => kind == Kind.rock || kind == Kind.fire || kind == Kind.wood;
  bool get jumpable => kind == Kind.fire || kind == Kind.wood;
}

class Prop {
  Prop(this.image, this.side, this.z, this.offset, this.height);

  final String image;
  final int side;
  double z;
  final double offset;
  final double height;
}

class Spark {
  Spark(this.p, this.v, this.color, this.life, this.size, {this.gravity = 900, this.star = false});

  Offset p;
  Offset v;
  final Color color;
  double life;
  final double max = 0;
  final double size;
  final double gravity;
  final bool star;
  double age = 0;
}

class Popup {
  Popup(this.text, this.p, this.color, {this.size = 26});

  final String text;
  Offset p;
  final Color color;
  final double size;
  double age = 0;
}

class Stats {
  final phase = ValueNotifier(Phase.ready);
  final coins = ValueNotifier(0);
  final meters = ValueNotifier(0);
  final seconds = ValueNotifier(0);
  final lives = ValueNotifier(3);
  final boost = ValueNotifier(0.0);
  final boosting = ValueNotifier(false);
  final combo = ValueNotifier(0);
  final countdown = ValueNotifier(3);
  final checkpoint = ValueNotifier(0);
  final shield = ValueNotifier(false);
  final magnet = ValueNotifier(0.0);
  static int best = 0;

  int get score => meters.value + coins.value * 10;
}

class RunGame extends FlameGame with KeyboardEvents {
  RunGame({this.seed = 7, this.autoStart = true});

  static const horizon = 430.0;
  static const depth = 460.0;
  static const laneUnit = 150.0;
  static const runnerZ = 1.55;
  static const farZ = 46.0;
  static const centerX = 201.0;

  final int seed;
  final bool autoStart;
  final stats = Stats();
  final hero = ValueNotifier<Rect>(Rect.zero);
  final airborne = ValueNotifier(false);
  bool useModel = false;
  late math.Random rng;

  final images0 = <String, ui.Image>{};
  late List<Sprite> runFrames;
  late List<Sprite> jumpFrames;

  final things = <Thing>[];
  final props = <Prop>[];
  final sparks = <Spark>[];
  final popups = <Popup>[];

  double travelled = 0;
  double speed = 0;
  double baseSpeed = 13;
  double laneX = 0;
  int lane = 0;
  double jumpH = 0;
  double jumpV = 0;
  double squash = 0;
  double runClock = 0;
  double shake = 0;
  double flash = 0;
  double hurt = 0;
  double nextSpawn = 14;
  double nextProp = 2;
  double readyClock = 0;
  double boostLeft = 0;
  double slowmo = 0;
  double overClock = 0;
  double clock = 0;
  double tumble = 0;
  double comboClock = 0;
  int lastCheckpoint = 0;

  double get boostFactor => stats.boosting.value ? 1.75 : 1.0;

  @override
  Color backgroundColor() => const Color(0xFF6A5FD8);

  @override
  Future<void> onLoad() async {
    images.prefix = 'assets/';
    for (final n in ['rock', 'fire', 'wood', 'gem_stone', 'red_heart', 'magnet', 'shield', 'deciduous_tree', 'evergreen_tree', 'cactus', 'tulip', 'mushroom', 'rocket']) {
      images0[n] = await images.load('game/$n.webp');
    }
    images0['coin'] = await images.load('art/coin.webp');
    images0['plate'] = await images.load('plates/run.webp');
    final sheet = await images.load('game/runner_sheet.webp');
    const fw = 198.0;
    const fh = 470.0;
    Sprite frame(int i) => Sprite(sheet, srcPosition: Vector2(i * fw, 0), srcSize: Vector2(fw, fh));
    runFrames = [for (var i = 0; i < 12; i++) frame(i)];
    jumpFrames = [for (var i = 12; i < 15; i++) frame(i)];
    add(_Stage());
    add(_Input());
    reset();
    if (!autoStart) readyClock = -1;
  }

  void reset() {
    rng = math.Random(seed);
    things.clear();
    props.clear();
    sparks.clear();
    popups.clear();
    travelled = 0;
    speed = 0;
    baseSpeed = 13;
    laneX = 0;
    lane = 0;
    jumpH = 0;
    jumpV = 0;
    shake = 0;
    flash = 0;
    hurt = 0;
    nextSpawn = 16;
    nextProp = 1;
    readyClock = 0;
    boostLeft = 0;
    slowmo = 0;
    overClock = 0;
    tumble = 0;
    lastCheckpoint = 0;
    stats.coins.value = 0;
    stats.meters.value = 0;
    stats.seconds.value = 0;
    stats.lives.value = 3;
    stats.boost.value = 0.35;
    stats.boosting.value = false;
    stats.combo.value = 0;
    stats.countdown.value = 3;
    stats.shield.value = false;
    stats.magnet.value = 0;
    stats.phase.value = Phase.ready;
    for (var z = 2.0; z < farZ; z += 2.2) {
      _addProps(z);
    }
  }

  void restart() {
    reset();
    readyClock = 0;
  }

  void moveLane(int dir) {
    if (stats.phase.value != Phase.playing) return;
    final next = (lane + dir).clamp(-1, 1);
    if (next == lane) {
      shake = math.max(shake, 0.25);
      return;
    }
    lane = next;
    HapticFeedback.selectionClick();
    _dust(Offset(_runnerScreenX(), _groundY(runnerZ)), 6, dir.toDouble());
  }

  void jump() {
    if (stats.phase.value != Phase.playing || jumpH > 0.01) return;
    jumpV = 9.5;
    squash = -0.25;
    HapticFeedback.lightImpact();
    _dust(Offset(_runnerScreenX(), _groundY(runnerZ)), 10, 0);
  }

  void fireBoost() {
    if (stats.phase.value != Phase.playing || stats.boosting.value || stats.boost.value < 1) return;
    stats.boosting.value = true;
    boostLeft = 5;
    shake = 0.8;
    HapticFeedback.heavyImpact();
    _pop('BOOST!', const Offset(201, 520), const Color(0xFFFF7AD0), size: 44);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.keyA) moveLane(-1);
    if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.keyD) moveLane(1);
    if (k == LogicalKeyboardKey.arrowUp || k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.keyW) jump();
    if (k == LogicalKeyboardKey.keyB) fireBoost();
    return KeyEventResult.handled;
  }

  double _ppu(double z) => laneUnit / z;

  double _groundY(double z) => horizon + depth / z;

  double _laneScreenX(double laneWorld, double z) => centerX + laneWorld * _ppu(z);

  double _runnerScreenX() => _laneScreenX(laneX, runnerZ);

  @override
  void update(double dt) {
    dt = math.min(dt, 1 / 20);
    clock += dt;
    final phase = stats.phase.value;
    if (slowmo > 0) {
      slowmo -= dt;
      dt *= 0.3;
    }
    if (phase == Phase.ready && readyClock >= 0) {
      readyClock += dt;
      final c = 3 - readyClock.floor();
      if (c != stats.countdown.value) {
        stats.countdown.value = c;
        if (c > 0) HapticFeedback.selectionClick();
      }
      if (readyClock >= 3) {
        stats.phase.value = Phase.playing;
        HapticFeedback.mediumImpact();
        _pop('GO!', const Offset(201, 470), const Color(0xFFFFD34A), size: 64);
      }
    }
    final playing = stats.phase.value == Phase.playing;
    if (playing) {
      baseSpeed = math.min(30, baseSpeed + dt * 0.22);
      speed += ((baseSpeed * boostFactor) - speed) * math.min(1, dt * 3);
    } else if (stats.phase.value == Phase.over) {
      speed *= math.pow(0.15, dt).toDouble();
      overClock += dt;
      tumble = math.min(1, tumble + dt * 2.5);
    } else {
      speed = 0;
    }
    final step = speed * dt;
    travelled += step;
    if (playing) {
      stats.meters.value = (travelled * 0.5).floor();
      stats.seconds.value = (stats.meters.value > 0) ? (clock - 3).clamp(0, 99999).floor() : 0;
      final cp = stats.meters.value ~/ 500;
      if (cp > lastCheckpoint) {
        lastCheckpoint = cp;
        stats.checkpoint.value = cp;
        slowmo = 0.6;
        flash = 0.5;
        HapticFeedback.heavyImpact();
        stats.coins.value += 25;
        _burst(const Offset(201, 330), const Color(0xFFFFD34A), 50, 420);
      }
    }

    laneX += (lane - laneX) * math.min(1, dt * 14);
    if (jumpH > 0 || jumpV > 0) {
      jumpV -= 26 * dt;
      jumpH += jumpV * dt;
      if (jumpH <= 0) {
        jumpH = 0;
        jumpV = 0;
        squash = 0.28;
        _dust(Offset(_runnerScreenX(), _groundY(runnerZ)), 12, 0);
      }
    }
    squash *= math.pow(0.0005, dt).toDouble();
    runClock += dt * (0.6 + speed / 14);
    shake = math.max(0, shake - dt * 2.2);
    flash = math.max(0, flash - dt * 2.5);
    hurt = math.max(0, hurt - dt);
    comboClock -= dt;
    if (comboClock <= 0 && stats.combo.value > 0) stats.combo.value = 0;
    if (stats.magnet.value > 0) stats.magnet.value = math.max(0, stats.magnet.value - dt / 8);

    if (stats.boosting.value) {
      boostLeft -= dt;
      stats.boost.value = math.max(0, boostLeft / 5);
      if (clock % 0.05 < dt) {
        sparks.add(Spark(Offset(_runnerScreenX() + (rng.nextDouble() - 0.5) * 30, _groundY(runnerZ) - 10), Offset((rng.nextDouble() - 0.5) * 80, 260 + rng.nextDouble() * 200), Color.lerp(const Color(0xFFFF7AD0), const Color(0xFFFFD34A), rng.nextDouble())!, 0.5, 5, gravity: 0, star: true));
      }
      if (boostLeft <= 0) {
        stats.boosting.value = false;
        stats.boost.value = 0;
      }
    }

    for (final t in things) {
      t.z -= step;
    }
    for (final p in props) {
      p.z -= step;
    }
    props.removeWhere((p) => p.z < 0.6);
    while (nextProp - travelled < farZ) {
      _addProps(nextProp - travelled);
      nextProp += 2.2;
    }
    if (playing) {
      while (nextSpawn - travelled < farZ) {
        _spawn(nextSpawn - travelled);
        nextSpawn += 7 + rng.nextDouble() * 4 - math.min(2.5, baseSpeed / 12);
      }
      _collide();
    }
    things.removeWhere((t) => t.z < 0.5 || (t.taken && t.pull >= 1));
    final heroX = _runnerScreenX();
    final heroBottom = _groundY(runnerZ) - jumpH * _ppu(runnerZ) * 0.42 + 10;
    hero.value = Rect.fromLTWH(heroX - 150, heroBottom - 282, 300, 300);
    airborne.value = jumpH > 0.01;

    for (final s in sparks) {
      s.age += dt;
      s.v = Offset(s.v.dx * math.pow(0.4, dt), s.v.dy + s.gravity * dt);
      s.p += s.v * dt;
    }
    sparks.removeWhere((s) => s.age >= s.life);
    for (final p in popups) {
      p.age += dt;
      p.p = p.p.translate(0, -60 * dt);
    }
    popups.removeWhere((p) => p.age > 1.0);
    super.update(dt);
  }

  void _addProps(double z) {
    for (final side in const [-1, 1]) {
      if (rng.nextDouble() < 0.25) continue;
      final pick = rng.nextDouble();
      final (img, h) = pick < 0.45
          ? ('deciduous_tree', 4.2 + rng.nextDouble() * 1.4)
          : pick < 0.75
              ? ('evergreen_tree', 4.4 + rng.nextDouble() * 1.4)
              : pick < 0.85
                  ? ('mushroom', 1.3)
                  : pick < 0.93
                      ? ('tulip', 1.1)
                      : ('cactus', 2.6);
      props.add(Prop(img, side, z + rng.nextDouble() * 1.4, 2.25 + rng.nextDouble() * 1.6, h));
    }
  }

  void _spawn(double z) {
    final r = rng.nextDouble();
    final open = rng.nextInt(3) - 1;
    if (r < 0.32) {
      final l = rng.nextInt(3) - 1;
      final n = 5 + rng.nextInt(3);
      for (var i = 0; i < n; i++) {
        things.add(Thing(Kind.coin, l, z + i * 1.5));
      }
    } else if (r < 0.52) {
      for (final l in const [-1, 0, 1]) {
        if (l == open) continue;
        things.add(Thing(Kind.rock, l, z));
      }
      for (var i = 0; i < 4; i++) {
        things.add(Thing(Kind.coin, open, z - 3 + i * 1.5));
      }
    } else if (r < 0.72) {
      final l = rng.nextInt(3) - 1;
      things.add(Thing(rng.nextBool() ? Kind.fire : Kind.wood, l, z));
      for (var i = 0; i < 5; i++) {
        final u = i / 4;
        things.add(Thing(Kind.coin, l, z - 3 + i * 1.5, lift: 1.7 * math.sin(u * math.pi)));
      }
    } else if (r < 0.86) {
      final a = rng.nextInt(3) - 1;
      var b = rng.nextInt(3) - 1;
      if (b == a) b = a == 1 ? -1 : a + 1;
      things.add(Thing(Kind.fire, a, z));
      things.add(Thing(Kind.rock, b, z + 4));
      things.add(Thing(Kind.gem, -a - b == 0 ? 0 : (-a - b).clamp(-1, 1), z + 2, lift: 0.3));
    } else {
      final l = rng.nextInt(3) - 1;
      final pick = rng.nextDouble();
      final kind = stats.lives.value < 3 && pick < 0.35
          ? Kind.heart
          : pick < 0.65
              ? Kind.magnet
              : Kind.shield;
      things.add(Thing(kind, l, z, lift: 0.4));
      for (final o in const [-1, 1]) {
        if (l + o >= -1 && l + o <= 1) things.add(Thing(Kind.coin, l + o, z));
      }
    }
  }

  void _collide() {
    final mag = stats.magnet.value > 0;
    for (final t in things) {
      if (t.taken) continue;
      final near = (t.z - runnerZ).abs() < 0.45;
      final sameLane = (t.lane - laneX).abs() < 0.45;
      if (mag && (t.kind == Kind.coin || t.kind == Kind.gem) && t.z < runnerZ + 6 && t.z > runnerZ - 0.4) {
        _take(t);
        continue;
      }
      if (!near || !sameLane) continue;
      if (t.hazard) {
        if (t.jumpable && jumpH > 0.55) continue;
        if (stats.boosting.value) {
          t.taken = true;
          t.pull = 1;
          shake = 0.6;
          _burst(_screenOf(t), const Color(0xFFFFB86A), 22, 260);
          _pop('SMASH!', _screenOf(t), const Color(0xFFFFB86A));
          continue;
        }
        if (hurt > 0) continue;
        t.taken = true;
        t.pull = 1;
        _hit(t);
        continue;
      }
      final reach = t.lift < 0.8 || jumpH > t.lift - 0.6;
      if (reach) _take(t);
    }
  }

  void _take(Thing t) {
    t.taken = true;
    t.pullX = t.lane.toDouble();
    final p = _screenOf(t);
    switch (t.kind) {
      case Kind.coin:
        stats.coins.value += 1;
        stats.combo.value += 1;
        comboClock = 1.2;
        stats.boost.value = stats.boosting.value ? stats.boost.value : math.min(1, stats.boost.value + 0.04);
        _burst(p, const Color(0xFFFFD34A), 8, 160);
        if (stats.combo.value % 10 == 0) {
          _pop('COMBO x${stats.combo.value}!', const Offset(201, 380), const Color(0xFFFF7AD0), size: 34);
          HapticFeedback.mediumImpact();
        } else {
          _pop('+1', p, const Color(0xFFFFE27A), size: 22);
        }
      case Kind.gem:
        stats.coins.value += 10;
        _burst(p, const Color(0xFF7FE0FF), 26, 280);
        _pop('+10 GEM!', p, const Color(0xFF9FEAFF), size: 30);
        HapticFeedback.mediumImpact();
      case Kind.heart:
        stats.lives.value = math.min(3, stats.lives.value + 1);
        _burst(p, const Color(0xFFFF5C8A), 24, 240);
        _pop('+1 LIFE', p, const Color(0xFFFF8FB0), size: 30);
      case Kind.magnet:
        stats.magnet.value = 1;
        _burst(p, const Color(0xFFFF6A6A), 24, 240);
        _pop('MAGNET!', p, const Color(0xFFFF9A9A), size: 30);
      case Kind.shield:
        stats.shield.value = true;
        _burst(p, const Color(0xFF8FD8FF), 24, 240);
        _pop('SHIELD!', p, const Color(0xFFB0E6FF), size: 30);
      default:
        break;
    }
    HapticFeedback.selectionClick();
  }

  void _hit(Thing t) {
    final p = _screenOf(t);
    shake = 1;
    flash = 0.9;
    stats.combo.value = 0;
    _burst(p, const Color(0xFFFF6A3A), 30, 300);
    if (stats.shield.value) {
      stats.shield.value = false;
      hurt = 1.0;
      _pop('BLOCKED!', p, const Color(0xFFB0E6FF), size: 32);
      HapticFeedback.mediumImpact();
      return;
    }
    hurt = 1.6;
    stats.lives.value -= 1;
    HapticFeedback.heavyImpact();
    _pop('OUCH!', p, const Color(0xFFFF6A6A), size: 34);
    if (stats.lives.value <= 0) {
      stats.phase.value = Phase.over;
      slowmo = 1.0;
      Stats.best = math.max(Stats.best, stats.score);
    }
  }

  Offset _screenOf(Thing t) {
    final z = math.max(t.z, 0.8);
    return Offset(_laneScreenX(t.lane.toDouble(), z), _groundY(z) - (t.lift + 0.4) * _ppu(z));
  }

  void _dust(Offset at, int n, double dir) {
    for (var i = 0; i < n; i++) {
      final a = math.pi + rng.nextDouble() * math.pi;
      sparks.add(Spark(at, Offset(math.cos(a) * (60 + rng.nextDouble() * 90) - dir * 80, math.sin(a) * (40 + rng.nextDouble() * 80)), const Color(0xFFFFE2C2), 0.45, 4 + rng.nextDouble() * 4, gravity: 300));
    }
  }

  void _burst(Offset at, Color color, int n, double power) {
    for (var i = 0; i < n; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final v = power * (0.4 + rng.nextDouble() * 0.6);
      sparks.add(Spark(at, Offset(math.cos(a) * v, math.sin(a) * v - 120), color, 0.55 + rng.nextDouble() * 0.35, 3 + rng.nextDouble() * 4, star: rng.nextDouble() < 0.4));
    }
  }

  void _pop(String text, Offset at, Color color, {double size = 26}) => popups.add(Popup(text, at, color, size: size));
}

class _Input extends PositionComponent with DragCallbacks, TapCallbacks, HasGameReference<RunGame> {
  Vector2 _drag = Vector2.zero();
  bool _used = false;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _drag = Vector2.zero();
    _used = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _drag += event.localDelta;
    if (_used) return;
    if (_drag.x.abs() > 28 && _drag.x.abs() > _drag.y.abs()) {
      game.moveLane(_drag.x > 0 ? 1 : -1);
      _used = true;
    } else if (_drag.y < -28 && _drag.y.abs() > _drag.x.abs()) {
      game.jump();
      _used = true;
    }
  }

  @override
  void onTapUp(TapUpEvent event) => game.jump();
}

class _Stage extends Component with HasGameReference<RunGame> {
  static final _textCache = <String, TextPainter>{};

  @override
  void render(Canvas canvas) {
    final g = game;
    final shake = g.shake * g.shake * 9;
    canvas.save();
    if (shake > 0) canvas.translate(math.sin(g.clock * 70) * shake, math.cos(g.clock * 53) * shake);
    final zoom = g.stats.boosting.value ? 1.04 : 1.0;
    if (zoom != 1) {
      canvas.translate(201, 600);
      canvas.scale(zoom);
      canvas.translate(-201, -600);
    }
    _sky(canvas, g);
    _ground(canvas, g);
    _world(canvas, g);
    _effects(canvas, g);
    canvas.restore();
    if (g.flash > 0) {
      canvas.drawRect(const Rect.fromLTWH(0, 0, 402, 874), Paint()..color = (g.hurt > 0 ? const Color(0xFFFF3A3A) : const Color(0xFFFFF4D0)).withValues(alpha: g.flash * 0.35));
    }
  }

  void _sky(Canvas canvas, RunGame g) {
    final img = g.images0['plate']!;
    final par = -g.laneX * 6;
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height * (RunGame.horizon + 40) / 874);
    final dst = Rect.fromLTWH(-12 + par, 0, 426, RunGame.horizon + 40);
    canvas.drawImageRect(img, src, dst, Paint()..filterQuality = FilterQuality.medium);
    canvas.drawRect(
      const Rect.fromLTWH(0, RunGame.horizon - 60, 402, 100),
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, RunGame.horizon - 60), const Offset(0, RunGame.horizon + 40), [const Color(0x00F7B9C8), const Color(0xCCF7C3B0)], [0, 1]),
    );
  }

  void _ground(Canvas canvas, RunGame g) {
    var z = RunGame.farZ;
    final paint = Paint()..isAntiAlias = false;
    while (z > 0.75) {
      final z2 = z * 0.93;
      final y1 = g._groundY(z);
      final y2 = math.min(g._groundY(z2), 900.0);
      final band = ((z + g.travelled) / 2.2).floor().isEven;
      final fog = ((z - 8) / (RunGame.farZ - 8)).clamp(0.0, 1.0);
      final grass = Color.lerp(band ? const Color(0xFF6DBA4A) : const Color(0xFF5FA940), const Color(0xFFD9B8E0), fog * 0.75)!;
      paint.color = grass;
      canvas.drawRect(Rect.fromLTRB(0, y1, 402, y2 + 1), paint);
      final half1 = 1.75 * g._ppu(z);
      final half2 = 1.75 * g._ppu(z2);
      final road = Color.lerp(band ? const Color(0xFFF7A766) : const Color(0xFFF29257), const Color(0xFFF2C6C8), fog * 0.75)!;
      final path = Path()
        ..moveTo(RunGame.centerX - half1, y1)
        ..lineTo(RunGame.centerX + half1, y1)
        ..lineTo(RunGame.centerX + half2, y2 + 1)
        ..lineTo(RunGame.centerX - half2, y2 + 1)
        ..close();
      paint.color = road;
      canvas.drawPath(path, paint);
      final edge1 = 0.14 * g._ppu(z);
      final edge2 = 0.14 * g._ppu(z2);
      for (final s in const [-1.0, 1.0]) {
        final e = Path()
          ..moveTo(RunGame.centerX + s * half1, y1)
          ..lineTo(RunGame.centerX + s * (half1 + edge1), y1)
          ..lineTo(RunGame.centerX + s * (half2 + edge2), y2 + 1)
          ..lineTo(RunGame.centerX + s * half2, y2 + 1)
          ..close();
        paint.color = Color.lerp(band ? const Color(0xFFFFE08A) : const Color(0xFFFFC75A), const Color(0xFFF6D6D6), fog)!;
        canvas.drawPath(e, paint);
      }
      if (band) {
        for (final s in const [-0.5, 0.5]) {
          final w1 = 0.05 * g._ppu(z);
          final w2 = 0.05 * g._ppu(z2);
          final x1 = RunGame.centerX + s * g._ppu(z);
          final x2 = RunGame.centerX + s * g._ppu(z2);
          final d = Path()
            ..moveTo(x1 - w1, y1)
            ..lineTo(x1 + w1, y1)
            ..lineTo(x2 + w2, y2)
            ..lineTo(x2 - w2, y2)
            ..close();
          paint.color = Colors.white.withValues(alpha: 0.55 * (1 - fog));
          canvas.drawPath(d, paint);
        }
      }
      z = z2;
    }
    canvas.drawRect(
      const Rect.fromLTWH(0, RunGame.horizon, 402, 40),
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, RunGame.horizon), const Offset(0, RunGame.horizon + 40), [const Color(0xFFF7C9C0), const Color(0x00F7C9C0)], [0, 1]),
    );
  }

  void _world(Canvas canvas, RunGame g) {
    final items = <(double, void Function())>[];
    for (final p in g.props) {
      items.add((p.z, () => _prop(canvas, g, p)));
    }
    for (final t in g.things) {
      if (t.taken && t.kind != Kind.coin && t.kind != Kind.gem) continue;
      if (t.taken) continue;
      items.add((t.z, () => _thing(canvas, g, t)));
    }
    items.add((RunGame.runnerZ, () => _runner(canvas, g)));
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, draw) in items) {
      draw();
    }
  }

  void _shadow(Canvas canvas, Offset at, double w, double alpha) {
    canvas.drawOval(
      Rect.fromCenter(center: at, width: w, height: w * 0.28),
      Paint()
        ..color = const Color(0xFF5A2A4A).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _sprite(Canvas canvas, ui.Image img, Offset foot, double h, {double alpha = 1, double rot = 0, double sx = 1}) {
    final w = h * img.width / img.height;
    canvas.save();
    canvas.translate(foot.dx, foot.dy);
    if (rot != 0) canvas.rotate(rot);
    canvas.scale(sx, 1);
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(-w / 2, -h, w, h),
      Paint()
        ..filterQuality = FilterQuality.medium
        ..color = Color.fromRGBO(255, 255, 255, alpha),
    );
    canvas.restore();
  }

  double _fogAlpha(double z) => 1 - ((z - 30) / (RunGame.farZ - 30)).clamp(0.0, 1.0);

  void _prop(Canvas canvas, RunGame g, Prop p) {
    if (p.z < 0.6) return;
    final x = RunGame.centerX + p.side * p.offset * g._ppu(p.z);
    final y = g._groundY(p.z);
    final h = p.height * g._ppu(p.z) * 0.62;
    if (x < -h || x > 402 + h) return;
    _shadow(canvas, Offset(x, y), h * 0.5, 0.25 * _fogAlpha(p.z));
    _sprite(canvas, g.images0[p.image]!, Offset(x, y + h * 0.02), h, alpha: _fogAlpha(p.z));
  }

  void _thing(Canvas canvas, RunGame g, Thing t) {
    final z = math.max(t.z, 0.7);
    final ppu = g._ppu(z);
    final x = g._laneScreenX(t.lane.toDouble(), z);
    final y = g._groundY(z);
    final a = _fogAlpha(z);
    final bob = math.sin(g.clock * 4 + t.z) * 0.08;
    switch (t.kind) {
      case Kind.coin:
        final s = 0.55 * ppu;
        final lift = (t.lift + 0.35 + bob) * ppu;
        _shadow(canvas, Offset(x, y), s * 0.8, 0.18 * a);
        final spin = math.cos(g.clock * 6 + t.z * 0.7);
        canvas.drawCircle(
          Offset(x, y - lift),
          s * 0.75,
          Paint()
            ..color = const Color(0xFFFFD34A).withValues(alpha: 0.35 * a)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.35),
        );
        _sprite(canvas, g.images0['coin']!, Offset(x, y - lift + s / 2), s, alpha: a, sx: 0.25 + 0.75 * spin.abs());
      case Kind.gem:
      case Kind.heart:
      case Kind.magnet:
      case Kind.shield:
        final name = switch (t.kind) {
          Kind.gem => 'gem_stone',
          Kind.heart => 'red_heart',
          Kind.magnet => 'magnet',
          _ => 'shield',
        };
        final s = 0.85 * ppu;
        final lift = (t.lift + 0.4 + bob * 2) * ppu;
        _shadow(canvas, Offset(x, y), s * 0.7, 0.2 * a);
        canvas.drawCircle(
          Offset(x, y - lift - s * 0.45),
          s * 0.75,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.45 * a)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.4),
        );
        _sprite(canvas, g.images0[name]!, Offset(x, y - lift), s, alpha: a, rot: math.sin(g.clock * 3) * 0.12);
      case Kind.rock:
        final s = 1.5 * ppu;
        _shadow(canvas, Offset(x, y), s * 1.1, 0.35 * a);
        _sprite(canvas, g.images0['rock']!, Offset(x, y + s * 0.06), s, alpha: a);
      case Kind.fire:
        final s = 1.2 * ppu;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: s * 1.4, height: s * 0.45),
          Paint()
            ..color = const Color(0xFFFF6A1A).withValues(alpha: 0.5 * a)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.2),
        );
        final flick = 1 + 0.08 * math.sin(g.clock * 22 + t.z);
        canvas.save();
        canvas.translate(x, y);
        canvas.scale(1, flick);
        canvas.translate(-x, -y);
        _sprite(canvas, g.images0['fire']!, Offset(x, y + s * 0.05), s, alpha: a);
        canvas.restore();
      case Kind.wood:
        final s = 1.15 * ppu;
        _shadow(canvas, Offset(x, y), s * 1.3, 0.35 * a);
        _sprite(canvas, g.images0['wood']!, Offset(x, y + s * 0.08), s, alpha: a);
    }
  }

  void _runner(Canvas canvas, RunGame g) {
    final x = g._runnerScreenX();
    final ground = g._groundY(RunGame.runnerZ);
    final ppu = g._ppu(RunGame.runnerZ);
    final lift = g.jumpH * ppu * 0.42;
    _shadow(canvas, Offset(x, ground - 4), 76 * (1 - math.min(0.5, g.jumpH / 4)), 0.4);
    if (g.stats.shield.value) {
      canvas.drawCircle(
        Offset(x, ground - lift - 100),
        78,
        Paint()
          ..color = const Color(0xFF8FD8FF).withValues(alpha: 0.18 + 0.06 * math.sin(g.clock * 6))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(
        Offset(x, ground - lift - 100),
        78,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFFCFF1FF).withValues(alpha: 0.7),
      );
    }
    if (g.stats.magnet.value > 0) {
      for (var k = 0; k < 3; k++) {
        final r = 40 + ((g.clock * 60 + k * 30) % 90);
        canvas.drawCircle(
          Offset(x, ground - lift - 120),
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFFFF7A7A).withValues(alpha: 0.4 * (1 - (r - 40) / 90)),
        );
      }
    }
    final airborne = g.jumpH > 0.01;
    final Sprite frame;
    if (airborne) {
      frame = g.jumpFrames[g.jumpV > 3 ? 0 : (g.jumpV > -3 ? 1 : 2)];
    } else {
      frame = g.runFrames[(g.runClock * 10).floor() % 12];
    }
    if (g.useModel) return;
    const h = 222.0;
    const w = h * 198 / 470;
    final blink = g.hurt > 0 && (g.clock * 14).floor().isEven;
    canvas.save();
    canvas.translate(x, ground - lift + 10);
    final tilt = (g.lane - g.laneX) * 0.25;
    canvas.rotate(tilt + g.tumble * 1.4);
    canvas.scale(1 + g.squash * 0.5, 1 - g.squash);
    frame.render(
      canvas,
      position: Vector2(-w / 2, -h),
      size: Vector2(w, h),
      overridePaint: Paint()
        ..filterQuality = FilterQuality.medium
        ..color = Color.fromRGBO(255, 255, 255, blink ? 0.35 : 1),
    );
    canvas.restore();
  }

  void _effects(Canvas canvas, RunGame g) {
    if (g.speed > 18 || g.stats.boosting.value) {
      final power = g.stats.boosting.value ? 1.0 : ((g.speed - 18) / 12).clamp(0.0, 0.6);
      final rng = math.Random(1);
      for (var i = 0; i < 22; i++) {
        final ang = rng.nextDouble() * math.pi * 2;
        final life = ((g.clock * (1.4 + rng.nextDouble()) + rng.nextDouble()) % 1.0);
        final r1 = 120 + life * 420;
        final r2 = r1 + 40 + life * 90;
        final c = const Offset(201, 460);
        canvas.drawLine(
          c + Offset(math.cos(ang), math.sin(ang)) * r1,
          c + Offset(math.cos(ang), math.sin(ang)) * r2,
          Paint()
            ..strokeWidth = 1.5 + life * 2.5
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.45 * power * math.sin(life * math.pi)),
        );
      }
    }
    for (final s in g.sparks) {
      final k = 1 - s.age / s.life;
      final paint = Paint()..color = s.color.withValues(alpha: k);
      if (s.star) {
        final r = s.size * (0.6 + 0.6 * k);
        final p = s.p;
        final path = Path()
          ..moveTo(p.dx, p.dy - r)
          ..quadraticBezierTo(p.dx, p.dy, p.dx + r, p.dy)
          ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r)
          ..quadraticBezierTo(p.dx, p.dy, p.dx - r, p.dy)
          ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r);
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(s.p, s.size * k, paint);
      }
    }
    for (final p in g.popups) {
      final k = p.age;
      final scale = k < 0.15 ? 0.5 + k / 0.15 * 0.7 : 1.2 - math.min(0.2, (k - 0.15) * 0.8);
      final alpha = k > 0.7 ? (1 - (k - 0.7) / 0.3) : 1.0;
      final tp = _text(p.text, p.size, p.color);
      canvas.save();
      canvas.translate(p.p.dx, p.p.dy);
      canvas.scale(scale);
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, alpha.clamp(0.0, 1.0)));
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      canvas.restore();
    }
  }

  TextPainter _text(String text, double size, Color color) {
    final key = '$text|$size|${color.toARGB32()}';
    return _textCache.putIfAbsent(key, () {
      final style = TextStyle(
        fontFamily: 'Baloo',
        fontSize: size,
        fontWeight: FontWeight.w800,
        fontVariations: const [FontVariation('wght', 800)],
        color: color,
        shadows: const [Shadow(color: Color(0xFF3A1E6E), offset: Offset(0, 3), blurRadius: 0), Shadow(color: Color(0x993A1E6E), blurRadius: 8)],
      );
      return TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    });
  }
}
