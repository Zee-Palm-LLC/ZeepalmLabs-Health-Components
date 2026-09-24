# FitJourney

"Turn your city into your gym." A fitness app that finds routes, gyms, parks and
water stations near you. There are four screens, rebuilt from a reference mockup:

| Screen | File |
| --- | --- |
| Splash | `lib/features/splash/splash_screen.dart` |
| Onboarding | `lib/features/onboarding/onboarding_screen.dart` |
| Home | `lib/features/home/home_screen.dart` |
| Route detail | `lib/features/route/route_screen.dart` |

## Matching the reference

In the mockup each phone was only about 345 px wide, so every measurement was
taken from a corrected plate, never by eye:

1. Each screen was located from its bezel edges, upscaled 4x with EDSR and
   warped to an exact 393 x 852 pt plate.
2. Every text run was measured as an ink box on the plate. Its size, pen x and
   baseline were solved with HarfBuzz shaping against Figtree's real glyph
   outlines. Figtree beat Plus Jakarta Sans, Manrope, DM Sans, Outfit, Urbanist,
   Lexend and Nunito Sans in a side-by-side check. The result was then rendered
   in `flutter test` and diffed against the plate. Positions land within about
   1 pt, and weights were raised a step where the reference strokes read heavier.
3. Colours were sampled from the plates: brand teal `#024B62`, action green
   `#00B486`, route blue `#1479EE`, and the category orb cores and halos.

Everything sits on a fixed 393 pt design canvas (`core/canvas.dart`) that scales
by width. The height follows the real screen, top content hangs off the
safe-area top, and bottom bars and CTAs hang off the safe-area bottom. Text scale
is clamped to 100%. The nav bar and the Start Journey button keep a margin above
the safe-area bottom. On short phones, home tightens its section gaps, and the
route sheet rides up over the map so that Highlights stays above the button.

## Images

Everything under `assets/images` was cut from the reference:

- `logo_ridge`, `logo_peak`, `logo_pin`: the logo, matted against a fitted sky
  model and split into three layers so it can assemble itself.
- `splash_backdrop` + `splash_hiker`: the hiker is cut out with GrabCut on a
  traced trimap. The backdrop has her, the logo, the status bar and the bottom
  labels painted out, so the two layers can move in depth.
- `onboarding_scene` + `onboarding_runner`: the same treatment. The feature
  cards and the runner are removed from the park scene.
- `leaves_left` / `leaves_right`: the foliage is un-premultiplied against the
  page white so it has true alpha.
- `route_map`: the aerial map with the route, pins and buttons inpainted out.
  The route is redrawn live from `data/route_path.dart`, which is the traced
  centreline.
- `riverside_park`, `avatar_ayesha`: the photos, with the Easy badge removed.

## Icons

Every icon comes from [Phosphor](https://phosphoricons.com) (MIT). The Fill
style is used for category orbs and pins, Regular and Fill cross-fade for the
nav bar's inactive and active states, Bold for chevrons and arrows, and Duotone
for the route highlights. The `phosphor_flutter` package no longer compiles on
current Flutter because `IconData` is now a final class. The Phosphor fonts are
bundled under `assets/fonts` instead, and `core/phosphor.dart` holds `const`
`IconData` for only the glyphs the app uses, so release builds tree-shake the
fonts down.

## Type

Figtree with tighter tracking: -2.2% of the font size from 28 pt up, -1.6% from
17 pt, and -0.8% below that, so headings and labels sit tight rather than airy.
Values that follow other text, such as `/ 7,500` after `5,200`, are placed from
measured widths.

## Motion

- **Splash.** The camera dollies in: the backdrop and the hiker settle at
  different speeds. The logo builds itself. The ridge and peak rise out of the
  ground, and the pin drops in with gravity, squashes on landing and sends a
  ripple across the peak. "FitJourney" springs up letter by letter from under a
  baseline, and a sheen then sweeps across it. Each tagline line rises out of
  its own clip. The pillars pop in: the runner jogs, the pin bobs and the
  heart beats. Drag anywhere to tilt the scene in parallax.
- **Splash → onboarding.** The screen zooms into the logo's pin, and onboarding
  is revealed through a pin-shaped portal that grows from that exact point.
- **Onboarding.** The scene paints in from the runner outward while she sprints
  into frame. Feature cards flip down on a hinge, and each icon orb fills with
  liquid before its glyph springs in. **Next** turns the page like a split-flap
  board: the cards flip over one after another to new features, the headline
  and body lines roll up, the camera pans across the scene, and the dots stretch
  like taffy. On the last page the button label rolls to "Get Started". Swipe
  left or right to change pages too.
- **Onboarding → home.** The button blooms to fill the screen, then collapses
  into the nav bar's **+** button, which spins into place.
- **Home.** A ring sweeps around the avatar. The greeting rises out of a clip,
  the sun spins and glows, and the bell swings and pings. The goal card tips up
  in 3D while the ring springs to 68%, the percentage counts up and the steps
  roll on odometer wheels. Tap the card to replay it. Category tiles spring up
  and wobble like jelly when pressed. The route card opens its photo like a
  curtain and has scroll parallax. **+** opens a radial quick-action menu under
  a circular veil. The actions fan out above the bar, and the **+** turns into
  an ×.
- **Home → route.** The card's photo morphs into the full-bleed map. The home
  screen recedes, and the sheet springs up from below.
- **Route.** The start pin pops, the "Start" tag unrolls, and the route draws
  itself around both sides of the lake. Its waypoint dots spring in behind the
  drawing head. The finish pin drops and ripples. The stat cards flip up, the
  numbers count, the clock spins into place and the flame flickers. Pinch and drag
  to zoom and pan the map. The target button eases back and pulses the start
  point. The bookmark bursts when saved. **Start Journey** morphs its play icon
  into pause with a spin, fills the button as progress, and sends a runner around the loop
  while the camera follows. The label rolls between Start, Pause, Resume and
  Journey Complete.

The back button, Android back gesture and **Skip** always give a visible way
out.

## Running

```bash
flutter pub get
flutter run
```

`flutter test` renders every screen, the transitions and the full flow from
splash to route natively. It also pumps every screen at 360x640, 360x740 and
412x915, plus a 393x873 phone with a 48 pt bottom inset (Android 3-button
navigation), and asserts that nothing throws. Pass `--dart-define=SNAP_DIR=<dir>` to
write the frames out as PNGs.
