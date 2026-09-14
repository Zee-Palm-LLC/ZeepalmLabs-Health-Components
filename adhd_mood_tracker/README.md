# ADHD Mood Tracker

A five-state mood check-in screen. The whole screen is the answer: background
colour, an animated face, a large word and a row of circular mood faces all
move together as one object.

Built to match the visual language and motion of the three-state "leave a
review" screen it was derived from, extended from 3 moods to 5.

## The scale

| # | Word | Background | Face |
|---|------|-----------|------|
| 0 | `OVERWHELMED` | `#F15A45` | Wide round eyes, deep frown |
| 1 | `DRAINED` | `#F08327` | Squint, shallow frown |
| 2 | `OKAY` | `#EBAA08` | Round eyes, flat mouth |
| 3 | `FOCUSED` | `#D1D41C` | Narrowed eyes, slight smile |
| 4 | `ENERGIZED` | `#A4DC3B` | Big round eyes, full smile |

Hues are evenly spaced (7° → 25° → 43° → 61° → 79°) so the ramp reads as one
continuous scale rather than five picked colours.

Only the background is authored. Everything else is `Mood.shade(bg, factor)` —
the same colour with its lightness scaled — so the palette cannot fall out of
tune with itself:

```dart
wordColor    = shade(bg, 0.72)   // the big word
surfaceColor = shade(bg, 0.84)   // note bar, header buttons
```

The background itself is a shallow radial gradient (`shade(bg, 1.07)` behind the
face falling to `shade(bg, 0.93)` at the corners) rather than a dead-flat fill.
The picker tray is a *translucent* ink scrim, not a tint — over a gradient a
fixed colour reads lighter than the page at one end and darker at the other.

The submit pill is the one exception to all of it: a fixed cream `#EBDBCE` in
every state, which is what keeps it reading as the primary action regardless of
the mood colour behind it.

## Picking a mood

A row of five circles on a tray that echoes the action bar below it, so the
bottom third reads as a deck of controls rather than five dots adrift in colour.
Each circle shows that mood's own face shrunk to fit — the same painter, so the
picker cannot drift out of sync with what it previews.

The selected one **enlarges** and inverts to an ink circle with the mood's
colour as the face. It has to invert: an unselected circle carries its own mood
colour, and the selected mood's colour is already the whole background.

- **Tap** a circle to pick it.
- **Drag** across the row to scrub continuously — the whole screen follows your
  finger, including the word.
- **Swipe** the big word sideways; that drives the scale too.

Circles sit on a fixed pitch and each scales about its own centre, so the
selected one can spring past full size without shoving its neighbours around.

## How the animation works

One `AnimationController`, one duration (580ms), four curves. The parts differ
only by curve, which is what keeps a mood change reading as a single object
moving.

| Part | Curve | Why |
|------|-------|-----|
| Background colour | `Interval(0, 0.62, easeOutCubic)` | Must **not** overshoot — springing past a mood would flash a colour that is not on the scale. Lands before the spring finishes. |
| Face geometry | `ElasticOutCurve(0.62)` | Single clean overshoot, then settles. |
| Picker circles | `ElasticOutCurve(0.62)` | The chosen circle overshoots *larger*. |
| The word | `easeOutBack`, 400ms | One overshoot. A full spring on a `PageView` reveals its neighbours and reads as a glitch. |
| The blurb | fade + rise, 260ms | It swaps rather than morphs, so it gets its own short transition. |

**On the spring specifically:** stock `Curves.elasticOut` (period 0.4) peaks at
+27% and rings twice — it reads as wobble, not weight. The longer 0.62 period
gives one overshoot of about +14% that settles almost immediately. Measured from
a real transition (eye width, OKAY → ENERGIZED):

```
90.0 → 108.3 (peak) → 105.7 (one small settle) → 106.0     ~430ms to rest
```

Two details make it work properly:

**The face springs its *shape*, not its position on the scale.** Interpolating
the six face numbers past the target (`lerpDouble` with `t > 1`) makes the eyes
bulge and the mouth over-curve before settling. Springing a position on the
0–4 scale instead would have pulled in geometry from the *next* mood along.

**The circles spring their *emphasis*, not their position.** Same reason: a
spring on position would slide a circle past its own slot; a spring on emphasis
makes it overshoot larger, which is what you actually want to see.

`test/bounce_test.dart` samples the live widget frame by frame and asserts that
trace, so the spring is verified on the screen rather than on the curve in
isolation.

## Pixel-perfect layout

Every dimension is a **design unit**: one logical pixel on an iPhone 16 Pro Max
(440 × 956), the device the reference was captured on. The screen is laid out at
exactly that size inside a `FittedBox`, then uniformly scaled to the viewport.

Proportions are therefore identical on every device instead of drifting the way
ad-hoc padding does. All the numbers live in `lib/core/design.dart`.

```
eyebrow top      150      eye top (fixed)     274
title top        174      mouth stroke         12
word centre      516      blurb top           571
picker centre    690      tray 384 x 104
circle resting    52      circle selected      82
bar top          816      bar height           64
bar gutter        28      bar inset             7
```

**Tradeoff:** the canvas uses `MediaQuery.withNoTextScaling`, which is what
"pixel perfect" requires but also means system Dynamic Type does not enlarge the
text. If you would rather honour it, drop that wrapper in `mood_screen.dart` —
the word already uses `FittedBox` and will absorb the change; the title is the
only thing you would need to re-check.

## Structure

```
lib/
  core/
    design.dart      all layout constants + motion tokens
    mood.dart        the 5 moods, palette derivation, continuous sampling
  features/mood/
    mood_screen.dart the screen, state machine, note + info sheets
    widgets/
      mood_face.dart         CustomPainter: eyes + mouth, full size and as an icon
      mood_picker_row.dart   the tray and the 5 circles
      mood_word_pager.dart   the large sliding word
      header_bar.dart        close / info
      bottom_action_bar.dart note field + submit
```

## Running

```bash
flutter pub get
flutter run
```

`Poppins` is bundled in `assets/fonts/` (OFL), so there is no runtime font
fetch.

### Previewing states

```bash
flutter run --dart-define=NOTE="Three deadlines, skipped lunch"
```

`MoodScreen(autoPlay: true)` cycles the moods on its own — useful for
recording. It is off by default; an app should not move the user's answer for
them.

## Hooking up storage

```dart
MoodScreen(
  initialMood: 2,
  initialNote: previousEntry?.note,
  eyebrow: 'MON 14 SEP   ·   CHECK-IN',  // defaults to today's date
  onSubmit: (mood, note) {
    // mood.word, mood.tick, mood.blurb, mood.color
    // note is null when the user did not add one
  },
)
```
