# Symptom Assessment

A three-screen symptom checker built from a single reference mockup: the
question, the search, the report. Pure Flutter, no third-party packages.

```bash
flutter run
```

## What it does

1. **Assess.** "What symptom is bothering you most?" with a live glass orb,
   a search prompt, a hold-to-talk button, a rail of popular symptoms and the
   "Your health, your data" card.
2. **Search.** The field lands at the top, results filter as you type, the
   count rolls like an odometer, and the green `?` badge opens a short
   explanation of any result.
3. **Report.** The best match, how urgently it needs attention, what to do
   about it, and two collapsible sections for the less likely causes and the
   symptoms you reported.

The catalogue is small and lives in `lib/data/symptoms.dart`; "back pain"
returns the ten results from the reference and escalates to the spine-trauma
report shown there.

## The assets

The reference is a 1050 px screenshot. Nothing in it is full-HD, so the
assets were sourced three ways, from best to least:

| Asset | Source | Why |
| --- | --- | --- |
| Glass orb (the mascot) | **Rendered live by a fragment shader** (`shaders/orb.frag`) | Resolution-independent, and it can move. The reference crop is kept as `assets/images/orb_reference.png` for comparison and as the fallback if the shader fails to load. |
| Symptom emoji (brain, nose, ambulance, and 36 more) | [Microsoft Fluent Emoji 3D](https://github.com/microsoft/fluentui-emoji), MIT, 256 px | Same objects and style as the reference's icons, at real resolution. The reference used Apple's emoji, which cannot be redistributed. |
| "Your health, your data" illustration | Cut from the reference with OpenCV: 6x Lanczos upscale, inpainted background estimate, colour-distance key, hole fill, de-fringe | No licensable high-res source exists for this specific render. It is 530 px wide, soft at 6x, and shown at 118 px, where it holds up. |

The reference's "sore throat" icon (a head with a red throat) was too small
to recover cleanly, so that chip uses Fluent's masked face.

Font: Manrope (variable, OFL), in `assets/fonts/`.

## The animations

Every screen has one `AnimationController` for its entrance; each element
reads its own `Interval` of it (all in `lib/core/design.dart`), so the page
arrives as one move.

| What | How |
| --- | --- |
| Glass orb | GLSL: outer sphere with Fresnel rim, two inner bubbles with their own rims and highlights, key light top-left, bounce light below, contact shadow. Bubbles drift on sines. **Drag** tilts it and the bubbles parallax by depth, then a hand-integrated spring carries it back with the drag's release velocity. **Tap** squashes it against its base and it pops back. **Holding the mic** makes it sway and run faster. |
| Page wash | GLSL: the mint-to-white gradient with three drifting soft blobs, ticked at 20 fps because the drift is minutes-scale. |
| Headline | Set one word at a time, each rising through a clip. |
| Search field | A `Hero` between screens with a custom shuttle, so the caret and keyboard never fly. Focus is requested when the flight lands, so the keyboard rises after the field, not during. Clear button spins in. |
| Mic | Hold to talk: two rings ripple out, the waveform bars breathe. Release lets the last ring finish. |
| Chips | Staggered pop on entrance. Tapping one sends a copy along a quadratic arc into the field's lens while shrinking; the results screen opens as it lands. |
| Results | Deal in from below, staggered. On every change of query they re-deal (shorter, tighter) instead of snapping. The count is an odometer: each digit column rolls independently. |
| Result to report | A container transform: the tapped tile's own rectangle grows to fill the screen, its content fading out as the report fades in. |
| Report | Head card, orb, urgency pill, explanation, action, button, sections, in that order. The pill's dot pulses a ring when the case is an emergency. The action emoji nods every few seconds. The button carries a slow sheen. |
| Sections | Height on an emphasized curve, contents rising a beat later, chevron turning 180 degrees. |
| Every press | `Pressable`: a real spring on a `Ticker`, quick pull-down, one small overshoot on release. Haptics on tap. |

## Pixel-perfect, with the caveat

The mockup's phone is 289 px wide for a 393-wide layout, so measured
positions are good to about 1.4 logical px and colours were sampled from
flat areas rather than edges. Type is Manrope by eye; the mockup's font was
not named. Text scaling is honoured up to 1.2x, then clamped.

## Structure

```
lib/
  core/        design tokens, palette, type, shader loader
  core/motion/ Pressable, entrance helpers, the two routes
  data/        the symptom catalogue and the assessment logic
  features/    assess, search, report screens
  widgets/     orb, wash, header, field, mic, chip, tile, card, sections
shaders/       orb.frag, aurora.frag
assets/        emoji (Fluent 3D), images (extracted), fonts (Manrope)
test/          16 tests: catalogue, entrances, hero, transform, sections
```
