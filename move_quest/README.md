# MoveQuest

A fitness adventure concept: real movement turns into quests on a living map.
Four screens rebuilt from a single reference mockup.

| Screen | File |
| --- | --- |
| Splash | `lib/features/splash_screen.dart` |
| Choose your path | `lib/features/onboarding_screen.dart` |
| Home map | `lib/features/home_screen.dart` |
| Quest detail | `lib/features/route_screen.dart` |

## Matching the reference

The mockup shows each phone at roughly 360 px wide, so nothing was measured by eye:

1. Each screen was located from its bezel edges, upscaled 4x with EDSR and warped
   to an exact 393 x 852 pt plate. Every position in the code is a measurement in
   points on that plate.
2. The typeface was identified by comparing width-to-cap-height ratios of real
   headings against forty Google fonts; Cabin won on headings, body copy and
   numerals. Sizes were then solved per label from ink extents, and baselines were
   read from letters without descenders.
3. Panel fills (stat pills, level card, quest card, nav bar, chips) are gradients
   fitted to vertical colour profiles sampled from the reference.
4. `test/snapshot_test.dart` renders every screen at 3x so it can be diffed against
   the plates. Text positions land within about 1 pt of the reference.

`core/canvas.dart` lays everything out on a fixed 393 pt design canvas scaled by
width. Taller phones get extra height instead of letterboxing: scene art stretches
with the screen while buttons and the nav bar stay pinned to the bottom, lifted
further when the device's bottom inset is larger than the reference's.

## Artwork

All raster art in `assets/images` was cut out of the reference:

- **Characters** were segmented with a human-segmentation network, refined with
  GrabCut and a guided filter, then hand-patched where limbs overlap scenery.
- **Logo, badges, icons** were extracted by difference matting: the background is
  rebuilt behind the object and alpha is solved from the difference, so glows and
  soft edges keep their real transparency. Hexagon badges and circular discs use
  fitted analytic shapes for crisp edges.
- **Scenes** are the reference backgrounds with every UI element and character
  removed. Holes are filled with shift-map texture synthesis (colour-corrected
  against a multigrid harmonic fill), so when a character or card moves away
  there is plausible scenery behind it rather than a blur.

Buttons, pills, cards, the nav bar, icons and all text are drawn in code.

## Motion

No slides or fades on their own; every screen has a small story.

- **Splash.** The world zooms out of darkness; the mountain rises from the
  ground line; *Move* and *Quest* flip up on springs; the flag on the peak is a
  real cloth mesh (`drawVertices`) that unfurls and keeps waving. The runner
  appears as a glowing silhouette and a scan line converts her to colour. The
  tagline lands letter by letter, the button rim traces itself before the fill
  blooms, and a spark keeps orbiting the outline.
- **Hex portal.** *Tap to Begin* opens the next screen through a rotating
  hexagonal iris that grows from the button.
- **Choose your path.** Each activity disc is thrown in a bezier arc from the
  runner's hand, spinning on Y, and lands with a shock ring while its pill springs
  open behind it. Tapping flips the disc and lights the pill with a check.
- **Descend.** *Next* drops the map in from a tilted camera, as if landing on it.
- **Home.** Stat pills swing open like doors; numbers roll on per-digit
  odometers; the level badge spins in and the XP bar fills with a moving liquid
  surface. Landmark badges fall onto the map and squash on impact, then hover.
  Energy pulses travel along the glowing paths and the player pad radiates.
  The nav bubble stretches as it travels between tabs.
- **Card expand.** The quest card grows into the detail screen, and the route
  title flies across as a shared hero.
- **Quest detail.** The hero scene parallaxes under scroll and stretches on
  overscroll. The runner keeps a running stride and the balloon drifts. Stars
  spin in, stat cards unfold, highlight tiles flip up. *Start Quest* bursts, and
  the runner sprints off into the distance.
- **Everywhere.** Drag anywhere to tilt the scene: background, characters and
  UI sit on different depth planes and spring back when released.

All idle motion comes from one shared clock (`core/motion.dart`), which pauses
for routes that are offstage.

## Running

```bash
flutter run
```

```bash
flutter test
```

To render snapshots for comparison:

```bash
flutter test test/snapshot_test.dart --dart-define=SNAP_DIR=/path/to/shots
```
