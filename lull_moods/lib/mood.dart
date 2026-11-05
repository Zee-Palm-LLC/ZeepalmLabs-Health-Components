import 'package:flutter/material.dart';

/// Moods are ordered by energy — this is also the order of the stops on the
/// mood switch, left (lowest energy) to right (highest).
enum Mood { sleepy, low, calm, stressed, radiant }

double _l(double a, double b, double t) => a + (b - a) * t;
Color _c(Color a, Color b, double t) => Color.lerp(a, b, t)!;

/// A fully parametric face. Every field is continuous, so any two moods can
/// morph into each other frame by frame instead of swapping artwork.
@immutable
class FaceSpec {
  const FaceSpec({
    this.eyeOpen = 1,
    this.closedCurve = 0,
    this.eyeScale = 1,
    this.lidDroop = 0,
    this.mouthCurve = 1,
    this.mouthWave = 0,
    this.mouthOpen = 0,
    this.mouthWidth = 40,
    this.browTilt = 0,
    this.browAlpha = 0,
    this.blush = 1,
    this.tear = 0,
    this.sweat = 0,
  });

  /// 1 = round open eyes, 0 = closed stroke.
  final double eyeOpen;

  /// Shape of the closed stroke: 1 = happy ^, 0 = flat, -1 = content ∪.
  final double closedCurve;
  final double eyeScale;

  /// How far a heavy upper lid covers the eye (sad / tired).
  final double lidDroop;

  /// -1 frown … 1 smile.
  final double mouthCurve;

  /// Wobbly, worried S-shaped mouth.
  final double mouthWave;

  /// Small "o" mouth (sleeping breath).
  final double mouthOpen;
  final double mouthWidth;

  /// 1 = worried (inner ends raised).
  final double browTilt;
  final double browAlpha;
  final double blush;
  final double tear;
  final double sweat;

  static FaceSpec lerp(FaceSpec a, FaceSpec b, double t) => FaceSpec(
        eyeOpen: _l(a.eyeOpen, b.eyeOpen, t),
        closedCurve: _l(a.closedCurve, b.closedCurve, t),
        eyeScale: _l(a.eyeScale, b.eyeScale, t),
        lidDroop: _l(a.lidDroop, b.lidDroop, t),
        mouthCurve: _l(a.mouthCurve, b.mouthCurve, t),
        mouthWave: _l(a.mouthWave, b.mouthWave, t),
        mouthOpen: _l(a.mouthOpen, b.mouthOpen, t),
        mouthWidth: _l(a.mouthWidth, b.mouthWidth, t),
        browTilt: _l(a.browTilt, b.browTilt, t),
        browAlpha: _l(a.browAlpha, b.browAlpha, t),
        blush: _l(a.blush, b.blush, t),
        tear: _l(a.tear, b.tear, t),
        sweat: _l(a.sweat, b.sweat, t),
      );
}

/// Weights (0..1) of each ambient effect painted around the character.
@immutable
class Ambient {
  const Ambient({
    this.rays = 0,
    this.stars = 0,
    this.clouds = 0,
    this.rain = 0,
    this.bubbles = 0,
    this.sparks = 0,
    this.zz = 0,
  });

  final double rays, stars, clouds, rain, bubbles, sparks, zz;

  static Ambient lerp(Ambient a, Ambient b, double t) => Ambient(
        rays: _l(a.rays, b.rays, t),
        stars: _l(a.stars, b.stars, t),
        clouds: _l(a.clouds, b.clouds, t),
        rain: _l(a.rain, b.rain, t),
        bubbles: _l(a.bubbles, b.bubbles, t),
        sparks: _l(a.sparks, b.sparks, t),
        zz: _l(a.zz, b.zz, t),
      );
}

/// Everything that is interpolated between moods.
@immutable
class MoodVisual {
  const MoodVisual({
    required this.skyTop,
    required this.skyBottom,
    required this.rays,
    required this.ink,
    required this.inkSoft,
    required this.headline,
    required this.chip,
    required this.track,
    required this.orbLight,
    required this.orbDark,
    required this.halo,
    required this.faceInk,
    required this.blush,
    required this.cloud,
    required this.knob,
    required this.knobHi,
    required this.navFill,
    required this.navSel,
    required this.navInk,
    required this.gauge,
    required this.face,
    required this.ambient,
  });

  final Color skyTop, skyBottom, rays;
  final Color ink, inkSoft, headline, chip, track;
  final Color orbLight, orbDark, halo, faceInk, blush, cloud;
  final Color knob, knobHi;
  final Color navFill, navSel, navInk;
  final double gauge;
  final FaceSpec face;
  final Ambient ambient;

  bool get isDark => skyTop.computeLuminance() < 0.2;

  static MoodVisual lerp(MoodVisual a, MoodVisual b, double t) => MoodVisual(
        skyTop: _c(a.skyTop, b.skyTop, t),
        skyBottom: _c(a.skyBottom, b.skyBottom, t),
        rays: _c(a.rays, b.rays, t),
        ink: _c(a.ink, b.ink, t),
        inkSoft: _c(a.inkSoft, b.inkSoft, t),
        headline: _c(a.headline, b.headline, t),
        chip: _c(a.chip, b.chip, t),
        track: _c(a.track, b.track, t),
        orbLight: _c(a.orbLight, b.orbLight, t),
        orbDark: _c(a.orbDark, b.orbDark, t),
        halo: _c(a.halo, b.halo, t),
        faceInk: _c(a.faceInk, b.faceInk, t),
        blush: _c(a.blush, b.blush, t),
        cloud: _c(a.cloud, b.cloud, t),
        knob: _c(a.knob, b.knob, t),
        knobHi: _c(a.knobHi, b.knobHi, t),
        navFill: _c(a.navFill, b.navFill, t),
        navSel: _c(a.navSel, b.navSel, t),
        navInk: _c(a.navInk, b.navInk, t),
        gauge: _l(a.gauge, b.gauge, t),
        face: FaceSpec.lerp(a.face, b.face, t),
        ambient: Ambient.lerp(a.ambient, b.ambient, t),
      );
}

@immutable
class StatSpec {
  const StatSpec(this.icon, this.value, this.label);
  final IconData icon;
  final String value, label;
}

/// Discrete content (cross-faded, not interpolated) plus the visual target.
@immutable
class MoodSpec {
  const MoodSpec({
    required this.visual,
    required this.gaugeLabel,
    required this.gaugeIcon,
    required this.stats,
    required this.headline,
    required this.sub,
  });

  final MoodVisual visual;
  final String gaugeLabel;
  final IconData gaugeIcon;
  final List<StatSpec> stats;
  final String headline, sub;
}

const kMoods = <Mood, MoodSpec>{
  Mood.radiant: MoodSpec(
    gaugeLabel: 'ENERGY',
    gaugeIcon: Icons.spa_outlined,
    headline: 'Fresh mind, full focus.\nLet’s get it done',
    sub: 'Top 3 first. Ship Worldclass work today',
    stats: [
      StatSpec(Icons.track_changes_rounded, '3', 'Focus tasks'),
      StatSpec(Icons.favorite_border_rounded, '72', 'Heart rate'),
      StatSpec(Icons.waves_rounded, '15m', 'Stress'),
      StatSpec(Icons.schedule_rounded, '2h', 'Deep work'),
    ],
    visual: MoodVisual(
      skyTop: Color(0xFFFFD84C),
      skyBottom: Color(0xFFFFC62E),
      rays: Color(0xFFFFEDA8),
      ink: Color(0xFF7C1D16),
      inkSoft: Color(0xFF6E3518),
      headline: Color(0xFF7C1D16),
      chip: Color(0x66FFF6CF),
      track: Color(0x4DFFF6CF),
      orbLight: Color(0xFFFFD63E),
      orbDark: Color(0xFFFFAC0C),
      halo: Color(0xFFFFE47E),
      faceInk: Color(0xFF3B1E19),
      blush: Color(0xFFFF7A72),
      cloud: Color(0xFFFFF3CC),
      knob: Color(0xFFDD3236),
      knobHi: Color(0xFFFF8A7E),
      navFill: Color(0x8C9C5A16),
      navSel: Color(0x40FFF1D0),
      navInk: Color(0xFFFFF6E2),
      gauge: 88,
      face: FaceSpec(),
      ambient: Ambient(rays: 1),
    ),
  ),
  Mood.stressed: MoodSpec(
    gaugeLabel: 'RESILIENCE',
    gaugeIcon: Icons.bolt_rounded,
    headline: 'A lot on your plate.\nLet’s take it slower',
    sub: 'Pick one task. Breathe. Then the next one',
    stats: [
      StatSpec(Icons.checklist_rounded, '9', 'Open tasks'),
      StatSpec(Icons.favorite_border_rounded, '96', 'Heart rate'),
      StatSpec(Icons.waves_rounded, '2h', 'Stress'),
      StatSpec(Icons.groups_outlined, '6', 'Meetings'),
    ],
    visual: MoodVisual(
      skyTop: Color(0xFFFFC3A6),
      skyBottom: Color(0xFFFF9672),
      rays: Color(0xFFFFE1D2),
      ink: Color(0xFF6E190E),
      inkSoft: Color(0xFF7E3220),
      headline: Color(0xFF6E190E),
      chip: Color(0x59FFF0EA),
      track: Color(0x40FFF0EA),
      orbLight: Color(0xFFFFA07A),
      orbDark: Color(0xFFF25F3A),
      halo: Color(0xFFFFC7B0),
      faceInk: Color(0xFF45130B),
      blush: Color(0xFFFF4848),
      cloud: Color(0xFFFFE6DC),
      knob: Color(0xFFC72F1A),
      knobHi: Color(0xFFFF8C6C),
      navFill: Color(0x8CA03A22),
      navSel: Color(0x40FFE7DD),
      navInk: Color(0xFFFFF1EB),
      gauge: 42,
      face: FaceSpec(
        eyeScale: 0.88,
        mouthCurve: -0.25,
        mouthWave: 1,
        mouthWidth: 38,
        browTilt: 1,
        browAlpha: 1,
        blush: 0.35,
        sweat: 1,
      ),
      ambient: Ambient(rays: 0.45, sparks: 1),
    ),
  ),
  Mood.calm: MoodSpec(
    gaugeLabel: 'BALANCE',
    gaugeIcon: Icons.eco_outlined,
    headline: 'Breathe in, slow down.\nYou’re right on time',
    sub: 'Calm mind, clear choices. One thing at a time',
    stats: [
      StatSpec(Icons.self_improvement_rounded, '20m', 'Mindful'),
      StatSpec(Icons.favorite_border_rounded, '64', 'Heart rate'),
      StatSpec(Icons.air_rounded, '6/m', 'Breathing'),
      StatSpec(Icons.directions_walk_rounded, '6.2k', 'Steps'),
    ],
    visual: MoodVisual(
      skyTop: Color(0xFFCFF0E2),
      skyBottom: Color(0xFF9BDBC6),
      rays: Color(0xFFE6FBF3),
      ink: Color(0xFF0F4C45),
      inkSoft: Color(0xFF2A6A62),
      headline: Color(0xFF0F4C45),
      chip: Color(0x66FFFFFF),
      track: Color(0x4DFFFFFF),
      orbLight: Color(0xFF94E6C9),
      orbDark: Color(0xFF4DC2A1),
      halo: Color(0xFFC4F1E1),
      faceInk: Color(0xFF12463F),
      blush: Color(0xFFFF9B8C),
      cloud: Color(0xFFF2FFFA),
      knob: Color(0xFF1C8C79),
      knobHi: Color(0xFF7FE2CA),
      navFill: Color(0x8C2F7A6B),
      navSel: Color(0x40E9FFF8),
      navInk: Color(0xFFF0FFF9),
      gauge: 76,
      face: FaceSpec(eyeOpen: 0, closedCurve: 1, mouthCurve: 0.7, mouthWidth: 34, blush: 0.85),
      ambient: Ambient(rays: 0.4, bubbles: 1),
    ),
  ),
  Mood.low: MoodSpec(
    gaugeLabel: 'MOOD',
    gaugeIcon: Icons.water_drop_outlined,
    headline: 'It’s okay to have\na slow day',
    sub: 'Be gentle with yourself. Small steps count',
    stats: [
      StatSpec(Icons.sentiment_neutral_rounded, '3/10', 'Mood'),
      StatSpec(Icons.favorite_border_rounded, '68', 'Heart rate'),
      StatSpec(Icons.bedtime_outlined, '5h', 'Sleep'),
      StatSpec(Icons.wb_sunny_outlined, '12m', 'Daylight'),
    ],
    visual: MoodVisual(
      skyTop: Color(0xFFBAC7DB),
      skyBottom: Color(0xFF8A9DBB),
      rays: Color(0xFFE3E9F4),
      ink: Color(0xFF21314A),
      inkSoft: Color(0xFF3B4D6C),
      headline: Color(0xFF21314A),
      chip: Color(0x4DFFFFFF),
      track: Color(0x40FFFFFF),
      orbLight: Color(0xFFB6C7E6),
      orbDark: Color(0xFF7D94C2),
      halo: Color(0xFFD0DAEC),
      faceInk: Color(0xFF243049),
      blush: Color(0xFFE7A0B3),
      cloud: Color(0xFFE6ECF5),
      knob: Color(0xFF475F8E),
      knobHi: Color(0xFFAABDE4),
      navFill: Color(0x8C44577D),
      navSel: Color(0x40F1F5FC),
      navInk: Color(0xFFF1F5FC),
      gauge: 31,
      face: FaceSpec(
        eyeOpen: 0.92,
        eyeScale: 0.92,
        lidDroop: 0.5,
        mouthCurve: -0.85,
        mouthWidth: 30,
        browTilt: 0.8,
        browAlpha: 0.55,
        blush: 0.3,
        tear: 1,
      ),
      ambient: Ambient(clouds: 0.85, rain: 1),
    ),
  ),
  Mood.sleepy: MoodSpec(
    gaugeLabel: 'SLEEP READY',
    gaugeIcon: Icons.dark_mode_outlined,
    headline: 'Sleep is a key part of\nDesign Inspiration',
    sub: 'Rest now. Tomorrow’s big ideas need you',
    stats: [
      StatSpec(Icons.nightlight_outlined, '7h40', 'Sleep goal'),
      StatSpec(Icons.favorite_border_rounded, '54', 'Heart rate'),
      StatSpec(Icons.air_rounded, '14', 'Breathing'),
      StatSpec(Icons.schedule_rounded, '23:30', 'Bedtime'),
    ],
    visual: MoodVisual(
      skyTop: Color(0xFF172E4D),
      skyBottom: Color(0xFF2C5886),
      rays: Color(0xFF2F5A87),
      ink: Color(0xFFFFFFFF),
      inkSoft: Color(0xFFB9CDE7),
      headline: Color(0xFF93BEF5),
      chip: Color(0x1FFFFFFF),
      track: Color(0x14FFFFFF),
      orbLight: Color(0xFFAACAF6),
      orbDark: Color(0xFF6D9AD9),
      halo: Color(0xFF3E6B9C),
      faceInk: Color(0xFF1B2D49),
      blush: Color(0x00FFFFFF),
      cloud: Color(0xFFB2CEF4),
      knob: Color(0xFFFFFFFF),
      knobHi: Color(0xFFFFFFFF),
      navFill: Color(0x99234770),
      navSel: Color(0x33FFFFFF),
      navInk: Color(0xFFFFFFFF),
      gauge: 74,
      face: FaceSpec(eyeOpen: 0, mouthCurve: 0, mouthOpen: 1, mouthWidth: 0, blush: 0),
      ambient: Ambient(stars: 1, clouds: 1, zz: 1),
    ),
  ),
};
